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
- (void)addDataPoint:(NSString *)category;

@end
