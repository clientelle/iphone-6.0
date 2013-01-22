//
//  RWSTwoPanelViewController.m
//  Created by Samuel Goodwin on 1/17/13.
//  Copyright (c) 2013 Roundwall Software. All rights reserved.
//

#import "RWSTwoPanelViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface RWSTwoPanelViewController()

@end

const CGFloat CTLMainMenuWidth = 170.0f;

@implementation RWSTwoPanelViewController

- (id)initWithMenu:(UIViewController<RWSPanelController> *)menuPanel andRightPanel:(UINavigationController *)rightPanel
{
    self = [super init];
    if(self){
        CGRect frame = self.view.bounds;
        [self setLeftPanel:menuPanel withFrame:frame];
        [self setRightPanel:rightPanel withFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(frame), CGRectGetHeight(frame))];
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

-(void)handleSwipeLeft:(UISwipeGestureRecognizer*)recognizer
{
    if(self.navigationController.view.frame.origin.x != 0){
        [self hideMenu];
    }
}

-(void)handleSwipeRight:(UISwipeGestureRecognizer*)recognizer
{
    if(self.navigationController.view.frame.origin.x == 0){
        [self showMenu];
    }
}

#pragma mark - Set Panels

- (void)setMainView:(UINavigationController*)navigationController
{
    if(self.navigationController){
        [self.navigationController removeFromParentViewController];
    }
    
    CGFloat width = CGRectGetWidth(self.view.bounds);
    CGFloat height = CGRectGetHeight(self.view.bounds);
    
    [self setRightPanel:navigationController withFrame:CGRectMake(CTLMainMenuWidth, 0.0f, width, height)];
    
    [UIView animateWithDuration:0.3 animations:^{
        self.navigationController.view.frame = CGRectMake(0.0f, 0.0f, width, height);
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
    self.navigationController = rightNavigationController;
    [self addChildViewController:self.navigationController];
    self.navigationController.view.frame = frame;
    [self.view addSubview:self.navigationController.view];
}

#pragma mark - Toggle Menu

- (void)toggleMenu:(id)sender
{
    if(self.navigationController.view.frame.origin.x == 0){
        [self showMenu];
    }else{
        [self hideMenu];
    }
}

-(void)showMenu
{
    [UIView animateWithDuration:0.3 animations:^{
        [self.navigationController.view setFrame:CGRectMake(self.panel.view.frame.size.width, self.navigationController.view.frame.origin.y, self.navigationController.view.frame.size.width, self.navigationController.view.frame.size.height)];
    }];
}

-(void)hideMenu
{
    [UIView animateWithDuration:0.3 animations:^{
        [self.navigationController.view setFrame:CGRectMake(0, self.navigationController.view.frame.origin.y, self.navigationController.view.frame.size.width, self.navigationController.view.frame.size.height)];
    }];
}

@end
