//
//  MVStoryLine.m
//  Move-iOS-SDK
//
//  Created by Vito on 13-7-14.
//  Copyright (c) 2013年 vito. All rights reserved.
//

#import "MVStoryLine.h"
#import "DFDateFormatterFactory.h"
#import "MVJsonValueParser.h"

@implementation MVStoryLine

- (MVStoryLine *)initWithDictionary:(NSDictionary *)dic {
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
        
        _segments = [MVJsonValueParser arrayValueFromObject:dic[@"segments"]
                                      withCreateObjectBlock:^MVBaseDataModel *(NSDictionary *dic) {
                                          return [[MVSegment alloc] initWithDictionary:dic];
                                      }];
        _summaries = [MVJsonValueParser arrayValueFromObject:dic[@"summary"]
                                       withCreateObjectBlock:^MVBaseDataModel *(NSDictionary *dic) {
                                           return [[MVSummary alloc] initWithDictionary:dic];
                                       }];
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
