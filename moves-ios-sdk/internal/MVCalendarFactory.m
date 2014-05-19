//
//  MVCalendarFactory.m
//  MovesSDKDemo
//
//  Created by Vito on 5/19/14.
//  Copyright (c) 2014 vito. All rights reserved.
//

#import "MVCalendarFactory.h"
#import "MVLightCache.h"

static NSString *const MVCalendarCachePrefix = @"MVCalendarCachePrefix-";

@implementation MVCalendarFactory

+ (NSCalendar *)calendarWithIdentifier:(NSString *)identifier
{
    NSString *key = [NSString stringWithFormat:@"%@%@", MVCalendarCachePrefix, identifier];
    NSCalendar *calendar = [[MVLightCache sharedInstance] objectForKey:key];
    
    if (!calendar) {
        calendar = [[NSCalendar alloc] initWithCalendarIdentifier:identifier];
        [[MVLightCache sharedInstance] setObject:calendar forKey:key];
    }
    
    return calendar;
}

@end
