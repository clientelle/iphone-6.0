//
//  CTLMainMenuViewController.m
//  Clientelle
//
//  Created by Kevin Liu on 1/21/13.
//  Copyright (c) 2013 Kevin Liu. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>
#import "CTLMainMenuViewController.h"
#import "RWSTwoPanelViewController.h"
#import "CTLContactsListViewController.h"



@implementation CTLMainMenuViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.backgroundColor = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"dark_matter.png"]];
    self.tableView.separatorColor = [UIColor blackColor];
    
    _menuItems = [[NSArray alloc]initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Clientelle-Menu" ofType:@"plist"]];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    
    cell.imageView.image = [UIImage imageNamed:menuItem[@"icon"]];
    cell.textLabel.text = menuItem[@"title"];
    
    [cell.textLabel setFont:[UIFont fontWithName:@"Helvetica" size:13.0f]];
    [cell.textLabel setTextColor:[UIColor whiteColor]];
 
    CALayer *bevelLine = [CALayer layer];
    bevelLine.frame = CGRectMake(0.0f, 0.0f, cell.frame.size.width, 1.0f);
    bevelLine.backgroundColor = [UIColor darkGrayColor].CGColor;
    [cell.layer addSublayer:bevelLine];
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSDictionary *menuItem = [_menuItems objectAtIndex:indexPath.row];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Clientelle" bundle: nil];
    UINavigationController *navigationController = (UINavigationController *)[storyboard instantiateViewControllerWithIdentifier:menuItem[@"identifier"]];
    [self.twoPanelViewController setDetailPanel:navigationController];
}

@end
