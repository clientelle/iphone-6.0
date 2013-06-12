//
//  CTLMessagePreferenceViewController.m
//  Clientelle
//
//  Created by Kevin Liu on 6/6/13.
//  Copyright (c) 2013 Kevin Liu. All rights reserved.
//

#import "UITableViewCell+CellShadows.h"
#import "CTLMessagePreferenceViewController.h"
#import "CTLContactToolbarView.h"

@implementation CTLMessagePreferenceViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if(self.isModal){
        self.navbar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44.0f)];
        UINavigationItem *item = [[UINavigationItem alloc] initWithTitle:NSLocalizedString(@"ACTION_REQUIRED", nil)];
        
        item.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismiss:)];
        [self.navbar pushNavigationItem:item animated:NO];
    }
      
    _preference = [[NSUserDefaults standardUserDefaults] integerForKey:@"CTLMessagePreferenceType"];
    
    NSLog(@"SOMETING %u", _preference);
    
    
    if(_preference != CTLMessagePreferenceTypeUndetermined){
        _checkedIndexPath = [NSIndexPath indexPathForRow:_preference inSection:0];
    }
}

- (void)dismiss:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if(self.isModal){
        return 64.0f;
    }
    
    return 0;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if(self.isModal){
        UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 64.0f)];
        headerView.backgroundColor = [UIColor clearColor];
        [headerView addSubview:self.navbar];
        return headerView;
    }
    
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    [cell addShadowToCellInGroupedTableView:self.tableView atIndexPath:indexPath];
    
    if([_checkedIndexPath isEqual:indexPath]){
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(_checkedIndexPath){
        UITableViewCell *checkedCell = [self.tableView cellForRowAtIndexPath:_checkedIndexPath];
        checkedCell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
    _checkedIndexPath = indexPath;
 
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:(CTLMessagePreferenceType)indexPath.row forKey:@"CTLMessagePreferenceType"];
    [defaults synchronize];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"com.clientelle.notification.messagePreference" object:@(indexPath.row)];
}

@end
