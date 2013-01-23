//
//  CTLMainMenuViewController.m
//  Clientelle
//
//  Created by Kevin Liu on 1/22/13.
//  Copyright (c) 2013 Kevin Liu. All rights reserved.
//

#import "CTLMainMenuViewControllerTest.h"
#import "CTLMainMenuViewController.h"

@implementation CTLMainMenuViewControllerTest

- (void)setUp
{
    [super setUp];
    
    _storyboard = [UIStoryboard storyboardWithName:@"Clientelle" bundle: nil];
    _menuItems = [[NSArray alloc]initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:CTLMenuPlistName ofType:@"plist"]];
}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}

- (void)testMenuHasValidItems
{
    NSInteger menuCount = [_menuItems count];
    
    if(menuCount == 0){
        STFail(@"Main menu has 0 items");
    }
    
    for(NSInteger i=0;i<menuCount;i++){
        NSDictionary *menuItem = _menuItems[i];
        STAssertNotNil(menuItem[@"title"], @"title key should exist");
        STAssertNotNil(menuItem[@"identifier"], @"identifier key should exist");
        STAssertNotNil(menuItem[@"icon"], @"icon key should exist");
    }
}

- (void)testMenuItemsInstantiateValidViewControllers
{
    NSInteger menuCount = [_menuItems count];
    for(NSInteger i=0;i<menuCount;i++){
        NSDictionary *menuItem = _menuItems[i];
        UINavigationController *navController = [_storyboard instantiateViewControllerWithIdentifier:menuItem[@"identifier"]];
        
        if(![navController isKindOfClass:[UINavigationController class]]){
            STFail(@"UIViewController with Storyboard ID: %@ is nil", menuItem[@"identifier"]);
        }
        
        UIViewController *vc = navController.topViewController;
        STAssertTrue([vc canPerformAction:@selector(setTwoPanelViewController:) withSender:vc], @"%@ does not implement delegate", menuItem[@"identifier"]);
    }
    
    
    
}


/*
- (void) testTableHasCorrectRowsAndSections
{
    id tableViewController = [[CTLMainMenuViewController alloc] init];
    
   
    //STAssertEquals(2,[tableViewController numberOfSectionsInTableView:nil], @"");
    STAssertEquals((NSInteger)[menuItems count],[tableViewController tableView:nil numberOfRowsInSection:0],@"");
    //STAssertEquals(5,[tableViewController tableView:nil numberOfRowsInSection:1],@"");
}
*/
@end
