//
//  MVLocalization.m
//  MovesSDKDemo
//
//  Created by Vito on 2/8/14.
//  Copyright (c) 2014 vito. All rights reserved.
//

#import "MVLocalization.h"
#import "MVJsonValueParser.h"

@implementation MVLocalization

- (instancetype)initWithDictionary:(NSDictionary *)dic {
    self = [super init];
    if (self && [dic isKindOfClass:[NSDictionary class]]) {
        if (dic[@"language"]) {
            _language = [MVJsonValueParser stringValueFromObject:dic[@"language"]];
        }
        if (dic[@"locale"]) {
            _locale = [MVJsonValueParser stringValueFromObject:dic[@"locale"]];
        }
        if (dic[@"firstWeekDay"] && !isNull(dic[@"firstWeekDay"])) {
            _firstWeekDay = [MVJsonValueParser integerValueFromObject:dic[@"firstWeekDay"]];
        } else {
            _firstWeekDay = MVFirstWeekDayTypeNone;
        }
        if (dic[@"metric"]) {
            _metric = [MVJsonValueParser boolValueFromObject:dic[@"metric"]];
        }
    }
    
    return self;
}

@end
