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
    
    self.date = dic[@"date"];
    self.caloriesIdle = [dic[@"caloriesIdle"] integerValue];
    
    if (![dic[@"summary"] isKindOfClass:[NSArray class]]) {
        return self;
    }
    
    NSMutableArray *summaries = [[NSMutableArray alloc] init];
    for (NSDictionary *summary in dic[@"summary"]) {
        [summaries addObject:[[MVSummary alloc] initWithDictionary:summary]];
    }
    self.summaries = summaries;
    
    return self;
}

@end
