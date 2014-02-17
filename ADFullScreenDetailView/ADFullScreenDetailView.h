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
@property (nonatomic, strong) UIColor *backgroundColor;
@property (nonatomic, strong) UIFont *titleFont;
@property (nonatomic, strong) UIFont *detailsFont;
@property (nonatomic, strong) UIColor *titleTextColor;
@property (nonatomic, strong) UIColor *detailsTextColor;
@property (nonatomic, assign) BOOL hasNavigationButtons;
@property (nonatomic, assign) BOOL owningViewControllerIsPresentedModally;

+ (ADFullScreenDetailView *)sharedInstance;
- (void)showIndex:(NSUInteger)index inViewController:(UIViewController *)viewController;
- (void)showTitle:(NSString *)title details:(NSString *)details inViewController:(UIViewController *)viewController;
- (void)remove;

@end
