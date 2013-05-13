//
//  CTLAppointmentsViewController.m
//  Clientelle
//
//  Created by Kevin Liu on 3/11/13.
//  Copyright (c) 2013 Kevin Liu. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "NSDate+CTLDate.h"
#import "UIColor+CTLColor.h"
#import "CTLViewDecorator.h"

#import "CTLPickerView.h"
#import "CTLPickerButton.h"

#import "CTLCDAppointment.h"
#import "CTLCDContact.h"

#import "CTLAppointmentsListViewController.h"
#import "CTLAppointmentFormViewController.h"
#import "CTLAppointmentCell.h"


NSString *const CTLAppointmentWasAddedNotification = @"com.clientelle.notifications.appointmentWasAdded";
NSString *const CTLAppointmentFormSegueIdentifyer = @"toAppointmentForm";
NSString *const CTLAppointmentModalSegueIdentifyer = @"toAppointmentModal";
NSString *const CTLDefaultSelectedCalendarFilter  = @"com.clientelle.defaultKey.appointmentFilter";

CGFloat CTLAppointmentRowHeight = 90.0f;
int const CTLSelectedFilterIndexActive = 0;
int const CTLSelectedFilterIndexCompleted = 1;

@implementation CTLAppointmentsListViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"groovepaper"]];
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"BACK", nil) style:UIBarButtonItemStyleBordered target:nil action:nil];
    
    [self.navigationItem setBackBarButtonItem: backButton];

    
    _eventStore = [[EKEventStore alloc] init];
    
    [self configureFilterPicker];
    
    if([[NSUserDefaults standardUserDefaults] integerForKey:@"showSplash"] == 0){
        self.navigationItem.title = NSLocalizedString(@"WELCOME", nil);
        
        _showSplashView = YES;
        _splashView = [self buildEmptyView];
        
    }else{
        _showSplashView = NO;
        [self createFilterPickerButton];
    }
    
    [self loadAllAppointments];

    //tap to dissmiss the filter picker
    //[self.tableView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissPickerFromTap:)]];
    
}

- (void)configureFilterPicker
{
    NSDictionary *active = @{@"title":NSLocalizedString(@"ACTIVE", nil), @"completed": @NO};
    NSDictionary *completed = @{@"title":NSLocalizedString(@"COMPLETED", nil), @"completed": @YES};
    
    _filterArray = @[active, completed];
    _filterPickerView = [self createFilterPickerView];
    [_filterPickerView selectRow:0 inComponent:0 animated:NO];
}

- (void)loadAllAppointments
{    
    NSInteger filterRow = [_filterPickerView selectedRowInComponent:0];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"completed = %i", [_filterArray[filterRow][@"completed"] intValue]];
    
    self.resultsController = [CTLCDAppointment fetchAllSortedBy:@"startDate" ascending:YES withPredicate:predicate groupBy:nil delegate:self];
    [self.resultsController performFetch:nil];
    [self.tableView reloadData];
}

- (UIView *)buildEmptyView
{
    CGFloat cielingY = 40.0f;
    CGRect viewFrame = self.view.frame;
    UIView *emptyView = [[UIView alloc] initWithFrame:viewFrame];
    
    CGFloat titleLabelHeight = 25.0f;
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(37.0f, cielingY, viewFrame.size.width-70.0f, titleLabelHeight)];
    [titleLabel setBackgroundColor:[UIColor clearColor]];
    [titleLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:18.0f]];
    [titleLabel setTextColor:[UIColor darkGrayColor]];
    [titleLabel setText:NSLocalizedString(@"TITLE_SPIEL", nil)];
    [emptyView addSubview:titleLabel];
    
    CGFloat lineHeight = 50.0f;
    CGFloat leftMargin = 40.0f;
    
    UIImageView *keyIcon = [self createIcon:@"237-key"];
    CGRect iconFrame = keyIcon.frame;
    iconFrame.origin.x = leftMargin;
    iconFrame.origin.y = cielingY;
    
    iconFrame.origin.y += lineHeight;
    keyIcon.frame = iconFrame;
    [emptyView addSubview:keyIcon];

    UIImageView *clockIcon = [self createIcon:@"11-clock-grey"];
    
    iconFrame.origin.y += lineHeight;
    clockIcon.frame = iconFrame;
    [emptyView addSubview:clockIcon];
    
    UIImageView *chatIcon = [self createIcon:@"09-chat-grey"];
    iconFrame.origin.y += lineHeight;
    chatIcon.frame = iconFrame;
    [emptyView addSubview:chatIcon];
        
    CGFloat leftMarginOffset = (iconFrame.origin.x + iconFrame.size.width) + 15.0f;
    CGRect labelFrame = CGRectMake(leftMarginOffset, cielingY, viewFrame.size.width-110, iconFrame.size.height);
    
    lineHeight -= 1;
    
    labelFrame.origin.y += lineHeight;
    UILabel *privateContactsLabel = [self createLabel:labelFrame withText:NSLocalizedString(@"BULLET_STORE_PRIVATE_CONTACTS", nil)];
    [emptyView addSubview:privateContactsLabel];

    labelFrame.origin.y += lineHeight;
    UILabel *appointmentLabel = [self createLabel:labelFrame withText:NSLocalizedString(@"BULLET_SCHEDULE_APPOINTMENTS", nil)];
    [emptyView addSubview:appointmentLabel];
    
    labelFrame.origin.y += lineHeight;
    UILabel *messageLabel = [self createLabel:labelFrame withText:NSLocalizedString(@"BULLET_PRIVATE_MESSAGING", nil)];
    [emptyView addSubview:messageLabel];
    
    CGFloat buttonWidth = 200.0f;
    CGFloat buttonCenter = viewFrame.size.width/2 - (buttonWidth/2);
    UIButton *addButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    UIImage *buttonImage = [[UIImage imageNamed:@"whiteButton"] resizableImageWithCapInsets:UIEdgeInsetsMake(18, 18, 18, 18)];
    UIImage *buttonImageHighlight = [[UIImage imageNamed:@"whiteButtonHighlight"] resizableImageWithCapInsets:UIEdgeInsetsMake(18, 18, 18, 18)];
    
    // Set the background for any states you plan to use
    [addButton setBackgroundImage:buttonImage forState:UIControlStateNormal];
    [addButton setTitleColor:[UIColor colorFromUnNormalizedRGB:81.0f green:91.0f blue:130.0f alpha:1.0f] forState:UIControlStateNormal];
    
    [addButton setBackgroundImage:buttonImageHighlight forState:UIControlStateHighlighted];
    [addButton setTitleColor:[UIColor colorFromUnNormalizedRGB:61.0f green:71.0f blue:110.0f alpha:1.0f] forState:UIControlStateHighlighted];
    
    [addButton setFrame:CGRectMake(buttonCenter, labelFrame.origin.y + 60, buttonWidth, 38.0f)];
    [addButton.titleLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:14.0f]];
    [addButton addTarget:self action:@selector(addAppointment:) forControlEvents:UIControlEventTouchUpInside];
    [addButton setTitle:NSLocalizedString(@"BUY_PRO", nil) forState:UIControlStateNormal];
    
    addButton.layer.shadowOpacity = 0.2f;
    addButton.layer.shadowRadius = 1.0f;
    addButton.layer.shadowOffset = CGSizeMake(0,0);
      
    [emptyView addSubview:addButton];
    
    return emptyView;
}

- (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    //UIGraphicsBeginImageContext(newSize);
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

- (UIImageView *)createIcon:(NSString *)imageName
{
    UIImage *image = [UIImage imageNamed:imageName];
    CGSize newSize = CGSizeMake(round(image.size.width*0.90) , round(image.size.height*0.90));
    UIImage *iconImage = [self imageWithImage:image scaledToSize:newSize];
    UIImageView *iconView = [[UIImageView alloc] initWithImage:iconImage];
    CGRect iconFrame = iconView.frame;
    iconView.alpha = 0.75;
    iconView.frame = iconFrame;
    return iconView;
}

- (UILabel *)createLabel:(CGRect)labelFrame withText:string
{
    UILabel *label = [[UILabel alloc] initWithFrame:labelFrame];
    [label setText:string];
    [label setBackgroundColor:[UIColor clearColor]];
    [label setFont:[UIFont fontWithName:@"Helvetica" size:15.0f]];
    [label setTextColor:[UIColor darkGrayColor]];
    return label;
}

- (IBAction)addAppointment:(id)sender
{
    [self performSegueWithIdentifier:CTLAppointmentModalSegueIdentifyer sender:sender];
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if(_showSplashView){
        return self.view.bounds.size.height;
    }
    
    if([[self.resultsController fetchedObjects] count] == 0){
        return CTLAppointmentRowHeight;
    }
    
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if(_showSplashView){
        return _splashView;
    }
    
    if([[self.resultsController fetchedObjects] count] == 0){
        return [self emptyRow];
    }

    return nil;
}

- (UIView *)emptyRow
{
    CGRect completedEmptyStateFrame = CGRectMake(0, 0, self.tableView.frame.size.width, CTLAppointmentRowHeight);
    UIView *completedEmptyStateView = [[UIView alloc] initWithFrame:completedEmptyStateFrame];
    UILabel *noCompletedItemsLabel = [[UILabel alloc] initWithFrame:completedEmptyStateFrame];
    noCompletedItemsLabel.backgroundColor = [UIColor clearColor];
    noCompletedItemsLabel.textAlignment = NSTextAlignmentCenter;
    noCompletedItemsLabel.font = [UIFont fontWithName:@"Helvetica" size:15];
    noCompletedItemsLabel.textColor = [UIColor lightGrayColor];
    noCompletedItemsLabel.text = NSLocalizedString(@"NO_COMPLETED_ITEMS", nil);
    
    [completedEmptyStateView addSubview:noCompletedItemsLabel];
    CTLViewDecorator *decorator = [[CTLViewDecorator alloc] init];
    CAShapeLayer *dottedLine = [decorator createDottedLine:completedEmptyStateFrame];
    [completedEmptyStateView.layer addSublayer:dottedLine];
    
    return completedEmptyStateView;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[self.resultsController fetchedObjects] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = nil;
    
    CTLCDAppointment *appointment = [[self.resultsController fetchedObjects] objectAtIndex:indexPath.row];
    
    if([appointment.startDate compare:[NSDate date]] == NSOrderedAscending){
        cellIdentifier = @"pastDueCell";
    }else{
        if([appointment.address length] > 0 || [appointment.address2 length] > 0){
            cellIdentifier = @"apptCellHasMap";
        }else{
            cellIdentifier = @"apptCellNoMap";
        }
    }
    
    CTLAppointmentCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    cell.delegate = self;
    [self configure:cell withAppointment:appointment];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(_filterPickerView.isVisible){
        [_filterPickerView hidePicker];
        return;
    }
    
    CTLCDAppointment *appointment = [[self.resultsController fetchedObjects] objectAtIndex:indexPath.row];
    [self performSegueWithIdentifier:CTLAppointmentFormSegueIdentifyer sender:appointment];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return CTLAppointmentRowHeight;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(editingStyle == UITableViewCellEditingStyleDelete){
        
        CTLCDAppointment *appointment = [[self.resultsController fetchedObjects] objectAtIndex:indexPath.row];
        [MagicalRecord saveUsingCurrentThreadContextWithBlock:^(NSManagedObjectContext *localContext) {
            [appointment deleteInContext:localContext];
        } completion:^(BOOL success, NSError *error) {
            //NOTE: Clean up appointments?
        }];
        
        NSError *error = nil;
        EKEvent *event = [_eventStore eventWithIdentifier:appointment.eventID];
        [_eventStore removeEvent:event span:EKSpanThisEvent error:&error];
    }
}

#pragma mark NSFetchResultsControllerDelegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(CTLCDAppointment *)appointment atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    
    CTLAppointmentCell *cell = (CTLAppointmentCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            [self.tableView reloadData];
            
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            
            
            [self configure:cell withAppointment:appointment];
            [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
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

- (void)changeAppointmentStatus:(CTLAppointmentCell *)cell
{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    CTLCDAppointment *appointment = [[self.resultsController fetchedObjects] objectAtIndex:indexPath.row];

    if(appointment.completedValue){
        [appointment setCompleted:@(0)];
        BOOL isOverDue = [appointment.startDate compare:[NSDate date]] == NSOrderedAscending;
        [cell decorateInCompletedCell:isOverDue];
        
    }else{
        [cell decorateCompletedCell];
        [appointment setCompleted:@(1)];
    }
    
    [[NSManagedObjectContext MR_contextForCurrentThread] MR_saveToPersistentStoreAndWait];
}

#pragma mark - CTLAppointmentDelegate methods

- (void)configure:(CTLAppointmentCell *)cell withAppointment:(CTLCDAppointment *)appointment
{
    [cell setSelectionStyle:UITableViewCellEditingStyleNone];
     CTLCDContact *contact = appointment.contact;
    cell.titleLabel.text = [contact compositeName];
    NSString *timeString = [NSString stringWithFormat:@"@%@", [NSDate formatShortTimeOnly:appointment.startDate]];
    cell.timeLabel.text = [timeString lowercaseString];
    cell.dateLabel.text= [NSDate formatShortDateOnly:appointment.startDate];
    cell.descLabel.text = appointment.title;
    cell.feeLabel.text = [appointment formattedFee];
    
    BOOL isOverDue = [appointment.startDate compare:[NSDate date]] == NSOrderedAscending;
    
    if([appointment.completed isEqual:@YES]){
        [cell decorateCompletedCell];
        
    }else{
        [cell decorateInCompletedCell:isOverDue];
    }
}

- (void)updateCellForRow:(int)row forEvent:(EKEvent *)appointment
{
    NSLog(@"APPOINTMENT %@", appointment);
    
    /*
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
    CTLAppointmentCell *cell = (CTLAppointmentCell *)[self.tableView cellForRowAtIndexPath:indexPath];
 
    cell.titleLabel.text = appointment.title;
    NSString *timeString = [NSString stringWithFormat:@"%@ - %@", [NSDate formatShortTimeOnly:appointment.startDate], [NSDate formatShortTimeOnly:appointment.endDate]];
    cell.timeLabel.text = [timeString lowercaseString];
    cell.dateLabel.text= [NSDate formatShortDateOnly:appointment.startDate];
    cell.dateLabel.textColor = [UIColor darkGrayColor];
    
    if([appointment.startDate compare:[NSDate date]] == NSOrderedAscending){
        cell.dateLabel.textColor = [UIColor redColor];
    }
     
     */
}

- (void)showMap:(CTLAppointmentCell *)cell
{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    CTLCDAppointment *appointment = [[self.resultsController fetchedObjects] objectAtIndex:indexPath.row];
    
    NSString *mapURL = [NSString stringWithFormat:@"%@ %@", appointment.address, appointment.address2];
    NSString *encodedAddress = [mapURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *mapURLString = [NSString stringWithFormat:@"http://maps.apple.com/?q=%@", encodedAddress];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:mapURLString]];
}

#pragma mark - Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([[segue identifier] isEqualToString:CTLAppointmentFormSegueIdentifyer]){
        if([sender isKindOfClass:[CTLCDAppointment class]]){
            CTLCDAppointment *appointment = (CTLCDAppointment *)sender;
            CTLAppointmentFormViewController *viewController = [segue destinationViewController];
            [viewController setPresentedAsModal:NO];
            [viewController setAppointment:appointment];
            return;
        }
    }
    
    if([[segue identifier] isEqualToString:CTLAppointmentModalSegueIdentifyer]){
        UINavigationController *navigationController = [segue destinationViewController];
        CTLAppointmentFormViewController *viewController = (CTLAppointmentFormViewController *)navigationController.topViewController;
        [viewController setPresentedAsModal:YES];
        return;
    }
}

#pragma mark - Filter Picker

- (void)createFilterPickerButton
{
    self.navigationItem.titleView = [self filterPickerButtonWithTitle:NSLocalizedString(@"APPOINTMENTS", nil)];
}

- (UIButton *)filterPickerButtonWithTitle:(NSString *)selectedFilterName
{
    CTLPickerButton *uiButton = [[CTLPickerButton alloc] initWithTitle:selectedFilterName];
    [uiButton addTarget:self action:@selector(togglePicker:) forControlEvents:UIControlEventTouchUpInside];
    return uiButton;
}

- (CTLPickerView *)createFilterPickerView
{
    CTLPickerView *filterPicker = [[CTLPickerView alloc] initWithWidth:self.view.bounds.size.width];
    filterPicker.delegate = self;
    filterPicker.dataSource = self;
    [self.view addSubview:filterPicker];
    return filterPicker;
}

- (void)togglePicker:(id)sender
{
    if(_filterPickerView.isVisible){
        [_filterPickerView hidePicker];
    }else{
        [_filterPickerView showPicker];
    }
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    CGPoint touchPoint = [gestureRecognizer locationInView:self.view];
    UIView *touchedView = [self.view hitTest:touchPoint withEvent:nil];
    return (touchedView == self.tableView || touchedView == _splashView);
}

- (IBAction)dismissPickerFromTap:(UITapGestureRecognizer *)recognizer
{
    if(_filterPickerView.isVisible){
        [_filterPickerView hidePicker];
    }
}

#pragma mark - Filter Picker Delegate

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
	return 1;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    [self loadAllAppointments];
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
     return [_filterArray objectAtIndex:row][@"title"];
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
	return [_filterArray count];
}

- (void)markAsCompleted:(id)sender
{
    //[self.cdAppointment setCompeleted:@(1)];
    //[self.cdAppointment setCompletedDate:[NSDate date]];
    //[self saveAppointment:sender];
}

@end
