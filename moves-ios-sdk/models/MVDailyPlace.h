//
//  MVDailyPlace.h
//  Move-iOS-SDK
//
//  Created by Vito on 13-7-14.
//  Copyright (c) 2013年 vito. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MVSegment.h"

@interface MVDailyPlace : NSObject

@property (nonatomic, strong) NSDate *date;
@property (nonatomic, strong) NSArray *segments;

- (MVDailyPlace *)initWithDictionary:(NSDictionary *)dic;

@end
