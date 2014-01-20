//
//  ADDetailView.h
//  AgileMD
//
//  Created by Zack Liston on 1/13/14.
//  Copyright (c) 2014 Agile Diagnosis. All rights reserved.
//

#import <Foundation/Foundation.h>

#define AD_TITLE_KEY @"title_key"
#define AD_DETAILS_KEY @"details_key"

@interface ADFullScreenDetailView : NSObject

@property (nonatomic, strong) NSArray *info;

+ (ADFullScreenDetailView *)sharedInstance;
- (void)showIndex:(NSUInteger)index;
- (void)remove;

@end
