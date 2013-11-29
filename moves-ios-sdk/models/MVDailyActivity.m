//
//  MVDailyActivities.m
//  Move-iOS-SDK
//
//  Created by Vito on 13-7-11.
//  Copyright (c) 2013年 vito. All rights reserved.
//

#import "MVDailyActivity.h"
#import "MVSegment.h"
#import "DFDateFormatterFactory.h"

@implementation MVDailyActivity

- (id)init {
    if (self = [super init]) {
    }
    return self;
}

- (MVDailyActivity *)initWithDictionary:(NSDictionary *)dic {
    self = [super init];
    
    if (dic[@"date"]) {
        NSDateFormatter *formatter = [[DFDateFormatterFactory sharedFactory] dateFormatterWithFormat:@"yyyyMMdd"];
        self.date = [formatter dateFromString:dic[@"date"]];
    }
    if (dic[@"caloriesIdle"]) {
        self.caloriesIdle = [dic[@"caloriesIdle"] integerValue];
    }
    
    if ([dic[@"segments"] isKindOfClass:[NSArray class]]) {
        NSMutableArray *segments = [[NSMutableArray alloc] init];
        for (NSDictionary *segment in dic[@"segments"]) {
            [segments addObject:[[MVSegment alloc] initWithDictionary:segment]];
        }
        if (segments.count > 0) {
            self.segments = segments;
        }
    }
    
    return self;
}

- (NSInteger)dailyCalories {
    NSInteger dailyCalories = 0;
    if (self.segments && self.segments.count > 0) {
        for (MVSegment *segment in self.segments) {
            for (MVActivity *activity in segment.activities) {
                dailyCalories += activity.calories;
            }
        }
    }
    return dailyCalories;
}

@end
