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
#import "CTLABGroup.h"

NSString *const CTLFormFieldAddedNotification = @"fieldAdded";


@implementation CTLContactFormEditorViewController

- (void)viewDidLoad{
    [super viewDidLoad];

    self.navigationItem.title = [NSString stringWithFormat:@"Edit %@ Form", [self.abGroup name]];
    
    _fieldRows = [[NSMutableArray alloc] init];
    _formSchema = [CTLCDFormSchema MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"groupID=%i",[self.abGroup groupID]]];
    
    NSArray *fieldsFromPList = [CTLCDFormSchema fieldsFromPlist:CTLABPersonSchemaPlist];
    NSMutableArray *fields = [[NSMutableArray alloc] initWithArray:fieldsFromPList];
    [fields addObject:@{@"label": @"Address", @"name": @"address"}];
    
    //copy field from plist into "_fieldRows"
    for(NSUInteger i=0; i< [fields count]; i++){
        NSDictionary *field = [fields objectAtIndex:i];
        NSMutableDictionary *inputField = [field mutableCopy];
        [inputField setValue:[_formSchema valueForKey:[field objectForKey:kCTLFieldName]] forKey:kCTLFieldEnabled];
        [_fieldRows addObject:inputField];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_fieldRows count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellIdentifier = @"fieldRow";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    NSMutableDictionary *field = [_fieldRows objectAtIndex:indexPath.row];
    cell.textLabel.text = [field objectForKey:kCTLFieldLabel];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    if([[field valueForKey:kCTLFieldEnabled] isEqualToNumber:[NSNumber numberWithBool:NO]]){
        [self styleDisabledField:cell];
    }else{
        [self styleEnabledField:cell];
    }

    return cell;    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self setFieldAtIndexPath:indexPath];
}

- (void)setFieldAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    NSString *fieldName = [[_fieldRows objectAtIndex:indexPath.row] objectForKey:kCTLFieldName];
    
    if(cell.accessoryType == UITableViewCellAccessoryCheckmark){
        [_formSchema setValue:@(0) forKey:fieldName];
        [self styleDisabledField:cell];
    }else{
        [_formSchema setValue:@(1) forKey:fieldName];
        [self styleEnabledField:cell];
    }
 
    [self.doneButton setStyle:UIBarButtonItemStyleDone];
}

- (void)styleEnabledField:(UITableViewCell *)cell {
    [cell setAccessoryView:nil];
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
    cell.textLabel.textColor = [UIColor blackColor];
    cell.backgroundColor = [UIColor colorFromUnNormalizedRGB:245.0f green:245.0f blue:245.0f alpha:1.0f];
}

- (void)styleDisabledField:(UITableViewCell *)cell {
    UIButton *accessory = [UIButton buttonWithType:UIButtonTypeContactAdd];
    [accessory setUserInteractionEnabled:NO];
    [cell setAccessoryView:accessory];
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.textLabel.textColor = [UIColor darkGrayColor];
    cell.backgroundColor = [UIColor whiteColor];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation{
    return NO;
}

- (IBAction)save:(id)sender{
    [[NSManagedObjectContext MR_contextForCurrentThread] MR_saveToPersistentStoreAndWait];
    [[NSNotificationCenter defaultCenter] postNotificationName:CTLFormFieldAddedNotification object:nil];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)cancel:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
