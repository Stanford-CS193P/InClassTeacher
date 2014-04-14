//
//  QuestionFactory.m
//  InClassTeacher
//
//  Created by Johan Ismael on 4/4/14.
//  Copyright (c) 2014 Johan Ismael. All rights reserved.
//

#import "QuestionFactory.h"
#import "TrueFalseQuestion.h"
#import "MultipleChoiceQuestion.h"

@implementation QuestionFactory

+ (Question *)questionFromDictionary:(NSDictionary *)questionDic
{
    Question *question = nil;
    NSString *title = questionDic[kTitleKey];
    NSString *text = questionDic[kTextKey];
    NSNumber *type = questionDic[kTypeKey];
    if ([type integerValue] == TRUE_FALSE) {
        question = [[TrueFalseQuestion alloc] initWithTitle:title text:text];
    }
    
    else if ([type integerValue] == MULTIPLE_CHOICE) {
        question = [[MultipleChoiceQuestion alloc] initWithTitle:title text:text];
        NSArray *choices = questionDic[kChoicesKey];
        
        for (NSString *choice in choices) {
            [(MultipleChoiceQuestion *)question addChoice:choice];
        }
    }
    
    question.objectId = questionDic[kObjectIdKey];
    question.sent = [questionDic[kSentKey] boolValue];
    return question;
}

@end
