//
//  MVJsonValueParser.h
//  MovesSDKDemo
//
//  Created by Vito on 5/28/14.
//  Copyright (c) 2014 vito. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MVBaseDataModel.h"
#define isNull(o) (!o || (NSNull *)o == [NSNull null])

@interface MVJsonValueParser : NSObject

+ (NSString *)stringValueFromObject:(id)obj;
+ (BOOL)boolValueFromObject:(id)obj;
+ (NSInteger)integerValueFromObject:(id)obj;
+ (CGFloat)floatValueFromObject:(id)obj;
+ (NSArray *)arrayValueFromObject:(id)obj withCreateObjectBlock:(MVBaseDataModel *(^)(NSDictionary *dic))createObjectBlock;

@end
