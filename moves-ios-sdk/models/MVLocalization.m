//
//  MVLocalization.m
//  MovesSDKDemo
//
//  Created by Vito on 2/8/14.
//  Copyright (c) 2014 vito. All rights reserved.
//

#import "MVLocalization.h"

@implementation MVLocalization

- (instancetype)initWithDictionary:(NSDictionary *)dic {
    self = [super init];
    if (self) {
        _language = dic[@"language"];
        _locale = dic[@"locale"];
        if (!isNull(dic[@"firstWeekDay"])) {
            _firstWeekDay = [dic[@"firstWeekDay"] integerValue];
        } else {
            _firstWeekDay = MVFirstWeekDayTypeNone;
        }
        if (!isNull(dic[@"metric"])) {
            _metric = [dic[@"metric"] boolValue];
        }
    }
    
    return self;
}

@end
