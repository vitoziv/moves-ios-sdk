//
//  MVLocalization.h
//  MovesSDKDemo
//
//  Created by Vito on 2/8/14.
//  Copyright (c) 2014 vito. All rights reserved.
//

#import "MVBaseDataModel.h"

typedef NS_ENUM(NSUInteger, MVFirstWeekDayType) {
    MVFirstWeekDayTypeNone = 0,
    MVFirstWeekDayTypeSunday = 1,
    MVFirstWeekDayTypeMonday = 2
};

@interface MVLocalization : MVBaseDataModel

@property (strong, nonatomic) NSString *language;
@property (strong, nonatomic) NSString *locale;
@property (nonatomic) MVFirstWeekDayType firstWeekDay;
@property (nonatomic) BOOL metric;

@end
