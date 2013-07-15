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

@end

#endif
