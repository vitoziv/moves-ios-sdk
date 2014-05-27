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
    if (self && [dic isKindOfClass:[NSDictionary class]]) {
        if (!isNull(dic[@"language"])) {
            _language = [dic[@"language"] stringValue];
        }
        if (!isNull(dic[@"locale"])) {
            _locale = [dic[@"locale"] stringValue];
        }
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
