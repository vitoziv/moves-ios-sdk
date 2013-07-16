//
//  MovesAPI.m
//  Move-iOS-SDK
//
//  Created by Vito on 13-7-11.
//  Copyright (c) 2013 vito. All rights reserved.
//

#include <ifaddrs.h>
#include <arpa/inet.h>
#include <pthread.h>
#import "mongoose.h"
#import "AFNetworking.h"
#import "MovesAPI.h"
#import "MovesAPI+Private.h"

static void (^authorizationSuccessCallback)(void);
static void (^authorizationFailureCallback)(NSError *reason);

static const char* LISTEN_PORT = "8080";
static int content_length;

static int request_handler(struct mg_connection *connection) {
    @autoreleasepool {
        const struct mg_request_info *info = mg_get_request_info(connection);
        
        __block const char *response = NULL;
        __block pthread_cond_t request_cond = PTHREAD_COND_INITIALIZER;
        pthread_mutex_t request_mutex = PTHREAD_MUTEX_INITIALIZER;
        
        NSString *uri = [NSString stringWithFormat:@"%@", [NSString stringWithUTF8String:info->uri]];
        if (info->query_string) {
            uri = [uri stringByAppendingFormat:@"?%@", [NSString stringWithUTF8String:info->query_string]];
        }
        
        [[MovesAPI sharedInstance] getPath:uri parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            response = [operation.responseString cStringUsingEncoding:operation.responseStringEncoding];
            content_length = [operation.responseString  lengthOfBytesUsingEncoding:operation.responseStringEncoding];
            
            pthread_cond_signal(&request_cond);
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            response = [[error description] cStringUsingEncoding:NSUTF8StringEncoding];
            content_length = [[error description] lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
            
            pthread_cond_signal(&request_cond);
        }];
        
        pthread_mutex_lock(&request_mutex);
        pthread_cond_wait(&request_cond, &request_mutex);
        
        pthread_mutex_destroy(&request_mutex);
        pthread_cond_destroy(&request_cond);
        
        // Send HTTP reply to the client
        mg_printf(connection,
                  "HTTP/1.1 200 OK\r\n"
                  "Content-Type: application/json\r\n"
                  "Content-Length: %d\r\n"        // Always set Content-Length
                  "\r\n",
                  content_length);
        
        mg_write(connection, response, content_length);
        return 1;
    }
}


@interface MovesAPI() {
    struct mg_context *context;
}


@end

@implementation MovesAPI
+ (MovesAPI*)sharedInstance {
    static MovesAPI *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[MovesAPI alloc] init];
    });
    
    return _sharedClient;
}

- (id) init
{
    if(self = [super initWithBaseURL:[NSURL URLWithString:@"https://api.moves-app.com/"]]) {
        [self registerHTTPOperationClass:[AFJSONRequestOperation class]];
        [self setParameterEncoding:AFJSONParameterEncoding];
        
        // Accept HTTP Header; see http://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html#sec14.1
        [self setDefaultHeader:@"Accept" value:@"application/json"];
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        self.accessToken = [defaults objectForKey:@"AccessToken"];
        self.fetchTime = (NSDate*) [defaults objectForKey:@"FetchTime"];
        self.expiry = (NSNumber*) [defaults objectForKey:@"Expires"];
    }
    return self;
}

#pragma mark - Setup
- (void)setShareMovesOauthClientId:(NSString *)oauthClientId oauthClientSecret:(NSString *)oauthClientSecret callbackUrlScheme:(NSString *)callbackUrlScheme {
    [MovesAPI sharedInstance].oauthClientId = oauthClientId;
    [MovesAPI sharedInstance].oauthClientSecret = oauthClientSecret;
    [MovesAPI sharedInstance].callbackUrlScheme = callbackUrlScheme;
}

- (void)authorizationCompletedCallback:(NSURL*)responseUrl
{
    NSArray *keysAndObjs = [[responseUrl.query stringByReplacingOccurrencesOfString:@"=" withString:@"&"] componentsSeparatedByString:@"&"];
    
    for(int i=0;i<keysAndObjs.count;i+=2) {
        NSString *key = keysAndObjs[i];
        NSString *value = keysAndObjs[i+1];
        
        if([key isEqualToString:@"code"]) {
            [self requestOrRefreshAccessToken:value complete:^{
                if (authorizationSuccessCallback) {
                    [self executeAuthorizationSuccessCallbackWithSuccess:authorizationSuccessCallback];
                    authorizationSuccessCallback = nil;
                    authorizationFailureCallback = nil;
                }
            } failure:^(NSError *reason) {
                if (authorizationFailureCallback) {
                    authorizationFailureCallback(reason);
                    authorizationFailureCallback = nil;
                    authorizationSuccessCallback = nil;
                }
            }];
            break;
        } else if([key isEqualToString:@"error"]) {
            if (authorizationFailureCallback) {
                authorizationFailureCallback([NSError errorWithDomain:@"moves-ios-sdk" code:0 userInfo:@{@"description": value}]);
                authorizationSuccessCallback = nil;
                authorizationFailureCallback = nil;
            }
        }
    }
}

#pragma mark - General methods appending authorization key to requests

- (void)getPath:(NSString *)path parameters:(NSDictionary *)parameters success:(void (^)(AFHTTPRequestOperation *, id))success failure:(void (^)(AFHTTPRequestOperation *, NSError *))failure
{
    NSRange range = [path rangeOfString:@"?" options:NSCaseInsensitiveSearch];
    if (range.location != NSNotFound) {
        path = [path stringByAppendingFormat:@"&access_token=%@", self.accessToken];
    } else {
        path = [path stringByAppendingFormat:@"?access_token=%@", self.accessToken];
    }
    
    [super getPath:path parameters:parameters
           success:success failure:failure];
}

#pragma mark - OAuth2 authentication with Moves app

- (void)executeAuthorizationSuccessCallbackWithSuccess:(void (^)(void))success {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),^{
        [self initServer];
        if (success) {
            dispatch_async(dispatch_get_main_queue(), ^{
                success();
            });
        }
    });
}

- (void)authorizationSuccess:(void (^)(void))success failure:(void (^)(NSError *reason))failure
{
    if(self.isAuthenticated) {
        [self executeAuthorizationSuccessCallbackWithSuccess:success];
    } else {
        authorizationSuccessCallback = success;
        authorizationFailureCallback = failure;
        
        NSURL *authUrl = [NSURL URLWithString:[NSString stringWithFormat:@"moves://app/authorize?client_id=%@&redirect_uri=%@&scope=activity%%20location", self.oauthClientId, self.oauthRedirectUri]];
        [[UIApplication sharedApplication] openURL:authUrl];
    }
}

- (void)updateUserDefaultsWithAccessToken:(NSString*)accessToken refreshToken:(NSString*)refreshToken andExpiry:(NSNumber*)expiry {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    [defaults setObject:accessToken forKey:@"AccessToken"];
    [defaults setObject:refreshToken forKey:@"RefreshToken"];
    [defaults setObject:expiry forKey:@"Expires"];
    [defaults setObject:[NSDate date] forKey:@"FetchTime"];
    
    [defaults synchronize];
    
    self.accessToken = accessToken;
    self.refreshToken = refreshToken;
    self.expiry = expiry;
}

- (void)requestOrRefreshAccessToken:(NSString*)code complete:(void (^)())complete failure:(void (^)(NSError* reason))failure
{
    NSString *path = [NSString stringWithFormat:@"/oauth/v1/access_token?grant_type=authorization_code&code=%@&client_id=%@&client_secret=%@&redirect_uri=%@", code, self.oauthClientId, self.oauthClientSecret, self.oauthRedirectUri];
    
    if(self.accessToken) {
        path = [NSString stringWithFormat:@"/oauth/v1/access_token?grant_type=refresh_token&refresh_token=%@&client_id=%@&client_secret=%@",
                self.refreshToken, self.oauthClientId, self.oauthClientSecret];
   
    }
    
    [self postPath:path parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [self updateUserDefaultsWithAccessToken:responseObject[@"access_token"]
                                   refreshToken:responseObject[@"refresh_token"]
                                      andExpiry:responseObject[@"expires_in"]];
        if (complete) complete();
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error.userInfo);
        if (failure) failure(error);
    }];
}

- (BOOL)isAuthenticated
{
    if(self.accessToken) {
        NSLog(@"Have a valid access token: %@", self.accessToken);
        return [[NSDate date] compare:[self.fetchTime dateByAddingTimeInterval:[self.expiry doubleValue]]] == NSOrderedAscending;
    }
    return NO;
}

- (void)logout {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:@"AccessToken"];
    [defaults removeObjectForKey:@"RefreshToken"];
    [defaults removeObjectForKey:@"Expires"];
    [defaults removeObjectForKey:@"FetchTime"];
    
    self.accessToken = nil;
    self.expiry = nil;
    self.refreshToken = nil;
    self.fetchTime = nil;
}

#pragma mark - Server

- (void)initServer {
    NSLog(@"Initializing server");
    const char *options[] = {"listening_ports", LISTEN_PORT, NULL};
    struct mg_callbacks callbacks = {0};
    memset(&callbacks, 0, sizeof(callbacks));
    
    callbacks.begin_request = request_handler;
    context = mg_start(&callbacks, (__bridge void *)(self), options);
}

#pragma mark - Helper
- (NSString *)oauthRedirectUri {
    return [NSString stringWithFormat:@"%@://authorization-completed", self.callbackUrlScheme];
}

- (NSString *)getIPAddressAndListenPort
{
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    NSString *wifiAddress = nil;
    NSString *cellAddress = nil;
    
    // retrieve the current interfaces - returns 0 on success
    if(!getifaddrs(&interfaces)) {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while(temp_addr != NULL) {
            sa_family_t sa_type = temp_addr->ifa_addr->sa_family;
            if(sa_type == AF_INET || sa_type == AF_INET6) {
                NSString *name = [NSString stringWithUTF8String:temp_addr->ifa_name];
                NSString *addr = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)]; // pdp_ip0
                NSLog(@"NAME: \"%@\" addr: %@", name, addr); // see for yourself
                
                if([name isEqualToString:@"en0"]) {
                    // Interface is the wifi connection on the iPhone
                    wifiAddress = addr;
                } else
                    if([name isEqualToString:@"pdp_ip0"]) {
                        // Interface is the cell connection on the iPhone
                        cellAddress = addr;
                    }
            }
            temp_addr = temp_addr->ifa_next;
        }
        // Free memory
        freeifaddrs(interfaces);
    }
    NSString *addr = wifiAddress ? wifiAddress : cellAddress;
    addr = addr ? addr : @"0.0.0.0";
    return [NSString stringWithFormat:@"http://%@:%s", addr, LISTEN_PORT];
}

- (NSString *)stringDate:(NSDate *)date ByFormatType:(MVDateFormatType)formatType {
    NSString *format = nil;
    if (formatType == MVDateFormatTypeDay) {
        format = @"yyyyMMdd";
    } else if(formatType == MVDateFormatTypeWeek) {
        format = @"yyyy-'W'ww";
    } else {
        format = @"yyyyMM";
    }
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:format];
    return [dateFormatter stringFromDate:date];
}

- (NSString *)encodingUrlString:(NSString *)url {
    return [url stringByAddingPercentEscapesUsingEncoding:
            NSUTF8StringEncoding];
}

- (NSString *)urlByMVUrl:(NSString *)MVUrl date:(NSDate *)date dateFormatType:(MVDateFormatType)dateFormatType {
    NSString *url = @"";
    if (!date) {
        url = [NSString stringWithFormat:@"%@%@", [self getIPAddressAndListenPort], MVUrl];
    } else {
        url = [NSString stringWithFormat:@"%@%@/%@", [self getIPAddressAndListenPort], MVUrl, [self stringDate:date ByFormatType:dateFormatType]];
    }
    return url;
}

- (NSString *)urlByMVUrl:(NSString *)MVUrl fromDate:(NSDate *)fromDate toDate:(NSDate *)toDate {
    NSString *url = [NSString stringWithFormat:@"%@%@?from=%@&to=%@",
                     [self getIPAddressAndListenPort],
                     MVUrl,
                     [self stringDate:fromDate ByFormatType:MVDateFormatTypeDay],
                     [self stringDate:toDate ByFormatType:MVDateFormatTypeDay]];
    return url;
}

- (NSString *)urlByMVUrl:(NSString *)MVUrl pastDays:(NSInteger)days {
    NSString *url = [NSString stringWithFormat:@"%@%@?pastDays=%i", [self getIPAddressAndListenPort], MVUrl, days];
    return url;//[self encodingUrlString:url];
}

- (NSString *)urlByModelType:(MVModelType)modelType {
    if (modelType == MVModelTypeSummary) {
        return MV_URL_SUMMARY;
    } else if (modelType == MVModelTypeActivity) {
        return MV_URL_ACTIVITY;
    } else if (modelType == MVModelTypePlace){
        return MV_URL_PLACES;
    } else if (modelType == MVModelTypeStoryLine){
        return MV_URL_STORYLINE;
    } else {
        return MV_URL_USER_PROFILE;
    }
}

- (NSArray *)arrayByJson:(id)json modelType:(MVModelType)modelType{
    NSMutableArray *array = [[NSMutableArray alloc] init];
    for (NSDictionary *dic in json) {
        NSObject *obj = nil;
        if (modelType == MVModelTypeSummary) {
            obj = [[MVDailySummary alloc] initWithDictionary:dic];
        } else if (modelType == MVModelTypeActivity) {
            obj = [[MVDailyActivity alloc] initWithDictionary:dic];
        } else if (modelType == MVModelTypePlace){
            obj = [[MVDailyPlace alloc] initWithDictionary:dic];
        } else if (modelType == MVModelTypeStoryLine){
            obj = [[MVStoryLine alloc] initWithDictionary:dic];
        }
        
        if (obj) [array addObject:obj];
    }
    return array;
}

- (void)getJsonByUrl:(NSURL *)url
             success:(void (^)(id json))success
             failure:(void (^)(NSError *error))failure {
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        NSLog(@"request: %@, response: %@", request, response);
        if (success) success(JSON);
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        NSLog(@"error with\nrequest: %@\nresponse: %@error: %@\nJSON: %@",request, response, error, JSON);
        if (failure) failure(error);
    }];
    
    [operation start];
}

#pragma mark - API
#pragma mark User

- (void)getUserSuccess:(void (^)(MVUser *user))success
               failure:(void (^)(NSError *error))failure {
    NSURL *url = [NSURL URLWithString:[self urlByMVUrl:[self urlByModelType:MVModelTypeProfile] date:nil dateFormatType:MVDateFormatTypeDay]];
    [self getJsonByUrl:url
               success:^(id json) {
                   MVUser *user = [[MVUser alloc] initWithDictionary:json];
                   if (success) success(user);
               }
               failure:failure];
}

#pragma mark MVSummary
// TODO: Add trackPoints param
- (void)getDayDailySummariesByDate:(NSDate *)date
                           success:(void (^)(NSArray *dailySummaries))success
                           failure:(void (^)(NSError *error))failure {
    NSURL *url = [NSURL URLWithString:[self urlByMVUrl:[self urlByModelType:MVModelTypeSummary] date:date dateFormatType:MVDateFormatTypeDay]];
    [self getJsonByUrl:url
               success:^(id json) {
                   if (success) success([self arrayByJson:json modelType:MVModelTypeSummary]);
               }
               failure:failure];
}

- (void)getWeekDailySummariesByDate:(NSDate *)date
                            success:(void (^)(NSArray *dailySummaries))success
                            failure:(void (^)(NSError *error))failure {
    NSURL *url = [NSURL URLWithString:[self urlByMVUrl:[self urlByModelType:MVModelTypeSummary] date:date dateFormatType:MVDateFormatTypeWeek]];
    [self getJsonByUrl:url
               success:^(id json) {
                   if (success) success([self arrayByJson:json modelType:MVModelTypeSummary]);
               }
               failure:failure];
}

- (void)getMonthDailySummariesByDate:(NSDate *)date
                             success:(void (^)(NSArray *dailySummaries))success
                             failure:(void (^)(NSError *error))failure {
    NSURL *url = [NSURL URLWithString:[self urlByMVUrl:[self urlByModelType:MVModelTypeSummary] date:date dateFormatType:MVDateFormatTypeMonth]];
    [self getJsonByUrl:url
               success:^(id json) {
                   if (success) success([self arrayByJson:json modelType:MVModelTypeSummary]);
               }
               failure:failure];
}

- (void)getDailySummariesFromDate:(NSDate *)fromDate
                           toDate:(NSDate *)toDate
                          success:(void (^)(NSArray *dailySummaries))success
                          failure:(void (^)(NSError *error))failure {
    NSURL *url = [NSURL URLWithString:[self urlByMVUrl:[self urlByModelType:MVModelTypeSummary] fromDate:fromDate toDate:toDate]];
    [self getJsonByUrl:url
               success:^(id json) {
                   if (success) success([self arrayByJson:json modelType:MVModelTypeSummary]);
               }
               failure:failure];
}

- (void)getDailySummariesByPastDays:(NSInteger)pastDays
                            success:(void (^)(NSArray *dailySummaries))success
                            failure:(void (^)(NSError *error))failure {
    NSURL *url = [NSURL URLWithString:[self urlByMVUrl:[self urlByModelType:MVModelTypeSummary] pastDays:pastDays]];
    [self getJsonByUrl:url
               success:^(id json) {
                   if (success) success([self arrayByJson:json modelType:MVModelTypeSummary]);
               }
               failure:failure];
}

#pragma mark MVActivity
- (void)getDayDailyActivitiesByDate:(NSDate *)date
                            success:(void (^)(NSArray *dailyActivities))success
                            failure:(void (^)(NSError *error))failure {
    NSURL *url = [NSURL URLWithString:[self urlByMVUrl:[self urlByModelType:MVModelTypeActivity] date:date dateFormatType:MVDateFormatTypeDay]];
    [self getJsonByUrl:url
               success:^(id json) {
                   if (success) success([self arrayByJson:json modelType:MVModelTypeActivity]);
               }
               failure:failure];
}

- (void)getWeekDailyActivitiesByDate:(NSDate *)date
                             success:(void (^)(NSArray *dailyActivities))success
                             failure:(void (^)(NSError *error))failure {
    NSURL *url = [NSURL URLWithString:[self urlByMVUrl:[self urlByModelType:MVModelTypeActivity] date:date dateFormatType:MVDateFormatTypeWeek]];
    [self getJsonByUrl:url
               success:^(id json) {
                   if (success) success([self arrayByJson:json modelType:MVModelTypeActivity]);
               }
               failure:failure];
}

#pragma mark MVPlace
- (void)getDayDailyPlacesByDate:(NSDate *)date
                        success:(void (^)(NSArray *dailyPlaces))success
                        failure:(void (^)(NSError *error))failure {
    NSURL *url = [NSURL URLWithString:[self urlByMVUrl:[self urlByModelType:MVModelTypePlace] date:date dateFormatType:MVDateFormatTypeDay]];
    [self getJsonByUrl:url
               success:^(id json) {
                   if (success) success([self arrayByJson:json modelType:MVModelTypePlace]);
               } failure:failure];
}

- (void)getWeekDailyPlacesByDate:(NSDate *)date
                         success:(void (^)(NSArray *dailyPlaces))success
                         failure:(void (^)(NSError *error))failure {
    NSURL *url = [NSURL URLWithString:[self urlByMVUrl:[self urlByModelType:MVModelTypePlace] date:date dateFormatType:MVDateFormatTypeWeek]];
    [self getJsonByUrl:url
               success:^(id json) {
                   if (success) success([self arrayByJson:json modelType:MVModelTypePlace]);
               }
               failure:failure];
}

#pragma mark - MVStoryLine
- (void)getDayStoryLineByDate:(NSDate *)date
                  trackPoints:(BOOL)trackPoints
                      success:(void (^)(NSArray *storyLines))success
                      failure:(void (^)(NSError *error))failure {
    NSString *urlString = [self urlByMVUrl:[self urlByModelType:MVModelTypeStoryLine] date:date dateFormatType:MVDateFormatTypeDay];
    if (trackPoints) {
        urlString = [urlString stringByAppendingFormat:@"%@", @"?trackPoints=true"];
    }
    NSURL *url = [NSURL URLWithString:urlString];
    [self getJsonByUrl:url
               success:^(id json) {
                   if (success) success([self arrayByJson:json modelType:MVModelTypeStoryLine]);
               }
               failure:failure];
}

- (void)getWeekStoryLineByDate:(NSDate *)date
                       success:(void (^)(NSArray *storyLines))success
                       failure:(void (^)(NSError *error))failure {
    NSString *urlString = [self urlByMVUrl:[self urlByModelType:MVModelTypeStoryLine] date:date dateFormatType:MVDateFormatTypeWeek];
    NSURL *url = [NSURL URLWithString:urlString];
    [self getJsonByUrl:url
               success:^(id json) {
                   if (success) success([self arrayByJson:json modelType:MVModelTypeStoryLine]);
               }
               failure:failure];
}

@end
