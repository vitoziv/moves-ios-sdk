//
//  MVDailyPlace.m
//  Move-iOS-SDK
//
//  Created by Vito on 13-7-14.
//  Copyright (c) 2013年 vito. All rights reserved.
//

#import "MVDailyPlace.h"
#import "DFDateFormatterFactory.h"

@implementation MVDailyPlace

- (id)init {
    if (self = [super init]) {
    }
    return self;
}

- (MVDailyPlace *)initWithDictionary:(NSDictionary *)dic {
    self = [super init];
    
    if (dic[@"date"]) {NSDateFormatter *formatter = [[DFDateFormatterFactory sharedFactory] dateFormatterWithFormat:@"yyyyMMdd"];
        self.date = [formatter dateFromString:dic[@"date"]];
    }
    
    if ([dic[@"segments"] isKindOfClass:[NSArray class]]) {
        NSMutableArray *segments = [[NSMutableArray alloc] init];
        for (NSDictionary *segment in dic[@"segments"]) {
            [segments addObject:[[MVSegment alloc] initWithDictionary:segment]];
        }
        if (segments.count > 0) {
            self.segments = segments;
        }
    }
    
    return self;
}

@end
