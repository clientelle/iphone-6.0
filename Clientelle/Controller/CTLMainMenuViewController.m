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
#import "CTLSlideMenuController.h"
#import "CTLContactsListViewController.h"

NSString *const CTLMenuPlistName = @"Clientelle-Menu";

@implementation CTLMainMenuViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //self.tableView.backgroundColor = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"dark_matter.png"]];
    
    self.tableView.backgroundColor = [UIColor colorFromUnNormalizedRGB:40 green:40 blue:40 alpha:1.0f];
    self.tableView.separatorColor = [UIColor clearColor];
    
    _offWhite = [UIColor colorFromUnNormalizedRGB:200 green:200 blue:200 alpha:1.0f];
    _topBevelColor = [UIColor colorFromUnNormalizedRGB:15.0f green:15.0f blue:15.0f alpha:1.0f];
    _bottomBevelColor = [UIColor colorFromUnNormalizedRGB:51.0f green:51.0f blue:51.0f alpha:1.0f];
    _menuItems = [[NSArray alloc]initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:CTLMenuPlistName ofType:@"plist"]];

//TODO: save this to nsuser defaults
self.menuController.hasPro = NO;
self.menuController.hasAccount = NO;
self.menuController.hasInbox = NO;

}

- (void)viewDidAppear:(BOOL)animated
{
    if(!_selectedIndexPath){
        _selectedIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        [self styleActiveCell];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 30.0f;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return @"Clientelle";
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 30.0f)];
    [headerView setBackgroundColor:[UIColor ctlTorquoise]];
    
    CALayer *bevelBottomLine = [CALayer layer];
    bevelBottomLine.frame = CGRectMake(0.0f, headerView.frame.size.height-1, headerView.frame.size.width, 1.0f);
    bevelBottomLine.backgroundColor = [UIColor blackColor].CGColor;
    [headerView.layer addSublayer:bevelBottomLine];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 29.0f)];
    [label setFont:[UIFont fontWithName:@"Helvetica-Bold" size:14.0f]];
    [label setTextColor:[UIColor colorFromUnNormalizedRGB:30.0f green:30.0f blue:30.0f alpha:1.0f]];
    [label setBackgroundColor:[UIColor clearColor]];
    [label setTextAlignment:NSTextAlignmentCenter];
    label.text = @"Clientelle";
    
    [headerView addSubview:label];
    
    return headerView;
}
 */

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
    return 35.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    [cell setSelectionStyle:UITableViewCellEditingStyleNone];
     
    NSDictionary *menuItem = [_menuItems objectAtIndex:indexPath.row];
    
    //cell.imageView.image = [UIImage imageNamed:menuItem[@"icon"]];
    cell.textLabel.text = NSLocalizedString(menuItem[@"title"], nil);
    
    [cell.textLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:13.0f]];
    [cell.textLabel setTextColor:_offWhite];
 
    CALayer *bevelTopLine = [CALayer layer];
    bevelTopLine.frame = CGRectMake(0.0f, 0.0f, cell.frame.size.width, 1.0f);
    bevelTopLine.backgroundColor = _topBevelColor.CGColor;
    [cell.layer addSublayer:bevelTopLine];
    
    CALayer *bevelLine = [CALayer layer];
    bevelLine.frame = CGRectMake(0.0f, 1.0f, cell.frame.size.width, 1.0f);
    bevelLine.backgroundColor = _bottomBevelColor.CGColor;
    [cell.layer addSublayer:bevelLine];

    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSDictionary *menuItem = [_menuItems objectAtIndex:indexPath.row];
    
    NSString *navControllerName = [self handleInboxSelection:menuItem[@"identifier"]];
    [self.menuController setMainView:navControllerName];
    
    [self removeStyleFromPreviouslyActiveCell];
    _selectedIndexPath = indexPath;
    [self styleActiveCell];
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

- (void)styleActiveCell
{
    UITableViewCell *cell = (UITableViewCell *)[self.tableView cellForRowAtIndexPath:_selectedIndexPath];
    cell.accessoryType = UITableViewCellAccessoryNone;
    UIImageView *accessory = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"white-indicator-right.png"]];
    [cell setAccessoryView:accessory];
    cell.textLabel.textColor = [UIColor whiteColor];
}

- (void)removeStyleFromPreviouslyActiveCell
{
    UITableViewCell *cell = (UITableViewCell *)[self.tableView cellForRowAtIndexPath:_selectedIndexPath];
    [cell setAccessoryView:nil];
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.textLabel.textColor = _offWhite;
    _selectedIndexPath = nil;
}

@end
