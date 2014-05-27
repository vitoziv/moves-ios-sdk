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
    NSArray *testArrayWithNull = [VIAPIRebot jsonFlowerWithJsonData:profileJson convertValueToObject:[NSNull null]];
    [testArrayWithNull enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        XCTAssertNoThrow([[MVUser alloc] initWithDictionary:obj], @"Profile should not crash app when JSON value is [NSNull null]");
    }];
    
    NSArray *testArrayWithString = [VIAPIRebot jsonFlowerWithJsonData:profileJson convertValueToObject:@""];
    [testArrayWithString enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        XCTAssertNoThrow([[MVUser alloc] initWithDictionary:obj], @"Profile should not crash app when JSON value is @'' ");
    }];
}

- (void)testDailySummaries
{
    NSDictionary *summaryJson = [MVJsonFactory summariesJson];
    NSArray *testArrayWithNull = [VIAPIRebot jsonFlowerWithJsonData:summaryJson convertValueToObject:[NSNull null]];
    for (NSDictionary *dic in testArrayWithNull) {
        XCTAssertNoThrow([[MVDailySummary alloc] initWithDictionary:dic], @"DailySummaries should not crash app when JSON value is [NSNull null]");
    }
    
    NSArray *testArrayWithString = [VIAPIRebot jsonFlowerWithJsonData:summaryJson convertValueToObject:@""];
    [testArrayWithString enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        XCTAssertNoThrow([[MVDailySummary alloc] initWithDictionary:obj], @"DailySummaries should not crash app when JSON value is @'' ");
    }];
}

- (void)testDailyActivities
{
    NSDictionary *activityJson = [MVJsonFactory activitiesJson];
    NSArray *testArrayWithNull = [VIAPIRebot jsonFlowerWithJsonData:activityJson convertValueToObject:[NSNull null]];
    [testArrayWithNull enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        XCTAssertNoThrow([[MVDailyActivity alloc] initWithDictionary:obj], @"DailyActivities should not crash app when JSON value is [NSNull null]");
    }];
    
    NSArray *testArrayWithString = [VIAPIRebot jsonFlowerWithJsonData:activityJson convertValueToObject:@""];
    [testArrayWithString enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        XCTAssertNoThrow([[MVDailyActivity alloc] initWithDictionary:obj], @"DailyActivities should not crash app when JSON value is @''");
    }];
}

- (void)testDailyPlaces
{
    NSDictionary *placesJson = [MVJsonFactory placesJson];
    NSArray *testArrayWithNull = [VIAPIRebot jsonFlowerWithJsonData:placesJson convertValueToObject:[NSNull null]];
    [testArrayWithNull enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        XCTAssertNoThrow([[MVDailyPlace alloc] initWithDictionary:obj], @"DailyPlaces should not crash app when JSON value is [NSNull null]");
    }];
    
    NSArray *testArrayWithString = [VIAPIRebot jsonFlowerWithJsonData:placesJson convertValueToObject:@""];
    [testArrayWithString enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        XCTAssertNoThrow([[MVDailyPlace alloc] initWithDictionary:obj], @"DailyPlaces should not crash app when JSON value is @''");
    }];
}

- (void)testDailyStoryline
{
    NSDictionary *storylineJson = [MVJsonFactory storylineJson];
    NSArray *testArrayWithNull = [VIAPIRebot jsonFlowerWithJsonData:storylineJson convertValueToObject:[NSNull null]];
    [testArrayWithNull enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        XCTAssertNoThrow([[MVStoryLine alloc] initWithDictionary:obj], @"DailyStoryline should not crash app when JSON value is [NSNull null]");
    }];
    
    NSArray *testArrayWithString = [VIAPIRebot jsonFlowerWithJsonData:storylineJson convertValueToObject:@""];
    [testArrayWithString enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        XCTAssertNoThrow([[MVStoryLine alloc] initWithDictionary:obj], @"DailyStoryline should not crash app when JSON value is @''");
    }];
}

- (void)testActivityList
{
    NSDictionary *activityListJson = [MVJsonFactory activityListJson];
    NSArray *testArrayWithNull = [VIAPIRebot jsonFlowerWithJsonData:activityListJson convertValueToObject:[NSNull null]];
    [testArrayWithNull enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        XCTAssertNoThrow([[MVSupportedActivity alloc] initWithDictionary:obj], @"ActivityList should not crash app when JSON value is [NSNull null]");
    }];
    
    NSArray *testArrayWithString = [VIAPIRebot jsonFlowerWithJsonData:activityListJson convertValueToObject:@""];
    [testArrayWithString enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        XCTAssertNoThrow([[MVSupportedActivity alloc] initWithDictionary:obj], @"ActivityList should not crash app when JSON value is @''");
    }];
}

@end
