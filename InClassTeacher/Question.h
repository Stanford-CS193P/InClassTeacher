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
#define kTitleKey @"title"

@interface Question : NSObject

- (instancetype)initWithTitle:(NSString *)title
                         text:(NSString *)questionText
                         type:(QuestionType)type;
- (NSDictionary *)toDictionary;

@property (nonatomic, strong, readonly) NSString *text;
@property (nonatomic, assign, readonly) QuestionType type;

@end
