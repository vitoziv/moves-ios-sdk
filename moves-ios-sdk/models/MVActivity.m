//
//  MVActivity.m
//  Move-iOS-SDK
//
//  Created by Vito on 13-7-11.
//  Copyright (c) 2013年 vito. All rights reserved.
//

#import "MVActivity.h"
#import "DFDateFormatterFactory.h"
#import "MVJsonValueParser.h"

@implementation MVActivity

- (MVActivity *)initWithDictionary:(NSDictionary *)dic {
    self = [super initWithDictionary:dic];
    
    if (self && [dic isKindOfClass:[NSDictionary class]]) {
        
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
        _manual = [MVJsonValueParser boolValueFromObject:dic[@"manual"]];
        _trackPoints = [MVJsonValueParser arrayValueFromObject:dic[@"trackPoints"]
                                         withCreateObjectBlock:^MVBaseDataModel *(NSDictionary *dic) {
                                             return [[MVTrackPoint alloc] initWithDictionary:dic];
                                         }];

    }
    
    return self;
}

@end
