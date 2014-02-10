//
//  MVPlace.h
//  Move-iOS-SDK
//
//  Created by Vito on 13-7-11.
//  Copyright (c) 2013年 vito. All rights reserved.
//

#import "MVBaseDataModel.h"
#import "MVLocation.h"

@interface MVPlace : MVBaseDataModel

@property (nonatomic, strong) NSString *placeId;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *type;
@property (nonatomic, strong) NSString *foursquareId;
@property (nonatomic) MVLocation *location;

@end
