//
//  MVSummary.h
//  Move-iOS-SDK
//
//  Created by Vito on 13-7-11.
//  Copyright (c) 2013年 vito. All rights reserved.
//

#import "MVBaseDataModel.h"

typedef NS_ENUM(NSInteger, MVActivityType) {
    MVActivityTypeWalking = 0,
    MVActivityTypeRunning,
    MVActivityTypeCycling,
    MVActivityTypeTransport
};

@interface MVSummary : MVBaseDataModel

@property (nonatomic) MVActivityType activity;
@property (nonatomic) NSUInteger duration;
@property (nonatomic) NSUInteger distance;
@property (nonatomic) NSUInteger steps;
@property (nonatomic) NSUInteger calories;

- (MVSummary *)initWithDictionary:(NSDictionary *)dic;

@end
