//
//  MVDailySummary.m
//  Move-iOS-SDK
//
//  Created by Vito on 13-7-11.
//  Copyright (c) 2013年 vito. All rights reserved.
//

#import "MVDailySummary.h"
#import "MVSummary.h"

@implementation MVDailySummary

- (id)init {
    if (self = [super init]) {
    }
    return self;
}

- (MVDailySummary *)initWithDictionary:(NSDictionary *)dic {
    self = [super init];
    
    if (dic[@"date"]) {
        self.date = dic[@"date"];
    }
    if (dic[@"caloriesIdle"]) {
        self.caloriesIdle = [dic[@"caloriesIdle"] integerValue];
    }
    
    if ([dic[@"summary"] isKindOfClass:[NSArray class]]) {
        NSMutableArray *summaries = [[NSMutableArray alloc] init];
        for (NSDictionary *summary in dic[@"summary"]) {
            [summaries addObject:[[MVSummary alloc] initWithDictionary:summary]];
        }
        if (summaries.count>0) {
            self.summaries = summaries;
        }
    }
    
    return self;
}

- (NSInteger)dailyCalories {
    NSInteger dailyCalories = 0;
    if (self.summaries && self.summaries.count > 0) {
        for (MVSummary *summary in self.summaries) {
            dailyCalories += summary.calories;
        }
    }
    return dailyCalories;
}

@end
