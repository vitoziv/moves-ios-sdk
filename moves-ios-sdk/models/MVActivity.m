//
//  MVActivity.m
//  Move-iOS-SDK
//
//  Created by Vito on 13-7-11.
//  Copyright (c) 2013年 vito. All rights reserved.
//

#import "MVActivity.h"
#import "DFDateFormatterFactory.h"

@implementation MVActivity

- (MVActivity *)initWithDictionary:(NSDictionary *)dic {
    self = [super initWithDictionary:dic];
    
    if (self && [dic isKindOfClass:[NSDictionary class]]) {
        
        NSDateFormatter *formatter = [[DFDateFormatterFactory sharedFactory] dateFormatterWithFormat:@"yyyyMMdd'T'HHmmssZ"];
        formatter.calendar = [MVCalendarFactory calendarWithIdentifier:NSGregorianCalendar];
        if (dic[@"startTime"] && !isNull(dic[@"startTime"])) {
            _startTime = [formatter dateFromString:dic[@"startTime"]];
        }
        if (dic[@"endTime"] && !isNull(dic[@"endTime"])) {
            _endTime = [formatter dateFromString:dic[@"endTime"]];
        }
        if (dic[@"manual"] && !isNull(dic[@"manual"])) {
            _manual = [dic[@"manual"] boolValue];
        }
        
        if ([dic[@"trackPoints"] isKindOfClass:[NSArray class]]) {
            NSMutableArray *trackPoints = [[NSMutableArray alloc] init];
            for (NSDictionary *trackPoint in dic[@"trackPoints"]) {
                [trackPoints addObject:[[MVTrackPoint alloc] initWithDictionary:trackPoint]];
            }
            if (trackPoints.count > 0) {
                _trackPoints = trackPoints;
            }
        }

    }
    
    return self;
}

@end
