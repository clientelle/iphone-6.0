//
//  CTLMainMenuViewController.m
//  Clientelle
//
//  Created by Kevin Liu on 1/21/13.
//  Copyright (c) 2013 Kevin Liu. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>
#import "UIColor+CTLColor.h"
#import "CTLMainMenuViewController.h"
#import "CTLMenuItemCell.h"
#import "CTLSlideMenuController.h"
#import "CTLContactsListViewController.h"
#import "CTLMessagesListViewController.h"
#import "CTLInboxViewController.h"

#import "CTLCDAccount.h"

@implementation CTLMainMenuViewController

@synthesize selectedIndexPath = _selectedIndexPath;

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.backgroundColor = [UIColor colorFromUnNormalizedRGB:40 green:40 blue:40 alpha:1.0f];
    
    self.account = [CTLCDAccount MR_findFirst];
}

- (void)viewDidAppear:(BOOL)animated
{
    if(!self.selectedIndexPath){
        self.selectedIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    }
    
    [self styleActiveCell:self.selectedIndexPath];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    if([cell.reuseIdentifier isEqualToString:self.menuController.mainViewControllerIdentifier]){
        [self styleActiveCell:indexPath];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self removeStyleFromPreviouslyActiveCell:indexPath];
    [self styleActiveCell:indexPath];
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    [self loadViewController:cell.reuseIdentifier];
}

- (void)loadViewController:(NSString *)storyboardIdentifier
{
    if([storyboardIdentifier isEqualToString:@"inboxNavigationController"]){
        self.menuController.nextNavString = @"inboxInterstitialNavigationController";
        if(!self.account){
            //No account yet. Prompt to upgrade
            storyboardIdentifier = @"upgradeInterstitialNavigationController";
        }else{
            if([self.account.has_inbox isEqual:@(1)]){
                //got to inbox!
                storyboardIdentifier = @"inboxNavigationController";
            }else{
                //Prompt to create inbox
                storyboardIdentifier = @"inboxInterstitialNavigationController";
            }
        }
    }
    
    if([storyboardIdentifier isEqualToString:@"messagesNavigationController"]){
        self.menuController.nextNavString = @"messagesNavigationController";
        if(!self.account){
            //No account yet. Prompt to upgrade
            storyboardIdentifier = @"upgradeInterstitialNavigationController";
        }else{
            storyboardIdentifier = @"messagesNavigationController";
        }
    }

    [self.menuController setMainView:storyboardIdentifier];
}

- (void)styleActiveCell:(NSIndexPath *)indexPath
{
    self.selectedIndexPath = indexPath;
    CTLMenuItemCell *cell = (CTLMenuItemCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    BOOL isLastCell = [self isLastRow:indexPath];
    [cell setActiveBorders:isLastCell];
}

- (void)removeStyleFromPreviouslyActiveCell:(NSIndexPath *)indexPath
{
    CTLMenuItemCell *cell = (CTLMenuItemCell *)[self.tableView cellForRowAtIndexPath:self.selectedIndexPath];
    [cell resetBorders];
}

- (BOOL)isLastRow:(NSIndexPath *)indexPath
{
    return indexPath.row == ([self.tableView numberOfRowsInSection:0] -1);
}

@end
