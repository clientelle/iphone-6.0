//
//  CTLMainMenuViewController.m
//  Clientelle
//
//  Created by Kevin Liu on 1/21/13.
//  Copyright (c) 2013 Kevin Liu. All rights reserved.
//

#import "UIColor+CTLColor.h"
#import "CTLMainMenuViewController.h"
#import "CTLMenuItemCell.h"

const CGFloat CTLMainMenuWidth = 80.0f;

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
    [self.containerView setMainView:cell.reuseIdentifier];
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
