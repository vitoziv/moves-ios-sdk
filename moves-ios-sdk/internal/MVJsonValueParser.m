//
//  MVJsonValueParser.m
//  MovesSDKDemo
//
//  Created by Vito on 5/28/14.
//  Copyright (c) 2014 vito. All rights reserved.
//

#import "MVJsonValueParser.h"

@implementation MVJsonValueParser

+ (NSString *)stringValueFromObject:(id)obj
{
    if (!isNull(obj) && obj) {
        if ([obj isKindOfClass:[NSString class]]) {
            return obj;
        } else if ([obj respondsToSelector:@selector(stringValue)]) {
            return [obj stringValue];
        } else {
            //TODO: API Changed, should notify developer...
            NSLog(@"\n\nWarning!! \nMoves API Changed!!!! Please notify developer!");
        }
    }
    
    return nil;
}

+ (BOOL)boolValueFromObject:(id)obj
{
    if (!isNull(obj) && obj) {
        if ([obj respondsToSelector:@selector(boolValue)]) {
            return [obj boolValue];
        } else {
            //TODO: API Changed, should notify developer...
            NSLog(@"\n\nWarning!! \nMoves API Changed!!!! Please notify developer!");
        }
    }
    return NO;
}

+ (NSInteger)integerValueFromObject:(id)obj
{
    if (!isNull(obj) && obj) {
        if ([obj respondsToSelector:@selector(integerValue)]) {
            return [obj integerValue];
        } else {
            //TODO: API Changed, should notify developer...
            NSLog(@"\n\nWarning!! \nMoves API Changed!!!! Please notify developer!");
        }
    }
    return 0;
}

+ (CGFloat)floatValueFromObject:(id)obj
{
    if (!isNull(obj) && obj) {
        if ([obj respondsToSelector:@selector(floatValue)]) {
            return [obj floatValue];
        } else {
            //TODO: API Changed, should notify developer...
            NSLog(@"\n\nWarning!! \nMoves API Changed!!!! Please notify developer!");
        }
    }
    return 0.0f;
}


+ (NSArray *)arrayValueFromObject:(id)obj withCreateObjectBlock:(MVBaseDataModel *(^)(NSDictionary *dic))createObjectBlock
{
    if ([obj isKindOfClass:[NSArray class]]) {
        NSArray *objs = [NSArray array];
        if ([obj count] > 0) {
            NSMutableArray *mutableObjs = [NSMutableArray arrayWithCapacity:[obj count]];
            [obj enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                [mutableObjs addObject:createObjectBlock(obj)];
            }];
            objs = [mutableObjs copy];
        }
        return objs;
    } else {
        return nil;
    }
}

@end
