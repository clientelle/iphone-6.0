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
#import "RWSSliderMenuViewController.h"
#import "CTLContactsListViewController.h"

NSString *const CTLMenuPlistName = @"Clientelle-Menu";

@implementation CTLMainMenuViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.backgroundColor = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"dark_matter.png"]];
    self.tableView.separatorColor = [UIColor clearColor];
    
    _menuItems = [[NSArray alloc]initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:CTLMenuPlistName ofType:@"plist"]];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"Clientelle";
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 30.0f;
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
    return 33.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    NSDictionary *menuItem = [_menuItems objectAtIndex:indexPath.row];
    
    //cell.imageView.image = [UIImage imageNamed:menuItem[@"icon"]];
    cell.textLabel.text = menuItem[@"title"];
    
    [cell.textLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:13.0f]];
    [cell.textLabel setTextColor:[UIColor whiteColor]];
 
    CALayer *bevelTopLine = [CALayer layer];
    bevelTopLine.frame = CGRectMake(0.0f, 0.0f, cell.frame.size.width, 1.0f);
    bevelTopLine.backgroundColor = [UIColor colorFromUnNormalizedRGB:51.0f green:51.0f blue:51.0f alpha:1.0f].CGColor;
    [cell.layer addSublayer:bevelTopLine];
    
    
    CALayer *bevelBottomLine = [CALayer layer];
    bevelBottomLine.frame = CGRectMake(0.0f, cell.frame.size.height-12, cell.frame.size.width, 1.0f);
    bevelBottomLine.backgroundColor = [UIColor colorFromUnNormalizedRGB:15.0f green:15.0f blue:15.0f alpha:1.0f].CGColor;
    [cell.layer addSublayer:bevelBottomLine];
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSDictionary *menuItem = [_menuItems objectAtIndex:indexPath.row];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Clientelle" bundle: nil];
    UINavigationController *navigationController = (UINavigationController *)[storyboard instantiateViewControllerWithIdentifier:menuItem[@"identifier"]];
    [self.twoPanelViewController setMainView:navigationController];
}

@end
