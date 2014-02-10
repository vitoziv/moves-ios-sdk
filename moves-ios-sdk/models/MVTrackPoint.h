//
//  MVTrackPoints.h
//  Move-iOS-SDK
//
//  Created by Vito on 13-7-11.
//  Copyright (c) 2013年 vito. All rights reserved.
//

#import "MVBaseDataModel.h"

@interface MVTrackPoint : MVBaseDataModel

@property (nonatomic) CGFloat lat;
@property (nonatomic) CGFloat lon;
@property (nonatomic) NSDate *time;

@end
