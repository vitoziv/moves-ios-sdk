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
    if (self) {
        _activity = dic[@"activity"];
        _geo = [dic[@"geo"] boolValue];
        _place = [dic[@"place"] boolValue];
        _color = dic[@"color"];
        _units = dic[@"units"];
    }
    
    return self;
}

@end
