//
//  MVActivity.m
//  Move-iOS-SDK
//
//  Created by Vito on 13-7-11.
//  Copyright (c) 2013年 vito. All rights reserved.
//

#import "MVActivity.h"

@implementation MVActivity

- (id)init {
    if (self = [super init]) {
    }
    return self;
}

- (MVActivity *)initWithDictionary:(NSDictionary *)dic {
    self = [super init];
    
    MVActivityType activityType = MVActivityTypeWalking;
    NSString *activityName = dic[@"activity"];
    if ([activityName isEqual: @"run"]) {
        activityType = MVActivityTypeRunning;
    } else if ([activityName isEqual: @"cyc"]){
        activityType = MVActivityTypeCycling;
    } else if ([activityName isEqual: @"trp"]){
        activityType = MVActivityTypeTransport;
    }
    self.activity = activityType;
    
    self.startTime = dic[@"startTime"];
    self.endTime = dic[@"endTime"];
    self.distance = [dic[@"distance"] integerValue];
    self.duration = [dic[@"duration"] integerValue];
    self.steps = [dic[@"steps"] integerValue];
    self.calories = [dic[@"calories"] integerValue];
    
    if ([dic[@"trackPoints"] isKindOfClass:[NSArray class]]) {
        NSMutableArray *trackPoints = [[NSMutableArray alloc] init];
        for (NSDictionary *trackPoint in dic[@"trackPoints"]) {
            [trackPoints addObject:[[MVTrackPoint alloc] initWithDictionary:trackPoint]];
        }
        
        self.trackPoints = trackPoints;
    }
    
    return self;
}

@end
