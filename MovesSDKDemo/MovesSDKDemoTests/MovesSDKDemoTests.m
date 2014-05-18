//
//  MovesSDKDemoTests.m
//  MovesSDKDemoTests
//
//  Created by Vito on 13-7-22.
//  Copyright (c) 2013年 vito. All rights reserved.
//

#import <XCTest/XCTest.h>

#define EXP_SHORTHAND YES
#import "Expecta.h"
#import "MovesAPI.h"

#define ONE_DAY 86400
#define ONE_WEEK 604800
#define ONE_MONTH 2592000

@interface MovesSDKDemoTests : XCTestCase

@end

@implementation MovesSDKDemoTests

+ (void)setUp {
    [super setUp];
    [Expecta setAsynchronousTestTimeout:5.0];
}

+ (void)tearDown {
    [super tearDown];
}

- (void)setUp
{
    [super setUp];
    // Set-up code here.
}

- (void)tearDown
{
    // Tear-down code here.
    [super tearDown];
}

- (void)testGetUser {
    __block id blockResponseObject = nil;
    
    [[MovesAPI sharedInstance] getUserSuccess:^(MVUser *user) {
        blockResponseObject = user;
    } failure:^(NSError *error) { }];
    
    expect(blockResponseObject).willNot.beNil();
}

- (void)testDayDailySummaries {
    __block id blockResponseObject = nil;
    
    [[MovesAPI sharedInstance] getDayDailySummariesByDate:[[NSDate date] dateByAddingTimeInterval:-ONE_DAY]
                                                  success:^(NSArray *dailySummaries) {
                                                      blockResponseObject = dailySummaries;
                                                  } failure:nil];
    
    expect([blockResponseObject isKindOfClass:[NSArray class]]).will.beTruthy();
}

- (void)testWeekDailySummaries {
    __block id blockResponseObject = nil;
    
    [[MovesAPI sharedInstance] getWeekDailySummariesByDate:[[NSDate date] dateByAddingTimeInterval:-ONE_DAY]
                                                   success:^(NSArray *dailySummaries) {
                                                       blockResponseObject = dailySummaries;
                                                   } failure:nil];
    
    expect([blockResponseObject isKindOfClass:[NSArray class]]).will.beTruthy();
}

- (void)testMonthDailySummaries {
    __block id blockResponseObject = nil;
    
    [[MovesAPI sharedInstance] getMonthDailySummariesByDate:[[NSDate date] dateByAddingTimeInterval:-ONE_DAY]
                                                    success:^(NSArray *dailySummaries) {
                                                        blockResponseObject = dailySummaries;
                                                    } failure:nil];
    
    expect([blockResponseObject isKindOfClass:[NSArray class]]).will.beTruthy();
}

- (void)testDailySummariesFromDateToDate {
    __block id blockResponseObject = nil;
    
    [[MovesAPI sharedInstance] getDailySummariesFromDate:[[NSDate date] dateByAddingTimeInterval:-ONE_MONTH] // Notice: Max range is 31
                                                  toDate:[NSDate date]
                                                 success:^(NSArray *dailySummaries) {
                                                     blockResponseObject = dailySummaries;
                                                 }
                                                 failure:nil];
    
    expect([blockResponseObject isKindOfClass:[NSArray class]]).will.beTruthy();
}

- (void)testDailySummariesByPastDays {
    __block id blockResponseObject = nil;
    
    [[MovesAPI sharedInstance] getDailySummariesByPastDays:10
                                                   success:^(NSArray *dailySummaries) {
                                                       blockResponseObject = dailySummaries;
                                                   } failure:nil];
    
    expect([blockResponseObject isKindOfClass:[NSArray class]]).will.beTruthy();
}

- (void)testDayDailyActivities {
    __block id blockResponseObject = nil;
    
    [[MovesAPI sharedInstance] getDayDailyActivitiesByDate:[[NSDate date] dateByAddingTimeInterval:-ONE_DAY]
                                                   success:^(NSArray *dailyActivities) {
                                                       blockResponseObject = dailyActivities;
                                                   } failure:nil];
    
    expect([blockResponseObject isKindOfClass:[NSArray class]]).will.beTruthy();
}

- (void)testWeekDailyActivities {
    __block id blockResponseObject = nil;
    
    [[MovesAPI sharedInstance] getWeekDailyActivitiesByDate:[[NSDate date] dateByAddingTimeInterval:-ONE_DAY]
                                                    success:^(NSArray *dailyActivities) {
                                                        blockResponseObject = dailyActivities;
                                                    } failure:nil];
    
    expect([blockResponseObject isKindOfClass:[NSArray class]]).will.beTruthy();
}

- (void)testDailyActivitiesFromDateToDate {
    __block id blockResponseObject = nil;
    
    [[MovesAPI sharedInstance] getDailyActivitiesFromDate:[[NSDate date] dateByAddingTimeInterval:-ONE_WEEK + ONE_DAY]
                                                   toDate:[NSDate date]
                                                  success:^(NSArray *dailyActivities) {
                                                      blockResponseObject = dailyActivities;
                                                  } failure:nil];
    
    expect([blockResponseObject isKindOfClass:[NSArray class]]).will.beTruthy();
}

- (void)testDailyActivitiesByPastDays {
    __block id blockResponseObject = nil;
    
    [[MovesAPI sharedInstance] getDailyActivitiesByPastDays:7
                                                    success:^(NSArray *dailyActivities) {
                                                        blockResponseObject = dailyActivities;
                                                    } failure:nil];
    
    expect([blockResponseObject isKindOfClass:[NSArray class]]).will.beTruthy();
}

- (void)testDayDailyPlaces {
    __block id blockResponseObject = nil;
    
    [[MovesAPI sharedInstance] getDayDailyPlacesByDate:[[NSDate date] dateByAddingTimeInterval:-ONE_DAY]
                                               success:^(NSArray *dailyPlaces) {
                                                   blockResponseObject = dailyPlaces;
                                               } failure:nil];
    
    expect([blockResponseObject isKindOfClass:[NSArray class]]).will.beTruthy();
}

- (void)testWeekDailyPlaces {
    __block id blockResponseObject = nil;
    
    [[MovesAPI sharedInstance] getWeekDailyPlacesByDate:[[NSDate date] dateByAddingTimeInterval:-ONE_DAY]
                                                success:^(NSArray *dailyPlaces) {
                                                    blockResponseObject = dailyPlaces;
                                                } failure:nil];
    
    expect([blockResponseObject isKindOfClass:[NSArray class]]).will.beTruthy();
}

- (void)testDailyPlacesFromDateToDate {
    __block id blockResponseObject = nil;
    
    [[MovesAPI sharedInstance] getDailyPlacesFromDate:[[NSDate date] dateByAddingTimeInterval:-ONE_WEEK + ONE_DAY]
                                               toDate:[NSDate date]
                                              success:^(NSArray *dailyPlaces) {
                                                  blockResponseObject = dailyPlaces;
                                              } failure:nil];
    
    expect([blockResponseObject isKindOfClass:[NSArray class]]).will.beTruthy();
}

- (void)testDailyPlacesByPastDays {
    __block id blockResponseObject = nil;
    
    [[MovesAPI sharedInstance] getDailyPlacesByPastDays:7
                                                success:^(NSArray *dailyPlaces) {
                                                    blockResponseObject = dailyPlaces;
                                                } failure:nil];
    
    expect([blockResponseObject isKindOfClass:[NSArray class]]).will.beTruthy();
}

- (void)testDayStoryLine {
    __block id blockResponseObject = nil;
    
    [[MovesAPI sharedInstance] getDayStoryLineByDate:[[NSDate date] dateByAddingTimeInterval:-ONE_DAY]
                                         trackPoints:YES
                                             success:^(NSArray *storyLines) {
                                                 blockResponseObject = storyLines;
                                             } failure:nil];
    
    expect([blockResponseObject isKindOfClass:[NSArray class]]).will.beTruthy();
}

- (void)testWeekStoryLine {
    __block id blockResponseObject = nil;
    
    [[MovesAPI sharedInstance] getWeekStoryLineByDate:[[NSDate date] dateByAddingTimeInterval:-ONE_DAY]
                                          trackPoints:YES
                                              success:^(NSArray *storyLines) {
                                                  blockResponseObject = storyLines;
                                              } failure:nil];
    
    expect([blockResponseObject isKindOfClass:[NSArray class]]).will.beTruthy();
}

- (void)testDailyStoryLineFromDateToDate {
    __block id blockResponseObject = nil;
    
    [[MovesAPI sharedInstance] getDailyStoryLineFromDate:[[NSDate date] dateByAddingTimeInterval:-ONE_WEEK + ONE_DAY]
                                                  toDate:[NSDate date]
                                             trackPoints:NO
                                                 success:^(NSArray *storyLines) {
                                                     blockResponseObject = storyLines;
                                                 } failure:nil];
    
    expect([blockResponseObject isKindOfClass:[NSArray class]]).will.beTruthy();
}

- (void)testDailyStoryLineByPastDays {
    __block id blockResponseObject = nil;
    
    [[MovesAPI sharedInstance] getDailyStoryLineByPastDays:7
                                               trackPoints:NO
                                                   success:^(NSArray *storyLines) {
                                                       blockResponseObject = storyLines;
                                                   } failure:nil];
    
    expect([blockResponseObject isKindOfClass:[NSArray class]]).will.beTruthy();
}

@end
