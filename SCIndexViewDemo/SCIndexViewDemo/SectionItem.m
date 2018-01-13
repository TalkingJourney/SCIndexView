//
//  SectionItem.m
//  iPhoneXDemo
//
//  Created by James on 2018/1/11.
//  Copyright © 2018年 James. All rights reserved.
//

#import "SectionItem.h"

@implementation SectionItem

+ (nullable NSDictionary<NSString *, id> *)modelContainerPropertyGenericClass
{
    return @{
             @"items" : NSString.class
             };
}

@end
