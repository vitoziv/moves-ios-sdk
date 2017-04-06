//
//  MVDailyActivities.h
//  Move-iOS-SDK
//
//  Created by Vito on 13-7-11.
//  Copyright (c) 2013年 vito. All rights reserved.
//

#import "MVBaseDataModel.h"
#import "MVSummary.h"
#import "MVSegment.h"

@interface MVDailyActivity : MVBaseDataModel

@property (nonatomic, strong) NSDate *date;
@property (nonatomic, strong) NSArray<MVSummary *> *summaries;
@property (nonatomic, strong) NSArray<MVSegment *> *segments;
@property (nonatomic) NSInteger caloriesIdle;
@property (nonatomic, strong) NSDate *lastUpdate;
@property (nonatomic, readonly) NSInteger dailyCalories;

@end
