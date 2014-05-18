//
//  VIAPIRebot.h
//  MovesSDKDemo
//
//  Created by Vito on 5/16/14.
//  Copyright (c) 2014 vito. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VIAPIRebot : NSObject

+ (void)requestUrl:(NSString *)url forJsonFlower:(void(^)(NSArray *jsonFlower))flower;
+ (NSArray *)jsonFlowerWithJsonData:(id)jsonData;

@end
