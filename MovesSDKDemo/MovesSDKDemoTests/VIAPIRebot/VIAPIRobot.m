//
//  VIAPIRobot.m
//  MovesSDKDemo
//
//  Created by Vito on 5/16/14.
//  Copyright (c) 2014 vito. All rights reserved.
//

#import "VIAPIRobot.h"

@implementation VIAPIRobot

+ (void)requestUrl:(NSString *)url convertValueToObject:(id)obj forJsonFlower:(void(^)(NSArray *jsonFlower))flower {
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:url]];
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                               NSError *jsonError;
                               NSDictionary *result = [NSJSONSerialization JSONObjectWithData:data
                                                                                      options:0
                                                                                        error:&jsonError];
                               if (!jsonError) {
                                   NSArray *resultData = [self jsonFlowerWithJsonData:result deep:YES convertValueToObject:obj];
                                   resultData = [resultData arrayByAddingObject:obj];
                                   if (flower) {
                                       flower(resultData);
                                   }
                                   NSLog(@"%@", resultData);
                               } else {
                                   NSLog(@"JSON error: %@", jsonError);
                                   if (flower) {
                                       flower(nil);
                                   }
                               }
                               
                           }];
}

+ (NSArray *)jsonFlowerWithJsonData:(id)jsonData convertValueToObject:(id)obj {
    NSArray *flowers = [self jsonFlowerWithJsonData:jsonData deep:YES convertValueToObject:obj];
    return [flowers arrayByAddingObject:obj];
}

+ (NSArray *)jsonFlowerWithJsonData:(id)value deep:(BOOL)deep convertValueToObject:(id)obj {
    NSMutableArray *allResults = [NSMutableArray array];
    
    id result = [value mutableCopy];
    if ([value isKindOfClass:[NSDictionary class]]) {
        for (NSString *key in [(NSDictionary *)value allKeys]) {
            if (deep && ([result[key] isKindOfClass:[NSDictionary class]] || [result[key] isKindOfClass:[NSArray class]])) {
                NSArray *innerResult = [self jsonFlowerWithJsonData:result[key] deep:YES convertValueToObject:obj];
                for (NSInteger i = 0; i < innerResult.count; i++) {
                    
                    if (i == innerResult.count - 1) {
                        result[key] = innerResult[i];
                    } else {
                        NSMutableDictionary *deepResult = [result mutableCopy];
                        deepResult[key] = innerResult[i];
                        [allResults addObject:deepResult];
                    }
                }
                
                // Set dictionary to null
                NSMutableDictionary *nullResult = [result mutableCopy];
                nullResult[key] = obj;
                [allResults addObject:[[self jsonFlowerWithJsonData:nullResult deep:NO convertValueToObject:obj] lastObject]];
            } else {
                result[key] = obj;
            }
        }
    } else if ([value isKindOfClass:[NSArray class]]) {
        for (NSInteger i=0; i < [(NSArray *)value count]; i++) {
            if (deep && ([result[i] isKindOfClass:[NSDictionary class]] || [result[i] isKindOfClass:[NSArray class]])) {
                NSArray *innerResult = [self jsonFlowerWithJsonData:result[i] deep:YES convertValueToObject:obj];
                for (NSInteger j = 0; j < innerResult.count; j++) {
                    
                    if (j == innerResult.count - 1) {
                        result[i] = innerResult[j];
                    } else {
                        NSMutableArray *deepResult = [result mutableCopy];
                        deepResult[i] = innerResult[j];
                        [allResults addObject:deepResult];
                    }
                }
                
                // Set array values to null
                NSMutableArray *nullResult = [result mutableCopy];
                nullResult[i] = obj;
                [allResults addObject:[[self jsonFlowerWithJsonData:nullResult deep:NO convertValueToObject:obj] lastObject]];
            } else {
                result[i] = obj;
            }
        }
    }
    
    [allResults addObject:result];
    
    return [allResults copy];
}

@end
