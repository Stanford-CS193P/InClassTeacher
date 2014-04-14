//
//  MultipleChoiceQuestion.m
//  InClassTeacher
//
//  Created by Johan Ismael on 4/1/14.
//  Copyright (c) 2014 Johan Ismael. All rights reserved.
//

#import "MultipleChoiceQuestion.h"

@interface MultipleChoiceQuestion()

@property (nonatomic, strong) NSMutableArray *choices; //of strings

@end

@implementation MultipleChoiceQuestion

- (NSMutableArray *)choices
{
    if (!_choices) _choices = [[NSMutableArray alloc] init];
    return _choices;
}

- (NSArray *)choicesArray
{
    return [NSArray arrayWithArray:self.choices];
}

- (NSUInteger)numberOfChoices
{
    return [self.choices count];
}

- (NSString *)choiceAtIndex:(NSUInteger)index
{
    if (index < [self numberOfChoices]) {
        return self.choices[index];
    } else {
        return nil;
    }
}

- (instancetype)initWithTitle:(NSString *)title
                         text:(NSString *)questionText
{
    return [super initWithTitle:title
                           text:questionText
                           type:MULTIPLE_CHOICE];
}


- (void)addChoice:(NSString *)choiceText
{
    [self.choices addObject:choiceText];
}

- (NSDictionary *)toDictionary
{
    NSDictionary *dict = [super toDictionary];
    NSMutableDictionary *mutableDic = [NSMutableDictionary dictionaryWithDictionary:dict];
    [mutableDic setObject:@(self.type)
                   forKey:kTypeKey];
    [mutableDic setObject:self.choices
                   forKey:kChoicesKey];
    return [NSDictionary dictionaryWithDictionary:mutableDic];
}

@end
