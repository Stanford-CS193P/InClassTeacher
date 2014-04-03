//
//  Question.m
//  InClassTeacher
//
//  Created by Johan Ismael on 3/31/14.
//  Copyright (c) 2014 Johan Ismael. All rights reserved.
//

#import "Question.h"

@interface Question()

@property (nonatomic, strong) NSString *questionText;
@property (nonatomic, assign) QuestionType type;

@end

@implementation Question

- (instancetype)initWithQuestionText:(NSString *)questionText
                                type:(QuestionType)type
{
    self = [super init];
    if (self) {
        _questionText = questionText;
        _type = type;
    }
    return self;
}

- (NSDictionary *)toDictionary
{
    return @{kTextKey: self.questionText};
}

@end
