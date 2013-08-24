//
//  MVStoryLine.m
//  Move-iOS-SDK
//
//  Created by Vito on 13-7-14.
//  Copyright (c) 2013年 vito. All rights reserved.
//

#import "MVStoryLine.h"

@implementation MVStoryLine

- (id)init {
    if (self = [super init]) {
    }
    return self;
}

- (MVStoryLine *)initWithDictionary:(NSDictionary *)dic {
    self = [super init];
    
    self.date = dic[@"date"];
    self.caloriesIdle = [dic[@"caloriesIdle"] integerValue];
    
    if ([dic[@"segments"] isKindOfClass:[NSArray class]]) {
        NSMutableArray *segments = [[NSMutableArray alloc] init];
        for (NSDictionary *segment in dic[@"segments"]) {
            [segments addObject:[[MVSegment alloc] initWithDictionary:segment]];
        }
        self.segments = segments;
    }
    
    return self;
}

- (NSInteger)dailyCalories {
    NSInteger dailyCalories = 0;
    for (MVSegment *segment in self.segments) {
        for (MVActivity *activity in segment.activities) {
            dailyCalories += activity.calories;
        }
    }
    
    return dailyCalories;
}

@end
