//
//  MVSupportedActivity.m
//  MovesSDKDemo
//
//  Created by Vito on 2/10/14.
//  Copyright (c) 2014 vito. All rights reserved.
//

#import "MVSupportedActivity.h"
#import "MVJsonValueParser.h"

@implementation MVSupportedActivity

- (instancetype)initWithDictionary:(NSDictionary *)dic {
    self = [super initWithDictionary:dic];
    if (self && [dic isKindOfClass:[NSDictionary class]]) {
        _activity = [MVJsonValueParser stringValueFromObject:dic[@"activity"]];
        if (dic[@"geo"]) {
            _geo = [MVJsonValueParser boolValueFromObject:dic[@"geo"]];
        }
        
        if (dic[@"place"]) {
            _place = [MVJsonValueParser boolValueFromObject:dic[@"place"]];
        }
        if (dic[@"color"]) {
            _color = [MVJsonValueParser stringValueFromObject:dic[@"color"]];
        }
        if (dic[@"units"]) {
            _units = [MVJsonValueParser stringValueFromObject:dic[@"units"]];
        }
    }
    
    return self;
}

@end
