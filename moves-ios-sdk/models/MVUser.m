//
//  MVUser.m
//  Move-iOS-SDK
//
//  Created by Vito on 13-7-11.
//  Copyright (c) 2013年 vito. All rights reserved.
//

#import "MVUser.h"
#import "DFDateFormatterFactory.h"
#import "MVJsonValueParser.h"

@implementation MVUser

- (MVUser *)initWithDictionary:(NSDictionary *)dic {
    self = [super init];
    
    if (self && [dic isKindOfClass:[NSDictionary class]]) {
        _userId = [MVJsonValueParser stringValueFromObject:dic[@"userId"]];
        NSDictionary *profile = dic[@"profile"];
        if ([profile isKindOfClass:[NSDictionary class]]) {
            NSString *firstDate = [MVJsonValueParser stringValueFromObject:profile[@"firstDate"]];
            if (firstDate) {
                NSDateFormatter *formatter = [[DFDateFormatterFactory sharedFactory] dateFormatterWithFormat:@"yyyyMMdd"];
                formatter.calendar = [MVCalendarFactory calendarWithIdentifier:NSGregorianCalendar];
                _firstDate = [formatter dateFromString:firstDate];
            }
            
            NSDictionary *currentTimeZone = profile[@"currentTimeZone"];
            if ([currentTimeZone isKindOfClass:[NSDictionary class]]) {
                _currentTimeZoneId = [MVJsonValueParser stringValueFromObject:currentTimeZone[@"id"]];
                _currentTimeZoneOffset = [MVJsonValueParser integerValueFromObject:currentTimeZone[@"offset"]];
            }
            if ([profile[@"localization"] isKindOfClass:[NSDictionary class]]) {
                _localization = [[MVLocalization alloc] initWithDictionary:profile[@"localization"]];
            }
            
            if (profile[@"caloriesAvailable"]) {
                _caloriesAvailable = [MVJsonValueParser boolValueFromObject:profile[@"caloriesAvailable"]];
            }
            
            _platform = [MVJsonValueParser stringValueFromObject:profile[@"platform"]];
        }
    }
    
    return self;
}

@end
