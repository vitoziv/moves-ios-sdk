//
//  MVLocation.m
//  Move-iOS-SDK
//
//  Created by Vito on 13-7-11.
//  Copyright (c) 2013年 vito. All rights reserved.
//

#import "MVLocation.h"
#import "MVJsonValueParser.h"

@implementation MVLocation

- (MVLocation *)initWithDictionary:(NSDictionary *)dic {
    self = [super init];
    
    if (self && [dic isKindOfClass:[NSDictionary class]]) {
        if (dic[@"lat"]) {
            _lat = [MVJsonValueParser floatValueFromObject:dic[@"lat"]];
        }
        
        if (dic[@"lon"]) {
            _lon = [MVJsonValueParser floatValueFromObject:dic[@"lon"]];
        }
    }
    
    return self;
}


@end
