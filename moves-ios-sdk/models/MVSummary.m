//
//  MVSummary.m
//  Move-iOS-SDK
//
//  Created by Vito on 13-7-11.
//  Copyright (c) 2013年 vito. All rights reserved.
//

#import "MVSummary.h"

@implementation MVSummary

- (id)init {
    if (self = [super init]) {
    }
    return self;
}

- (MVSummary *)initWithDictionary:(NSDictionary *)dic {
    self = [super init];
    
    if (dic[@"duration"]) {
        self.duration = [dic[@"duration"] integerValue];
    }
    if (dic[@"distance"]) {
        self.distance = [dic[@"distance"] integerValue];
    }
    if (dic[@"steps"]) {
        self.steps = [dic[@"steps"] integerValue];
    }
    if (dic[@"calories"]) {
        self.calories = [dic[@"calories"] integerValue];
    }
    
    if (dic[@"activity"]) {
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
    }
    
    return self;
}

@end
