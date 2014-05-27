//
//  MVSummary.m
//  Move-iOS-SDK
//
//  Created by Vito on 13-7-11.
//  Copyright (c) 2013年 vito. All rights reserved.
//

#import "MVSummary.h"

@implementation MVSummary

- (MVSummary *)initWithDictionary:(NSDictionary *)dic {
    self = [super init];
    
    if (self && [dic isKindOfClass:[NSDictionary class]]) {
        if (!isNull(dic[@"duration"])) {
            _duration = [dic[@"duration"] integerValue];
        }
        if (!isNull(dic[@"distance"])) {
            _distance = [dic[@"distance"] integerValue];
        }
        if (!isNull(dic[@"steps"])) {
            _steps = [dic[@"steps"] integerValue];
        }
        if (!isNull(dic[@"calories"])) {
            _calories = [dic[@"calories"] integerValue];
        }
        
        _activity = dic[@"activity"];
        _group = dic[@"group"];
    }
    
    return self;
}

@end
