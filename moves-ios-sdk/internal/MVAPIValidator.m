//
//  MVAPIValidator.m
//  MovesSDKDemo
//
//  Created by Vito on 5/29/14.
//  Copyright (c) 2014 vito. All rights reserved.
//

#import "MVAPIValidator.h"
#import "MVRPJSONValidator.h"
#import "MVRPValidatorPredicate.h"

@implementation MVAPIValidator

+ (void)validateProfileJson:(id)json error:(NSError **)error
{
    [MVRPJSONValidator validateValuesFrom:json
                         withRequirements:[self profileJsonRequirements]
                                    error:error];
    
    if (!*error) {
        NSDictionary *localization = json[@"profile"][@"localization"];
        if (localization) {
            [MVRPJSONValidator validateValuesFrom:localization
                                 withRequirements:[self profileLocalizationJsonRequirements]
                                            error:error];
        }
    }
}

+ (void)validateSummariesJson:(id)json error:(NSError **)error
{
    if ([json isKindOfClass:[NSArray class]]) {
        [json enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [MVRPJSONValidator validateValuesFrom:obj
                                 withRequirements:[self summariesJsonRequirementsWithError:error]
                                            error:error];
            
            if (*error) {
                *stop = YES;
            }
        }];
    }
}

+ (void)validateActivitiesJson:(id)json error:(NSError **)error
{

}

+ (void)validatePlacesJson:(id)json error:(NSError **)error
{

}

+ (void)validateStorylineJson:(id)json error:(NSError **)error
{

}

+ (void)validateActivityListJson:(id)json error:(NSError **)error
{
    
}

#pragma mark - Private

+ (BOOL)validateSummaryArrayJson:(id)jsonValue error:(NSError **)error
{
    if ((NSNull *)jsonValue == [NSNull null]) {
        return YES;
    } else if ([jsonValue isKindOfClass:[NSArray class]]) {
        [jsonValue enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [MVRPJSONValidator validateValuesFrom:obj
                                 withRequirements:[self summaryJsonRequirements]
                                            error:error];
            if (*error) {
                *stop = YES;
            }
        }];
        
        return *error ? NO : YES;
    }
    
    return NO;
}

#pragma mark - Requiements

+ (NSDictionary *)profileJsonRequirements
{
    return @{
             @"profile" :@{
                     @"caloriesAvailable": MVRPValidatorPredicate.isNumber,
                     @"currentTimeZone": @{
                             @"id": MVRPValidatorPredicate.isString,
                             @"offset": MVRPValidatorPredicate.isNumber
                             },
                     @"firstDate": MVRPValidatorPredicate.isString,
                     @"localization": MVRPValidatorPredicate.isDictionary.isOptional,
                     @"platform" : MVRPValidatorPredicate.isString
                     },
             @"userId": MVRPValidatorPredicate.isNumber
             };
}

+ (NSDictionary *)profileLocalizationJsonRequirements
{
    return @{
             @"firstWeekDay": MVRPValidatorPredicate.isNumber.isOptional,
             @"language": MVRPValidatorPredicate.isString.isOptional,
             @"locale": MVRPValidatorPredicate.isString.isOptional,
             @"metric": MVRPValidatorPredicate.isNumber.isOptional
             };
}

+ (NSDictionary *)summariesJsonRequirementsWithError:(NSError **)error
{
    return @{
             @"date" : MVRPValidatorPredicate.isString,
             @"caloriesIdle" : MVRPValidatorPredicate.isNumber.isOptional,
             @"lastUpdate" : MVRPValidatorPredicate.isString.isOptional,
             @"summary" : [MVRPValidatorPredicate validateValueWithBlock:^BOOL(NSString *jsonKey, id jsonValue) {
                 return [self validateSummaryArrayJson:jsonValue error:error];
             }]
             };
}

#pragma mark Reuse

+ (NSDictionary *)summaryJsonRequirements
{
    return @{
             @"activity" : MVRPValidatorPredicate.isString,
             @"duration" : MVRPValidatorPredicate.isNumber,
             @"calories" : MVRPValidatorPredicate.isNumber.isOptional,
             @"distance" : MVRPValidatorPredicate.isNumber.isOptional,
             @"group" : MVRPValidatorPredicate.isString.isOptional,
             @"steps" : MVRPValidatorPredicate.isNumber.isOptional,
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
