//
//  ICKeywordResultController.m
//  InClassTeacher
//
//  Created by Johan Ismael on 3/3/14.
//  Copyright (c) 2014 Johan Ismael. All rights reserved.
//

#import "ICKeywordResultController.h"

@interface ICKeywordResultController ()

@property (nonatomic, strong) NSMutableDictionary *data;

@end

@implementation ICKeywordResultController

- (instancetype)initWithDictionary:(NSDictionary *)data
{
    self = [self init];
    if (self) {
        self.data = [NSMutableDictionary dictionaryWithDictionary:data];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    
}

@end
