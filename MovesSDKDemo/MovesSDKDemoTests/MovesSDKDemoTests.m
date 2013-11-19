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

@interface MovesSDKDemoTests : XCTestCase

@end

@implementation MovesSDKDemoTests

- (void)setUp
{
    [super setUp];
    [Expecta setAsynchronousTestTimeout:5.0];
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
        NSLog(@"user: %@", user);
        blockResponseObject = user;
    } failure:^(NSError *error) {
        NSLog(@"error: %@", error);
        XCTAssertNotNil(error, @"error not nil");
    }];
    
    expect(blockResponseObject).willNot.beNil();
}

@end
