//
//  CTLContactFormEditorViewController.m
//  Clientelle
//
//  Created by Kevin Liu on 6/24/12.
//  Copyright (c) 2012 Clientelle Ltd.. All rights reserved.
//

#import "UIColor+CTLColor.h"
#import "CTLContactFormEditorViewController.h"
#import "CTLCDContactField.h"
#import "UITableViewCell+CellShadows.h"
#import "KBPopupBubbleView.h"

NSString *const CTLFormFieldAddedNotification = @"fieldAdded";

@implementation CTLContactFormEditorViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.navBar.topItem.title = NSLocalizedString(@"EDIT_FORM", nil);
    self.tableView.backgroundColor = [UIColor colorFromUnNormalizedRGB:206.0f green:206.0f blue:206.0f alpha:1.0f];
    
    [self setupFetchedResultsController];
    
    _fields = [self.fetchedResultsController fetchedObjects];
    
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

#pragma mark NSFetchResultsControllerDelegate

- (void)setupFetchedResultsController
{
    self.fetchedResultsController = [CTLCDContactField fetchAllSortedBy:@"sortOrder" ascending:YES withPredicate:nil groupBy:nil delegate:self];
    [self.fetchedResultsController performFetch:nil];
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)object atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate: {
            // do nothing
        }
            break;
            
        case NSFetchedResultsChangeMove:
            [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView endUpdates];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellAccessoryNone;
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
    if(self.editButton.enabled == NO){
        self.editButton.enabled = YES;
    }

    if([fromIndexPath isEqual:toIndexPath]){
        return;
    }

    CTLCDContactField *targetField = [self.fetchedResultsController fetchedObjects][fromIndexPath.row];
    CTLCDContactField *displacedField = [self.fetchedResultsController fetchedObjects][toIndexPath.row];

    targetField.sortOrder = @(toIndexPath.row);
    displacedField.sortOrder = @(fromIndexPath.row);

    UITableViewCell *toCell = [tableView cellForRowAtIndexPath:toIndexPath];
    UITableViewCell *fromCell = [tableView cellForRowAtIndexPath:fromIndexPath];

    [toCell addShadowToCellInGroupedTableView:self.tableView atIndexPath:toIndexPath];
    [fromCell addShadowToCellInGroupedTableView:self.tableView atIndexPath:fromIndexPath];
    
    [toCell.backgroundView setNeedsDisplay];
    [fromCell.backgroundView setNeedsDisplay];
    
    [self.tableView reloadData];
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return YES;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[self.fetchedResultsController fetchedObjects] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"fieldRow";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    CTLCDContactField *field = [[self.fetchedResultsController fetchedObjects] objectAtIndex:indexPath.row];
    
    cell.textLabel.text = field.label;
    
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
    CTLCDContactField *row = [[self.fetchedResultsController fetchedObjects] objectAtIndex:indexPath.row];
    
    if(cell.accessoryType == UITableViewCellAccessoryCheckmark){
        [row setValue:@(0) forKey:kCTLFieldEnabled];
        
        if([row.field isEqualToString:@"address"]){
            [self triggerAddress2Save:@(0)];
        }
        [self styleDisabledField:cell];
    }else{
        [row setValue:@(1) forKey:kCTLFieldEnabled];
        if([row.field isEqualToString:@"address"]){
            [self triggerAddress2Save:@(1)];
        }
        [self styleEnabledField:cell];
    }
    
    [self requireMinimumContactFields];
}

- (void)triggerAddress2Save:(NSNumber *)enable
{
    for (NSInteger i=0;i<[_fields count];i++) {
        CTLCDContactField *row = (CTLCDContactField *)_fields[i];
        if([row.field isEqualToString:@"address2"]){
            row.enabled = enable;
            break;
        }
    }
}

- (void)requireMinimumContactFields
{
    NSInteger disabledCount = 0;
    
    for (NSInteger i=0;i<[_fields count];i++) {
        CTLCDContactField *row = (CTLCDContactField *)_fields[i];
        if([row.enabled boolValue] == NO){
            disabledCount++;
        }
    }
    
    if(disabledCount == [_fields count]){
        self.editButton.enabled = NO;
    }else{
        self.editButton.enabled = YES;
        [self.editButton setStyle:UIBarButtonItemStyleDone];
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
    [[NSManagedObjectContext MR_contextForCurrentThread]  MR_saveToPersistentStoreAndWait];
    [[NSNotificationCenter defaultCenter] postNotificationName:CTLFormFieldAddedNotification object:nil];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)enableReordering:(UIBarButtonItem *)button
{
    [self.tableView setEditing:YES animated:YES];
    [button setAction:@selector(doneReordering:)];
    [button setStyle:UIBarButtonItemStyleDone];
}

- (void)doneReordering:(UIBarButtonItem *)button
{
    [self.tableView setEditing:NO animated:YES];
    [button setAction:@selector(enableReordering:)];
    [button setStyle:UIBarButtonItemStylePlain];
}

@end
