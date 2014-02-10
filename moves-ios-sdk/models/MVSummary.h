//
//  MVSummary.h
//  Move-iOS-SDK
//
//  Created by Vito on 13-7-11.
//  Copyright (c) 2013年 vito. All rights reserved.
//

#import "MVBaseDataModel.h"

@interface MVSummary : MVBaseDataModel

@property (nonatomic, strong) NSString *activity;
@property (nonatomic, strong) NSString *group;
@property (nonatomic) NSUInteger duration;
@property (nonatomic) NSUInteger distance;
@property (nonatomic) NSUInteger steps;
@property (nonatomic) NSUInteger calories;

@end
