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

+ (instancetype)taggedTimestampedDoubleFromDictionary:(NSDictionary *)dictionary
{
    TaggedTimestampedDouble *ttd =  [[self alloc] initWithCreationDate:dictionary[kDateKey]
                                                                Double:0.0
                                                                   Tag:dictionary[kTagKey]];
    ttd.sent = [dictionary[kSentKey] boolValue];
    return ttd;
}

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

- (instancetype)initWithTag:(NSString *)tag
{
    self = [super initWithDouble:0.0];
    if (self) {
        _tag = tag;
    }
    return self;
}

- (NSDictionary *)toDictionary
{
    return @{kTagKey: self.tag,
             kSentKey: @(self.sent)};
}

@end
