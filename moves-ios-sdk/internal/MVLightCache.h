//
//  MVLightCache.h
//  MovesSDKDemo
//
//  Created by Vito on 5/19/14.
//  Copyright (c) 2014 vito. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MVLightCache : NSObject 

+ (instancetype)sharedInstance;

- (void)setObject:(id)object forKey:(id)key;
- (id)objectForKey:(id)key;

@end
