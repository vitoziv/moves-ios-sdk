//
//  MVDailyPlace.m
//  Move-iOS-SDK
//
//  Created by Vito on 13-7-14.
//  Copyright (c) 2013年 vito. All rights reserved.
//

#import "MVDailyPlace.h"
#import "DFDateFormatterFactory.h"
#import "MVJsonValueParser.h"

@implementation MVDailyPlace

- (MVDailyPlace *)initWithDictionary:(NSDictionary *)dic {
    self = [super init];
    if (self && [dic isKindOfClass:[NSDictionary class]]) {
        if (dic[@"date"]) {
            NSDateFormatter *formatter = [[DFDateFormatterFactory sharedFactory] dateFormatterWithFormat:@"yyyyMMdd"];
            formatter.calendar = [MVCalendarFactory calendarWithIdentifier:NSGregorianCalendar];;
            NSString *dateString = [MVJsonValueParser stringValueFromObject:dic[@"date"]];
            if (dateString) {
                _date = [formatter dateFromString:dateString];
            }
        }
        
        _segments = [MVJsonValueParser arrayValueFromObject:dic[@"segments"]
                                      withCreateObjectBlock:^MVBaseDataModel *(NSDictionary *dic) {
                                          return [[MVSegment alloc] initWithDictionary:dic];
                                      }];
        
        if (dic[@"lastUpdate"]) {
            NSDateFormatter *formatter = [[DFDateFormatterFactory sharedFactory] dateFormatterWithFormat:@"yyyyMMdd'T'HHmmssZ"];
            formatter.calendar = [MVCalendarFactory calendarWithIdentifier:NSGregorianCalendar];
            NSString *dateString = [MVJsonValueParser stringValueFromObject:dic[@"lastUpdate"]];
            if (dateString) {
                _lastUpdate = [formatter dateFromString:dateString];
            }
        }
    }
    
    return self;
}

@end
