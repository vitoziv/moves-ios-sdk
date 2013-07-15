//
//  MVTrackPoints.m
//  Move-iOS-SDK
//
//  Created by Vito on 13-7-11.
//  Copyright (c) 2013年 vito. All rights reserved.
//

#import "MVTrackPoint.h"

@implementation MVTrackPoint

- (id)init {
    if (self = [super init]) {
    }
    
    return self;
}

- (MVTrackPoint *)initWithDictionary:(NSDictionary *)dic {
    self = [super init];
    
    self.lat = [dic[@"lat"] floatValue];
    self.lon = [dic[@"lon"] floatValue];
    self.time = [dic[@"time"] doubleValue];
    
    return self;
}


@end
