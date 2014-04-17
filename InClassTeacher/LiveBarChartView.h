//
//  LiveBarChartView.h
//  InClassTeacher
//
//  Created by Johan Ismael on 4/13/14.
//  Copyright (c) 2014 Johan Ismael. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LiveBarChartView : UIView

//configuration
@property (strong, nonatomic) NSArray *categories;
@property (strong, nonatomic) NSString *highlightedCategory;

- (void)addDataPoint:(NSString *)category;

@property (nonatomic, getter = isDataVisible) BOOL dataVisible;
@property (nonatomic, getter = isHiddenDataAnimated) BOOL animateHiddenData;

@end
