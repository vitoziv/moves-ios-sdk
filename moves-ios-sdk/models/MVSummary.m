//
//  MVSummary.m
//  Move-iOS-SDK
//
//  Created by Vito on 13-7-11.
//  Copyright (c) 2013年 vito. All rights reserved.
//

#import "MVSummary.h"
#import "MVJsonValueParser.h"

@implementation MVSummary

- (MVSummary *)initWithDictionary:(NSDictionary *)dic {
    self = [super init];
    
    if (self && [dic isKindOfClass:[NSDictionary class]]) {
        if (dic[@"duration"]) {
            _duration = [MVJsonValueParser integerValueFromObject:dic[@"duration"]];
        }
        if (dic[@"distance"]) {
            _distance = [MVJsonValueParser integerValueFromObject:dic[@"distance"]];
        }
        if (dic[@"steps"]) {
            _steps = [MVJsonValueParser integerValueFromObject:dic[@"steps"]];
        }
        if (dic[@"calories"]) {
            _calories = [MVJsonValueParser integerValueFromObject:dic[@"calories"]];
        }
        if (dic[@"activity"]) {
            _activity = [MVJsonValueParser stringValueFromObject:dic[@"activity"]];
        }
        if (dic[@"group"]) {
            _group = [MVJsonValueParser stringValueFromObject:dic[@"group"]];
        }
    }
    
    return self;
}

@end
