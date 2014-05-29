//
//  MVAPIValidator.h
//  MovesSDKDemo
//
//  Created by Vito on 5/29/14.
//  Copyright (c) 2014 vito. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MVAPIValidator : NSObject

+ (void)validateProfileJson:(id)json error:(NSError **)error;
+ (void)validateSummariesJson:(id)json error:(NSError **)error;
+ (void)validateActivitiesJson:(id)json error:(NSError **)error;
+ (void)validatePlacesJson:(id)json error:(NSError **)error;
+ (void)validateStorylineJson:(id)json error:(NSError **)error;
+ (void)validateActivityListJson:(id)json error:(NSError **)error;

@end
