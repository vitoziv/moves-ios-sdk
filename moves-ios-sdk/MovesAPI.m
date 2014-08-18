//
//  MovesAPI.m
//  Move-iOS-SDK
//
//  Created by Vito on 13-7-11.
//  Copyright (c) 2013 vito. All rights reserved.
//

#import "MovesAPI.h"
#import "MVOAuthViewController.h"
#import "DFDateFormatterFactory.h"
#import "MVCalendarFactory.h"
#import "MVAPIValidator.h"

static NSString *const BASE_DOMAIN = @"https://api.moves-app.com";
static NSString *const BASE_DOMAIN_1_1 = @"https://api.moves-app.com/api/1.1";

static NSString *const MV_URL_USER_PROFILE = @"/user/profile";
static NSString *const MV_URL_ACTIVITY_LIST = @"/activities";
static NSString *const MV_URL_SUMMARY = @"/user/summary/daily";
static NSString *const MV_URL_ACTIVITY = @"/user/activities/daily";
static NSString *const MV_URL_PLACES = @"/user/places/daily";
static NSString *const MV_URL_STORYLINE = @"/user/storyline/daily";

static NSString *const MV_AUTH_ACCESS_TOKEN = @"MV_AUTH_ACCESS_TOKEN";
static NSString *const MV_AUTH_REFRESH_TOKEN = @"MV_AUTH_REFRESH_TOKEN";
static NSString *const MV_AUTH_FETCH_TIME = @"MV_AUTH_FETCH_TIME";
static NSString *const MV_AUTH_EXPIRY = @"MV_AUTH_EXPIRY";
static NSString *const MV_AUTH_USER_ID = @"MV_AUTH_USER_ID";


static NSString *const kDateFormatTypeDay = @"yyyyMMdd";
static NSString *const kDateFormatTypeWeek = @"yyyy-'W'ww";
static NSString *const kDateFormatTypeMonth = @"yyyyMM";

static NSString *const kModelTypeSupportedActivity = @"MVSupportedActivity";
static NSString *const kModelTypeSummary = @"MVDailySummary";
static NSString *const kModelTypeActivity = @"MVDailyActivity";
static NSString *const kModelTypePlace = @"MVDailyPlace";
static NSString *const kModelTypeStoryLine = @"MVStoryLine";

@interface MovesAPI() <MVOAuthViewControllerDelegate>

@property (nonatomic, strong) NSString *accessToken;
@property (nonatomic, strong) NSString *refreshToken;
@property (nonatomic, strong) NSDate *fetchTime;
@property (nonatomic, strong) NSNumber *expiry;
@property (nonatomic, strong) NSString *userID;
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
        self.userID = [defaults objectForKey:MV_AUTH_USER_ID];
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
    
    if ([url.absoluteString hasPrefix:BASE_DOMAIN] || [url.absoluteString hasPrefix:[NSString stringWithFormat:@"%@://authorization-completed", self.callbackUrlScheme]]) {
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
            // use a formsheet on iPad
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                self.oauthViewController.modalPresentationStyle = UIModalPresentationFormSheet;
                oauthNavController.modalPresentationStyle = UIModalPresentationFormSheet;
            }
            [viewController presentViewController:oauthNavController
                                         animated:YES
                                       completion:nil];
        }
    }
    
}

- (void)updateUserDefaultsWithAuthDic:(NSDictionary *)dic {
    NSString *accessToken = dic[@"access_token"];
    NSString *refreshToken = dic[@"refresh_token"];
    NSNumber *expiry = dic[@"expires_in"];
    NSString *userID = dic[@"user_id"];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    [defaults setObject:accessToken forKey:MV_AUTH_ACCESS_TOKEN];
    [defaults setObject:refreshToken forKey:MV_AUTH_REFRESH_TOKEN];
    [defaults setObject:expiry forKey:MV_AUTH_EXPIRY];
    [defaults setObject:userID forKey:MV_AUTH_USER_ID];
    NSDate *fetchTime = [NSDate date];
    [defaults setObject:fetchTime forKey:MV_AUTH_FETCH_TIME];
    
    [defaults synchronize];
    
    self.accessToken = accessToken;
    self.refreshToken = refreshToken;
    self.expiry = expiry;
    self.userID = userID;
    self.fetchTime = fetchTime;
}

- (void)requestOrRefreshAccessToken:(NSString *)code
                            success:(void(^)(void))success
                            failure:(void(^)(NSError *reason))failure
{
    NSString *params;
    NSString *path = @"/oauth/v1/access_token";
    
    if(self.accessToken) {
        params = [NSString stringWithFormat:@"grant_type=refresh_token&refresh_token=%@&client_id=%@&client_secret=%@",
                  self.refreshToken,
                  self.oauthClientId,
                  self.oauthClientSecret];
    } else {
        params = [NSString stringWithFormat:@"grant_type=authorization_code&code=%@&client_id=%@&client_secret=%@&redirect_uri=%@",
                  code,
                  self.oauthClientId,
                  self.oauthClientSecret,
                  [self oauthRedirectUri]];
    }
    
    NSString *url = [NSString stringWithFormat:@"%@%@", BASE_DOMAIN, path];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    request.HTTPBody = [params dataUsingEncoding:NSUTF8StringEncoding];
    request.HTTPMethod = @"POST";
    
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response,
                                               NSData *data,
                                               NSError *error) {
                               // handle response
                               
                               if (!error) {
                                   NSError *jsonError;
                                   NSDictionary *responseDic = [NSJSONSerialization JSONObjectWithData:data
                                                                                               options:NSJSONReadingMutableLeaves
                                                                                                 error:&jsonError];
                                   if (!jsonError) {
                                       [self updateUserDefaultsWithAuthDic:responseDic];
                                       if (success) success();
                                   } else {
                                       if (failure) failure(jsonError);
                                   }
                               } else {
                                   if (failure) failure(error);
                               }
                               
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
    dateFormatter.calendar = [MVCalendarFactory calendarWithIdentifier:NSGregorianCalendar];
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
        url = [NSString stringWithFormat:@"%@%@", BASE_DOMAIN_1_1, MVUrl];
    } else {
        url = [NSString stringWithFormat:@"%@%@/%@", BASE_DOMAIN_1_1, MVUrl, [self stringFromDate:date byFormat:dateFormat]];
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
                     BASE_DOMAIN_1_1,
                     MVUrl,
                     fromDateString,
                     toDateString];
    return url;
}

- (NSString *)urlByMVUrl:(NSString *)MVUrl pastDays:(NSInteger)days {
    NSAssert(days <= 31, @"Moves Error! You should set the pastDays less than 31.");
    NSString *url = [NSString stringWithFormat:@"%@%@?pastDays=%li", BASE_DOMAIN_1_1, MVUrl, (long)days];
    return url;
}

#pragma mark Objects

- (NSArray *)arrayByJSON:(id)JSON modelClassName:(NSString *)className {
    if (![JSON isKindOfClass:[NSArray class]]) {
        return nil;
    }
    
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
        if (failure) failure(authError);
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
            
            NSRange range = [url rangeOfString:@"?" options:NSCaseInsensitiveSearch];
            if (range.location != NSNotFound) {
                url = [url stringByAppendingFormat:@"&access_token=%@", self.accessToken];
            } else {
                url = [url stringByAppendingFormat:@"?access_token=%@", self.accessToken];
            }
            
            NSLog(@"Moves request url: %@", url);
            
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]
                                                                   cachePolicy:NSURLRequestReloadRevalidatingCacheData
                                                               timeoutInterval:25];
            
            [NSURLConnection sendAsynchronousRequest:request
                                               queue:[NSOperationQueue mainQueue]
                                   completionHandler:^(NSURLResponse *response,
                                                       NSData *data,
                                                       NSError *error) {
                                       if (!error) {
                                           NSError *jsonError;
                                           NSDictionary *responseDic = [NSJSONSerialization JSONObjectWithData:data
                                                                                                       options:NSJSONReadingMutableLeaves
                                                                                                         error:&jsonError];
                                           if (jsonError) {
                                               if (failure) {failure(jsonError);}
                                           } else {
                                               if (success) {success(responseDic);}
                                           }
                                       } else {
                                           // Cause your app was revoked in Moves app.
                                           if ([error.userInfo[@"NSLocalizedRecoverySuggestion"] isEqualToString:@"expired_access_token"]) {
                                               NSLog(@"expired_access_token");
                                               
                                               NSError *expiredError = [NSError errorWithDomain:@"MovesAPI Error" code:401 userInfo:@{@"ErrorReason": @"expired_access_token"}];
                                               
                                               if (failure) {failure(expiredError);}
                                           } else {
                                               if (failure) {failure(error);}
                                           }
                                       }
                                   }];
        }
    }
    
}

#pragma mark General

- (void)getUserSuccess:(void(^)(MVUser *user))success
               failure:(void(^)(NSError *error))failure {
    NSString *url = [self urlByMVUrl:MV_URL_USER_PROFILE date:nil dateFormat:nil];
    [self getJsonByUrl:url
               success:^(id json) {
                   [MVAPIValidator validateProfileJson:json success:^{
                       MVUser *user = [[MVUser alloc] initWithDictionary:json];
                       if (success) success(user);
                   } failure:failure];
               }
               failure:failure];
}

- (void)getActivityListSuccess:(void(^)(NSArray *activityList))success
                       failure:(void(^)(NSError *error))failure {
    NSString *url = [NSString stringWithFormat:@"%@%@", BASE_DOMAIN_1_1, MV_URL_ACTIVITY_LIST];
    [self getJsonByUrl:url
               success:^(id json) {
                   [MVAPIValidator validateActivityListJson:json success:^{
                       if (success) {
                           success([self arrayByJSON:json modelClassName:kModelTypeSupportedActivity]);
                       }
                   } failure:failure];
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
                   [MVAPIValidator validateSummariesJson:json success:^{
                       if (success) success([self arrayByJSON:json modelClassName:kModelTypeSummary]);
                   } failure:failure];
               }
               failure:failure];
}

- (void)getWeekDailySummariesByDate:(NSDate *)date
                            success:(void(^)(NSArray *dailySummaries))success
                            failure:(void(^)(NSError *error))failure {
    NSString *url = [self urlByMVUrl:MV_URL_SUMMARY date:date dateFormat:kDateFormatTypeWeek];
    [self getJsonByUrl:url
               success:^(id json) {
                   [MVAPIValidator validateSummariesJson:json success:^{
                       if (success) success([self arrayByJSON:json modelClassName:kModelTypeSummary]);
                   } failure:failure];
               }
               failure:failure];
}

- (void)getMonthDailySummariesByDate:(NSDate *)date
                             success:(void(^)(NSArray *dailySummaries))success
                             failure:(void(^)(NSError *error))failure {
    NSString *url = [self urlByMVUrl:MV_URL_SUMMARY date:date dateFormat:kDateFormatTypeMonth];
    [self getJsonByUrl:url
               success:^(id json) {
                   [MVAPIValidator validateSummariesJson:json success:^{
                       if (success) success([self arrayByJSON:json modelClassName:kModelTypeSummary]);
                   } failure:failure];
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
                   [MVAPIValidator validateSummariesJson:json success:^{
                       if (success) success([self arrayByJSON:json modelClassName:kModelTypeSummary]);
                   } failure:failure];
               }
               failure:failure];
}

- (void)getDailySummariesByPastDays:(NSInteger)pastDays
                            success:(void(^)(NSArray *dailySummaries))success
                            failure:(void(^)(NSError *error))failure {
    NSString *url = [self urlByMVUrl:MV_URL_SUMMARY pastDays:pastDays];
    [self getJsonByUrl:url
               success:^(id json) {
                   [MVAPIValidator validateSummariesJson:json success:^{
                       if (success) success([self arrayByJSON:json modelClassName:kModelTypeSummary]);
                   } failure:failure];
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
                   [MVAPIValidator validateActivitiesJson:json success:^{
                       if (success) success([self arrayByJSON:json modelClassName:kModelTypeActivity]);
                   } failure:failure];
               }
               failure:failure];
}

- (void)getWeekDailyActivitiesByDate:(NSDate *)date
                             success:(void(^)(NSArray *dailyActivities))success
                             failure:(void(^)(NSError *error))failure {
    NSString *url = [self urlByMVUrl:MV_URL_ACTIVITY date:date dateFormat:kDateFormatTypeWeek];
    [self getJsonByUrl:url
               success:^(id json) {
                   [MVAPIValidator validateActivitiesJson:json success:^{
                       if (success) success([self arrayByJSON:json modelClassName:kModelTypeActivity]);
                   } failure:failure];
               }
               failure:failure];
}

- (void)getMonthDailyActivitiesByDate:(NSDate *)date
                              success:(void (^)(NSArray *dailyActivities))success
                              failure:(void (^)(NSError *error))failure {
    NSString *url = [self urlByMVUrl:MV_URL_ACTIVITY date:date dateFormat:kDateFormatTypeMonth];
    [self getJsonByUrl:url
               success:^(id json) {
                   [MVAPIValidator validateActivitiesJson:json success:^{
                       if (success) success([self arrayByJSON:json modelClassName:kModelTypeActivity]);
                   } failure:failure];
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
                   [MVAPIValidator validateActivitiesJson:json success:^{
                       if (success) success([self arrayByJSON:json modelClassName:kModelTypeActivity]);
                   } failure:failure];
               }
               failure:failure];
}

- (void)getDailyActivitiesByPastDays:(NSInteger)pastDays
                             success:(void(^)(NSArray *dailyActivities))success
                             failure:(void(^)(NSError *error))failure {
    NSString *url = [self urlByMVUrl:MV_URL_ACTIVITY pastDays:pastDays];
    [self getJsonByUrl:url
               success:^(id json) {
                   [MVAPIValidator validateActivitiesJson:json success:^{
                       if (success) success([self arrayByJSON:json modelClassName:kModelTypeActivity]);
                   } failure:failure];
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
                   [MVAPIValidator validatePlacesJson:json success:^{
                       if (success) success([self arrayByJSON:json modelClassName:kModelTypePlace]);
                   } failure:failure];
               } failure:failure];
}

- (void)getWeekDailyPlacesByDate:(NSDate *)date
                         success:(void(^)(NSArray *dailyPlaces))success
                         failure:(void(^)(NSError *error))failure {
    NSString *url = [self urlByMVUrl:MV_URL_PLACES date:date dateFormat:kDateFormatTypeWeek];
    [self getJsonByUrl:url
               success:^(id json) {
                   [MVAPIValidator validatePlacesJson:json success:^{
                       if (success) success([self arrayByJSON:json modelClassName:kModelTypePlace]);
                   } failure:failure];
               }
               failure:failure];
}

- (void)getMonthDailyPlacesByDate:(NSDate *)date
                          success:(void(^)(NSArray *dailyPlaces))success
                          failure:(void(^)(NSError *error))failure {
    NSString *url = [self urlByMVUrl:MV_URL_PLACES date:date dateFormat:kDateFormatTypeMonth];
    [self getJsonByUrl:url
               success:^(id json) {
                   [MVAPIValidator validatePlacesJson:json success:^{
                       if (success) success([self arrayByJSON:json modelClassName:kModelTypePlace]);
                   } failure:failure];
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
                   [MVAPIValidator validatePlacesJson:json success:^{
                       if (success) success([self arrayByJSON:json modelClassName:kModelTypePlace]);
                   } failure:failure];
               }
               failure:failure];
}

- (void)getDailyPlacesByPastDays:(NSInteger)pastDays
                         success:(void(^)(NSArray *dailyPlaces))success
                         failure:(void(^)(NSError *error))failure {
    NSString *url = [self urlByMVUrl:MV_URL_PLACES pastDays:pastDays];
    [self getJsonByUrl:url
               success:^(id json) {
                   [MVAPIValidator validatePlacesJson:json success:^{
                       if (success) success([self arrayByJSON:json modelClassName:kModelTypePlace]);
                   } failure:failure];
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
        urlString = [urlString stringByAppendingString:@"?trackPoints=true"];
    }
    [self getJsonByUrl:urlString
               success:^(id json) {
                   [MVAPIValidator validateStorylineJson:json success:^{
                       if (success) success([self arrayByJSON:json modelClassName:kModelTypeStoryLine]);
                   } failure:failure];
               }
               failure:failure];
}

- (void)getWeekStoryLineByDate:(NSDate *)date
                   trackPoints:(BOOL)trackPoints
                       success:(void(^)(NSArray *storyLines))success
                       failure:(void(^)(NSError *error))failure {
    NSString *urlString = [self urlByMVUrl:MV_URL_STORYLINE date:date dateFormat:kDateFormatTypeWeek];
    if (trackPoints) {
        urlString = [urlString stringByAppendingString:@"?trackPoints=true"];
    }
    [self getJsonByUrl:urlString
               success:^(id json) {
                   [MVAPIValidator validateStorylineJson:json success:^{
                       if (success) success([self arrayByJSON:json modelClassName:kModelTypeStoryLine]);
                   } failure:failure];
               }
               failure:failure];
}

- (void)getMonthStoryLineByDate:(NSDate *)date
                        success:(void(^)(NSArray *storyLines))success
                        failure:(void(^)(NSError *error))failure {
    NSString *urlString = [self urlByMVUrl:MV_URL_STORYLINE date:date dateFormat:kDateFormatTypeMonth];
    [self getJsonByUrl:urlString
               success:^(id json) {
                   [MVAPIValidator validateStorylineJson:json success:^{
                       if (success) success([self arrayByJSON:json modelClassName:kModelTypeStoryLine]);
                   } failure:failure];
               }
               failure:failure];
}

- (void)getDailyStoryLineFromDate:(NSDate *)fromDate
                           toDate:(NSDate *)toDate
                      trackPoints:(BOOL)trackPoints
                          success:(void(^)(NSArray *storyLines))success
                          failure:(void(^)(NSError *error))failure {
    NSString *urlString = [self urlByMVUrl:MV_URL_STORYLINE fromDate:fromDate toDate:toDate];
    if (trackPoints) {
        urlString = [urlString stringByAppendingString:@"&trackPoints=true"];
    }
    [self getJsonByUrl:urlString
               success:^(id json) {
                   [MVAPIValidator validateStorylineJson:json success:^{
                       if (success) success([self arrayByJSON:json modelClassName:kModelTypeStoryLine]);
                   } failure:failure];
               }
               failure:failure];
}

- (void)getDailyStoryLineByPastDays:(NSInteger)pastDays
                        trackPoints:(BOOL)trackPoints
                            success:(void(^)(NSArray *storyLines))success
                            failure:(void(^)(NSError *error))failure {
    NSAssert(pastDays <= 7, @"Moves Error! You should set the pastDays less than 7.");
    NSString *urlString = [self urlByMVUrl:MV_URL_STORYLINE pastDays:pastDays];
    if (trackPoints) {
        urlString = [urlString stringByAppendingString:@"&trackPoints=true"];
    }
    [self getJsonByUrl:urlString
               success:^(id json) {
                   [MVAPIValidator validateStorylineJson:json success:^{
                       if (success) success([self arrayByJSON:json modelClassName:kModelTypeStoryLine]);
                   } failure:failure];
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
