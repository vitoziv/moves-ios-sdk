//
//  MovesAPI.h
//  Move-iOS-SDK
//
//  Created by Vito on 13-7-11.
//  Copyright (c) 2013 vito. All rights reserved.
//

#import "AFHTTPClient.h"
#import "MVUser.h"
#import "MVDailySummary.h"
#import "MVSummary.h"
#import "MVDailyActivity.h"
#import "MVSegment.h"
#import "MVDailyPlace.h"
#import "MVStoryLine.h"

@interface MovesAPI : AFHTTPClient
+ (MovesAPI*)sharedInstance;
- (void)setShareMovesOauthClientId:(NSString *)oauthClientId oauthClientSecret:(NSString *)oauthClientSecret callbackUrlScheme:(NSString *)callbackUrlScheme;
- (void)authorizationCompletedCallback:(NSURL*)responseUrl;

#pragma mark - Authorization
- (void)authorizationSuccess:(void (^)(void))success failure:(void (^)(NSError *reason))failure;
- (void)logout;

- (BOOL)isAuthenticated;

#pragma mark - MVUser
- (void)getUserSuccess:(void (^)(MVUser *user))success
               failure:(void (^)(NSError *error))failure;

#pragma mark - MVSummary
- (void)getDayDailySummariesByDate:(NSDate *)date
                           success:(void (^)(NSArray *dailySummaries))success
                           failure:(void (^)(NSError *error))failure;

- (void)getWeekDailySummariesByDate:(NSDate *)date
                            success:(void (^)(NSArray *dailySummaries))success
                            failure:(void (^)(NSError *error))failure;

- (void)getMonthDailySummariesByDate:(NSDate *)date
                             success:(void (^)(NSArray *dailySummaries))success
                             failure:(void (^)(NSError *error))failure;

- (void)getDailySummariesFromDate:(NSDate *)fromDate
                           toDate:(NSDate *)toDate
                          success:(void (^)(NSArray *dailySummaries))success
                          failure:(void (^)(NSError *error))failure;

- (void)getDailySummariesByPastDays:(NSInteger)pastDays
                            success:(void (^)(NSArray *dailySummaries))success
                            failure:(void (^)(NSError *error))failure;

#pragma mark - MVActivity
- (void)getDayDailyActivitiesByDate:(NSDate *)date
                            success:(void (^)(NSArray *dailyActivities))success
                            failure:(void (^)(NSError *error))failure;

- (void)getWeekDailyActivitiesByDate:(NSDate *)date
                             success:(void (^)(NSArray *dailyActivities))success
                             failure:(void (^)(NSError *error))failure;

#pragma mark - MVPlace
- (void)getDayDailyPlacesByDate:(NSDate *)date
                        success:(void (^)(NSArray *dailyPlaces))success
                        failure:(void (^)(NSError *error))failure;

- (void)getWeekDailyPlacesByDate:(NSDate *)date
                         success:(void (^)(NSArray *dailyPlaces))success
                         failure:(void (^)(NSError *error))failure;

#pragma mark - MVStoryLine
- (void)getDayStoryLineByDate:(NSDate *)date
                      success:(void (^)(NSArray *storyLines))success
                      failure:(void (^)(NSError *error))failure;

- (void)getWeekStoryLineByDate:(NSDate *)date
               withtrackPoints:(BOOL)trackPoints
                       success:(void (^)(NSArray *storyLines))success
                       failure:(void (^)(NSError *error))failure;

@end
