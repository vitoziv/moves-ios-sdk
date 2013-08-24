//
//  MVDailyPlace.m
//  Move-iOS-SDK
//
//  Created by Vito on 13-7-14.
//  Copyright (c) 2013年 vito. All rights reserved.
//

#import "MVDailyPlace.h"

@implementation MVDailyPlace

- (id)init {
    if (self = [super init]) {
    }
    return self;
}

- (MVDailyPlace *)initWithDictionary:(NSDictionary *)dic {
    self = [super init];
    
    self.date = dic[@"date"];
    
    if ([dic[@"segments"] isKindOfClass:[NSArray class]]) {
        NSMutableArray *segments = [[NSMutableArray alloc] init];
        for (NSDictionary *segment in dic[@"segments"]) {
            [segments addObject:[[MVSegment alloc] initWithDictionary:segment]];
        }
        self.segments = segments;
    }
    
    return self;
}

@end
