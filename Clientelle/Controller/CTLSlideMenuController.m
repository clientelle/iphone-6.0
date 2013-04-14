//
//  RWSSlideMenuViewController.m
//  Created by Samuel Goodwin on 1/17/13.
//  Copyright (c) 2013 Roundwall Software. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>

#import "CTLSlideMenuController.h"
#import "CTLMainMenuViewController.h"

const CGFloat CTLMainMenuWidth = 190.0f;

@implementation CTLSlideMenuController

- (id)initWithIdentifier:(NSString *)identifier
{
    self = [super init];
    self.mainStoryboard = [UIStoryboard storyboardWithName:@"Clientelle" bundle: nil];
    
    if(self){
        
        CGRect frame = self.view.bounds;
        
        CTLMainMenuViewController *menuViewController = [self.mainStoryboard instantiateInitialViewController];
        [self setLeftPanel:menuViewController withFrame:frame];
        [self setActiveMenuItem:identifier];
        
        UINavigationController *navigationController = (UINavigationController *)[self.mainStoryboard instantiateViewControllerWithIdentifier:identifier];
        
        [self setRightPanel:navigationController withFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(frame), CGRectGetHeight(frame))];
        [self setShadow:navigationController];
    }

    return self;
}

- (id)initWithIdentifier:(NSString *)identifier viewController:(UIViewController<CTLSlideMenuDelegate> *)viewController
{
    self = [super init];
    self.mainStoryboard = [UIStoryboard storyboardWithName:@"Clientelle" bundle: nil];
    
    if(self){
        
        CGRect frame = self.view.bounds;
        CGRect viewFrame = CGRectMake(0.0f, 0.0f, CGRectGetWidth(frame), CGRectGetHeight(frame));
        
        CTLMainMenuViewController *menuViewController = [self.mainStoryboard instantiateInitialViewController];
        [self setLeftPanel:menuViewController withFrame:frame];
        [self setActiveMenuItem:identifier];
        
        self.mainNavigationController = [self.mainStoryboard instantiateViewControllerWithIdentifier:identifier];
        self.mainViewController = viewController;
        self.mainViewController.menuController = self;

        [self renderMenuButton:(UIViewController<CTLSlideMenuDelegate> *)self.mainNavigationController.topViewController];
        [self.mainNavigationController pushViewController:viewController animated:NO];

        [self addChildViewController:self.mainNavigationController];

        self.mainNavigationController.view.frame = viewFrame;
        [self.view addSubview:self.mainNavigationController.view];
        [self setShadow:self.mainNavigationController];
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.rightSwipeEnabled = YES;
    
    UISwipeGestureRecognizer *swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeLeft:)];
    [swipeLeft setDirection:UISwipeGestureRecognizerDirectionLeft];
    [self.view addGestureRecognizer:swipeLeft];
    
    UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeRight:)];
    [swipeRight setDirection:UISwipeGestureRecognizerDirectionRight];
    [self.view addGestureRecognizer:swipeRight];
}

-(void)handleSwipeLeft:(UISwipeGestureRecognizer*)recognizer
{
    if(self.mainNavigationController.view.frame.origin.x != 0){
        [self hideMenu];
    }
}

-(void)handleSwipeRight:(UISwipeGestureRecognizer*)recognizer
{
    if(self.rightSwipeEnabled && self.mainNavigationController.view.frame.origin.x == 0){
        [self showMenu];
    }
}

#pragma mark - Set Panels

- (void)setLeftPanel:(CTLMainMenuViewController *)leftPanel withFrame:(CGRect)frame
{
    frame.size.width = CTLMainMenuWidth;
    leftPanel.view.frame = frame;
    self.panel = leftPanel;
    [self.panel setMenuController:self];
    [self addChildViewController:self.panel];
    [self.view addSubview:self.panel.view];
}

- (void)setMainView:(NSString *)identifier
{
    UINavigationController *navigationController = [self.mainStoryboard instantiateViewControllerWithIdentifier:identifier];
    
    CGFloat width = CGRectGetWidth(self.view.bounds);
    CGFloat height = CGRectGetHeight(self.view.bounds);
    
    if(self.mainNavigationController){
        [self.mainNavigationController removeFromParentViewController];
        [self.mainNavigationController.view removeFromSuperview];
    }
    
    [self setRightPanel:navigationController withFrame:CGRectMake(CTLMainMenuWidth, 0.0f, width, height)];
    
    [UIView animateWithDuration:0.3 animations:^{
        self.mainNavigationController.view.frame = CGRectMake(0.0f, 0.0f, width, height);
    }];

    [self setShadow:navigationController];
}

- (void)setShadow:(UINavigationController *)mainView
{
    CGPathRef shadowPath = [UIBezierPath bezierPathWithRect:mainView.view.bounds].CGPath;
    [mainView.view.layer setShadowPath:shadowPath];
    
    mainView.view.layer.shadowOpacity = 0.85f;
    mainView.view.layer.shadowRadius = 5.0f;
    mainView.view.layer.shadowOffset = CGSizeMake(-3, 0);
}

- (void)flipToView
{
    [self.mainViewController setMenuController:self];
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration: 1];
    [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:self.view cache:YES];
    [self.mainNavigationController pushViewController:self.mainViewController animated:NO];
    [UIView commitAnimations];
}

- (void)transitionToView:(UIViewController<CTLSlideMenuDelegate> *)viewController withAnimationStyle:(UIViewAnimationTransition)animationStyle
{
    self.mainViewController = viewController;
    [self.mainViewController setMenuController:self];
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration: 1];
    [UIView setAnimationTransition:animationStyle forView:self.view cache:YES];
    [self.mainNavigationController pushViewController:self.mainViewController animated:NO];
    [UIView commitAnimations];
}

- (void)renderMenuButton:(UIViewController<CTLSlideMenuDelegate> *)viewController
{
    UIBarButtonItem *menuButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"menu.png"] style:UIBarButtonItemStyleBordered target:self action:@selector(toggleMenu:)];
    viewController.navigationItem.leftBarButtonItem = menuButton;
}

- (void)setRightPanel:(UINavigationController *)rightNavigationController withFrame:(CGRect)frame
{
    self.mainNavigationController = rightNavigationController;
    self.mainViewController = (UIViewController<CTLSlideMenuDelegate> *)rightNavigationController.topViewController;
        
    [self renderMenuButton:self.mainViewController];
    [self.mainViewController setMenuController:self];
    [self addChildViewController:self.mainNavigationController];
    self.mainNavigationController.view.frame = frame;
    [self.view addSubview:self.mainNavigationController.view];
}

- (void)setActiveMenuItem:(NSString *)identifier
{
    NSArray *menuItems = self.panel.menuItems;
    NSInteger selectedRowIndex = 0;
    
    for(NSInteger i=0; i<[menuItems count];i++){
        if([menuItems[i][@"identifier"] isEqualToString:identifier]){
            selectedRowIndex = i;
            break;
        }
    }
    
    [self.panel setSelectedIndexPath:[NSIndexPath indexPathForRow:selectedRowIndex inSection:0]];
}

#pragma mark - Toggle Menu

- (void)toggleMenu:(id)sender
{
    if(self.mainNavigationController.view.frame.origin.x == 0){
        [self showMenu];
    }else{
        [self hideMenu];
    }
}

-(void)showMenu
{
    [self.view endEditing:YES];
    CGRect mainFrame = self.mainNavigationController.view.frame;
    CGRect movedFrame = CGRectMake(self.panel.view.frame.size.width, mainFrame.origin.y, mainFrame.size.width, mainFrame.size.height);
    [UIView animateWithDuration:0.3 animations:^{
        [self.mainNavigationController.view setFrame:movedFrame];
    }];
}

-(void)hideMenu
{
    CGRect mainFrame = self.mainNavigationController.view.frame;
    CGRect movedFrame = CGRectMake(0, mainFrame.origin.y, mainFrame.size.width, mainFrame.size.height);
    [UIView animateWithDuration:0.3 animations:^{
        [self.mainNavigationController.view setFrame:movedFrame];
    }];
}

- (BOOL)isCurrentViewIsModal
{
    UIViewController *presentedViewController = self.mainViewController.presentedViewController;
    
    BOOL presentedViewHasNavigationController = [presentedViewController isKindOfClass:[UINavigationController class]];
    
    return presentedViewHasNavigationController == NO && presentedViewController != nil;
}

//UILocationNotification in AppDelegate prompts user to open cooresponding view
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 0){
        self.nextViewController = nil;
        return;
    }
    
    if(buttonIndex == 1){

        UINavigationController *presentedNavigationController = self.mainNavigationController;
        UIViewController *presentedViewController = self.mainViewController.presentedViewController;
        
        BOOL presentedViewHasNavigationController = [presentedViewController isKindOfClass:[UINavigationController class]];
        BOOL presentedViewIsModal = presentedViewHasNavigationController == NO && presentedViewController != nil;
        
        if(presentedViewHasNavigationController){
            presentedNavigationController = (UINavigationController *)presentedViewController;
        }

        if(presentedViewIsModal){
            self.nextViewController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"CLOSE", nil) style:UIBarButtonSystemItemCancel target:self.nextViewController action:@selector(dismiss:)];
            UINavigationController *tmpNavController = [[UINavigationController alloc] initWithRootViewController:self.nextViewController];
                        
            tmpNavController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
            [presentedViewController presentViewController:tmpNavController animated:YES completion:nil];
            
        }else{

            [UIView beginAnimations:nil context:NULL];
            [UIView setAnimationDuration: 1];
            [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:self.view cache:YES];
            [presentedNavigationController pushViewController:self.nextViewController animated:NO];
            [UIView commitAnimations];
        }
    }
}

@end
