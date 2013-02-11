//
//  RWSSlideMenuViewController.m
//  Created by Samuel Goodwin on 1/17/13.
//  Copyright (c) 2013 Roundwall Software. All rights reserved.
//

#import "CTLSlideMenuController.h"
#import <QuartzCore/QuartzCore.h>

const CGFloat CTLMainMenuWidth = 170.0f;

@implementation CTLSlideMenuController

- (id)initWithMenu:(UIViewController<CTLSlideMenuDelegate> *)menuView mainView:(UINavigationController *)mainView
{
    self = [super init];

    if(self){
        CGRect frame = self.view.bounds;
        [self setLeftPanel:menuView withFrame:frame];
        [self setRightPanel:mainView withFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(frame), CGRectGetHeight(frame))];
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
    if(self.mainViewNavController.view.frame.origin.x != 0){
        [self hideMenu];
    }
}

-(void)handleSwipeRight:(UISwipeGestureRecognizer*)recognizer
{
    if(self.mainViewNavController.view.frame.origin.x == 0){
        [self showMenu];
    }
}


#pragma mark - Set Panels

- (void)setLeftPanel:(UIViewController<CTLSlideMenuDelegate> *)leftPanel withFrame:(CGRect)frame
{
    frame.size.width = CTLMainMenuWidth;
    leftPanel.view.frame = frame;
    self.panel = leftPanel;
    [self.panel setMenuController:self];
    [self addChildViewController:self.panel];
    [self.view addSubview:self.panel.view];
}

- (void)setMainView:(NSString *)navigationControllerName
{
    UINavigationController *navigationController = (UINavigationController *)[self.mainStoryboard instantiateViewControllerWithIdentifier:navigationControllerName];
    
    if(self.mainViewNavController){
        [self.mainViewNavController removeFromParentViewController];
        [self.mainViewNavController.view removeFromSuperview];
    }
    
    CGFloat width = CGRectGetWidth(self.view.bounds);
    CGFloat height = CGRectGetHeight(self.view.bounds);
    [self setRightPanel:navigationController withFrame:CGRectMake(CTLMainMenuWidth, 0.0f, width, height)];
    [UIView animateWithDuration:0.3 animations:^{
        self.mainViewNavController.view.frame = CGRectMake(0.0f, 0.0f, width, height);
    }];
}

- (void)setRightPanel:(UINavigationController *)rightNavigationController withFrame:(CGRect)frame
{
    UIViewController<CTLSlideMenuDelegate> *mainViewController = (UIViewController<CTLSlideMenuDelegate> *)rightNavigationController.topViewController;
    
    //set view main menu button
    mainViewController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"38-house.png"] style:UIBarButtonItemStyleBordered target:self action:@selector(toggleMenu:)];
    
    [mainViewController setMenuController:self];
    self.mainViewNavController = rightNavigationController;
    [self addChildViewController:self.mainViewNavController];
    self.mainViewNavController.view.frame = frame;
    [self.view addSubview:self.mainViewNavController.view];
}

#pragma mark - Toggle Menu

- (void)toggleMenu:(id)sender
{
    if(self.mainViewNavController.view.frame.origin.x == 0){
        [self showMenu];
    }else{
        [self hideMenu];
    }
}

-(void)showMenu
{
    [self.view endEditing:YES];
    CGRect mainFrame = self.mainViewNavController.view.frame;
    CGRect movedFrame = CGRectMake(self.panel.view.frame.size.width, mainFrame.origin.y, mainFrame.size.width, mainFrame.size.height);
    [UIView animateWithDuration:0.3 animations:^{
        [self.mainViewNavController.view setFrame:movedFrame];
    }];
}

-(void)hideMenu
{
    CGRect mainFrame = self.mainViewNavController.view.frame;
    CGRect movedFrame = CGRectMake(0, mainFrame.origin.y, mainFrame.size.width, mainFrame.size.height);
    [UIView animateWithDuration:0.3 animations:^{
        [self.mainViewNavController.view setFrame:movedFrame];
    }];
}

@end
