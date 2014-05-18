//
//  VIAPIRebot.m
//  MovesSDKDemo
//
//  Created by Vito on 5/16/14.
//  Copyright (c) 2014 vito. All rights reserved.
//

#import "VIAPIRebot.h"

@implementation VIAPIRebot

+ (void)requestUrl:(NSString *)url forJsonFlower:(void(^)(NSArray *jsonFlower))flower {
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:url]];
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                               NSError *jsonError;
                               NSDictionary *result = [NSJSONSerialization JSONObjectWithData:data
                                                                                      options:0
                                                                                        error:&jsonError];
                               if (!jsonError) {
                                   NSArray *resultData = [self jsonFlowerWithJsonData:result deep:YES];
                                   resultData = [resultData arrayByAddingObject:[NSNull null]];
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

+ (NSArray *)jsonFlowerWithJsonData:(id)jsonData {
    NSArray *flowers = [self jsonFlowerWithJsonData:jsonData deep:YES];
    return [flowers arrayByAddingObject:[NSNull null]];
}

+ (NSArray *)jsonFlowerWithJsonData:(id)value deep:(BOOL)deep {
    NSMutableArray *allResults = [NSMutableArray array];
    
    id result = [value mutableCopy];
    if ([value isKindOfClass:[NSDictionary class]]) {
        for (NSString *key in [(NSDictionary *)value allKeys]) {
            if (deep && ([result[key] isKindOfClass:[NSDictionary class]] || [result[key] isKindOfClass:[NSArray class]])) {
                NSArray *innerResult = [self jsonFlowerWithJsonData:result[key] deep:YES];
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
                nullResult[key] = [NSNull null];
                [allResults addObject:[[self jsonFlowerWithJsonData:nullResult deep:NO] lastObject]];
            } else {
                result[key] = [NSNull null];
            }
        }
    } else if ([value isKindOfClass:[NSArray class]]) {
        for (NSInteger i=0; i < [(NSArray *)value count]; i++) {
            if (deep && ([result[i] isKindOfClass:[NSDictionary class]] || [result[i] isKindOfClass:[NSArray class]])) {
                NSArray *innerResult = [self jsonFlowerWithJsonData:result[i] deep:YES];
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
                nullResult[i] = [NSNull null];
                [allResults addObject:[[self jsonFlowerWithJsonData:nullResult deep:NO] lastObject]];
            } else {
                result[i] = [NSNull null];
            }
        }
    }
    
    [allResults addObject:result];
    
    return [allResults copy];
}

@end
