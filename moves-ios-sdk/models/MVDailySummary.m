//
//  MVDailySummary.m
//  Move-iOS-SDK
//
//  Created by Vito on 13-7-11.
//  Copyright (c) 2013年 vito. All rights reserved.
//

#import "MVDailySummary.h"
#import "MVSummary.h"
#import "DFDateFormatterFactory.h"
#import "MVJsonValueParser.h"

@implementation MVDailySummary

- (MVDailySummary *)initWithDictionary:(NSDictionary *)dic {
    self = [super init];
    
    if (self && [dic isKindOfClass:[NSDictionary class]]) {
        NSString *date = [MVJsonValueParser stringValueFromObject:dic[@"date"]];
        if (date) {
            NSDateFormatter *formatter = [[DFDateFormatterFactory sharedFactory] dateFormatterWithFormat:@"yyyyMMdd"];
            formatter.calendar = [MVCalendarFactory calendarWithIdentifier:NSGregorianCalendar];
            _date = [formatter dateFromString:date];
        }
        if (dic[@"caloriesIdle"]) {
            _caloriesIdle = [MVJsonValueParser integerValueFromObject:dic[@"caloriesIdle"]];
        }
        
        NSString *lastUpdate = [MVJsonValueParser stringValueFromObject:dic[@"lastUpdate"]];
        if (lastUpdate) {
            NSDateFormatter *formatter = [[DFDateFormatterFactory sharedFactory] dateFormatterWithFormat:@"yyyyMMdd'T'HHmmssZ"];
            formatter.calendar = [MVCalendarFactory calendarWithIdentifier:NSGregorianCalendar];
            _lastUpdate = [formatter dateFromString:lastUpdate];
        }
        
        _summaries = [MVJsonValueParser arrayValueFromObject:dic[@"summary"]
                                       withCreateObjectBlock:^MVBaseDataModel *(NSDictionary *dic) {
                                           return [[MVSummary alloc] initWithDictionary:dic];
                                       }];
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
