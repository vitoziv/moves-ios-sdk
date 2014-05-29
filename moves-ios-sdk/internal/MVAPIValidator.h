//
//  MVAPIValidator.h
//  MovesSDKDemo
//
//  Created by Vito on 5/29/14.
//  Copyright (c) 2014 vito. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^MVAVSuccessBlock)(void);
typedef void(^MVAVFailureBlock)(NSError *error);

@interface MVAPIValidator : NSObject

+ (void)validateProfileJson:(id)json success:(MVAVSuccessBlock)success failure:(MVAVFailureBlock)failure;
+ (void)validateSummariesJson:(id)json success:(MVAVSuccessBlock)success failure:(MVAVFailureBlock)failure;
+ (void)validateActivitiesJson:(id)json success:(MVAVSuccessBlock)success failure:(MVAVFailureBlock)failure;
+ (void)validatePlacesJson:(id)json success:(MVAVSuccessBlock)success failure:(MVAVFailureBlock)failure;
+ (void)validateStorylineJson:(id)json success:(MVAVSuccessBlock)success failure:(MVAVFailureBlock)failure;
+ (void)validateActivityListJson:(id)json success:(MVAVSuccessBlock)success failure:(MVAVFailureBlock)failure;

@end
