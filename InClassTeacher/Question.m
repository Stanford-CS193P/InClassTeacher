//
//  Question.m
//  InClassTeacher
//
//  Created by Johan Ismael on 3/31/14.
//  Copyright (c) 2014 Johan Ismael. All rights reserved.
//

#import "Question.h"

@interface Question()

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *text;
@property (nonatomic, assign) QuestionType type;

@end

@implementation Question

- (instancetype)initWithTitle:(NSString *)title
                         text:(NSString *)questionText
                         type:(QuestionType)type
{
    self = [super init];
    if (self) {
        _title = title;
        _text = questionText;
        _type = type;
    }
    return self;
}

- (NSDictionary *)toDictionary
{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
  
    dict[kTextKey] = self.text;
    dict[kTitleKey] = self.title;
    dict[kSentKey] = @(self.sent);
    
    if (self.objectId) {
        dict[kObjectIdKey] = self.objectId;
    }
    
    return [NSDictionary dictionaryWithDictionary:dict];
}

@end
