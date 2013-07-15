//
//  MVDailyActivities.h
//  Move-iOS-SDK
//
//  Created by Vito on 13-7-11.
//  Copyright (c) 2013年 vito. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MVDailyActivity : NSObject

@property (nonatomic, strong) NSDate *date;
@property (nonatomic, strong) NSArray *segments;
@property (nonatomic) NSInteger caloriesIdle;

- (MVDailyActivity *)initWithDictionary:(NSDictionary *)dic;

@end
