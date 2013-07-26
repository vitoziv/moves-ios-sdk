//
//  MovesSDKDemoTests.m
//  MovesSDKDemoTests
//
//  Created by Vito on 13-7-22.
//  Copyright (c) 2013年 vito. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "MovesAPI.h"

@interface MovesSDKDemoTests : XCTestCase

@end

@implementation MovesSDKDemoTests

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

- (void)testExample
{
    XCTFail(@"No implementation for \"%s\"", __PRETTY_FUNCTION__);
}

- (void)testGetUser {
    [[MovesAPI sharedInstance] getUserSuccess:^(MVUser *user) {
        XCTAssertNotNil(user, @"User not nil");
    } failure:^(NSError *error) {
        XCTAssertNotNil(error, @"error not nil");
    }];
}

@end
