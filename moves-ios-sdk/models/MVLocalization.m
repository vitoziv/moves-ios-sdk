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
        if (dic[@"firstWeekDay"]) {
            _firstWeekDay = [dic[@"firstWeekDay"] integerValue];
        } else {
            _firstWeekDay = MVFirstWeekDayTypeNone;
        }
        _metric = [dic[@"metric"] boolValue];
    }
    
    return self;
}

@end
