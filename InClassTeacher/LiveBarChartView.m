//
//  LiveBarChartView.m
//  InClassTeacher
//
//  Created by Johan Ismael on 4/13/14.
//  Copyright (c) 2014 Johan Ismael. All rights reserved.
//

#import "LiveBarChartView.h"

@interface LiveBarChartView()
@property (strong, nonatomic) NSCountedSet *data;
@property (strong, nonatomic) NSString *mostVotedCategory;
@property (strong, nonatomic) NSMutableDictionary *animatedHiddenBarPosition;
@property (readonly, nonatomic) NSInteger mostVotedCategoryCount;
@property (weak, nonatomic) NSTimer *animationTimer;
@end

@implementation LiveBarChartView

#define CHANGE_DIRECTION_ODDS 7 // 1 in 7 chance of changing direction
#define ANIMATION_INTERVAL 1.0

- (NSMutableDictionary *)animatedHiddenBarPosition
{
    if (!_animatedHiddenBarPosition) _animatedHiddenBarPosition = [[NSMutableDictionary alloc] init];
    return _animatedHiddenBarPosition;
}

- (NSInteger)mostVotedCategoryCount
{
    return self.mostVotedCategory ? [self.data countForObject:self.mostVotedCategory] : 0;
}

- (void)setHighlightedCategory:(NSString *)highlightedCategory
{
    _highlightedCategory = highlightedCategory;
    [self setNeedsDisplay];
}

- (NSCountedSet *)data
{
    if (!_data) _data = [[NSCountedSet alloc] init];
    return _data;
}

- (void)startAnimation
{
    if (!self.animationTimer && self.animateHiddenData) {
        self.animationTimer = [NSTimer scheduledTimerWithTimeInterval:ANIMATION_INTERVAL target:self selector:@selector(animate:) userInfo:nil repeats:YES];
    }
}

- (void)animate:(NSTimer *)timer
{
    [self setNeedsDisplay];
}

- (void)stopAnimation
{
    [self.animationTimer invalidate];
}

- (void)setAnimateHiddenData:(BOOL)animateHiddenData
{
    _animateHiddenData = animateHiddenData;
    if (!animateHiddenData) [self stopAnimation];
}

- (void)setDataVisible:(BOOL)dataVisible
{
    _dataVisible = dataVisible;
    if (dataVisible) [self stopAnimation];
}

- (void)addDataPoint:(NSString *)category
{
    [self.data addObject:category];

    if (!self.mostVotedCategory) {
        self.mostVotedCategory = category;
        [self setNeedsDisplay];
    } else if (![category isEqualToString:self.mostVotedCategory]) {
        NSUInteger numberVotesForCategory = [self.data countForObject:category];
        if (numberVotesForCategory > self.mostVotedCategoryCount) {
            self.mostVotedCategory = category;
        }
    }
    
    [self startAnimation];

    [self setNeedsDisplay];
}

#pragma mark - Drawing

#define X_PADDING 10
#define Y_PADDING 40

- (void)drawRect:(CGRect)rect
{
    // Drawing code
    [self drawBars];
}

- (void)drawBars
{
    CGFloat barX = X_PADDING;
    NSUInteger numCategories = [self.categories count];
    CGFloat barWidth = (CGRectGetWidth(self.bounds) -  (numCategories + 1) * X_PADDING)/ [self.categories count];
    
    for (NSString *category in self.categories) {
        CGFloat numDataItemsForCategory = (CGFloat)[self.data countForObject:category];
    
        if (!self.dataVisible) {
            if (self.animateHiddenData) {
                NSInteger animatedHiddenBarPosition = [self.animatedHiddenBarPosition[category] longValue];
                animatedHiddenBarPosition += 1;
                BOOL changeDirection = (arc4random()%CHANGE_DIRECTION_ODDS == 0) ? YES : NO;
                if (changeDirection) animatedHiddenBarPosition *= -1;
                if (animatedHiddenBarPosition >= self.mostVotedCategoryCount) animatedHiddenBarPosition = -1 * self.mostVotedCategoryCount;
                self.animatedHiddenBarPosition[category] = @(animatedHiddenBarPosition);
                if (animatedHiddenBarPosition < 0) {
                    numDataItemsForCategory = - animatedHiddenBarPosition;
                } else {
                    numDataItemsForCategory = animatedHiddenBarPosition;
                }
            } else {
                numDataItemsForCategory = 0;
            }
        }
        
        BOOL isHighlightedCategory = self.highlightedCategory && [category isEqualToString:self.highlightedCategory];
        UIColor *barColor = isHighlightedCategory ? [UIColor greenColor] : [UIColor blackColor];
        CGFloat barHeight = (numDataItemsForCategory / [self totalNumberOfDataPoints]) * CGRectGetHeight(self.bounds);
        CGFloat barY = CGRectGetHeight(self.bounds) - barHeight - Y_PADDING;
        
        //draw bar
        [barColor set];
        UIRectFill(CGRectMake(barX, barY, barWidth, barHeight));
        
        //draw label
        [self drawLabelForCategory:category
                            inRect:CGRectMake(barX, CGRectGetHeight(self.bounds) - Y_PADDING, barWidth, Y_PADDING)];
        
        barX += barWidth + X_PADDING;
    }
}

- (void)drawLabelForCategory:(NSString *)category
                      inRect:(CGRect)rect
{
    UIFont *font = [UIFont systemFontOfSize:14.0];
    NSMutableParagraphStyle *textStyle = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
    textStyle.lineBreakMode = NSLineBreakByWordWrapping;
    textStyle.alignment = NSTextAlignmentCenter;

    [category drawInRect:rect
          withAttributes:@{NSFontAttributeName: font,
                           NSParagraphStyleAttributeName: textStyle}];
}

- (NSUInteger)dataCount
{
    NSUInteger count = 0;
    for (NSString *response in self.data) {
        count += [self.data countForObject:response];
    }
    return count;
}

- (NSUInteger)totalNumberOfDataPoints
{
    NSUInteger count = 0;
    for (NSString *response in self.data) {
        count += [self.data countForObject:response];
    }
    return count;
}

@end
