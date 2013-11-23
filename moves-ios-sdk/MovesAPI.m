//
//  MovesAPI.m
//  Move-iOS-SDK
//
//  Created by Vito on 13-7-11.
//  Copyright (c) 2013 vito. All rights reserved.
//

#import "MovesAPI.h"
#import "AFNetworking.h"
#import "MVOAuthViewController.h"
#import "DFDateFormatterFactory.h"

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


#define kDateFormatTypeDay @"yyyyMMdd"
#define kDateFormatTypeWeek @"yyyy-'W'ww"
#define kDateFormatTypeMonth @"yyyyMM"

#define kModelTypeSummary @"MVDailySummary"
#define kModelTypeActivity @"MVDailyActivity"
#define kModelTypePlace @"MVDailyPlace"
#define kModelTypeStoryLine @"MVStoryLine"

@interface MovesAPI() <MVOAuthViewControllerDelegate>

@property (nonatomic, strong) NSString *accessToken;
@property (nonatomic, strong) NSString *refreshToken;
@property (nonatomic, strong) NSDate *fetchTime;
@property (nonatomic, strong) NSNumber *expiry;
@property (nonatomic, strong) NSString *oauthClientId;
@property (nonatomic, strong) NSString *oauthClientSecret;
@property (nonatomic, strong) NSString *callbackUrlScheme;
@property (nonatomic) MVScopeType scope;

@property (nonatomic) BOOL serverStarted;

@property (nonatomic, copy) MVAuthorizationSuccessBlock authorizationSuccessCallback;
@property (nonatomic, copy) MVAuthorizationFailureBlock authorizationFailureCallback;

@property (nonatomic, strong) MVOAuthViewController *oauthViewController;

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

- (id)init {
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
- (void)setShareMovesOauthClientId:(NSString *)oauthClientId
                 oauthClientSecret:(NSString *)oauthClientSecret
                 callbackUrlScheme:(NSString *)callbackUrlScheme
                             scope:(MVScopeType)scope {
    _oauthClientId = oauthClientId;
    _oauthClientSecret = oauthClientSecret;
    _callbackUrlScheme = callbackUrlScheme;
    _scope = scope;
}

- (void)setShareMovesOauthClientId:(NSString *)oauthClientId
                 oauthClientSecret:(NSString *)oauthClientSecret
                 callbackUrlScheme:(NSString *)callbackUrlScheme {
    [self setShareMovesOauthClientId:oauthClientId
                   oauthClientSecret:oauthClientSecret
                   callbackUrlScheme:callbackUrlScheme
                               scope:MVScopeTypeActivity | MVScopeTypeLocation];
}

- (BOOL)canHandleOpenUrl:(NSURL *)url {
    BOOL canHandle = NO;
    
    if ([url.absoluteString hasPrefix:BASE_DOMAIN] || [url.absoluteString hasPrefix:@"MovesSDKDemo://authorization-completed"]) {
        [self handleOpenUrl:url completion:nil];
        canHandle = YES;
    }
    
    return canHandle;
}

- (void)handleOpenUrl:(NSURL *)url completion:(void(^)(BOOL success))completion {
    NSString *value = [self valueForKey:@"code" inUrl:url];
    NSString *errorValue = [self valueForKey:@"error" inUrl:url];
    if (value) {
        [self requestOrRefreshAccessToken:value success:^{
            if (completion) completion(YES);
            
            if (self.authorizationSuccessCallback) {
                if (self.authorizationSuccessCallback) self.authorizationSuccessCallback();
                self.authorizationSuccessCallback = nil;
                self.authorizationFailureCallback = nil;
            }
        } failure:^(NSError *reason) {
            if (completion) completion(NO);
            
            if (self.authorizationFailureCallback) {
                self.authorizationFailureCallback(reason);
                self.authorizationFailureCallback = nil;
                self.authorizationSuccessCallback = nil;
            }
        }];
    } else if(errorValue) {
        if (completion) completion(NO);
        if (self.authorizationFailureCallback) {
            self.authorizationFailureCallback([NSError errorWithDomain:@"moves-ios-sdk" code:0 userInfo:@{@"description": errorValue}]);
            self.authorizationSuccessCallback = nil;
            self.authorizationFailureCallback = nil;
        }
    } else {
        if (completion) completion(NO);
        if (self.authorizationFailureCallback) self.authorizationFailureCallback([NSError errorWithDomain:@"moves-ios-sdk" code:0 userInfo:@{@"description": @"Unknown_error"}]);
        self.authorizationSuccessCallback = nil;
        self.authorizationFailureCallback = nil;
    }
}

#pragma mark - OAuth2 authentication with Moves app

- (void)authorizationWithViewController:(UIViewController *)viewController
                                success:(MVAuthorizationSuccessBlock)success
                                failure:(MVAuthorizationFailureBlock)failure {
    if(self.isAuthenticated) {
        if (success) success();
    } else {
        self.authorizationSuccessCallback = success;
        self.authorizationFailureCallback = failure;
        if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"moves://"]]) {
            NSString *urlString = [NSString stringWithFormat:@"moves://app/authorize?client_id=%@&redirect_uri=%@&scope=%@",
                                   self.oauthClientId,
                                   self.oauthRedirectUri,
                                   [self scopeStringByScopeType:self.scope]];
            urlString = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
        } else {
            NSString *urlString = [NSString stringWithFormat:@"%@/oauth/v1/authorize?response_type=code&client_id=%@&scope=%@", BASE_DOMAIN, self.oauthClientId, [self scopeStringByScopeType:self.scope]];
            urlString = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            
            self.oauthViewController = [[MVOAuthViewController alloc] initWithAuthorizationURL:[NSURL URLWithString:urlString]
                                                                                      delegate:self];
            UINavigationController *oauthNavController = [[UINavigationController alloc] initWithRootViewController:self.oauthViewController];
            
            [viewController presentViewController:oauthNavController
                                         animated:YES
                                       completion:nil];
        }
    }
    
}

- (void)updateUserDefaultsWithAccessToken:(NSString *)accessToken
                             refreshToken:(NSString *)refreshToken
                                andExpiry:(NSNumber *)expiry {
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

- (void)requestOrRefreshAccessToken:(NSString *)code
                            success:(void(^)(void))success
                            failure:(void(^)(NSError *reason))failure
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
        if (success) success();
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

- (void)logout
{
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

- (BOOL)isAccessTokenExpiry
{
    // Expiry time
    if ([[NSDate date] timeIntervalSinceDate:[self.fetchTime dateByAddingTimeInterval:[self.expiry doubleValue]]] <= 0) {
        return NO;
    }
    return YES;
}

- (NSString *)oauthRedirectUri {
    return [NSString stringWithFormat:@"%@://authorization-completed", self.callbackUrlScheme];
}

- (NSString *)stringFromDate:(NSDate *)date byFormat:(NSString *)format {
    NSDateFormatter *dateFormatter = [[DFDateFormatterFactory sharedFactory] dateFormatterWithFormat:format];
    [dateFormatter setDateFormat:format];
    return [dateFormatter stringFromDate:date];
}

- (NSString *)scopeStringByScopeType:(MVScopeType)scopeType {
    NSMutableString *scope = [[NSMutableString alloc] init];
    if (scopeType == MVScopeTypeDefault) {
        [scope appendString:@"default"];
    } else {
        if (scopeType & MVScopeTypeActivity) {
            [scope appendString:@"activity"];
        }
        
        if (scopeType & MVScopeTypeLocation) {
            if (scope.length > 0) [scope appendString:@" "];
            [scope appendString:@"location"];
        }
    }
    
    return scope;
}

- (NSString *)valueForKey:(NSString *)key inUrl:(NSURL *)url {
    NSArray *keysAndObjs = [[url.query stringByReplacingOccurrencesOfString:@"=" withString:@"&"] componentsSeparatedByString:@"&"];
    
    for(NSUInteger i = 0, len = keysAndObjs.count; i < len; i += 2) {
        NSString *aKey = keysAndObjs[i];
        NSString *aValue = keysAndObjs[i+1];
        if ([aKey isEqualToString:key]) {
            return aValue;
        }
    }
    
    return nil;
}

- (BOOL)key:(NSString *)key existingInUrl:(NSURL *)url {
    NSArray *keysAndObjs = [[url.query stringByReplacingOccurrencesOfString:@"=" withString:@"&"] componentsSeparatedByString:@"&"];
    
    for(NSUInteger i = 0, len = keysAndObjs.count; i < len; i += 2) {
        NSString *aKey = keysAndObjs[i];
        if ([aKey isEqualToString:key]) {
            return YES;
        }
    }
    
    return NO;
}

#pragma mark Url Creator

- (NSString *)urlByMVUrl:(NSString *)MVUrl
                    date:(NSDate *)date
              dateFormat:(NSString *)dateFormat {
    NSString *url = @"";
    if (!date) {
        url = [NSString stringWithFormat:@"%@%@", BASE_DOMAIN, MVUrl];
    } else {
        url = [NSString stringWithFormat:@"%@%@/%@", BASE_DOMAIN, MVUrl, [self stringFromDate:date byFormat:dateFormat]];
    }
    
    return url;
}

- (NSString *)urlByMVUrl:(NSString *)MVUrl
                fromDate:(NSDate *)fromDate
                  toDate:(NSDate *)toDate {
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyyMMdd"];
    NSString *fromDateString = [dateFormatter stringFromDate:fromDate];
    
    NSString *toDateString = [dateFormatter stringFromDate:toDate];
    
    NSString *url = [NSString stringWithFormat:@"%@%@?from=%@&to=%@",
                     BASE_DOMAIN,
                     MVUrl,
                     fromDateString,
                     toDateString];
    return url;
}

- (NSString *)urlByMVUrl:(NSString *)MVUrl pastDays:(NSInteger)days {
    NSString *url = [NSString stringWithFormat:@"%@%@?pastDays=%i", BASE_DOMAIN, MVUrl, days];
    return url;
}

#pragma mark Objects

- (NSArray *)arrayByJSON:(id)JSON modelClassName:(NSString *)className {
    NSMutableArray *array = [[NSMutableArray alloc] init];
    for (NSDictionary *dic in JSON) {
        NSObject *obj = [(MVBaseDataModel *)[NSClassFromString(className) alloc] initWithDictionary:dic];
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
        NSError *authError = [NSError errorWithDomain:@"MovesAPI Auth Error" code:401 userInfo:@{@"ErrorReason": @"no_access_token"}];
        failure(authError);
    } else {
        // Step 2. If accessToken is out of date, try to get a new one
        if ([self isAccessTokenExpiry]) {
            [self requestOrRefreshAccessToken:self.accessToken
                                      success:^{
                                          [self getJsonByUrl:url success:success failure:failure];
                                      }
                                      failure:failure];
        } else {
            // Step 3. Everthing is right, now try to getting data
            NSLog(@"Moves demo request url: %@", url);
            
            NSRange range = [url rangeOfString:@"?" options:NSCaseInsensitiveSearch];
            if (range.location != NSNotFound) {
                url = [url stringByAppendingFormat:@"&access_token=%@", self.accessToken];
            } else {
                url = [url stringByAppendingFormat:@"?access_token=%@", self.accessToken];
            }
            
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]
                                                                   cachePolicy:NSURLRequestReloadRevalidatingCacheData
                                                               timeoutInterval:25];
            
            AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                if (success) success(JSON);
            } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                // Cause your app was revoked in Moves app.
                if ([error.userInfo[@"NSLocalizedRecoverySuggestion"] isEqualToString:@"expired_access_token"]) {
                    NSLog(@"expired_access_token");
                    
                    NSError *expiredError = [NSError errorWithDomain:@"MovesAPI Error" code:401 userInfo:@{@"ErrorReason": @"expired_access_token"}];
                    failure(expiredError);
                } else {
                    failure(error);
                }
            }];
            
            [operation start];
        }
    }
    
}

#pragma mark User

- (void)getUserSuccess:(void(^)(MVUser *user))success
               failure:(void(^)(NSError *error))failure {
    NSString *url = [self urlByMVUrl:MV_URL_USER_PROFILE date:nil dateFormat:kDateFormatTypeDay];
    [self getJsonByUrl:url
               success:^(id json) {
                   MVUser *user = [[MVUser alloc] initWithDictionary:json];
                   if (success) success(user);
               }
               failure:failure];
}

#pragma mark MVSummary

- (void)getDayDailySummariesByDate:(NSDate *)date
                           success:(void(^)(NSArray *dailySummaries))success
                           failure:(void(^)(NSError *error))failure {
    NSString *url = [self urlByMVUrl:MV_URL_SUMMARY date:date dateFormat:kDateFormatTypeDay];
    [self getJsonByUrl:url
               success:^(id json) {
                   if (success) success([self arrayByJSON:json modelClassName:kModelTypeSummary]);
               }
               failure:failure];
}

- (void)getWeekDailySummariesByDate:(NSDate *)date
                            success:(void(^)(NSArray *dailySummaries))success
                            failure:(void(^)(NSError *error))failure {
    NSString *url = [self urlByMVUrl:MV_URL_SUMMARY date:date dateFormat:kDateFormatTypeWeek];
    [self getJsonByUrl:url
               success:^(id json) {
                   if (success) success([self arrayByJSON:json modelClassName:kModelTypeSummary]);
               }
               failure:failure];
}

- (void)getMonthDailySummariesByDate:(NSDate *)date
                             success:(void(^)(NSArray *dailySummaries))success
                             failure:(void(^)(NSError *error))failure {
    NSString *url = [self urlByMVUrl:MV_URL_SUMMARY date:date dateFormat:kDateFormatTypeMonth];
    [self getJsonByUrl:url
               success:^(id json) {
                   if (success) success([self arrayByJSON:json modelClassName:kModelTypeSummary]);
               }
               failure:failure];
}

- (void)getDailySummariesFromDate:(NSDate *)fromDate
                           toDate:(NSDate *)toDate
                          success:(void(^)(NSArray *dailySummaries))success
                          failure:(void(^)(NSError *error))failure {
    NSString *url = [self urlByMVUrl:MV_URL_SUMMARY fromDate:fromDate toDate:toDate];
    [self getJsonByUrl:url
               success:^(id json) {
                   if (success) success([self arrayByJSON:json modelClassName:kModelTypeSummary]);
               }
               failure:failure];
}

- (void)getDailySummariesByPastDays:(NSInteger)pastDays
                            success:(void(^)(NSArray *dailySummaries))success
                            failure:(void(^)(NSError *error))failure {
    NSString *url = [self urlByMVUrl:MV_URL_SUMMARY pastDays:pastDays];
    [self getJsonByUrl:url
               success:^(id json) {
                   if (success) success([self arrayByJSON:json modelClassName:kModelTypeSummary]);
               }
               failure:failure];
}

#pragma mark MVActivity
- (void)getDayDailyActivitiesByDate:(NSDate *)date
                            success:(void(^)(NSArray *dailyActivities))success
                            failure:(void(^)(NSError *error))failure {
    NSString *url = [self urlByMVUrl:MV_URL_ACTIVITY date:date dateFormat:kDateFormatTypeDay];
    [self getJsonByUrl:url
               success:^(id json) {
                   if (success) success([self arrayByJSON:json modelClassName:kModelTypeActivity]);
               }
               failure:failure];
}

- (void)getWeekDailyActivitiesByDate:(NSDate *)date
                             success:(void(^)(NSArray *dailyActivities))success
                             failure:(void(^)(NSError *error))failure {
    NSString *url = [self urlByMVUrl:MV_URL_ACTIVITY date:date dateFormat:kDateFormatTypeWeek];
    [self getJsonByUrl:url
               success:^(id json) {
                   if (success) success([self arrayByJSON:json modelClassName:kModelTypeActivity]);
               }
               failure:failure];
}

- (void)getDailyActivitiesFromDate:(NSDate *)fromDate
                            toDate:(NSDate *)toDate
                           success:(void(^)(NSArray *dailyActivities))success
                           failure:(void(^)(NSError *error))failure {
    NSString *url = [self urlByMVUrl:MV_URL_ACTIVITY fromDate:fromDate toDate:toDate];
    [self getJsonByUrl:url
               success:^(id json) {
                   if (success) success([self arrayByJSON:json modelClassName:kModelTypeActivity]);
               }
               failure:failure];
}

- (void)getDailyActivitiesByPastDays:(NSInteger)pastDays
                             success:(void(^)(NSArray *dailyActivities))success
                             failure:(void(^)(NSError *error))failure {
    NSString *url = [self urlByMVUrl:MV_URL_ACTIVITY pastDays:pastDays];
    [self getJsonByUrl:url
               success:^(id json) {
                   if (success) success([self arrayByJSON:json modelClassName:kModelTypeActivity]);
               }
               failure:failure];
}


#pragma mark MVPlace
- (void)getDayDailyPlacesByDate:(NSDate *)date
                        success:(void(^)(NSArray *dailyPlaces))success
                        failure:(void(^)(NSError *error))failure {
    NSString *url = [self urlByMVUrl:MV_URL_PLACES date:date dateFormat:kDateFormatTypeDay];
    [self getJsonByUrl:url
               success:^(id json) {
                   if (success) success([self arrayByJSON:json modelClassName:kModelTypePlace]);
               } failure:failure];
}

- (void)getWeekDailyPlacesByDate:(NSDate *)date
                         success:(void(^)(NSArray *dailyPlaces))success
                         failure:(void(^)(NSError *error))failure {
    NSString *url = [self urlByMVUrl:MV_URL_PLACES date:date dateFormat:kDateFormatTypeWeek];
    [self getJsonByUrl:url
               success:^(id json) {
                   if (success) success([self arrayByJSON:json modelClassName:kModelTypePlace]);
               }
               failure:failure];
}

- (void)getDailyPlacesFromDate:(NSDate *)fromDate
                        toDate:(NSDate *)toDate
                       success:(void(^)(NSArray *dailyPlaces))success
                       failure:(void(^)(NSError *error))failure {
    NSString *url = [self urlByMVUrl:MV_URL_PLACES fromDate:fromDate toDate:toDate];
    [self getJsonByUrl:url
               success:^(id json) {
                   if (success) success([self arrayByJSON:json modelClassName:kModelTypePlace]);
               }
               failure:failure];
}

- (void)getDailyPlacesByPastDays:(NSInteger)pastDays
                         success:(void(^)(NSArray *dailyPlaces))success
                         failure:(void(^)(NSError *error))failure {
    NSString *url = [self urlByMVUrl:MV_URL_PLACES pastDays:pastDays];
    [self getJsonByUrl:url
               success:^(id json) {
                   if (success) success([self arrayByJSON:json modelClassName:kModelTypePlace]);
               }
               failure:failure];
}

#pragma mark - MVStoryLine
- (void)getDayStoryLineByDate:(NSDate *)date
                  trackPoints:(BOOL)trackPoints
                      success:(void(^)(NSArray *storyLines))success
                      failure:(void(^)(NSError *error))failure {
    NSString *urlString = [self urlByMVUrl:MV_URL_STORYLINE date:date dateFormat:kDateFormatTypeDay];
    if (trackPoints) {
        urlString = [urlString stringByAppendingFormat:@"%@", @"?trackPoints=true"];
    }
    [self getJsonByUrl:urlString
               success:^(id json) {
                   if (success) success([self arrayByJSON:json modelClassName:kModelTypeStoryLine]);
               }
               failure:failure];
}

- (void)getWeekStoryLineByDate:(NSDate *)date
                       success:(void(^)(NSArray *storyLines))success
                       failure:(void(^)(NSError *error))failure {
    NSString *urlString = [self urlByMVUrl:MV_URL_STORYLINE date:date dateFormat:kDateFormatTypeWeek];
    [self getJsonByUrl:urlString
               success:^(id json) {
                   if (success) success([self arrayByJSON:json modelClassName:kModelTypeStoryLine]);
               }
               failure:failure];
}

- (void)getDailyStoryLineFromDate:(NSDate *)fromDate
                           toDate:(NSDate *)toDate
                          success:(void(^)(NSArray *storyLines))success
                          failure:(void(^)(NSError *error))failure {
    NSString *url = [self urlByMVUrl:MV_URL_STORYLINE fromDate:fromDate toDate:toDate];
    [self getJsonByUrl:url
               success:^(id json) {
                   if (success) success([self arrayByJSON:json modelClassName:kModelTypeStoryLine]);
               }
               failure:failure];
}

- (void)getDailyStoryLineByPastDays:(NSInteger)pastDays
                            success:(void(^)(NSArray *storyLines))success
                            failure:(void(^)(NSError *error))failure {
    NSString *url = [self urlByMVUrl:MV_URL_STORYLINE pastDays:pastDays];
    [self getJsonByUrl:url
               success:^(id json) {
                   if (success) success([self arrayByJSON:json modelClassName:kModelTypeStoryLine]);
               }
               failure:failure];
}

#pragma mark - MVOAuthViewControllerDelegate

- (void)oauthViewControllerDidCancel:(MVOAuthViewController *)sender {
    [sender dismissViewControllerAnimated:YES completion:nil];
    
    if (self.authorizationFailureCallback) self.authorizationFailureCallback(nil);
    self.authorizationSuccessCallback = nil;
    self.authorizationFailureCallback = nil;
}

- (void)oauthViewController:(MVOAuthViewController *)sender didFailWithError:(NSError *)error {
    [sender dismissViewControllerAnimated:YES completion:nil];
    
    if (self.authorizationFailureCallback) self.authorizationFailureCallback(error);
    self.authorizationSuccessCallback = nil;
    self.authorizationFailureCallback = nil;
}

- (void)oauthViewController:(MVOAuthViewController *)sender receivedOAuthCallbackURL:(NSURL *)url {
    [self handleOpenUrl:url
             completion:^(BOOL success) {
                 [sender dismissViewControllerAnimated:YES completion:nil];
                }];
    
}

@end
