//
//  MovesAPI.m
//  Move-iOS-SDK
//
//  Created by Vito on 13-7-11.
//  Copyright (c) 2013 vito. All rights reserved.
//

#import "AFNetworking.h"
#import "MovesAPI.h"

#define BASE_DOMAIN @"https://api.moves-app.com"

#define MV_URL_USER_PROFILE @"/api/v1/user/profile"
#define MV_URL_SUMMARY @"/api/v1/user/summary/daily"
#define MV_URL_ACTIVITY @"/api/v1/user/activities/daily"
#define MV_URL_PLACES @"/api/v1/user/places/daily"
#define MV_URL_STORYLINE @"/api/v1/user/storyline/daily"

#define MV_AUTH_ACCESS_TOKEN @"MV_AUTH_ACCESS_TOKEN"
#define MV_AUTH_REFRESH_TOKEN @"MV_AUTH_REFRESH_TOKEN"
#define MV_AUTH_FETCH_TIME @"MV_AUTH_FETCH_TIME"
#define MV_AUTH_EXPIRY @"MV_AUTH_EXPIRY"

typedef NS_ENUM(NSInteger, MVModelType) {
    MVModelTypeProfile = 0,
    MVModelTypeSummary,
    MVModelTypeActivity,
    MVModelTypePlace,
    MVModelTypeStoryLine
};

typedef NS_ENUM(NSInteger, MVDateFormatType) {
    MVDateFormatTypeDay = 0,
    MVDateFormatTypeWeek,
    MVDateFormatTypeMonth
};

@interface MovesAPI()

@property (strong, nonatomic) NSString *accessToken;
@property (strong, nonatomic) NSString *refreshToken;
@property (strong, nonatomic) NSDate *fetchTime;
@property (strong, nonatomic) NSNumber *expiry;
@property (nonatomic, strong) NSString *oauthClientId;
@property (nonatomic, strong) NSString *oauthClientSecret;
@property (nonatomic, strong) NSString *callbackUrlScheme;

@property (nonatomic) BOOL serverStarted;

@property (nonatomic, copy) void (^authorizationSuccessCallback)(void);
@property (nonatomic, copy) void (^authorizationFailureCallback)(NSError *reason);

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
    if(self = [super init]) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        self.accessToken = [defaults objectForKey:MV_AUTH_ACCESS_TOKEN];
        self.refreshToken = [defaults objectForKey:MV_AUTH_REFRESH_TOKEN];
        self.fetchTime = (NSDate*) [defaults objectForKey:MV_AUTH_FETCH_TIME];
        self.expiry = (NSNumber*) [defaults objectForKey:MV_AUTH_EXPIRY];
    }
    return self;
}

#pragma mark - Setup
- (void)setShareMovesOauthClientId:(NSString *)oauthClientId oauthClientSecret:(NSString *)oauthClientSecret callbackUrlScheme:(NSString *)callbackUrlScheme {
    [MovesAPI sharedInstance].oauthClientId = oauthClientId;
    [MovesAPI sharedInstance].oauthClientSecret = oauthClientSecret;
    [MovesAPI sharedInstance].callbackUrlScheme = callbackUrlScheme;
}

- (BOOL)canHandleOpenUrl:(NSURL*)url
{
    BOOL canHandle = NO;
    NSArray *keysAndObjs = [[url.query stringByReplacingOccurrencesOfString:@"=" withString:@"&"] componentsSeparatedByString:@"&"];
    
    for(NSUInteger i=0, len=keysAndObjs.count; i<len; i+=2) {
        NSString *key = keysAndObjs[i];
        NSString *value = keysAndObjs[i+1];
        
        if([key isEqualToString:@"code"]) {
            [self requestOrRefreshAccessToken:value complete:^{
                if (self.authorizationSuccessCallback) {
                    if (self.authorizationSuccessCallback) self.authorizationSuccessCallback();
                    self.authorizationSuccessCallback = nil;
                    self.authorizationFailureCallback = nil;
                }
            } failure:^(NSError *reason) {
                if (self.authorizationFailureCallback) {
                    self.authorizationFailureCallback(reason);
                    self.authorizationFailureCallback = nil;
                    self.authorizationSuccessCallback = nil;
                }
            }];
            canHandle = YES;
            break;
        } else if([key isEqualToString:@"error"]) {
            if (self.authorizationFailureCallback) {
                self.authorizationFailureCallback([NSError errorWithDomain:@"moves-ios-sdk" code:0 userInfo:@{@"description": value}]);
                self.authorizationSuccessCallback = nil;
                self.authorizationFailureCallback = nil;
            }
            canHandle = NO;
            break;
        }
    }
    
    return canHandle;
}

#pragma mark - OAuth2 authentication with Moves app

- (void)authorizationSuccess:(void (^)(void))success failure:(void (^)(NSError *reason))failure
{
    if(self.isAuthenticated) {
        if (success) success();
    } else {
        self.authorizationSuccessCallback = success;
        self.authorizationFailureCallback = failure;
        NSURL *authUrl = [NSURL URLWithString:[NSString stringWithFormat:@"moves://app/authorize?client_id=%@&redirect_uri=%@&scope=activity%%20location", self.oauthClientId, self.oauthRedirectUri]];
        [[UIApplication sharedApplication] openURL:authUrl];
    }
}

- (void)updateUserDefaultsWithAccessToken:(NSString*)accessToken refreshToken:(NSString*)refreshToken andExpiry:(NSNumber*)expiry {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    [defaults setObject:accessToken forKey:MV_AUTH_ACCESS_TOKEN];
    [defaults setObject:refreshToken forKey:MV_AUTH_REFRESH_TOKEN];
    [defaults setObject:expiry forKey:MV_AUTH_EXPIRY];
    NSDate *fetchTime = [NSDate date];
    [defaults setObject:fetchTime forKey:MV_AUTH_FETCH_TIME];
    
    [defaults synchronize];
    
    self.accessToken = accessToken;
    self.refreshToken = refreshToken;
    self.expiry = expiry;
    self.fetchTime = fetchTime;
}

- (void)requestOrRefreshAccessToken:(NSString*)code complete:(void (^)())complete failure:(void (^)(NSError* reason))failure
{
    NSDictionary *params;
    NSString *path = @"/oauth/v1/access_token";
    
    if(self.accessToken) {
        params = @{@"grant_type":@"refresh_token",
                   @"refresh_token":self.refreshToken,
                   @"client_id":self.oauthClientId,
                   @"client_secret":self.oauthClientSecret};
    } else {
        params = @{@"grant_type":@"authorization_code",
                   @"code":code,
                   @"client_id":self.oauthClientId,
                   @"client_secret":self.oauthClientSecret,
                   @"redirect_uri":[self oauthRedirectUri]};
    }
    
    AFHTTPClient *client = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:BASE_DOMAIN]];
    [client postPath:path parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *responseDic = [NSJSONSerialization JSONObjectWithData:responseObject
                                                                    options:NSJSONReadingMutableLeaves
                                                                      error:nil];
        
        [self updateUserDefaultsWithAccessToken:responseDic[@"access_token"]
                                   refreshToken:responseDic[@"refresh_token"]
                                      andExpiry:responseDic[@"expires_in"]];
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
        return ![self isAccessTokenExpiry];
    }
    return NO;
}

- (void)logout {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:MV_AUTH_ACCESS_TOKEN];
    [defaults removeObjectForKey:MV_AUTH_REFRESH_TOKEN];
    [defaults removeObjectForKey:MV_AUTH_EXPIRY];
    [defaults removeObjectForKey:MV_AUTH_FETCH_TIME];
    
    self.accessToken = nil;
    self.expiry = nil;
    self.refreshToken = nil;
    self.fetchTime = nil;
}

#pragma mark - Helper

- (BOOL)isAccessTokenExpiry {
    // Expiry time
    if ([[NSDate date] timeIntervalSinceDate:[self.fetchTime dateByAddingTimeInterval:[self.expiry doubleValue]]] <= 0) {
        return NO;
    }
    return YES;
}

- (NSString *)oauthRedirectUri {
    return [NSString stringWithFormat:@"%@://authorization-completed", self.callbackUrlScheme];
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
        url = [NSString stringWithFormat:@"%@%@", BASE_DOMAIN, MVUrl];
    } else {
        url = [NSString stringWithFormat:@"%@%@/%@", BASE_DOMAIN, MVUrl, [self stringDate:date ByFormatType:dateFormatType]];
    }
    
    return url;
}

- (NSString *)urlByMVUrl:(NSString *)MVUrl fromDate:(NSDate *)fromDate toDate:(NSDate *)toDate {
    NSString *url = [NSString stringWithFormat:@"%@%@?from=%@&to=%@",
                     BASE_DOMAIN,
                     MVUrl,
                     [self stringDate:fromDate ByFormatType:MVDateFormatTypeDay],
                     [self stringDate:toDate ByFormatType:MVDateFormatTypeDay]];
    return url;
}

- (NSString *)urlByMVUrl:(NSString *)MVUrl pastDays:(NSInteger)days {
    NSString *url = [NSString stringWithFormat:@"%@%@?pastDays=%i", BASE_DOMAIN, MVUrl, days];
    return url;
}

- (NSString *)urlByModelType:(MVModelType)modelType {
    switch (modelType) {
        case MVModelTypeSummary:
            return MV_URL_SUMMARY;
            break;
        case MVModelTypeActivity:
            return MV_URL_ACTIVITY;
            break;
        case MVModelTypePlace:
            return MV_URL_PLACES;
            break;
        case MVModelTypeStoryLine:
            return MV_URL_STORYLINE;
            break;
        case MVModelTypeProfile:
            return MV_URL_USER_PROFILE;
            break;
        default:
            return @"";
            break;
    }
}

- (NSArray *)arrayByJson:(id)json modelType:(MVModelType)modelType{
    NSMutableArray *array = [[NSMutableArray alloc] init];
    for (NSDictionary *dic in json) {
        NSObject *obj = nil;
        
        switch (modelType) {
            case MVModelTypeSummary:
                obj = [[MVDailySummary alloc] initWithDictionary:dic];
                break;
            case MVModelTypeActivity:
                obj = [[MVDailyActivity alloc] initWithDictionary:dic];
                break;
            case MVModelTypePlace:
                obj = [[MVDailyPlace alloc] initWithDictionary:dic];
                break;
            case MVModelTypeStoryLine:
                obj = [[MVStoryLine alloc] initWithDictionary:dic];
                break;
            default:
                break;
        }
        
        if (obj) [array addObject:obj];
    }
    return array;
}

  // Auto init by UrlScheme
//- (BOOL)verifyCFBundleURLSchemes {
//    NSArray *urlTypes = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleURLTypes"];
//    NSString* callbackScheme = [NSString stringWithFormat:@"mv-%@",self.oauthClientId];
//    
//    for (NSDictionary *dict in urlTypes) {
//        NSArray *urlSchemes = [dict objectForKey:@"CFBundleURLSchemes"];
//        for (NSString *urlScheme in urlSchemes) {
//            if ([callbackScheme isEqualToString:urlScheme]) {
//                return YES;
//            }
//        }
//    }
//    return NO;
//}

#pragma mark - API

- (void)getJsonByUrl:(NSString *)url
             success:(void (^)(id json))success
             failure:(void (^)(NSError *error))failure {
    // Step 1.
    if (!self.accessToken) {
        NSError *authError = [NSError errorWithDomain:@"MovesAPI Auth Error" code:1001 userInfo:@{@"ErrorReason": @"no_access_token"}];
        failure(authError);
    } else {
        // Step 2. If accessToken is out of date, try to get a new one
        if ([self isAccessTokenExpiry]) {
            [self requestOrRefreshAccessToken:self.accessToken
                                     complete:^{
                                         [self getJsonByUrl:url success:success failure:failure];
                                     }
                                      failure:failure];
        } else {
            // Step 3. Everthing is right, now try to getting data
            NSLog(@"%@", url);
            
            NSRange range = [url rangeOfString:@"?" options:NSCaseInsensitiveSearch];
            if (range.location != NSNotFound) {
                url = [url stringByAppendingFormat:@"&access_token=%@", self.accessToken];
            } else {
                url = [url stringByAppendingFormat:@"?access_token=%@", self.accessToken];
            }
            
            NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]
                                                     cachePolicy:NSURLRequestReloadRevalidatingCacheData
                                                 timeoutInterval:25];
            AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                if (success) success(JSON);
            } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                if (failure) {
                    // Cause your app was revoked in Moves app.
                    if ([error.userInfo[@"NSLocalizedRecoverySuggestion"] isEqualToString:@"expired_access_token"]) {
                        NSLog(@"expired_access_token");
                        
                        NSError *expiredError = [NSError errorWithDomain:@"MovesAPI Error" code:401 userInfo:@{@"ErrorReason": @"expired_access_token"}];
                        failure(expiredError);
                    } else {
                        failure(error);
                    }
                }
            }];
            
            [operation start];
        }
    }
    
}

#pragma mark User

- (void)getUserSuccess:(void (^)(MVUser *user))success
               failure:(void (^)(NSError *error))failure {
    NSString *url = [self urlByMVUrl:[self urlByModelType:MVModelTypeProfile] date:nil dateFormatType:MVDateFormatTypeDay];
    [self getJsonByUrl:url
               success:^(id json) {
                   MVUser *user = [[MVUser alloc] initWithDictionary:json];
                   if (success) success(user);
               }
               failure:failure];
}

#pragma mark MVSummary

- (void)getDayDailySummariesByDate:(NSDate *)date
                           success:(void (^)(NSArray *dailySummaries))success
                           failure:(void (^)(NSError *error))failure {
    NSString *url = [self urlByMVUrl:[self urlByModelType:MVModelTypeSummary] date:date dateFormatType:MVDateFormatTypeDay];
    [self getJsonByUrl:url
               success:^(id json) {
                   if (success) success([self arrayByJson:json modelType:MVModelTypeSummary]);
               }
               failure:failure];
}

- (void)getWeekDailySummariesByDate:(NSDate *)date
                            success:(void (^)(NSArray *dailySummaries))success
                            failure:(void (^)(NSError *error))failure {
    NSString *url = [self urlByMVUrl:[self urlByModelType:MVModelTypeSummary] date:date dateFormatType:MVDateFormatTypeWeek];
    [self getJsonByUrl:url
               success:^(id json) {
                   if (success) success([self arrayByJson:json modelType:MVModelTypeSummary]);
               }
               failure:failure];
}

- (void)getMonthDailySummariesByDate:(NSDate *)date
                             success:(void (^)(NSArray *dailySummaries))success
                             failure:(void (^)(NSError *error))failure {
    NSString *url = [self urlByMVUrl:[self urlByModelType:MVModelTypeSummary] date:date dateFormatType:MVDateFormatTypeMonth];
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
    NSString *url = [self urlByMVUrl:[self urlByModelType:MVModelTypeSummary] fromDate:fromDate toDate:toDate];
    [self getJsonByUrl:url
               success:^(id json) {
                   if (success) success([self arrayByJson:json modelType:MVModelTypeSummary]);
               }
               failure:failure];
}

- (void)getDailySummariesByPastDays:(NSInteger)pastDays
                            success:(void (^)(NSArray *dailySummaries))success
                            failure:(void (^)(NSError *error))failure {
    NSString *url = [self urlByMVUrl:[self urlByModelType:MVModelTypeSummary] pastDays:pastDays];
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
    NSString *url = [self urlByMVUrl:[self urlByModelType:MVModelTypeActivity] date:date dateFormatType:MVDateFormatTypeDay];
    [self getJsonByUrl:url
               success:^(id json) {
                   if (success) success([self arrayByJson:json modelType:MVModelTypeActivity]);
               }
               failure:failure];
}

- (void)getWeekDailyActivitiesByDate:(NSDate *)date
                             success:(void (^)(NSArray *dailyActivities))success
                             failure:(void (^)(NSError *error))failure {
    NSString *url = [self urlByMVUrl:[self urlByModelType:MVModelTypeActivity] date:date dateFormatType:MVDateFormatTypeWeek];
    [self getJsonByUrl:url
               success:^(id json) {
                   if (success) success([self arrayByJson:json modelType:MVModelTypeActivity]);
               }
               failure:failure];
}

- (void)getDailyActivitiesFromDate:(NSDate *)fromDate
                            toDate:(NSDate *)toDate
                           success:(void (^)(NSArray *dailyActivities))success
                           failure:(void (^)(NSError *error))failure {
    NSString *url = [self urlByMVUrl:[self urlByModelType:MVModelTypeActivity] fromDate:fromDate toDate:toDate];
    [self getJsonByUrl:url
               success:^(id json) {
                   if (success) success([self arrayByJson:json modelType:MVModelTypeActivity]);
               }
               failure:failure];
}

- (void)getDailyActivitiesByPastDays:(NSInteger)pastDays
                             success:(void (^)(NSArray *dailyActivities))success
                             failure:(void (^)(NSError *error))failure {
    NSString *url = [self urlByMVUrl:[self urlByModelType:MVModelTypeActivity] pastDays:pastDays];
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
    NSString *url = [self urlByMVUrl:[self urlByModelType:MVModelTypePlace] date:date dateFormatType:MVDateFormatTypeDay];
    [self getJsonByUrl:url
               success:^(id json) {
                   if (success) success([self arrayByJson:json modelType:MVModelTypePlace]);
               } failure:failure];
}

- (void)getWeekDailyPlacesByDate:(NSDate *)date
                         success:(void (^)(NSArray *dailyPlaces))success
                         failure:(void (^)(NSError *error))failure {
    NSString *url = [self urlByMVUrl:[self urlByModelType:MVModelTypePlace] date:date dateFormatType:MVDateFormatTypeWeek];
    [self getJsonByUrl:url
               success:^(id json) {
                   if (success) success([self arrayByJson:json modelType:MVModelTypePlace]);
               }
               failure:failure];
}

- (void)getDailyPlacesFromDate:(NSDate *)fromDate
                        toDate:(NSDate *)toDate
                       success:(void (^)(NSArray *dailyPlaces))success
                       failure:(void (^)(NSError *error))failure {
    NSString *url = [self urlByMVUrl:[self urlByModelType:MVModelTypePlace] fromDate:fromDate toDate:toDate];
    [self getJsonByUrl:url
               success:^(id json) {
                   if (success) success([self arrayByJson:json modelType:MVModelTypePlace]);
               }
               failure:failure];
}

- (void)getDailyPlacesByPastDays:(NSInteger)pastDays
                         success:(void (^)(NSArray *dailyPlaces))success
                         failure:(void (^)(NSError *error))failure {
    NSString *url = [self urlByMVUrl:[self urlByModelType:MVModelTypePlace] pastDays:pastDays];
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
    [self getJsonByUrl:urlString
               success:^(id json) {
                   if (success) success([self arrayByJson:json modelType:MVModelTypeStoryLine]);
               }
               failure:failure];
}

- (void)getWeekStoryLineByDate:(NSDate *)date
                       success:(void (^)(NSArray *storyLines))success
                       failure:(void (^)(NSError *error))failure {
    NSString *urlString = [self urlByMVUrl:[self urlByModelType:MVModelTypeStoryLine] date:date dateFormatType:MVDateFormatTypeWeek];
    [self getJsonByUrl:urlString
               success:^(id json) {
                   if (success) success([self arrayByJson:json modelType:MVModelTypeStoryLine]);
               }
               failure:failure];
}

- (void)getDailyStoryLineFromDate:(NSDate *)fromDate
                           toDate:(NSDate *)toDate
                          success:(void (^)(NSArray *storyLines))success
                          failure:(void (^)(NSError *error))failure {
    NSString *url = [self urlByMVUrl:[self urlByModelType:MVModelTypeStoryLine] fromDate:fromDate toDate:toDate];
    [self getJsonByUrl:url
               success:^(id json) {
                   if (success) success([self arrayByJson:json modelType:MVModelTypeStoryLine]);
               }
               failure:failure];
}

- (void)getDailyStoryLineByPastDays:(NSInteger)pastDays
                            success:(void (^)(NSArray *storyLines))success
                            failure:(void (^)(NSError *error))failure {
    NSString *url = [self urlByMVUrl:[self urlByModelType:MVModelTypeStoryLine] pastDays:pastDays];
    [self getJsonByUrl:url
               success:^(id json) {
                   if (success) success([self arrayByJson:json modelType:MVModelTypeStoryLine]);
               }
               failure:failure];
}

@end
