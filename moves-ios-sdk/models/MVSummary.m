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
    
    if (self) {
        if (dic[@"duration"]) {
            _duration = [dic[@"duration"] integerValue];
        }
        if (dic[@"distance"]) {
            _distance = [dic[@"distance"] integerValue];
        }
        if (dic[@"steps"]) {
            _steps = [dic[@"steps"] integerValue];
        }
        if (dic[@"calories"]) {
            _calories = [dic[@"calories"] integerValue];
        }
        
        _activity = dic[@"activity"];
        _group = dic[@"group"];
    }
    
    return self;
}

@end
