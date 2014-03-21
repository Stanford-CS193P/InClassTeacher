//
//  LiveGraph.m
//  LiveGraph
//
//  Created by Paul Hegarty on 3/15/14.
//  Copyright (c) 2014 CS193p. All rights reserved.
//

#import "LiveGraphView.h"

@interface LiveGraphView()
@property (nonatomic, strong) NSMutableDictionary *data;
@property (nonatomic) long random;
@property (nonatomic, weak) NSTimer *updateTimer;
@property (nonatomic, getter=isValid) BOOL valid;
@property (readwrite, nonatomic, strong) NSArray *validValues;
@property (nonatomic) BOOL maxValueSet;
@property (nonatomic) BOOL minValueSet;
@property (nonatomic, strong) NSMutableArray *timeline;
@property (readonly, nonatomic) NSAttributedString *attributedStringForUntaggedTimelinePoint;
@property (readonly, nonatomic) NSAttributedString *attributedStringForTaggedTimelinePoint;
@property (readonly, nonatomic) NSUInteger maxTimelinePoints;
@property (nonatomic, strong) NSString *pendingTag;
@end

@implementation LiveGraphView

@synthesize bars = _bars;
@synthesize minValue = _minValue;
@synthesize maxValue = _maxValue;

#pragma mark Properties

- (void)setUpdateInterval:(NSTimeInterval)updateInterval
{
    if (_updateInterval != updateInterval) {
        _updateInterval = updateInterval;
        [self.updateTimer invalidate];
        if (updateInterval > 0) {
            NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:updateInterval
                                                              target:self
                                                            selector:@selector(update:)
                                                            userInfo:nil
                                                             repeats:YES];
            self.updateTimer = timer;
        }
    }
}

- (void)setMaxAge:(NSTimeInterval)maxAge
{
    _maxAge = MAX(maxAge, 0);
    [self invalidate];
}

- (void)setBars:(NSUInteger)bars
{
    _bars = MAX(bars, 0);
    [self invalidate];
}

- (NSUInteger)bars
{
    if (!_bars) {
        NSUInteger bars = [self.validValues count];
        return bars ? bars : 1;
    } else {
        return _bars;
    }
}

- (void)setMaxValue:(double)maxValue
{
    self.maxValueSet = YES;
    _maxValue = maxValue;
    [self invalidate];
}

- (void)setMinValue:(double)minValue
{
    self.minValueSet = YES;
    _minValue = minValue;
    [self invalidate];
}

- (double)minValue
{
    if (!self.minValueSet) [self validate];
    return _minValue;
}

- (double)maxValue
{
    if (!self.maxValueSet) [self validate];
    return _maxValue;
}

- (NSMutableArray *)timeline
{
    if (!_timeline) _timeline = [[NSMutableArray alloc] init];
    return _timeline;
}

#pragma mark Validation

- (void)validate
{
    if (!self.isValid) {
        NSMutableArray *validValues = [[NSMutableArray alloc] init];
        if (!self.minValueSet) self.minValue = 0;
        if (!self.maxValueSet) self.maxValue = 0;
        [[self.data allValues] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            if (![self valueIsTooOld:obj]) {
                double value = [obj doubleValue];
                if (![validValues count]) {
                    if (!self.minValueSet) self.minValue = value;
                    if (!self.maxValueSet) self.maxValue = value;
                } else {
                    if (!self.minValueSet && (value < self.minValue)) self.minValue = value;
                    if (!self.maxValueSet && (value > self.maxValue)) self.maxValue = value;
                }
                [validValues addObject:obj];
            }
        }];
        self.validValues = [validValues sortedArrayUsingSelector:@selector(compare:)];
        NSLog(@"==============> %lu", (unsigned long)[validValues count]);
        self.valid = YES;
    }
}

- (void)invalidate
{
    self.valid = NO;
    [self setNeedsDisplay];
}

- (BOOL)valueIsTooOld:(id)value
{
    return (self.maxAge &&
            [value respondsToSelector:@selector(age)] &&
            ([value age] > self.maxAge));
}

#pragma mark Updating

- (void)update:(NSTimer *)timer
{
    [self invalidate];
    if ([self.validValues count]) {
        [self addToTimeline:@([[self.validValues valueForKeyPath:@"@avg.doubleValue"] doubleValue])];
    } else {
        [self addToTimeline:@(self.minValue-1)];
    }
}

#pragma mark Timeline

- (void)tag:(NSString *)tag
{
    for (id object in self.timeline) {
        if ([tag isEqual:object]) return;
        if ([object isKindOfClass:[NSString class]]) {
            break;
        }
    }
    self.pendingTag = tag;
}

- (void)addToTimeline:(id)object
{
    if (object) {
        while ([self.timeline count] >= self.maxTimelinePoints) [self.timeline removeLastObject];
        [self.timeline insertObject:object atIndex:0];
        if (self.pendingTag && ([object doubleValue] > self.minValue) && ([object doubleValue] < self.maxValue)) {
            [self.timeline insertObject:self.pendingTag atIndex:0];
            self.pendingTag = nil;
        }
    }
}

- (NSUInteger)maxTimelinePoints
{
    return MAX(CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds)) / [self.attributedStringForUntaggedTimelinePoint size].width; // approximation
}

- (NSAttributedString *)attributedStringForUntaggedTimelinePoint
{
    static NSAttributedString *attributedStringForUntaggedTimelinePoint = nil;
    if (!attributedStringForUntaggedTimelinePoint) attributedStringForUntaggedTimelinePoint = [[NSAttributedString alloc] initWithString:@"•"];
    return attributedStringForUntaggedTimelinePoint;
}

- (NSAttributedString *)attributedStringForTaggedTimelinePoint
{
    static NSAttributedString *attributedStringForTaggedTimelinePoint = nil;
    if (!attributedStringForTaggedTimelinePoint) attributedStringForTaggedTimelinePoint = [[NSAttributedString alloc] initWithString:@"❉"];
    return attributedStringForTaggedTimelinePoint;
}

#pragma mark Drawing

- (void)drawRect:(CGRect)rect
{
    [self drawBarGraph];
    [self drawTimeline];
}

- (void)drawBarGraph
{
    CGFloat barSegmentWidth = CGRectGetWidth(self.bounds)/self.bars;
    CGFloat barSegmentHeight = [self maxBarSegmentHeight];
    if (!barSegmentHeight) return;
    if (barSegmentHeight > barSegmentWidth) {
        barSegmentHeight = barSegmentWidth;
    }
    CGRect barSegmentRect = CGRectMake(0, CGRectGetMaxX(self.bounds), barSegmentWidth, barSegmentHeight);
    CGFloat hue = 0;
    CGFloat hueStep = 0.3/self.bars;
    
    for (NSArray *ages in [self barsByAge]) {
        barSegmentRect.origin.y = CGRectGetMaxY(self.bounds) - [ages count]*barSegmentHeight;
        for (NSNumber *age in ages) {
            UIColor *color = [UIColor colorWithHue:hue saturation:[age floatValue] brightness:1.0 alpha:1.0];
            [self drawBarSegment:barSegmentRect usingColor:color];
            barSegmentRect.origin.y += barSegmentHeight;
        }
        hue += hueStep;
        barSegmentRect.origin.x += barSegmentWidth;
    }
}

- (void)drawTimeline
{
    CGFloat x = CGRectGetMaxX(self.bounds);
    CGFloat xstep = - [self.attributedStringForUntaggedTimelinePoint size].width;
    
    NSString *tag;
    UIBezierPath *timelinePath;
    
    for (id timelineEntry in self.timeline) {
        x += xstep;
        if ([timelineEntry isKindOfClass:[NSString class]]) {
            tag = (NSString *)timelineEntry;
        } else if ([timelineEntry respondsToSelector:@selector(doubleValue)]) {
            double value = [timelineEntry doubleValue];
            if ((value > self.minValue) && (value < self.maxValue)) { // maybe should include "equal to" boundaries too?
                CGFloat y = CGRectGetMaxY(self.bounds) - (((value - self.minValue) / (self.maxValue - self.minValue)) * CGRectGetHeight(self.bounds));
                NSAttributedString *pointString = tag ? self.attributedStringForTaggedTimelinePoint : self.attributedStringForUntaggedTimelinePoint;
                [pointString drawAtPoint:CGPointMake(x-[pointString size].width/2.0, y-[pointString size].height/2.0)];
                if (tag) {
                    NSAttributedString *tagString = [[NSAttributedString alloc] initWithString:tag];
                    [tagString drawAtPoint:CGPointMake(x-[tagString size].width/2, y-3*[tagString size].height/2)];
                }
                if (timelinePath) {
                    [timelinePath addLineToPoint:CGPointMake(x, y)];
                } else {
                    timelinePath = [UIBezierPath bezierPath];
                    [timelinePath moveToPoint:CGPointMake(x, y)];
                }
            } else {
                [timelinePath stroke];
                timelinePath = nil;
            }
            tag = nil;
        }
    }
    [timelinePath stroke];
}

- (NSArray *)barsByAge
{
    NSMutableArray *bars = [[NSMutableArray alloc] init];
    NSMutableArray *barSegmentAges = [[NSMutableArray alloc] init];
    double step = (self.maxValue - self.minValue) / self.bars;
    double offset = step;
    for (id valueObject in self.validValues) {
        double value = [valueObject doubleValue];
        NSTimeInterval age = [valueObject respondsToSelector:@selector(age)] ? [valueObject age] : 0;
        while (value > self.minValue + offset) {
            [bars addObject:[barSegmentAges sortedArrayUsingSelector:@selector(compare:)]];
            offset += step;
            barSegmentAges = [[NSMutableArray alloc] init];
        }
        CGFloat agePercentage = self.maxAge ? (self.maxAge-age)/self.maxAge : 1.0;
        [barSegmentAges addObject:@(agePercentage)];
    }
    [bars addObject:[barSegmentAges sortedArrayUsingSelector:@selector(compare:)]];
    return bars;
}

- (CGFloat)maxBarSegmentHeight
{
    double step = (self.maxValue - self.minValue) / self.bars;
    if (!step) return 0;

    double offset = step;
    int maxBarHeight = 0;
    int barHeight = 0;
    for (id valueObject in self.validValues) {
        barHeight++;
        while ([valueObject doubleValue] > self.minValue + offset) {
            offset += step;
            if (barHeight > maxBarHeight) maxBarHeight = barHeight;
            barHeight = 0;
        }
    }
    return (CGRectGetHeight(self.bounds)/maxBarHeight);
}

- (void)drawBarSegment:(CGRect)rect usingColor:(UIColor *)color
{
    [color set];
    UIRectFill(rect);
}

#pragma mark Data

- (NSMutableDictionary *)data
{
    if (!_data) _data = [[NSMutableDictionary alloc] init];
    return _data;
}

- (void)setValue:(id)value forKey:(NSString *)key
{
    self[key] = value;
}

- (id)valueForKey:(NSString *)key
{
    return self[key];
}

- (void)setNilValueForKey:(NSString *)key
{
    [self.data removeObjectForKey:key];
    [self invalidate];
}

// this is the primitive value setter
- (void)setObject:(id)value forKeyedSubscript:(id <NSCopying>)key
{
    self.data[key] = value;
    [self invalidate];
}

- (id)objectForKeyedSubscript:(id <NSCopying>)key
{
    return self.data[key];
}

- (void)addValue:(id)value
{
    [self setValue:value forKey:[self randomKey]];
}

- (void)addValues:(NSArray *)values
{
    [values enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) { [self addValue:obj]; }];
}

- (void)clearAllValues
{
    [self.data removeAllObjects];
    [self.timeline removeAllObjects];
    [self invalidate];
}

- (NSArray *)values
{
    return [self.data allValues];
}

- (NSArray *)validValues
{
    [self validate];
    return _validValues;
}

- (long)random
{
    if (!_random) _random = arc4random();
    return _random++;
}

- (NSString *)randomKey
{
    return [NSString stringWithFormat:@"LiveGraphRandomKey%ld", self.random];
}

@end
