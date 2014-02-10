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
    
    if (self) {
        if (dic[@"lat"]) {
            _lat = [dic[@"lat"] floatValue];
        }
        if (dic[@"lon"]) {
            _lon = [dic[@"lon"] floatValue];
        }
        if (dic[@"time"]) {
            NSDateFormatter *formatter = [[DFDateFormatterFactory sharedFactory] dateFormatterWithFormat:@"yyyyMMdd'T'HHmmssZ"];
            _time = [formatter dateFromString:dic[@"time"]];
        }
    }
    
    return self;
}


@end
