//
//  MultipleChoiceQuestion.h
//  InClassTeacher
//
//  Created by Johan Ismael on 4/1/14.
//  Copyright (c) 2014 Johan Ismael. All rights reserved.
//

#import "Question.h"

#define kChoicesKey @"choices"

@interface MultipleChoiceQuestion : Question

- (instancetype)initWithQuestionText:(NSString *)questionText;
- (void)addChoice:(NSString *)choiceText;

@end
