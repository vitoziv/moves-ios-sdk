//
//  MVSupportedActivity.h
//  MovesSDKDemo
//
//  Created by Vito on 2/10/14.
//  Copyright (c) 2014 vito. All rights reserved.
//

#import "MVBaseDataModel.h"

@interface MVSupportedActivity : MVBaseDataModel

@property (nonatomic, strong) NSString *activity;
@property (nonatomic) BOOL geo;
@property (nonatomic) BOOL place;
@property (nonatomic, strong) NSString *color;
@property (nonatomic, strong) NSString *units;

@end
