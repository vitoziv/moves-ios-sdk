//
//  MVActivity.m
//  Move-iOS-SDK
//
//  Created by Vito on 13-7-11.
//  Copyright (c) 2013年 vito. All rights reserved.
//

#import "MVActivity.h"
#import "DFDateFormatterFactory.h"

@implementation MVActivity

- (id)init {
    if (self = [super init]) {
    }
    return self;
}

- (MVActivity *)initWithDictionary:(NSDictionary *)dic {
    self = [super init];
    
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
    
    NSDateFormatter *formatter = [[DFDateFormatterFactory sharedFactory] dateFormatterWithFormat:@"yyyyMMdd'T'HHmmssZ"];
    if (dic[@"startTime"]) {
        self.startTime = [formatter dateFromString:dic[@"startTime"]];
    }
    if (dic[@"endTime"]) {
        self.endTime = [formatter dateFromString:dic[@"endTime"]];
    }
    if (dic[@"distance"]) {
        self.distance = [dic[@"distance"] integerValue];
    }
    if (dic[@"duration"]) {
        self.duration = [dic[@"duration"] integerValue];
    }
    if (dic[@"steps"]) {
        self.steps = [dic[@"steps"] integerValue];
    }
    if (dic[@"calories"]) {
        self.calories = [dic[@"calories"] integerValue];
    }
    
    if ([dic[@"trackPoints"] isKindOfClass:[NSArray class]]) {
        NSMutableArray *trackPoints = [[NSMutableArray alloc] init];
        for (NSDictionary *trackPoint in dic[@"trackPoints"]) {
            [trackPoints addObject:[[MVTrackPoint alloc] initWithDictionary:trackPoint]];
        }
        if (trackPoints.count > 0) {
            self.trackPoints = trackPoints;
        }
    }
    
    return self;
}

@end
