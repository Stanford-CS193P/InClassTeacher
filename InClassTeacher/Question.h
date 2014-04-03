//
//  Question.h
//  InClassTeacher
//
//  Created by Johan Ismael on 3/31/14.
//  Copyright (c) 2014 Johan Ismael. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    TRUE_FALSE,
    MULTIPLE_CHOICE
} QuestionType;

#define kTypeKey @"type"
#define kTextKey @"text"

@interface Question : NSObject

- (instancetype)initWithQuestionText:(NSString *)questionText
                                type:(QuestionType)type;
- (NSDictionary *)toDictionary;

@property (nonatomic, strong, readonly) NSString *questionText;
@property (nonatomic, assign, readonly) QuestionType type;

@end
