//
//  MVUser.h
//  Move-iOS-SDK
//
//  Created by Vito on 13-7-11.
//  Copyright (c) 2013年 vito. All rights reserved.
//

#import "MVBaseDataModel.h"
#import "MVLocalization.h"

@interface MVUser : MVBaseDataModel

@property (nonatomic, strong) NSString *userId;
@property (nonatomic, strong) NSDate *firstDate;
@property (nonatomic, strong) NSString *currentTimeZoneId;
@property (nonatomic) NSInteger currentTimeZoneOffset;
@property (nonatomic, strong) MVLocalization *localization;
@property (nonatomic) BOOL caloriesAvailable;
@property (nonatomic) NSString *platform;

@end
