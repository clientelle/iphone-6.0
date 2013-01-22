//
//  RWSTwoPanelViewController.m
//  Created by Samuel Goodwin on 1/17/13.
//  Copyright (c) 2013 Roundwall Software. All rights reserved.
//

#import "RWSTwoPanelViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface RWSTwoPanelViewController()

@end

const CGFloat CTLMainMenuWidth = 215.0f;

@implementation RWSTwoPanelViewController

- (id)initWithPanels:(UIViewController<RWSPanelController> *)leftPanel andRightPanel:(UINavigationController *)rightPanel
{
    self = [super init];
    if(self){

        _isOpened = NO;
        
        CGRect frame = self.view.bounds;
        CGFloat width = CGRectGetWidth(frame);
        CGFloat height = CGRectGetHeight(frame);
        
        [self setLeftPanel:leftPanel withFrame:frame];
        [self setRightPanel:rightPanel withFrame:CGRectMake(0.0f, 0.0f, width, height)];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UISwipeGestureRecognizer *swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeLeft:)];
    [swipeLeft setDirection:UISwipeGestureRecognizerDirectionLeft];
    [self.view addGestureRecognizer:swipeLeft];
    
    UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeRight:)];
    [swipeRight setDirection:UISwipeGestureRecognizerDirectionRight];
    [self.view addGestureRecognizer:swipeRight];
}

- (void)setDetailPanel:(UINavigationController*)detail
{
    if(self.detail){
        [self.detail removeFromParentViewController];
    }
    
    [self animateInDetail:detail];
}

- (void)animateInDetail:(UINavigationController *)detail
{
    CGFloat width = CGRectGetWidth(self.view.bounds);
    CGFloat height = CGRectGetHeight(self.view.bounds);
    
    [self setRightPanel:detail withFrame:CGRectMake(CTLMainMenuWidth, 0.0f, width, height)];

    [UIView animateWithDuration:0.3 animations:^{
        self.detail.view.frame = CGRectMake(0.0f, 0.0f, width, height);
    }];
}

- (void)setLeftPanel:(UIViewController<RWSPanelController> *)leftPanel withFrame:(CGRect)frame
{
    frame.size.width = CTLMainMenuWidth;
    leftPanel.view.frame = frame;
    self.panel = leftPanel;
    [self.panel setTwoPanelViewController:self];
    [self addChildViewController:self.panel];
    [self.view addSubview:self.panel.view];
}

- (void)setRightPanel:(UINavigationController *)rightNavigationController withFrame:(CGRect)frame
{
    UIViewController<RWSDetailPanel> *rightViewController = (UIViewController <RWSDetailPanel>*)rightNavigationController.topViewController;
    [rightViewController setTwoPanelViewController:self];
    self.detail = rightNavigationController;
    [self addChildViewController:self.detail];
    self.detail.view.frame = frame;
    [self.view addSubview:self.detail.view];
}

- (void)toggleMenu:(id)sender
{
    if(self.detail.view.frame.origin.x == 0){
        [self showMenu];
    }else{
        [self hideMenu];
    }
}

-(void)showMenu
{
    [UIView animateWithDuration:0.3 animations:^{
        [self.detail.view setFrame:CGRectMake(self.panel.view.frame.size.width, self.detail.view.frame.origin.y, self.detail.view.frame.size.width, self.detail.view.frame.size.height)];
    }];
    _isOpened = YES;
}

-(void)hideMenu
{
    [UIView animateWithDuration:0.3 animations:^{
        [self.detail.view setFrame:CGRectMake(0, self.detail.view.frame.origin.y, self.detail.view.frame.size.width, self.detail.view.frame.size.height)];
    }];
    _isOpened = NO;
}

#pragma mark - Gesture handlers -

-(void)handleSwipeLeft:(UISwipeGestureRecognizer*)recognizer
{
    if(self.detail.view.frame.origin.x != 0){
        [self hideMenu];
    }
}

-(void)handleSwipeRight:(UISwipeGestureRecognizer*)recognizer
{
    if(self.detail.view.frame.origin.x == 0){
        [self showMenu];
    }
}

@end
