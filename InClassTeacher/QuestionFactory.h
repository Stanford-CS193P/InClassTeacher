//
//  QuestionFactory.h
//  InClassTeacher
//
//  Created by Johan Ismael on 4/4/14.
//  Copyright (c) 2014 Johan Ismael. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Question.h"

@interface QuestionFactory : NSObject

+ (Question *)questionFromDictionary:(NSDictionary *)questionDic;

@end
