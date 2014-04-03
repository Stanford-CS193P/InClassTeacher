//
//  TrueFalseQuestion.m
//  InClassTeacher
//
//  Created by Johan Ismael on 4/1/14.
//  Copyright (c) 2014 Johan Ismael. All rights reserved.
//

#import "TrueFalseQuestion.h"

@implementation TrueFalseQuestion

- (instancetype)initWithQuestionText:(NSString *)questionText
{
    return [super initWithQuestionText:questionText
                                  type:TRUE_FALSE];
}

- (NSDictionary *)toDictionary
{
    NSDictionary *dict = [super toDictionary];
    NSMutableDictionary *mutableDic = [NSMutableDictionary dictionaryWithDictionary:dict];
    [mutableDic setObject:@"TRUE_FALSE"
                   forKey:kTypeKey];
    return [NSDictionary dictionaryWithDictionary:mutableDic];
}

@end
