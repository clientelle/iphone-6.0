//
//  CTLContainerViewController.m
//  Created by Kevin Liu on 1/17/13.
//  Copyright (c) 2013 Clientelle. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>
#import "CTLMainMenuViewController.h"
#import "CTLAppointmentFormViewController.h"
#import "CTLWelcomeViewController.h"

#import "CTLCDAppointment.h"
#import "CTLAccountManager.h"
#import "CTLCDAccount.h"

@interface CTLContainerViewController()

@end

@implementation CTLContainerViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    //[self setupMenuView];
    
    int loggedInUserId = [[CTLAccountManager sharedInstance] getLoggedInUserId];
    
//NSLog(@"loggedinUser ID %d", loggedInUserId);
//[self setMainViewWithStoryboardName:@"Welcome" withMenuButton:NO];
    
    //Brand new user does not have an account yet!
    if([CTLCDAccount countOfEntities] == 0 || loggedInUserId == 0){
        [self setMainViewWithStoryboardName:@"Welcome" withMenuButton:NO];
    }else{
        self.mainViewControllerIdentifier = @"contacts";
        self.mainStoryboard = [UIStoryboard storyboardWithName:@"Contacts" bundle:[NSBundle mainBundle]];
        self.mainNavigationController = [self.mainStoryboard instantiateViewControllerWithIdentifier:self.mainViewControllerIdentifier];
        CGRect mainViewFrame = CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds));
        [self setRightPanel:mainViewFrame];
    }
}

-  (void)setupMenuView
{     
    CTLMainMenuViewController *menuViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"mainMenuViewController"];
    [menuViewController setContainerView:self];
    
    //set slideout drawer width
    CGRect menuFrame = self.view.bounds;
    menuFrame.size.width = CTLMainMenuWidth;
    
    CGRect rect = [[UIApplication sharedApplication] statusBarFrame];
    
    menuFrame.origin.y += rect.size.height;
    menuViewController.view.frame = menuFrame;
    
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

- (void)renderMenuDropShadow
{
    self.mainNavigationController.view.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.mainNavigationController.view.bounds].CGPath;
    self.mainNavigationController.view.layer.shadowOpacity = 0.85f;
    self.mainNavigationController.view.layer.shadowRadius = 5.0f;
    self.mainNavigationController.view.layer.shadowOffset = CGSizeMake(-3, 0);
}

- (void)flipToView
{
    [self.mainViewController setContainerView:self];
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration: 1];
    [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:self.view cache:YES];
    [self.mainNavigationController pushViewController:self.mainViewController animated:NO];
    [UIView commitAnimations];
}

- (void)transitionToView:(UIViewController<CTLContainerViewDelegate> *)viewController withAnimationStyle:(UIViewAnimationTransition)animationStyle
{
    self.mainViewController = viewController;
    [self.mainViewController setContainerView:self];
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration: 1];
    [UIView setAnimationTransition:animationStyle forView:self.view cache:YES];
    [self.mainNavigationController pushViewController:self.mainViewController animated:NO];
    [UIView commitAnimations];
}

- (void)renderMenuButton:(UIViewController<CTLContainerViewDelegate> *)viewController
{
    UIBarButtonItem *menuButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"menu"] style:UIBarButtonItemStyleBordered target:self action:@selector(toggleMenu:)];
    viewController.navigationItem.leftBarButtonItem = menuButton;
}

- (void)disableMenuButton
{
  self.mainViewController.navigationItem.leftBarButtonItem = nil;
}

- (void)setActiveView:(NSString *)identifier
{
    
}

//Called from main menu
- (void)setMainView:(NSString *)identifier
{
    CGFloat width = CGRectGetWidth(self.view.bounds);
    CGFloat height = CGRectGetHeight(self.view.bounds);
    
    self.mainStoryboard = [UIStoryboard storyboardWithName:identifier bundle:[NSBundle mainBundle]];
    
    self.mainNavigationController = [self.mainStoryboard instantiateInitialViewController];
    
    [self setRightPanel:CGRectMake(CTLMainMenuWidth, 0.0f, width, height)];
    
    [UIView animateWithDuration:0.3 animations:^{
        self.mainNavigationController.view.frame = CGRectMake(0.0f, 0.0f, width, height);
    }];
    
   // [self renderMenuDropShadow];
}

- (void)setRightPanel:(CGRect)frame
{
    if(self.mainNavigationController){
        [self.mainNavigationController removeFromParentViewController];
        [self.mainNavigationController.view removeFromSuperview];
    }
    
    self.mainViewController = (UIViewController<CTLContainerViewDelegate> *)self.mainNavigationController.topViewController;
        
    [self renderMenuButton:self.mainViewController];
    [self.mainViewController setContainerView:self];
    [self addChildViewController:self.mainNavigationController];
    self.mainNavigationController.view.frame = frame;
    [self.view addSubview:self.mainNavigationController.view];
   // [self renderMenuDropShadow];
}

- (void)setMainViewWithStoryboardName:(NSString *)storyboardName withMenuButton:(BOOL)shouldRenderMenuButton
{
    self.mainStoryboard = [UIStoryboard storyboardWithName:storyboardName bundle:nil];
    self.mainNavigationController = [self.mainStoryboard instantiateInitialViewController];    
    self.mainViewController = (UIViewController<CTLContainerViewDelegate> *)self.mainNavigationController.topViewController;
    [self.mainViewController setContainerView:self];       
    
    [self addChildViewController:self.mainNavigationController];
    
    self.mainNavigationController.view.frame = CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds));
    [self.view addSubview:self.mainNavigationController.view];
    
    if(shouldRenderMenuButton){
        [self renderMenuButton:self.mainViewController];
    }
    
    //[self renderMenuDropShadow];
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
        CTLAppointmentFormViewController *viewController = (CTLAppointmentFormViewController *)[self.mainStoryboard instantiateViewControllerWithIdentifier:userInfo[@"viewController"]];
        CTLCDAppointment *appointment = [CTLCDAppointment MR_findFirstByAttribute:@"eventID" withValue:userInfo[@"eventID"]];
        [viewController setAppointment:appointment];
        self.mainViewController = viewController;
    }

    self.mainNavigationController = [self.mainStoryboard instantiateViewControllerWithIdentifier:self.mainViewControllerIdentifier];
    self.mainNavigationController.view.frame = CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds));
    
    self.mainViewController.containerView = self;
    
    [self renderMenuButton:(UIViewController<CTLContainerViewDelegate> *)self.mainNavigationController.topViewController];
    [self.mainNavigationController pushViewController:self.mainViewController animated:NO];
    
    [self addChildViewController:self.mainNavigationController];
    [self.view addSubview:self.mainNavigationController.view];
    //[self renderMenuDropShadow];
    
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"IS_LOCKED"]){
        [self performSelector:@selector(showPinView:) withObject:nil afterDelay:0.1];
    } 
    
}

- (void)setMainViewFromNotification:(UILocalNotification *)notification applicationState:(UIApplicationState)applicationState
{
    NSDictionary *userInfo = [notification userInfo];
        
    if([userInfo[@"viewController"] isEqualToString:@"appointmentFormViewController"]){
        CTLAppointmentFormViewController *viewController = (CTLAppointmentFormViewController *)[self.mainStoryboard instantiateViewControllerWithIdentifier:userInfo[@"viewController"]];
        
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


@end
