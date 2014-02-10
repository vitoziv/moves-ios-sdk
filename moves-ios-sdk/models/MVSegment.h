//
//  MVSegment.h
//  Move-iOS-SDK
//
//  Created by Vito on 13-7-11.
//  Copyright (c) 2013年 vito. All rights reserved.
//

#import "MVBaseDataModel.h"
#import "MVPlace.h"
#import "MVActivity.h"

@interface MVSegment : MVBaseDataModel

@property (nonatomic, strong) NSString *type;
@property (nonatomic, strong) NSDate *startTime;
@property (nonatomic, strong) NSDate *endTime;
@property (nonatomic, strong) MVPlace *place;
@property (nonatomic, strong) NSArray *activities;
@property (nonatomic, strong) NSDate *lastUpdate;

@end
