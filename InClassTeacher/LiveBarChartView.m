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

@end

@implementation LiveBarChartView

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

- (void)addDataPoint:(NSString *)category
{
    [self.data addObject:category];

    if (!self.mostVotedCategory) {
        self.mostVotedCategory = category;
        [self setNeedsDisplay];
        return;
    }
    
    if (![category isEqualToString:self.mostVotedCategory]) {
        NSUInteger maxNumberOfVotesForCategory = [self.data countForObject:self.mostVotedCategory];
        NSUInteger numberVotesForCategory = [self.data countForObject:category];

        if (numberVotesForCategory > maxNumberOfVotesForCategory) {
            self.mostVotedCategory = category;
        }
    }
    
    [self setNeedsDisplay];
}

#pragma mark - Drawing

#define X_PADDING 10
#define Y_PADDING 20

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
        
        BOOL isHighlightedCategory = self.highlightedCategory && [category isEqualToString:self.highlightedCategory];
        UIColor *barColor = isHighlightedCategory ? [UIColor greenColor] : [UIColor blackColor];
        CGFloat barHeight = (numDataItemsForCategory / [self totalNumberOfDataPoints]) * CGRectGetHeight(self.bounds);
        
        //draw bar
        [barColor set];
        UIRectFill(CGRectMake(barX, Y_PADDING, barWidth, barHeight));
        
        //draw label
        [self drawLabelForCategory:category
                            inRect:CGRectMake(barX, 0, barWidth, Y_PADDING)];
        
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
