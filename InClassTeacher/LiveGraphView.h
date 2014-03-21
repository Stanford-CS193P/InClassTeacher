//
//  LiveGraph.h
//  LiveGraph
//
//  Created by Paul Hegarty on 3/15/14.
//  Copyright (c) 2014 CS193p. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LiveGraphView : UIView

// configuration

@property (nonatomic) NSUInteger bars; // number of bars in the graph
@property (nonatomic) NSTimeInterval maxAge; // oldest allowable value
@property (nonatomic) NSTimeInterval updateInterval; // how often to update graph
@property (nonatomic) double minValue; // will autorange if never set
@property (nonatomic) double maxValue; // will autorange if never set

// tagging the data (will appear in the graph's historical timeline)
- (void)tag:(NSString *)tag;

// setting the data
// all values must implement the methods in the AgeableValue protocol
// (doesn't have to actually implement the protocol formally, just the methods in it)
// having the data be keyed is optional
// (use addValue(s): if you don't want the data to be keyed)

- (void)setValue:(id)value forKey:(NSString *)key;
- (id)valueForKey:(NSString *)key;
- (void)setNilValueForKey:(NSString *)key;

- (void)setObject:(id)value forKeyedSubscript:(id<NSCopying>)key;
- (id)objectForKeyedSubscript:(id<NSCopying>)key;

- (void)addValue:(id)value;
- (void)addValues:(NSArray *)values;

- (void)clearAllValues; // turns autoranging for min/max values back on too

// getting the data

@property (nonatomic, readonly) NSArray *values; // all values of any age, random order
@property (nonatomic, readonly) NSArray *validValues; // values that are not too old, sorted

@end

@protocol AgeableValue
- (double)doubleValue;
- (NSComparisonResult)compare:(id)otherObject;
@optional
- (NSTimeInterval)age;
- (NSString *)tag;
@end
