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

+ (void)validateProfileJson:(id)json success:(MVAVSuccessBlock)success failure:(MVAVFailureBlock)failure
{
    NSError *error;
    [MVRPJSONValidator validateValuesFrom:json
                         withRequirements:[self profileJsonRequirements]
                                    error:&error];
    
    if (!error) {
        NSDictionary *localization = json[@"profile"][@"localization"];
        if (localization) {
            [MVRPJSONValidator validateValuesFrom:localization
                                 withRequirements:[self profileLocalizationJsonRequirements]
                                            error:&error];
        }
    }
    
    
    if (error){
        if (failure) { failure(error); }
    } else {
        if (success) { success(); };
    }
}

+ (void)validateActivityListJson:(id)json success:(MVAVSuccessBlock)success failure:(MVAVFailureBlock)failure
{
    __block NSError *error;
    if ([json isKindOfClass:[NSArray class]]) {
        [json enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [MVRPJSONValidator validateValuesFrom:obj
                                 withRequirements:[self activityListJsonRequirements]
                                            error:&error];
            
            if (error) {
                *stop = YES;
            }
        }];
    }
    
    if (error){
        if (failure) { failure(error); }
    } else {
        if (success) { success(); };
    }
}

+ (void)validateSummariesJson:(id)json success:(MVAVSuccessBlock)success failure:(MVAVFailureBlock)failure
{
    __block NSError *error;
    if ([json isKindOfClass:[NSArray class]]) {
        [json enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [MVRPJSONValidator validateValuesFrom:obj
                                 withRequirements:[self summariesJsonRequirementsWithError:&error]
                                            error:&error];
            
            if (error) {
                *stop = YES;
            }
        }];
    }
    
    if (error){
        if (failure) { failure(error); }
    } else {
        if (success) { success(); };
    }
}

+ (void)validateActivitiesJson:(id)json success:(MVAVSuccessBlock)success failure:(MVAVFailureBlock)failure
{
    __block NSError *error;
    if ([json isKindOfClass:[NSArray class]]) {
        [json enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [MVRPJSONValidator validateValuesFrom:obj
                                 withRequirements:[self activitiesJsonRequirementsWithError:&error]
                                            error:&error];
            
            if (error) {
                *stop = YES;
            }
        }];
    }
    
    if (error){
        if (failure) { failure(error); }
    } else {
        if (success) { success(); };
    }
}

+ (void)validatePlacesJson:(id)json success:(MVAVSuccessBlock)success failure:(MVAVFailureBlock)failure
{
    __block NSError *error;
    if ([json isKindOfClass:[NSArray class]]) {
        [json enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [MVRPJSONValidator validateValuesFrom:obj
                                 withRequirements:[self placesJsonRequirementsWithError:&error]
                                            error:&error];
            
            if (error) {
                *stop = YES;
            }
        }];
    }
    
    if (error){
        if (failure) { failure(error); }
    } else {
        if (success) { success(); };
    }
}

+ (void)validateStorylineJson:(id)json success:(MVAVSuccessBlock)success failure:(MVAVFailureBlock)failure
{
    __block NSError *error;
    if ([json isKindOfClass:[NSArray class]]) {
        [json enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [MVRPJSONValidator validateValuesFrom:obj
                                 withRequirements:[self storylineJsonRequirementsWithError:&error]
                                            error:&error];
            
            if (error) {
                *stop = YES;
            }
        }];
    }
    
    if (error){
        if (failure) { failure(error); }
    } else {
        if (success) { success(); };
    }
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

+ (BOOL)validateActivityArrayJson:(id)jsonValue error:(NSError **)error
{
    if ((NSNull *)jsonValue == [NSNull null]) {
        return YES;
    } else if ([jsonValue isKindOfClass:[NSArray class]]) {
        [jsonValue enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [MVRPJSONValidator validateValuesFrom:obj
                                 withRequirements:[self activityJsonRequirements]
                                            error:error];
            if (*error) {
                *stop = YES;
            } else {
                NSArray *trackPoints = obj[@"trackPoints"];
                if ([trackPoints isKindOfClass:[NSArray class]]) {
                    [trackPoints enumerateObjectsUsingBlock:^(id trackPoint, NSUInteger idx, BOOL *stop) {
                        [MVRPJSONValidator validateValuesFrom:trackPoint
                                             withRequirements:[self trackPointsJsonRequirements]
                                                        error:error];
                        if (*error) { *stop = YES; }
                    }];
                    // Outer stop
                    if (*error) { *stop = YES; }
                }
            }
        }];
        
        return *error ? NO : YES;
    }
    
    return NO;
}

+ (BOOL)validateSegmentArrayJson:(id)jsonValue error:(NSError **)error
{
    if ((NSNull *)jsonValue == [NSNull null]) {
        return YES;
    } else if ([jsonValue isKindOfClass:[NSArray class]]) {
        [jsonValue enumerateObjectsUsingBlock:^(id segment, NSUInteger idx, BOOL *stop) {
            [MVRPJSONValidator validateValuesFrom:segment
                                 withRequirements:[self segmentJsonRequirements]
                                            error:error];
            if (*error) {
                *stop = YES;
            } else {
                NSDictionary *place = segment[@"place"];
                if (place) {
                    [MVRPJSONValidator validateValuesFrom:place
                                         withRequirements:[self placeJsonRequirements]
                                                    error:error];
                    if (*error) { *stop = YES; }
                }
                
                NSArray *activities = segment[@"activities"];
                if ([activities isKindOfClass:[NSArray class]]) {
                    [activities enumerateObjectsUsingBlock:^(id activity, NSUInteger idx, BOOL *stop) {
                        [MVRPJSONValidator validateValuesFrom:activity
                                             withRequirements:[self activityJsonRequirements]
                                                        error:error];
                        if (*error) { *stop = YES; }
                    }];
                    // Outer stop
                    if (*error) { *stop = YES; }
                }
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

+ (NSDictionary *)activityListJsonRequirements
{
    return @{
             @"activity": MVRPValidatorPredicate.isString,
             @"group": MVRPValidatorPredicate.isString.isOptional,
             @"geo": MVRPValidatorPredicate.isNumber,
             @"place": MVRPValidatorPredicate.isNumber,
             @"color": MVRPValidatorPredicate.isString,
             @"units": MVRPValidatorPredicate.isString
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

+ (NSDictionary *)activitiesJsonRequirementsWithError:(NSError **)error
{
    return @{
             @"date": MVRPValidatorPredicate.isString,
             @"summary": [MVRPValidatorPredicate validateValueWithBlock:^BOOL(NSString *jsonKey, id jsonValue) {
                 return [self validateSummaryArrayJson:jsonValue error:error];
             }],
             @"segments": [MVRPValidatorPredicate validateValueWithBlock:^BOOL(NSString *jsonKey, id jsonValue) {
                 return [self validateSegmentArrayJson:jsonValue error:error];
             }],
             @"caloriesIdle": MVRPValidatorPredicate.isNumber.isOptional,
             @"lastUpdate": MVRPValidatorPredicate.isString.isOptional
             };
}

+ (NSDictionary *)placesJsonRequirementsWithError:(NSError **)error
{
    return @{
             @"date": MVRPValidatorPredicate.isString,
             @"segments": [MVRPValidatorPredicate validateValueWithBlock:^BOOL(NSString *jsonKey, id jsonValue) {
                 return [self validateSegmentArrayJson:jsonValue error:error];
             }],
             @"lastUpdate": MVRPValidatorPredicate.isString.isOptional
             };
}

+ (NSDictionary *)storylineJsonRequirementsWithError:(NSError **)error
{
    return @{
             @"date": MVRPValidatorPredicate.isString,
             @"summary": [MVRPValidatorPredicate validateValueWithBlock:^BOOL(NSString *jsonKey, id jsonValue) {
                 return [self validateSummaryArrayJson:jsonValue error:error];
             }],
             @"segments": [MVRPValidatorPredicate validateValueWithBlock:^BOOL(NSString *jsonKey, id jsonValue) {
                 return [self validateSegmentArrayJson:jsonValue error:error];
             }],
             @"caloriesIdle": MVRPValidatorPredicate.isNumber.isOptional,
             @"lastUpdate": MVRPValidatorPredicate.isString.isOptional
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

+ (NSDictionary *)segmentJsonRequirements
{
    return @{
             @"type": MVRPValidatorPredicate.isString,
             @"startTime": MVRPValidatorPredicate.isString,
             @"endTime": MVRPValidatorPredicate.isString,
             @"place": MVRPValidatorPredicate.isDictionary.isOptional,
             @"activities": MVRPValidatorPredicate.isArray.isOptional,
             @"lastUpdate": MVRPValidatorPredicate.isString.isOptional
             };
}

+ (NSDictionary *)placeJsonRequirements
{
    return @{
             @"id": MVRPValidatorPredicate.isNumber.isOptional,
             @"name": MVRPValidatorPredicate.isString.isOptional,
             @"type": MVRPValidatorPredicate.isString,
             @"foursquareId": MVRPValidatorPredicate.isString.isOptional,
             @"foursquareCategoryIds": MVRPValidatorPredicate.isArray.isOptional,
             @"location": @{
                     @"lat": MVRPValidatorPredicate.isNumber,
                     @"lon": MVRPValidatorPredicate.isNumber
                     }
             };
}

+ (NSDictionary *)activityJsonRequirements
{
    return @{
             @"activity": MVRPValidatorPredicate.isString,
             @"group": MVRPValidatorPredicate.isString.isOptional,
             @"manual": MVRPValidatorPredicate.isNumber,
             @"startTime": MVRPValidatorPredicate.isString.isOptional,
             @"endTime": MVRPValidatorPredicate.isString.isOptional,
             @"duration": MVRPValidatorPredicate.isNumber,
             @"distance": MVRPValidatorPredicate.isNumber.isOptional,
             @"steps": MVRPValidatorPredicate.isNumber.isOptional,
             @"calories": MVRPValidatorPredicate.isNumber.isOptional,
             @"trackPoints": MVRPValidatorPredicate.isArray.isOptional
             };
}

+ (NSDictionary *)trackPointsJsonRequirements
{
    return @{
             @"lat": MVRPValidatorPredicate.isNumber,
             @"lon": MVRPValidatorPredicate.isNumber,
             @"time": MVRPValidatorPredicate.isString
             };
}

@end
