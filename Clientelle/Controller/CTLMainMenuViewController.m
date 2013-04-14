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

NSString *const CTLMenuPlistName = @"Clientelle-Menu";

@implementation CTLMainMenuViewController

@synthesize menuItems = _menuItems, selectedIndexPath = _selectedIndexPath;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //self.tableView.backgroundColor = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"dark_matter.png"]];
    
    self.tableView.backgroundColor = [UIColor colorFromUnNormalizedRGB:40 green:40 blue:40 alpha:1.0f];
    self.tableView.separatorColor = [UIColor clearColor];

    _menuItems = [[NSArray alloc]initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:CTLMenuPlistName ofType:@"plist"]];

//TODO: save this to nsuser defaults
self.menuController.hasPro = NO;
self.menuController.hasAccount = NO;
self.menuController.hasInbox = NO;
    
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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_menuItems count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    CTLMenuItemCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[CTLMenuItemCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }

   [cell setSelectionStyle:UITableViewCellEditingStyleNone];
     
    NSDictionary *menuItem = _menuItems[indexPath.row];
    
    cell.imageView.image = [UIImage imageNamed:menuItem[@"icon"]];
    cell.textLabel.text = NSLocalizedString(menuItem[@"title"], nil);
    
    if([self isLastRow:indexPath]){
        [cell lastBorder];
    }
    return cell;
}

- (void)setActiveCell:(NSNotification *)notification
{
    NSIndexPath *indexPath = (NSIndexPath *)notification.object;
    [self styleActiveCell:indexPath];
}

- (void)styleActiveCell:(NSIndexPath *)indexPath
{
    self.selectedIndexPath = indexPath;
    CTLMenuItemCell *cell = (CTLMenuItemCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    [cell setActiveBorders:[self isLastRow:indexPath]];
}

- (void)removeStyleFromPreviouslyActiveCell:(NSIndexPath *)indexPath
{
    CTLMenuItemCell *cell = (CTLMenuItemCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    [cell resetBorders];
    
    if([self isLastRow:indexPath]){
        [cell lastBorder];
    }
}

- (BOOL)isLastRow:(NSIndexPath *)indexPath
{
    return indexPath.row == ([_menuItems count] -1);
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self removeStyleFromPreviouslyActiveCell:self.selectedIndexPath];
    [self styleActiveCell:indexPath];
    
    NSDictionary *menuItem = [_menuItems objectAtIndex:indexPath.row];
    [self.menuController setMainView:[self handleInboxSelection:menuItem[@"identifier"]]];
}

- (NSString *)handleInboxSelection:(NSString *)navControllerName
{
    if([navControllerName isEqualToString:@"inboxNavigationController"]){
        if(!self.menuController.hasPro || !self.menuController.hasAccount){
            return @"accountInterstitialNavigationController";
        }
        if(!self.menuController.hasInbox){
            return @"inboxInterstitialNavigationController";
        }
        return @"inboxNavigationController";
    }
    return navControllerName;
}

@end
