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
#import "CTLContactsListViewController.h"
#import "CTLConversationListViewController.h"
#import "CTLInboxViewController.h"

#import "CTLAccountManager.h"
#import "CTLCDAccount.h"

const CGFloat CTLMainMenuWidth = 80.0f;

@interface CTLMainMenuViewController()
@property (nonatomic, strong) CTLCDAccount *currentUser;
@end

@implementation CTLMainMenuViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.backgroundColor = [UIColor colorFromUnNormalizedRGB:40 green:40 blue:40 alpha:1.0f];
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
    if([cell.reuseIdentifier isEqualToString:self.containerView.mainViewControllerIdentifier]){
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
    [self switchActiveView:cell.reuseIdentifier];
}

- (void)switchActiveView:(NSString *)identifier
{
    NSString *storyboardName = identifier;
    
    if(self.currentUser.user_idValue){
        if([self shouldShowInboxSetup:identifier]){
            storyboardName = @"InboxSetup";
        }
    }else{
        if([self shouldShowUpgradeInterstitial:identifier]){
            [self.containerView setNextNavString:identifier];
            storyboardName = @"Upgrade";
        }        
    }

    [self.containerView setMainView:storyboardName];
}

- (BOOL)shouldShowInboxSetup:(NSString *)identifier
{
    return [identifier isEqualToString:@"Inbox"] && self.currentUser.has_inboxValue == 0;
}

- (BOOL)shouldShowUpgradeInterstitial:(NSString *)identifier
{
    return [@[@"Messages", @"Inbox"] containsObject:identifier];
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
