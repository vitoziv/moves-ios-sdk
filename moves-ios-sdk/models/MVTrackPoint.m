//
//  MVTrackPoints.m
//  Move-iOS-SDK
//
//  Created by Vito on 13-7-11.
//  Copyright (c) 2013年 vito. All rights reserved.
//

#import "MVTrackPoint.h"
#import "DFDateFormatterFactory.h"

@implementation MVTrackPoint

- (MVTrackPoint *)initWithDictionary:(NSDictionary *)dic {
    self = [super init];
    
    if (self && [dic isKindOfClass:[NSDictionary class]]) {
        if (dic[@"lat"] && !isNull(dic[@"lat"])) {
            _lat = [dic[@"lat"] floatValue];
        }
        if (dic[@"lon"] && !isNull(dic[@"lon"])) {
            _lon = [dic[@"lon"] floatValue];
        }
        if (dic[@"time"] && !isNull(dic[@"time"])) {
            NSDateFormatter *formatter = [[DFDateFormatterFactory sharedFactory] dateFormatterWithFormat:@"yyyyMMdd'T'HHmmssZ"];
            formatter.calendar = [MVCalendarFactory calendarWithIdentifier:NSGregorianCalendar];
            _time = [formatter dateFromString:dic[@"time"]];
        }
    }
    
    return self;
}


@end
