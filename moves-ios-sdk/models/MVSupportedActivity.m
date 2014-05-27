//
//  MVSupportedActivity.m
//  MovesSDKDemo
//
//  Created by Vito on 2/10/14.
//  Copyright (c) 2014 vito. All rights reserved.
//

#import "MVSupportedActivity.h"

@implementation MVSupportedActivity

- (instancetype)initWithDictionary:(NSDictionary *)dic {
    self = [super initWithDictionary:dic];
    if (self && [dic isKindOfClass:[NSDictionary class]]) {
        _activity = dic[@"activity"];
        if (!isNull(dic[@"geo"])) {
            _geo = [dic[@"geo"] boolValue];
        }
        
        if (!isNull(dic[@"place"])) {
            _place = [dic[@"place"] boolValue];
        }
        if (!isNull(dic[@"color"])) {
            _color = [dic[@"color"] stringValue];
        }
        if (!isNull(dic[@"units"])) {
            _units = [dic[@"units"] stringValue];
        }
    }
    
    return self;
}

@end
