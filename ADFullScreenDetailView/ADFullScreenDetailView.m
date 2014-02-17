//
//  ADDetailView.m
//  AgileMD
//
//  Created by Zack Liston on 1/13/14.
//  Copyright (c) 2014 Agile Diagnosis. All rights reserved.
//

#import "ADFullScreenDetailView.h"
#import <QuartzCore/QuartzCore.h>

#define ANIMATION_TIME 0.3f

@interface ADFullScreenDetailView ()

@property (nonatomic, weak) UIViewController *viewController;
@property (nonatomic, weak) UIWindow *window;
@property (nonatomic, strong) UIView *rootView;
@property (nonatomic, strong) UIView *mainView;
@property (nonatomic, strong) UIView *titleView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UITextView *detailsView;
@property (nonatomic, strong) UIView *buttonView;

@property (nonatomic, strong) UIButton *previousButton;
@property (nonatomic, strong) UIButton *nextButton;

@property (nonatomic, strong) CALayer *titleBorderLayer;
@property (nonatomic, strong) CALayer *textBorderLayer;

@property (nonatomic, strong) NSString *currentTitle;
@property (nonatomic, strong) NSString *currentText;

@property (nonatomic, assign) NSUInteger selectedIndex;
@property (nonatomic, assign) BOOL isActive;

@property (nonatomic, assign) BOOL canScroll;
@end

@implementation ADFullScreenDetailView

#pragma mark Sythesize
@synthesize window = _window;
@synthesize rootView = _rootView;
@synthesize mainView = _mainView;
@synthesize titleView = _titleView;
@synthesize titleLabel = _titleLabel;
@synthesize detailsView = _detailsView;
@synthesize buttonView = _buttonView;

@synthesize canScroll = _canScroll;
@synthesize hasNavigationButtons = _hasNavigationButtons;

@synthesize previousButton = _previousButton;
@synthesize nextButton = _nextButton;

@synthesize info = _info;
@synthesize currentTitle = _currentTitle;
@synthesize currentText = _currentText;

@synthesize selectedIndex = _selectedIndex;

@synthesize backgroundColor = _backgroundColor;
@synthesize titleFont = _titleFont;
@synthesize detailsFont = _detailsFont;
@synthesize titleTextColor = _titleTextColor;
@synthesize detailsTextColor = _detailsTextColor;

static ADFullScreenDetailView *sharedDetailView;

#pragma mark Getters and Setters

+ (ADFullScreenDetailView *)sharedInstance
{
    if (!sharedDetailView) {
        sharedDetailView = [[ADFullScreenDetailView alloc] init];
    }
    return sharedDetailView;
}

- (UIColor *)backgroundColor
{
    if (!_backgroundColor) {
        _backgroundColor = [UIColor whiteColor];
    }
    return _backgroundColor;
}

- (void)setBackgroundColor:(UIColor *)backgroundColor
{
    if (_backgroundColor != backgroundColor) {
        _backgroundColor = backgroundColor;
        self.mainView.backgroundColor = backgroundColor;
    }
}

- (UIFont *)titleFont
{
    if (!_titleFont) {
        _titleFont = [UIFont fontWithName:@"Helvetica" size:16.0];
    }
    return _titleFont;
}

- (void)setTitleFont:(UIFont *)titleFont
{
    if (_titleFont != titleFont) {
        _titleFont = titleFont;
        self.titleLabel.font = titleFont;
    }
}

- (UIFont *)detailsFont
{
    if (!_detailsFont) {
        _detailsFont = [UIFont fontWithName:@"Helvetica" size:15.0];
    }
    return _detailsFont;
}

- (void)setDetailsFont:(UIFont *)detailsFont
{
    if (_detailsFont != detailsFont) {
        _detailsFont = detailsFont;
        self.detailsView.font = _detailsFont;
    }
}

- (UIColor *)titleTextColor
{
    if (!_titleTextColor) {
        _titleTextColor = [UIColor darkTextColor];
    }
    return _titleTextColor;
}

- (void)setTitleTextColor:(UIColor *)titleTextColor
{
    if (_titleTextColor != titleTextColor) {
        _titleTextColor = titleTextColor;
        self.titleLabel.textColor = _titleTextColor;
    }
}

- (UIColor *)detailsTextColor
{
    if (!_detailsTextColor) {
        _detailsTextColor = [UIColor darkTextColor];
    }
    return _detailsTextColor;
}

- (void)setDetailsTextColor:(UIColor *)detailsTextColor
{
    if (_detailsTextColor != detailsTextColor) {
        _detailsTextColor = detailsTextColor;
        self.detailsView.textColor = _detailsTextColor;
    }
}

- (NSString *)currentTitle
{
    if (!_currentTitle) {
        _currentTitle = @"";
    }
    return _currentTitle;
}

- (NSString *)currentText
{
    if (!_currentText) {
        _currentText = @"";
    }
    return _currentText;
}

- (void)setSelectedIndex:(NSUInteger)selectedIndex
{
    if (_selectedIndex != selectedIndex || selectedIndex == 0) {
        _selectedIndex = selectedIndex;
        
        if (_selectedIndex != NSNotFound) {
            if ([self.info count] > 0 && _selectedIndex < [self.info count]) {
                id object = [self.info objectAtIndex:_selectedIndex];
                if ([object isKindOfClass:[NSDictionary class]]) {
                    NSDictionary *dictionary = (NSDictionary *)object;
                    if ([dictionary objectForKey:AD_TITLE_KEY]) {
                        self.currentTitle = [dictionary objectForKey:AD_TITLE_KEY];
                    }
                    if ([dictionary objectForKey:AD_DETAILS_KEY]) {
                        self.currentText = [dictionary objectForKey:AD_DETAILS_KEY];
                    }
                }
            }
            self.previousButton.enabled = (_selectedIndex > 0) ? YES : NO;
            self.nextButton.enabled = (_selectedIndex < self.info.count-1) ? YES : NO;
        } else {
            self.previousButton.enabled = NO;
            self.nextButton.enabled = NO;
        }
    }
}

- (void)setCanScroll:(BOOL)canScroll
{
    if (_canScroll != canScroll) {
        _canScroll = canScroll;
        
        if (_canScroll) {
            self.detailsView.showsVerticalScrollIndicator = YES;
        } else {
            self.detailsView.showsVerticalScrollIndicator = NO;
        }
    }
}

- (void)setHasNavigationButtons:(BOOL)hasNavigationButtons
{
    if (_hasNavigationButtons != hasNavigationButtons) {
        _hasNavigationButtons = hasNavigationButtons;
    }
}

#pragma mark Initialization

- (id)init
{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceOrientationDidChange:) name:UIDeviceOrientationDidChangeNotification object:nil];
        
        self.isActive = NO;
        self.hasNavigationButtons = YES;
        self.window = [[UIApplication sharedApplication] keyWindow];
        [self setupRootView];
    }
    return self;
}

#pragma mark Setup
- (void)setupRootView
{
    self.rootView = [[UIView alloc] initWithFrame:self.window.rootViewController.view.bounds];
    self.rootView.backgroundColor = [UIColor clearColor];
    
    self.rootView.autoresizesSubviews = YES;
    self.rootView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dimmedViewTapped:)];
    [self.rootView addGestureRecognizer:tap];
    
    [self setupMainView];
}

- (void)setupMainView
{
    CGFloat height = [self titleLabelHeight]+[self textLabelHeight]+[self buttonViewHeight];
    
    self.mainView = [[UIView alloc] initWithFrame:CGRectMake(0.0, -height, self.window.rootViewController.view.bounds.size.width, height)];
    self.mainView.backgroundColor = self.backgroundColor;
    
    self.mainView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    [self setupTitleView];
    [self setupTextView];
    [self setupButtonView];
    [self.rootView addSubview:self.mainView];
}

- (void)setupTitleView
{
    self.titleView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.mainView.bounds.size.width, [self titleLabelHeight])];
    self.titleView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.titleView.backgroundColor = [UIColor clearColor];
    
    if (!self.titleBorderLayer) {
        self.titleBorderLayer = [CALayer layer];
    }
    self.titleBorderLayer.frame = CGRectMake(0.0f, self.titleView.bounds.size.height-1.0, self.titleView.bounds.size.width, 0.5f);
    self.titleBorderLayer.backgroundColor = [UIColor grayColor].CGColor;
    [self.titleView.layer addSublayer:self.titleBorderLayer];

    
    CGRect titleFrame = CGRectInset(self.titleView.bounds, 10.0, 10.0);
    titleFrame.size.width -= 55.0;
    
    self.titleLabel = [[UILabel alloc] initWithFrame:titleFrame];
    self.titleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.titleLabel.backgroundColor = [UIColor clearColor];
    self.titleLabel.font = self.titleFont;
    self.titleLabel.textColor = self.titleTextColor;
    self.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.titleLabel.numberOfLines = 0;
    self.titleLabel.text = self.currentTitle;
    
    CGRect buttonFrame = CGRectMake(self.titleView.frame.size.width-50.0, self.titleView.frame.size.height/2.0-20.0, 40.0, 40.0);
    
    UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [closeButton addTarget:self action:@selector(closeButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    closeButton.frame = buttonFrame;
    closeButton.tag = 9;
    [closeButton setTitle:@"Close" forState:UIControlStateNormal];
    [closeButton setTintColor:[UIColor colorWithRed:0.0 green:190.0/255.0 blue:236.0/255.0 alpha:1.0]];
;
    
    [self.titleView addSubview:self.titleLabel];
    [self.titleView addSubview:closeButton];
    [self.mainView addSubview:self.titleView];
}

- (void)setupTextView
{
    CGRect textFrame = CGRectMake(10.0, [self titleLabelHeight], self.window.rootViewController.view.bounds.size.width-20.0, [self textLabelHeight]);
    
    self.detailsView = [[UITextView alloc] initWithFrame:textFrame];
    self.detailsView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.detailsView.font = self.detailsFont;
    self.detailsView.textColor = self.detailsTextColor;
    self.detailsView.backgroundColor = [UIColor clearColor];
    self.detailsView.text = self.currentText;
    self.detailsView.editable = NO;
    self.detailsView.showsVerticalScrollIndicator = NO;
    self.detailsView.showsHorizontalScrollIndicator = NO;
    self.detailsView.scrollEnabled = YES;
    
    [self.mainView addSubview:self.detailsView];
}

- (void)setupButtonView
{
    CGRect buttonViewFrame = CGRectMake(0.0, [self titleLabelHeight]+[self textLabelHeight], self.window.rootViewController.view.bounds.size.width, 44.0);
    
    self.buttonView = [[UIView alloc] initWithFrame:buttonViewFrame];
    self.buttonView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.buttonView.backgroundColor = [UIColor clearColor];
    
    self.previousButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.previousButton setTitle:@"Previous" forState:UIControlStateNormal];
    [self.previousButton setTitleColor:[UIColor colorWithRed:88.0/255.0 green:167.0/255.0 blue:0.0 alpha:1.0] forState:UIControlStateNormal];
    [self.previousButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
    CGRect backButtonFrame = CGRectMake(5.0, 5.0, 75.0, 34.0);
    self.previousButton.frame = backButtonFrame;
    [self.previousButton addTarget:self action:@selector(previousButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.buttonView addSubview:self.previousButton];
    
    self.nextButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.nextButton setTitle:@"Next" forState:UIControlStateNormal];
    [self.nextButton setTitleColor:[UIColor colorWithRed:88.0/255.0 green:167.0/255.0 blue:0.0 alpha:1.0] forState:UIControlStateNormal];
    [self.nextButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
    CGRect nextButtonFrame = CGRectMake(self.buttonView.bounds.size.width-45.0, 5.0, 40.0, 34.0);
    self.nextButton.frame = nextButtonFrame;
    [self.nextButton addTarget:self action:@selector(nextButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.buttonView addSubview:self.nextButton];
    
    if (!self.textBorderLayer) {
        self.textBorderLayer = [CALayer layer];
    }
    self.textBorderLayer.frame = CGRectMake(0.0f, 1.0f, self.window.rootViewController.view.bounds.size.width, 0.5f);
    self.textBorderLayer.backgroundColor = [UIColor grayColor].CGColor;
    [self.buttonView.layer addSublayer:self.textBorderLayer];
    
    [self.mainView addSubview:self.buttonView];
}

- (void)showIndex:(NSUInteger)index inViewController:(UIViewController *)viewController
{
    self.viewController = viewController;
    self.selectedIndex = index;
    [self layoutViews];
    [self present];
}

- (void)showTitle:(NSString *)title details:(NSString *)details inViewController:(UIViewController *)viewController
{
    self.viewController = viewController;
    self.selectedIndex = NSNotFound;
    self.currentTitle = title;
    self.currentText = details;
    [self layoutViews];
    [self present];
}

- (void)remove
{
    self.isActive = NO;
    
    CGRect mainViewFrame = self.mainView.frame;
    mainViewFrame.origin.y = -mainViewFrame.size.height;
    
    [UIView animateWithDuration:ANIMATION_TIME animations:^{
        self.rootView.backgroundColor = [UIColor clearColor];
        self.mainView.frame = mainViewFrame;
    } completion:^(BOOL finished) {
        [self.rootView removeFromSuperview];
    }];
}

#pragma mark Helpers

- (void)present
{
    if (!self.isActive) {
        
        self.isActive = YES;
        
        if (self.owningViewControllerIsPresentedModally) {
            [self.viewController.view addSubview:self.rootView];
        } else {
            [self.window.rootViewController.view addSubview:self.rootView];
        }
        
        CGRect mainViewFrame = self.mainView.frame;
        mainViewFrame.origin.y = 20;
        
        [UIView animateWithDuration:ANIMATION_TIME animations:^{
            self.rootView.backgroundColor = [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:0.5];
            self.mainView.frame = mainViewFrame;
            
        } completion:^(BOOL finished) {
            
        }];
    }
}

- (CGFloat)titleLabelHeight
{
    CGSize maxSize = CGSizeMake(self.window.rootViewController.view.bounds.size.width-75.0, MAXFLOAT);
    CGSize labelSize = [self.currentTitle sizeWithFont:[UIFont fontWithName:@"Helvetica" size:16.0] constrainedToSize:maxSize lineBreakMode:NSLineBreakByWordWrapping];
    
    return MAX(44.0, labelSize.height+20.0);
}

- (CGFloat)textLabelHeight
{
    CGSize maxSize = CGSizeMake(self.window.rootViewController.view.bounds.size.width-30.0, MAXFLOAT);
    CGSize labelSize = [self.currentText sizeWithFont:self.detailsFont constrainedToSize:maxSize lineBreakMode:NSLineBreakByWordWrapping];
    
    if (labelSize.height+20.0 > [self maxDetailsHeight]) {
        return [self maxDetailsHeight];
    }
    
    return labelSize.height + 20.0;
}

- (CGFloat)buttonViewHeight
{
    return 44.0;
}

- (CGFloat)maxDetailsHeight
{
    CGFloat maxHeight = self.window.rootViewController.view.bounds.size.height;
    maxHeight -= [self titleLabelHeight];
    maxHeight -= [self buttonViewHeight];
    maxHeight -= 20.0;
    
    return maxHeight;
}

- (void)layoutViews
{
    [UIView animateWithDuration:ANIMATION_TIME animations:^{
        self.titleLabel.text = self.currentTitle;
        self.detailsView.text = self.currentText;
        
        self.rootView.frame = self.window.rootViewController.view.bounds;

        CGFloat height = [self titleLabelHeight]+[self textLabelHeight];
        
        if (self.hasNavigationButtons) {
            height += [self buttonViewHeight];
        }
        
        if (self.isActive) {
            self.mainView.frame = CGRectMake(0.0, 20.0, self.window.rootViewController.view.bounds.size.width, height);
        
        } else {
            self.mainView.frame = CGRectMake(0.0, -height, self.window.rootViewController.view.bounds.size.width, height);
        }
        
        self.titleView.frame = CGRectMake(0.0, 0.0, self.mainView.bounds.size.width, [self titleLabelHeight]);
        
        CGRect titleFrame = CGRectInset(self.titleView.bounds, 10.0, 10.0);
        titleFrame.size.width -= 55.0;
        self.titleLabel.frame = titleFrame;
        
        for (UIView *subView in self.titleView.subviews) {
            if (subView.tag == 9) {
                subView.frame = CGRectMake(self.titleView.frame.size.width-50.0, self.titleView.frame.size.height/2.0-20.0, 40.0, 40.0);
            }
        }
        
        self.titleBorderLayer.frame = CGRectMake(0.0f, self.titleView.bounds.size.height-1.0, self.titleView.bounds.size.width, 0.5f);
        self.detailsView.frame = CGRectMake(10.0, [self titleLabelHeight], self.window.rootViewController.view.bounds.size.width-20.0, [self textLabelHeight]);
        
        self.textBorderLayer.frame = CGRectMake(0.0f, 1.0, self.window.rootViewController.view.bounds.size.width, 0.5f);
        
        self.buttonView.frame = CGRectMake(0.0, [self titleLabelHeight]+[self textLabelHeight], self.window.rootViewController.view.bounds.size.width, [self buttonViewHeight]);
        
        CGRect nextButtonFrame = CGRectMake(self.buttonView.bounds.size.width-45.0, 5.0, 40.0, 34.0);
        self.nextButton.frame = nextButtonFrame;
        CGRect backButtonFrame = CGRectMake(5.0, 5.0, 75.0, 34.0);
        self.previousButton.frame = backButtonFrame;
        
    } completion:^(BOOL finished) {
        if ([self textLabelHeight] == [self maxDetailsHeight]) {
            self.canScroll = YES;
        } else {
            self.canScroll = NO;
        }
        
        self.buttonView.hidden = !self.hasNavigationButtons;
    }];
}

#pragma mark Button Responders

- (void)closeButtonClicked:(UIButton *)button
{
    [self remove];
}

- (void)previousButtonClicked:(UIButton *)button
{
    self.selectedIndex--;
    [self layoutViews];
}

- (void)nextButtonClicked:(UIButton *)button
{
    self.selectedIndex++;
    [self layoutViews];
}

- (void)dimmedViewTapped:(UITapGestureRecognizer *)tap
{
    CGPoint pointInView = [tap locationInView:self.rootView];
    CGFloat height = [self titleLabelHeight]+[self textLabelHeight]+[self buttonViewHeight]+20.0;
    
    if (pointInView.y >= height) {
        [self remove];
    }
}

- (void)deviceOrientationDidChange:(NSNotification *)notification
{
    [self layoutViews];
}


@end
