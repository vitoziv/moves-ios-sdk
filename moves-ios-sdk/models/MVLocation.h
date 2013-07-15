//
//  MVLocation.h
//  Move-iOS-SDK
//
//  Created by Vito on 13-7-11.
//  Copyright (c) 2013年 vito. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MVLocation : NSObject

@property (nonatomic) CGFloat lat;
@property (nonatomic) CGFloat lon;

- (MVLocation *)initWithDictionary:(NSDictionary *)dic;

@end
