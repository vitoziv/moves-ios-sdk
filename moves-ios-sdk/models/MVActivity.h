//
//  MVActivity.h
//  Move-iOS-SDK
//
//  Created by Vito on 13-7-11.
//  Copyright (c) 2013年 vito. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MVSummary.h"
#import "MVTrackPoint.h"

@interface MVActivity : MVSummary

@property (nonatomic) BOOL manual;
@property (nonatomic, strong) NSDate *startTime;
@property (nonatomic, strong) NSDate *endTime;
@property (nonatomic, strong) NSArray *trackPoints;

@end
