//
//  ADDetailView.h
//  AgileMD
//
//  Created by Zack Liston on 1/13/14.
//  Copyright (c) 2014 Agile Diagnosis. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ADFullScreenDetailView : NSObject

@property (nonatomic, strong) NSArray *info;

+ (ADFullScreenDetailView *)sharedInstance;
- (void)showIndex:(NSUInteger)index;
- (void)remove;

@end
