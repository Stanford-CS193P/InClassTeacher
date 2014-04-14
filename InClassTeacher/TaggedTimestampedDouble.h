//
//  TaggedTimestampedDouble.h
//  InClassTeacher
//
//  Created by Johan Ismael on 3/20/14.
//  Copyright (c) 2014 Johan Ismael. All rights reserved.
//

#import "TimestampedDouble.h"
#import "SendableData.h"

#define kTagKey @"conceptName"
#define kDateKey @"date"

@interface TaggedTimestampedDouble : TimestampedDouble<SendableData>

+ (instancetype)taggedTimestampedDoubleFromDictionary:(NSDictionary *)dictionary;
- (instancetype)initWithCreationDate:(NSDate *)date
                              Double:(double)value
                                 Tag:(NSString *)tag;
- (instancetype)initWithTag:(NSString *)tag;

@property (strong, nonatomic, readonly) NSString *tag;

//SendableData protocol
@property (nonatomic, assign) NSString *objectId;
@property (assign, nonatomic) BOOL sent;
- (NSDictionary *)toDictionary;

@end
