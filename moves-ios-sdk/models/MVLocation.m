//
//  MVLocation.m
//  Move-iOS-SDK
//
//  Created by Vito on 13-7-11.
//  Copyright (c) 2013年 vito. All rights reserved.
//

#import "MVLocation.h"

@implementation MVLocation

- (id)init {
    if (self = [super init]) {
    }
    return self;
}

- (MVLocation *)initWithDictionary:(NSDictionary *)dic {
    self = [super init];
    
    self.lat = [dic[@"lat"] floatValue];
    self.lon = [dic[@"lon"] floatValue];
    
    return self;
}


@end
