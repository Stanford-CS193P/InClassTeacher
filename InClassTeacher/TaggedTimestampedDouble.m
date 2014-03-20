//
//  TaggedTimestampedDouble.m
//  InClassTeacher
//
//  Created by Johan Ismael on 3/20/14.
//  Copyright (c) 2014 Johan Ismael. All rights reserved.
//

#import "TaggedTimestampedDouble.h"

@interface TaggedTimestampedDouble()

@property (strong, nonatomic) NSString *tag;

@end

@implementation TaggedTimestampedDouble

- (instancetype)initWithCreationDate:(NSDate *)date
                              Double:(double)value
                                 Tag:(NSString *)tag
{
    self = [super initWithCreationDate:date
                                Double:value];
    if (self) {
        _tag = tag;
    }
    return self;
}

@end
