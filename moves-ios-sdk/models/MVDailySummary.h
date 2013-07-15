//
//  MVDailySummary.h
//  Move-iOS-SDK
//
//  Created by Vito on 13-7-11.
//  Copyright (c) 2013年 vito. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MVDailySummary : NSObject

@property (nonatomic, strong) NSDate *date;
@property (nonatomic, strong) NSArray *summaries;
@property (nonatomic) NSInteger caloriesIdle;

- (MVDailySummary *)initWithDictionary:(NSDictionary *)dic;

@end
