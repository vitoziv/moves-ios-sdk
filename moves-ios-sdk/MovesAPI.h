//
//  MovesAPI.h
//  Move-iOS-SDK
//
//  Created by Vito on 13-7-11.
//  Copyright (c) 2013 vito. All rights reserved.
//

#import "MVUser.h"
#import "MVDailySummary.h"
#import "MVSummary.h"
#import "MVDailyActivity.h"
#import "MVSegment.h"
#import "MVDailyPlace.h"
#import "MVStoryLine.h"
#import "MVSupportedActivity.h"

typedef NS_ENUM(NSUInteger, MVScopeType) {
    MVScopeTypeDefault = 0,
    MVScopeTypeActivity,
    MVScopeTypeLocation
};

typedef void(^MVAuthorizationSuccessBlock)(void);
typedef void(^MVAuthorizationFailureBlock)(NSError *error);

@interface MovesAPI : NSObject

+ (MovesAPI *)sharedInstance;

- (void)setShareMovesOauthClientId:(NSString *)oauthClientId
                 oauthClientSecret:(NSString *)oauthClientSecret
                 callbackUrlScheme:(NSString *)callbackUrlScheme;

- (void)setShareMovesOauthClientId:(NSString *)oauthClientId
                 oauthClientSecret:(NSString *)oauthClientSecret
                 callbackUrlScheme:(NSString *)callbackUrlScheme
                             scope:(MVScopeType)scope;

- (BOOL)canHandleOpenUrl:(NSURL *)url;

#pragma mark - Authorization
- (void)authorizationWithViewController:(UIViewController *)viewController
                                success:(MVAuthorizationSuccessBlock)success
                                failure:(MVAuthorizationFailureBlock)failure;

- (void)logout;

- (BOOL)isAuthenticated;

#pragma mark - General
- (void)getUserSuccess:(void(^)(MVUser *user))success
               failure:(void(^)(NSError *error))failure;

- (void)getActivityListSuccess:(void(^)(NSArray *activityList))success
                       failure:(void(^)(NSError *error))failure;

#pragma mark - MVSummary
- (void)getDayDailySummariesByDate:(NSDate *)date
                           success:(void(^)(NSArray *dailySummaries))success
                           failure:(void(^)(NSError *error))failure;

- (void)getWeekDailySummariesByDate:(NSDate *)date
                            success:(void(^)(NSArray *dailySummaries))success
                            failure:(void(^)(NSError *error))failure;

- (void)getMonthDailySummariesByDate:(NSDate *)date
                             success:(void(^)(NSArray *dailySummaries))success
                             failure:(void(^)(NSError *error))failure;

- (void)getDailySummariesFromDate:(NSDate *)fromDate
                           toDate:(NSDate *)toDate
                          success:(void(^)(NSArray *dailySummaries))success
                          failure:(void(^)(NSError *error))failure;

- (void)getDailySummariesByPastDays:(NSInteger)pastDays
                            success:(void(^)(NSArray *dailySummaries))success
                            failure:(void(^)(NSError *error))failure;

#pragma mark - MVActivity
- (void)getDayDailyActivitiesByDate:(NSDate *)date
                            success:(void(^)(NSArray *dailyActivities))success
                            failure:(void(^)(NSError *error))failure;

- (void)getWeekDailyActivitiesByDate:(NSDate *)date
                             success:(void(^)(NSArray *dailyActivities))success
                             failure:(void(^)(NSError *error))failure;

- (void)getMonthDailyActivitiesByDate:(NSDate *)date
                              success:(void (^)(NSArray *dailyActivities))success
                              failure:(void (^)(NSError *error))failure;

- (void)getDailyActivitiesFromDate:(NSDate *)fromDate
                            toDate:(NSDate *)toDate
                           success:(void(^)(NSArray *dailyActivities))success
                           failure:(void(^)(NSError *error))failure;

- (void)getDailyActivitiesByPastDays:(NSInteger)pastDays
                             success:(void(^)(NSArray *dailyActivities))success
                             failure:(void(^)(NSError *error))failure;

#pragma mark - MVPlace
- (void)getDayDailyPlacesByDate:(NSDate *)date
                        success:(void(^)(NSArray *dailyPlaces))success
                        failure:(void(^)(NSError *error))failure;

- (void)getWeekDailyPlacesByDate:(NSDate *)date
                         success:(void(^)(NSArray *dailyPlaces))success
                         failure:(void(^)(NSError *error))failure;

- (void)getMonthDailyPlacesByDate:(NSDate *)date
                          success:(void(^)(NSArray *dailyPlaces))success
                          failure:(void(^)(NSError *error))failure;

- (void)getDailyPlacesFromDate:(NSDate *)fromDate
                        toDate:(NSDate *)toDate
                       success:(void(^)(NSArray *dailyPlaces))success
                       failure:(void(^)(NSError *error))failure;

- (void)getDailyPlacesByPastDays:(NSInteger)pastDays
                         success:(void(^)(NSArray *dailyPlaces))success
                         failure:(void(^)(NSError *error))failure;

#pragma mark - MVStoryLine
- (void)getDayStoryLineByDate:(NSDate *)date
                  trackPoints:(BOOL)trackPoints
                      success:(void(^)(NSArray *storyLines))success
                      failure:(void(^)(NSError *error))failure;

- (void)getWeekStoryLineByDate:(NSDate *)date
                   trackPoints:(BOOL)trackPoints
                       success:(void(^)(NSArray *storyLines))success
                       failure:(void(^)(NSError *error))failure;

- (void)getMonthStoryLineByDate:(NSDate *)date
                        success:(void(^)(NSArray *storyLines))success
                        failure:(void(^)(NSError *error))failure;

- (void)getDailyStoryLineFromDate:(NSDate *)fromDate
                           toDate:(NSDate *)toDate
                      trackPoints:(BOOL)trackPoints
                          success:(void(^)(NSArray *storyLines))success
                          failure:(void(^)(NSError *error))failure;

- (void)getDailyStoryLineByPastDays:(NSInteger)pastDays
                        trackPoints:(BOOL)trackPoints
                            success:(void(^)(NSArray *storyLines))success
                            failure:(void(^)(NSError *error))failure;
@end
