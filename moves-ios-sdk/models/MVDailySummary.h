//
//  MVDailySummary.h
//  Move-iOS-SDK
//
//  Created by Vito on 13-7-11.
//  Copyright (c) 2013年 vito. All rights reserved.
//

#import "MVBaseDataModel.h"

@interface MVDailySummary : MVBaseDataModel

@property (nonatomic, strong) NSDate *date;
@property (nonatomic, strong) NSArray *summaries;
@property (nonatomic, strong) NSDate *lastUpdate;
@property (nonatomic) NSInteger caloriesIdle;
@property (nonatomic, readonly) NSInteger dailyCalories;

@end
