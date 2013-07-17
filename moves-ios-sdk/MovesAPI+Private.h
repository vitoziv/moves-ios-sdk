//
//  MovesAPI+Private.h
//  Move-iOS-SDK
//
//  Created by Vito on 13-7-11.
//  Copyright (c) 2013 vito. All rights reserved.
//

#ifndef MovesBridge_MovesAPI_Private_h
#define MovesBridge_MovesAPI_Private_h

#define MV_URL_USER_PROFILE @"/api/v1/user/profile"
#define MV_URL_SUMMARY @"/api/v1/user/summary/daily"
#define MV_URL_ACTIVITY @"/api/v1/user/activities/daily"
#define MV_URL_PLACES @"/api/v1/user/places/daily"
#define MV_URL_STORYLINE @"/api/v1/user/storyline/daily"

#define MV_AUTH_ACCESS_TOKEN @"MV_AUTH_ACCESS_TOKEN"
#define MV_AUTH_REFRESH_TOKEN @"MV_AUTH_REFRESH_TOKEN"
#define MV_AUTH_FETCH_TIME @"MV_AUTH_FETCH_TIME"
#define MV_AUTH_EXPIRY @"MV_AUTH_EXPIRY"

typedef NS_ENUM(NSInteger, MVModelType) {
    MVModelTypeProfile = 0,
    MVModelTypeSummary,
    MVModelTypeActivity,
    MVModelTypePlace,
    MVModelTypeStoryLine
};

typedef NS_ENUM(NSInteger, MVDateFormatType) {
    MVDateFormatTypeDay = 0,
    MVDateFormatTypeWeek,
    MVDateFormatTypeMonth
};

@interface MovesAPI ()

@property (strong, nonatomic) NSString *accessToken;
@property (strong, nonatomic) NSString *refreshToken;
@property (strong, nonatomic) NSDate *fetchTime;
@property (strong, nonatomic) NSNumber *expiry;
@property (nonatomic, strong) NSString *oauthClientId;
@property (nonatomic, strong) NSString *oauthClientSecret;
@property (nonatomic, strong) NSString *callbackUrlScheme;

@property (nonatomic) BOOL serverStarted;

@property (nonatomic, copy) void (^authorizationSuccessCallback)(void);
@property (nonatomic, copy) void (^authorizationFailureCallback)(NSError *reason);
@property (nonatomic, strong) NSError *expiredError;

- (void)initServer;

@end

#endif
