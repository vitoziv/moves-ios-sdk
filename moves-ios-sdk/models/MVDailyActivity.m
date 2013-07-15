//
//  MVDailyActivities.m
//  Move-iOS-SDK
//
//  Created by Vito on 13-7-11.
//  Copyright (c) 2013年 vito. All rights reserved.
//

#import "MVDailyActivity.h"
#import "MVSegment.h"

@implementation MVDailyActivity

- (id)init {
    if (self = [super init]) {
    }
    return self;
}

- (MVDailyActivity *)initWithDictionary:(NSDictionary *)dic {
    self = [super init];
    
    self.date = dic[@"date"];
    self.caloriesIdle = [dic[@"caloriesIdle"] integerValue];
    
    NSMutableArray *segments = [[NSMutableArray alloc] init];
    for (NSDictionary *segment in dic[@"segments"]) {
        [segments addObject:[[MVSegment alloc] initWithDictionary:segment]];
    }
    self.segments = segments;
    
    return self;
}

@end
