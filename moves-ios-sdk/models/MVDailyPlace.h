//
//  MVDailyPlace.h
//  Move-iOS-SDK
//
//  Created by Vito on 13-7-14.
//  Copyright (c) 2013年 vito. All rights reserved.
//

#import "MVBaseDataModel.h"
#import "MVSegment.h"

@interface MVDailyPlace : MVBaseDataModel

@property (nonatomic, strong) NSDate *date;
@property (nonatomic, strong) NSArray *segments;
@property (nonatomic, strong) NSDate *lastUpdate;

@end
