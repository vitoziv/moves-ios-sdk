//
//  MVJsonFactory.h
//  MovesSDKDemo
//
//  Created by Vito on 5/18/14.
//  Copyright (c) 2014 vito. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MVJsonFactory : NSObject

+ (NSDictionary *)profileJson;
+ (NSDictionary *)summariesJson;
+ (NSDictionary *)activitiesJson;
+ (NSDictionary *)placesJson;
+ (NSDictionary *)storylineJson;
+ (NSDictionary *)activityListJson;

@end
