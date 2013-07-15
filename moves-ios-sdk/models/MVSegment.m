//
//  MVSegment.m
//  Move-iOS-SDK
//
//  Created by Vito on 13-7-11.
//  Copyright (c) 2013年 vito. All rights reserved.
//

#import "MVSegment.h"

@implementation MVSegment

- (id)init {
    if (self = [super init]) {
    }
    
    return self;
}

- (MVSegment *)initWithDictionary:(NSDictionary *)dic {
    self = [super init];
    
    if ([dic[@"type"] isEqual:@"move"]) {
        self.type = MVSegmentTypeMove;
    } else {
        self.type = MVSegmentTypePlace;
    }
    
    self.startTime = dic[@"startTime"];
    self.endTime = dic[@"endTime"];
    self.place = [[MVPlace alloc] initWithDictionary:dic[@"place"]];
    
    if (![dic[@"activities"] isKindOfClass:[NSArray class]]) {
        return self;
    }
    NSMutableArray *activities = [[NSMutableArray alloc] init];
    for (NSDictionary *activity in dic[@"activities"]) {
        [activities addObject:[[MVActivity alloc] initWithDictionary:activity]];
    }
    self.activities = activities;
    
    return self;
}

@end
