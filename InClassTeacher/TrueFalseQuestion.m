//
//  TrueFalseQuestion.m
//  InClassTeacher
//
//  Created by Johan Ismael on 4/1/14.
//  Copyright (c) 2014 Johan Ismael. All rights reserved.
//

#import "TrueFalseQuestion.h"

@implementation TrueFalseQuestion

- (instancetype)initWithTitle:(NSString *)title
                         text:(NSString *)questionText
{
    return [super initWithTitle:title
                           text:questionText
                           type:TRUE_FALSE];
}

- (NSDictionary *)toDictionary
{
    NSDictionary *dict = [super toDictionary];
    NSMutableDictionary *mutableDic = [NSMutableDictionary dictionaryWithDictionary:dict];
    [mutableDic setObject:@(self.type)
                   forKey:kTypeKey];
    return [NSDictionary dictionaryWithDictionary:mutableDic];
}

@end
