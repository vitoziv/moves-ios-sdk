//
//  MovesModelTests.m
//  MovesSDKDemo
//
//  Created by Vito on 5/16/14.
//  Copyright (c) 2014 vito. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "MovesAPI.h"
#import "VIAPIRobot.h"
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
    NSArray *testArrayWithNull = [VIAPIRobot jsonFlowerWithJsonData:profileJson convertValueToObject:[NSNull null]];
    [testArrayWithNull enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        XCTAssertNoThrow([[MVUser alloc] initWithDictionary:obj], @"Profile should not crash app when JSON value is [NSNull null]");
    }];
    
    NSArray *testArrayWithString = [VIAPIRobot jsonFlowerWithJsonData:profileJson convertValueToObject:@""];
    [testArrayWithString enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        XCTAssertNoThrow([[MVUser alloc] initWithDictionary:obj], @"Profile should not crash app when JSON value is @'' ");
    }];
}

- (void)testDailySummaries
{
    NSDictionary *summaryJson = [MVJsonFactory summariesJson];
    NSArray *testArrayWithNull = [VIAPIRobot jsonFlowerWithJsonData:summaryJson convertValueToObject:[NSNull null]];
    for (NSDictionary *dic in testArrayWithNull) {
        XCTAssertNoThrow([[MVDailySummary alloc] initWithDictionary:dic], @"DailySummaries should not crash app when JSON value is [NSNull null]");
    }
    
    NSArray *testArrayWithString = [VIAPIRobot jsonFlowerWithJsonData:summaryJson convertValueToObject:@""];
    [testArrayWithString enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        XCTAssertNoThrow([[MVDailySummary alloc] initWithDictionary:obj], @"DailySummaries should not crash app when JSON value is @'' ");
    }];
}

- (void)testDailyActivities
{
    NSDictionary *activityJson = [MVJsonFactory activitiesJson];
    NSArray *testArrayWithNull = [VIAPIRobot jsonFlowerWithJsonData:activityJson convertValueToObject:[NSNull null]];
    [testArrayWithNull enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        XCTAssertNoThrow([[MVDailyActivity alloc] initWithDictionary:obj], @"DailyActivities should not crash app when JSON value is [NSNull null]");
    }];
    
    NSArray *testArrayWithString = [VIAPIRobot jsonFlowerWithJsonData:activityJson convertValueToObject:@""];
    [testArrayWithString enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        XCTAssertNoThrow([[MVDailyActivity alloc] initWithDictionary:obj], @"DailyActivities should not crash app when JSON value is @''");
    }];
}

- (void)testDailyPlaces
{
    NSDictionary *placesJson = [MVJsonFactory placesJson];
    NSArray *testArrayWithNull = [VIAPIRobot jsonFlowerWithJsonData:placesJson convertValueToObject:[NSNull null]];
    [testArrayWithNull enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        XCTAssertNoThrow([[MVDailyPlace alloc] initWithDictionary:obj], @"DailyPlaces should not crash app when JSON value is [NSNull null]");
    }];
    
    NSArray *testArrayWithString = [VIAPIRobot jsonFlowerWithJsonData:placesJson convertValueToObject:@""];
    [testArrayWithString enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        XCTAssertNoThrow([[MVDailyPlace alloc] initWithDictionary:obj], @"DailyPlaces should not crash app when JSON value is @''");
    }];
}

- (void)testDailyStoryline
{
    NSDictionary *storylineJson = [MVJsonFactory storylineJson];
    NSArray *testArrayWithNull = [VIAPIRobot jsonFlowerWithJsonData:storylineJson convertValueToObject:[NSNull null]];
    [testArrayWithNull enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        XCTAssertNoThrow([[MVStoryLine alloc] initWithDictionary:obj], @"DailyStoryline should not crash app when JSON value is [NSNull null]");
    }];
    
    NSArray *testArrayWithString = [VIAPIRobot jsonFlowerWithJsonData:storylineJson convertValueToObject:@""];
    [testArrayWithString enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        XCTAssertNoThrow([[MVStoryLine alloc] initWithDictionary:obj], @"DailyStoryline should not crash app when JSON value is @''");
    }];
}

- (void)testActivityList
{
    NSDictionary *activityListJson = [MVJsonFactory activityListJson];
    NSArray *testArrayWithNull = [VIAPIRobot jsonFlowerWithJsonData:activityListJson convertValueToObject:[NSNull null]];
    [testArrayWithNull enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        XCTAssertNoThrow([[MVSupportedActivity alloc] initWithDictionary:obj], @"ActivityList should not crash app when JSON value is [NSNull null]");
        
        MVSupportedActivity *activity = [[MVSupportedActivity alloc] initWithDictionary:obj];
        XCTAssertTrue([activity.activity isKindOfClass:[NSString class]] || !activity.activity, @"SopportedActivity's activity name should be a NSString class or nil");
        XCTAssertTrue([NSNumber numberWithBool:activity.geo], @"SopportedActivity's geo should be a bool");
    }];
    
    NSArray *testArrayWithString = [VIAPIRobot jsonFlowerWithJsonData:activityListJson convertValueToObject:@""];
    [testArrayWithString enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        XCTAssertNoThrow([[MVSupportedActivity alloc] initWithDictionary:obj], @"ActivityList should not crash app when JSON value is @''");
    }];
}

@end
