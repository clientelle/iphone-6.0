//
//  CTLContactFormEditorViewController.m
//  Clientelle
//
//  Created by Kevin Liu on 6/24/12.
//  Copyright (c) 2012 Clientelle Ltd.. All rights reserved.
//

#import "UIColor+CTLColor.h"
#import "CTLContactFormEditorViewController.h"
#import "CTLCDFormSchema.h"
#import "UITableViewCell+CellShadows.h"
#import "KBPopupBubbleView.h"

NSString *const CTLFormFieldAddedNotification = @"fieldAdded";

@implementation CTLContactFormEditorViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.navBar.topItem.title = NSLocalizedString(@"EDIT_FORM", nil);
    self.tableView.backgroundColor = [UIColor colorFromUnNormalizedRGB:206.0f green:206.0f blue:206.0f alpha:1.0f];
    
    if(![[NSUserDefaults standardUserDefaults] boolForKey:@"display_form_editor_tooltip_once"]){
        [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(displayTooltip:) userInfo:nil repeats:NO];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"display_form_editor_tooltip_once"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (void)displayTooltip:(id)userInfo
{
    KBPopupBubbleView *bubble2 = [[KBPopupBubbleView alloc] initWithFrame:CGRectMake(55.0f, 60.0f, 210.0f, 60.0f) text:NSLocalizedString(@"EDIT_FORM_TOOLTIP", nil)];
    [bubble2 setPosition:2 animated:NO];
    [bubble2 setSide:kKBPopupPointerSideRight];
    [bubble2 showInView:self.tableView animated:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_fields count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"fieldRow";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    NSMutableDictionary *field = [_fields objectAtIndex:indexPath.row];
    cell.textLabel.text = [field objectForKey:kCTLFieldPlaceholder];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    [cell addShadowToCellInGroupedTableView:self.tableView atIndexPath:indexPath];
    
    if([[field valueForKey:kCTLFieldEnabled] isEqualToNumber:[NSNumber numberWithBool:NO]]){
        [self styleDisabledField:cell];
    }else{
        [self styleEnabledField:cell];
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self setFieldAtIndexPath:indexPath];
}

- (void)setFieldAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    NSString *fieldName = [[_fields objectAtIndex:indexPath.row] objectForKey:kCTLFieldName];
    
    if(cell.accessoryType == UITableViewCellAccessoryCheckmark){
        [_formSchema setValue:@(0) forKey:fieldName];
        [self styleDisabledField:cell];
    }else{
        [_formSchema setValue:@(1) forKey:fieldName];
        [self styleEnabledField:cell];
    }
    
    [self requireMinimumContactFields];
}

- (void)requireMinimumContactFields
{
    NSInteger disabledCount = 0;
    NSDictionary *attributes = [_formSchema.entity attributesByName];
    for (NSString *attribute in attributes) {
        NSNumber *value = (NSNumber *)[_formSchema valueForKey: attribute];
        if([value boolValue] == NO){
            disabledCount++;
        }
    }
    
    if(disabledCount == [attributes count]){
        self.doneButton.enabled = NO;
    }else{
        self.doneButton.enabled = YES;
        [self.doneButton setStyle:UIBarButtonItemStyleDone];
    }
}

- (void)styleEnabledField:(UITableViewCell *)cell
{
    [cell setAccessoryView:nil];
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
    cell.textLabel.textColor = [UIColor blackColor];
    cell.backgroundColor = [UIColor ctlLightGray];
}

- (void)styleDisabledField:(UITableViewCell *)cell
{
    UIButton *accessory = [UIButton buttonWithType:UIButtonTypeContactAdd];
    [accessory setUserInteractionEnabled:NO];
    [cell setAccessoryView:accessory];
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.textLabel.textColor = [UIColor lightGrayColor];
    cell.backgroundColor = [UIColor whiteColor];
}

- (IBAction)save:(id)sender
{
    [[NSManagedObjectContext MR_contextForCurrentThread] MR_saveToPersistentStoreAndWait];
    [[NSNotificationCenter defaultCenter] postNotificationName:CTLFormFieldAddedNotification object:nil];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)cancel:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
