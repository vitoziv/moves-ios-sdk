//
//  MVSegment.m
//  Move-iOS-SDK
//
//  Created by Vito on 13-7-11.
//  Copyright (c) 2013年 vito. All rights reserved.
//

#import "MVSegment.h"
#import "DFDateFormatterFactory.h"

@implementation MVSegment

- (MVSegment *)initWithDictionary:(NSDictionary *)dic {
    self = [super init];
    
    if (self && !isNull(dic)) {
        _type = dic[@"type"];
        
        NSDateFormatter *formatter = [[DFDateFormatterFactory sharedFactory] dateFormatterWithFormat:@"yyyyMMdd'T'HHmmssZ"];
        if (dic[@"startTime"] && !isNull(dic[@"startTime"])) {
            _startTime = [formatter dateFromString:dic[@"startTime"]];
        }
        if (dic[@"endTime"] && !isNull(dic[@"endTime"])) {
            _endTime = [formatter dateFromString:dic[@"endTime"]];
        }
        if (dic[@"place"] && !isNull(dic[@"place"])) {
            _place = [[MVPlace alloc] initWithDictionary:dic[@"place"]];
        }
        
        if ([dic[@"activities"] isKindOfClass:[NSArray class]]) {
            NSMutableArray *activities = [[NSMutableArray alloc] init];
            for (NSDictionary *activity in dic[@"activities"]) {
                [activities addObject:[[MVActivity alloc] initWithDictionary:activity]];
            }
            _activities = activities;
        }
        
        if (dic[@"lastUpdate"] && !isNull(dic[@"lastUpdate"])) {
            _lastUpdate = [formatter dateFromString:dic[@"lastUpdate"]];
        }
    }
    
    return self;
}

@end
