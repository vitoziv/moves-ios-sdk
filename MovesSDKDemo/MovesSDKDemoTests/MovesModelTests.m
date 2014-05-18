//
//  MovesModelTests.m
//  MovesSDKDemo
//
//  Created by Vito on 5/16/14.
//  Copyright (c) 2014 vito. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "MovesAPI.h"
#import "VIAPIRebot.h"
#import "MVJsonFactory.h"


@interface MovesModelTests : XCTestCase

@end

@implementation MovesModelTests

+ (void)setUp {
    [super setUp];
}

+ (void)tearDown {
    [super tearDown];
}

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}



- (void)testProfile
{
    NSDictionary *profileJson = [MVJsonFactory profileJson];
    NSArray *testArray = [VIAPIRebot jsonFlowerWithJsonData:profileJson];
    
    for (NSDictionary *dic in testArray) {
        XCTAssertNoThrow([[MVUser alloc] initWithDictionary:dic], @"Profile should not crash app when JSON value is [NSNull null]");
    }
}

- (void)testDailySummaries
{
    NSDictionary *summaryJson = [MVJsonFactory summariesJson];
    NSArray *testArray = [VIAPIRebot jsonFlowerWithJsonData:summaryJson];
    for (NSDictionary *dic in testArray) {
        XCTAssertNoThrow([[MVDailySummary alloc] initWithDictionary:dic], @"DailySummaries should not crash app when JSON value is [NSNull null]");
    }
}

- (void)testDailyActivities
{
    NSDictionary *activityJson = [MVJsonFactory activitiesJson];
    NSArray *testArray = [VIAPIRebot jsonFlowerWithJsonData:activityJson];
    for (NSDictionary *dic in testArray) {
        XCTAssertNoThrow([[MVDailyActivity alloc] initWithDictionary:dic], @"DailyActivities should not crash app when JSON value is [NSNull null]");
    }
}

- (void)testDailyPlaces
{
    NSDictionary *placesJson = [MVJsonFactory placesJson];
    NSArray *testArray = [VIAPIRebot jsonFlowerWithJsonData:placesJson];
    for (NSDictionary *dic in testArray) {
        XCTAssertNoThrow([[MVDailyPlace alloc] initWithDictionary:dic], @"DailyPlaces should not crash app when JSON value is [NSNull null]");
    }
}

- (void)testDailyStoryline
{
    NSDictionary *storylineJson = [MVJsonFactory storylineJson];
    NSArray *testArray = [VIAPIRebot jsonFlowerWithJsonData:storylineJson];
    for (NSDictionary *dic in testArray) {
        XCTAssertNoThrow([[MVStoryLine alloc] initWithDictionary:dic], @"DailyStoryline should not crash app when JSON value is [NSNull null]");
    }
}

- (void)testActivityList
{
    NSDictionary *activityListJson = [MVJsonFactory activityListJson];
    NSArray *testArray = [VIAPIRebot jsonFlowerWithJsonData:activityListJson];
    
    for (NSDictionary *dic in testArray) {
        XCTAssertNoThrow([[MVSupportedActivity alloc] initWithDictionary:dic], @"ActivityList should not crash app when JSON value is [NSNull null]");
    }
}

@end
