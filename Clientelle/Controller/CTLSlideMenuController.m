//
//  CTLSlideMenuController.m
//  Created by Kevin Liu on 1/17/13.
//  Copyright (c) 2013 Clientelle. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>
#import "CTLCDAppointment.h"
#import "CTLCDAccount.h"

#import "CTLSlideMenuController.h"
#import "CTLMainMenuViewController.h"
#import "CTLAppointmentFormViewController.h"
#import "CTLPinInterstialViewController.h"

const CGFloat CTLMainMenuWidth = 80.0f;
NSString *const CTLDefaultNavigationControllerIdentifier = @"appointmentsNavigationController";


@implementation CTLSlideMenuController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupMenuView:self.view.bounds];

    if(!self.mainViewControllerIdentifier){
        self.mainViewControllerIdentifier = CTLDefaultNavigationControllerIdentifier;
        UINavigationController *navigationController = [self.storyboard instantiateViewControllerWithIdentifier:self.mainViewControllerIdentifier];
        [self setRightPanel:navigationController withFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds))];
    }
}

-  (void)setupMenuView:(CGRect)frame
{
    CTLMainMenuViewController *menuViewController = (CTLMainMenuViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"mainMenuViewController"];
    [menuViewController setMenuController:self];
    frame.size.width = CTLMainMenuWidth;
    menuViewController.view.frame = frame;
    [self addChildViewController:menuViewController];
    [self.view addSubview:menuViewController.view];

    self.rightSwipeEnabled = NO;
    
    UISwipeGestureRecognizer *swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeLeft:)];
    [swipeLeft setDirection:UISwipeGestureRecognizerDirectionLeft];
    [self.view addGestureRecognizer:swipeLeft];
    
    UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeRight:)];
    [swipeRight setDirection:UISwipeGestureRecognizerDirectionRight];
    [self.view addGestureRecognizer:swipeRight];
}

#pragma mark - UI Controls

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

- (IBAction)toggleMenu:(id)sender
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
    CGRect movedFrame = CGRectMake(CTLMainMenuWidth, mainFrame.origin.y, mainFrame.size.width, mainFrame.size.height);
    
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

#pragma mark - Set Panels

- (void)setMainView:(NSString *)identifier
{
    if(self.mainNavigationController){
        [self.mainNavigationController removeFromParentViewController];
        [self.mainNavigationController.view removeFromSuperview];
    }
    
    CGFloat width = CGRectGetWidth(self.view.bounds);
    CGFloat height = CGRectGetHeight(self.view.bounds);
    
    UINavigationController *navigationController = [self.storyboard instantiateViewControllerWithIdentifier:identifier];
    
    [self setRightPanel:navigationController withFrame:CGRectMake(CTLMainMenuWidth, 0.0f, width, height)];
    
    [UIView animateWithDuration:0.3 animations:^{
        self.mainNavigationController.view.frame = CGRectMake(0.0f, 0.0f, width, height);
    }];

    [self setShadow:navigationController];
}

- (void)setShadow:(UINavigationController *)mainView
{
    mainView.view.layer.shadowPath = [UIBezierPath bezierPathWithRect:mainView.view.bounds].CGPath;
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
    UIBarButtonItem *menuButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"menu"] style:UIBarButtonItemStyleBordered target:self action:@selector(toggleMenu:)];
    viewController.navigationItem.leftBarButtonItem = menuButton;
}

- (void)setRightPanel:(UINavigationController *)rightNavigationController withFrame:(CGRect)frame
{
    if(self.mainNavigationController){
        [self.mainNavigationController removeFromParentViewController];
        [self.mainNavigationController.view removeFromSuperview];
    }
    
    self.mainNavigationController = rightNavigationController;
    self.mainViewController = (UIViewController<CTLSlideMenuDelegate> *)rightNavigationController.topViewController;
        
    [self renderMenuButton:self.mainViewController];
    [self.mainViewController setMenuController:self];
    [self addChildViewController:self.mainNavigationController];
    self.mainNavigationController.view.frame = frame;
    [self.view addSubview:self.mainNavigationController.view];
    [self setShadow:self.mainNavigationController];
}

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

- (void)launchWithViewFromNotification:(UILocalNotification *)notification
{
    NSDictionary *userInfo = [notification userInfo];
    self.mainViewControllerIdentifier = userInfo[@"navigationController"];
    
    if([userInfo[@"viewController"] isEqualToString:@"appointmentFormViewController"]){
        CTLAppointmentFormViewController *viewController = (CTLAppointmentFormViewController *)[self.storyboard instantiateViewControllerWithIdentifier:userInfo[@"viewController"]];
        CTLCDAppointment *appointment = [CTLCDAppointment MR_findFirstByAttribute:@"eventID" withValue:userInfo[@"eventID"]];
        [viewController setAppointment:appointment];
        self.mainViewController = viewController;
    }

    self.mainNavigationController = [self.storyboard instantiateViewControllerWithIdentifier:self.mainViewControllerIdentifier];
    self.mainNavigationController.view.frame = CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds));
    
    self.mainViewController.menuController = self;
    
    [self renderMenuButton:(UIViewController<CTLSlideMenuDelegate> *)self.mainNavigationController.topViewController];
    [self.mainNavigationController pushViewController:self.mainViewController animated:NO];
    
    [self addChildViewController:self.mainNavigationController];
    [self.view addSubview:self.mainNavigationController.view];
    [self setShadow:self.mainNavigationController];
    
    
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"IS_LOCKED"]){
        [self performSelector:@selector(showPinView:) withObject:nil afterDelay:0.1];
    } 
    
}

- (void)showPinView:(id)sender
{
    CTLPinInterstialViewController *viewController = (CTLPinInterstialViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"pinInterstitial"];
    [self.mainNavigationController presentViewController:viewController animated:YES completion:nil];
}

- (void)setMainViewFromNotification:(UILocalNotification *)notification applicationState:(UIApplicationState)applicationState
{
    NSDictionary *userInfo = [notification userInfo];
        
    if([userInfo[@"viewController"] isEqualToString:@"appointmentFormViewController"]){
        CTLAppointmentFormViewController *viewController = (CTLAppointmentFormViewController *)[self.storyboard instantiateViewControllerWithIdentifier:userInfo[@"viewController"]];
        
        CTLCDAppointment *appointment = [CTLCDAppointment MR_findFirstByAttribute:@"eventID" withValue:userInfo[@"eventID"]];
        [viewController setAppointment:appointment];
        [viewController setTransitionedFromLocalNotification:YES];
        
        
        UIViewController *presentedViewController = self.mainViewController.presentedViewController;
        BOOL currentlyInModalView = [presentedViewController isKindOfClass:[UINavigationController class]] == NO && presentedViewController != nil;
        
        [viewController setPresentedAsModal:currentlyInModalView];
        
        if(applicationState == UIApplicationStateInactive){
            [self transitionToView:viewController withAnimationStyle:UIViewAnimationTransitionFlipFromLeft];
        }else if(applicationState == UIApplicationStateActive){
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:notification.alertBody delegate:self cancelButtonTitle:NSLocalizedString(@"CLOSE", nil) otherButtonTitles:NSLocalizedString(@"VIEW", nil), nil];
            [alert show];
            
            self.nextViewController = viewController;
        }
    }
}

- (void)requirePin
{
    self.mainViewControllerIdentifier = @"pinInterstitial";
    CTLPinInterstialViewController *viewController = (CTLPinInterstialViewController *)[self.storyboard instantiateViewControllerWithIdentifier:self.mainViewControllerIdentifier];
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
    
    [self setRightPanel:navigationController withFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds))];
}


@end
