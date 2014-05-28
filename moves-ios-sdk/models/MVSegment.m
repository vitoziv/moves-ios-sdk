//
//  MVSegment.m
//  Move-iOS-SDK
//
//  Created by Vito on 13-7-11.
//  Copyright (c) 2013年 vito. All rights reserved.
//

#import "MVSegment.h"
#import "DFDateFormatterFactory.h"
#import "MVJsonValueParser.h"

@implementation MVSegment

- (MVSegment *)initWithDictionary:(NSDictionary *)dic {
    self = [super init];
    
    if (self && [dic isKindOfClass:[NSDictionary class]]) {
        _type = [MVJsonValueParser stringValueFromObject:dic[@"type"]];
        
        NSDateFormatter *formatter = [[DFDateFormatterFactory sharedFactory] dateFormatterWithFormat:@"yyyyMMdd'T'HHmmssZ"];
        formatter.calendar = [MVCalendarFactory calendarWithIdentifier:NSGregorianCalendar];
        NSString *startTime = [MVJsonValueParser stringValueFromObject:dic[@"startTime"]];
        if (startTime) {
            _startTime = [formatter dateFromString:startTime];
        }
        
        NSString *endTime = [MVJsonValueParser stringValueFromObject:dic[@"endTime"]];
        if (endTime) {
            _endTime = [formatter dateFromString:endTime];
        }
        
        if ([dic[@"place"] isKindOfClass:[NSDictionary class]]) {
            _place = [[MVPlace alloc] initWithDictionary:dic[@"place"]];
        }
        
        _activities = [MVJsonValueParser arrayValueFromObject:dic[@"activities"]
                                        withCreateObjectBlock:^MVBaseDataModel *(NSDictionary *dic) {
                                            return [[MVActivity alloc] initWithDictionary:dic];
                                        }];
        
        NSString *lastUpdate = [MVJsonValueParser stringValueFromObject:dic[@"lastUpdate"]];
        if (lastUpdate) {
            _lastUpdate = [formatter dateFromString:lastUpdate];
        }
    }
    
    return self;
}

@end
