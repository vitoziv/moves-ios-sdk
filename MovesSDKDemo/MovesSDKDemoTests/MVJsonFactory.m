//
//  MVJsonFactory.m
//  MovesSDKDemo
//
//  Created by Vito on 5/18/14.
//  Copyright (c) 2014 vito. All rights reserved.
//

#import "MVJsonFactory.h"

@implementation MVJsonFactory

+ (NSDictionary *)profileJson
{
    return @{
             @"profile" :@{
                     @"caloriesAvailable" : @1,
                     @"currentTimeZone" : @{
                             @"id" : @"Asia/Shanghai",
                             @"offset": @28800
                             },
                     @"firstDate" : @20130922,
                     @"localization" :         @{
                             @"firstWeekDay" : @1,
                             @"language": @"zh-Hans",
                             @"locale": @"zh_CN",
                             @"metric": @1
                             },
                     @"platform" : @"ios"
                     },
             @"userId": @20933782050890778
             };
}

+ (NSDictionary *)summariesJson
{
    return @{
             @"caloriesIdle" : [NSNull null],
             @"date" : [NSNull null],
             @"lastUpdate" : [NSNull null],
             @"summary" :
                 @[
                     [self summaryJson]
                     ]
             
             };
}

+ (NSDictionary *)activitiesJson
{
    return @{
             @"date": @"20121212",
             @"summary": @[
                     [self summaryJson]
                     ],
             @"segments": @[
                     [self segmentJson]
                     ],
             @"caloriesIdle": @1785,
             @"lastUpdate": @"20130317T121143Z"
             };
}

+ (NSDictionary *)placesJson
{
    return @{
        @"date": @"20121212",
        @"segments": @[
                     @{
                         @"type": @"place",
                         @"startTime": @"20121212T100715+0200",
                         @"endTime": @"20121212T110530+0200",
                         @"place": [self placeJson],
                         @"lastUpdate": @"20130317T121143Z"
                     }
                     ],
        @"lastUpdate": @"20130317T121143Z"
        };
}

+ (NSDictionary *)storylineJson
{
    return @{
             @"date": @"20121212",
             @"summary": [self summaryJson],
             @"segments": [self segmentJson],
             @"caloriesIdle": @1785,
             @"lastUpdate": @"20130317T121143Z"
             };
}

+ (NSDictionary *)activityListJson
{
    return @{
             @"activity": @"aerobics",
             @"group": @"transport",
             @"geo": @NO,
             @"place": @YES,
             @"color": @"bc4fff",
             @"units": @"duration,calories"
             };
}

#pragma mark - Private

+ (NSDictionary *)summaryJson
{
    return @{
             @"activity" : [NSNull null],
             @"calories" : [NSNull null],
             @"distance" : [NSNull null],
             @"duration" : [NSNull null],
             @"group" : [NSNull null],
             @"steps" : [NSNull null],
             };
}

+ (NSDictionary *)placeJson
{
    return @{
             @"id": @4,
             @"name": @"test",
             @"type": @"foursquare",
             @"foursquareId": @"4df0fdb17d8ba370a011d24c",
             @"foursquareCategoryIds": @[@"4bf58dd8d48988d125941735"],
             @"location": @{
                     @"lat": @55.55555,
                     @"lon": @33.33333
                     }
             };
}

+ (NSDictionary *)activityJson
{
    return @{
             @"activity": @"walking",
             @"group": @"walking",
             @"manual": @NO,
             @"startTime": @"20121212T071430+0200",
             @"endTime": @"20121212T072732+0200",
             @"duration": @782,
             @"distance": @1251,
             @"steps": @1353,
             @"calories": @99,
             @"trackPoints": @[
                     @{
                         @"lat": @55.55555,
                         @"lon": @33.33333,
                         @"time": @"20121212T071430+0200"
                         }
                     ]
             };
}

+ (NSDictionary *)segmentJson
{
    return @{
             @"type": @"move",
             @"startTime": @"20121212T071430+0200",
             @"endTime": @"20121212T074617+0200",
             @"place": [self placeJson],
             @"activities": @[
                     [self activityJson]
                     ],
             @"lastUpdate": @"20130317T121143Z"
             };
}

@end
