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

#import "CTLPickerView.h"
#import "CTLPickerButton.h"

#import "CTLCDAppointment.h"
#import "CTLAppointmentsListViewController.h"
#import "CTLAppointmentFormViewController.h"
#import "CTLAppointmentCell.h"

NSString *const CTLReloadAppointmentsNotification = @"com.clientelle.notifications.reloadAppointments";
NSString *const CTLAppointmentFormSegueIdentifyer = @"toAppointmentForm";
NSString *const CTLAppointmentModalSegueIdentifyer = @"toAppointmentModal";
NSString *const CTLDefaultSelectedCalendarFilter  = @"com.clientelle.defaultKey.appointmentFilter";

@interface CTLAppointmentsListViewController ()
@property (nonatomic, strong) NSFetchedResultsController *resultsController;
@end

@implementation CTLAppointmentsListViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"groovepaper.png"]];
        
    _eventStore = [[EKEventStore alloc] init];
    self.resultsController = [CTLCDAppointment fetchedResultsController];
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"BACK", nil) style:UIBarButtonItemStyleBordered target:nil action:nil];
    [self.navigationItem setBackBarButtonItem: backButton];
    
    NSDictionary *todayDict = [self filterDict:NSLocalizedString(@"TODAY", nil)
                                     startDate:[NSDate today]
                                       endDate:[NSDate tomorrow]];
    
    NSDictionary *weekDict = [self filterDict:NSLocalizedString(@"THIS_WEEK", nil)
                                    startDate:[NSDate firstDayOfCurrentWeek]
                                      endDate:[NSDate lastDayOfCurrentWeek]];
    
    NSDictionary *monthDict = [self filterDict:NSLocalizedString(@"THIS_MONTH", nil)
                                     startDate:[NSDate firstDateOfCurrentMonth]
                                       endDate:[NSDate lastDateOfCurrentMonth]];
    
    _filterArray = @[todayDict, weekDict, monthDict];
    
    
    int selectedCalendarFilterRow = [[NSUserDefaults standardUserDefaults] integerForKey:CTLDefaultSelectedCalendarFilter];
    _appointments = [[self.resultsController fetchedObjects] filteredArrayUsingPredicate:_filterArray[selectedCalendarFilterRow][@"predicate"]];
    
    [self setEventKeys];
    
     _filterPickerView = [self createFilterPickerView];
    [_filterPickerView selectRow:selectedCalendarFilterRow inComponent:0 animated:NO];
    self.navigationItem.titleView = [self filterPickerButtonWithTitle:_filterArray[selectedCalendarFilterRow][@"title"]];
   
    _emptyView = [self buildEmptyView];

    //tap to dissmiss the filter picker
    //[self.tableView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissPickerFromTap:)]];
}

- (void)setEventKeys
{
    _events = [NSMutableDictionary dictionary];
    if([_appointments count] > 0){
        for(NSInteger i=0;i<[_appointments count]; i++){
            CTLCDAppointment *appt = _appointments[i];
            [_events setObject:appt forKey:appt.eventID];
        }
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reloadAppointments:)
                                                 name:CTLReloadAppointmentsNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(eventDidChange:)
                                                 name:EKEventStoreChangedNotification
                                               object:_eventStore];
}

- (NSDictionary *)filterDict:title startDate:(NSDate *)startDate endDate:(NSDate *)endDate
{
    NSPredicate *calPredicate = [_eventStore predicateForEventsWithStartDate:startDate endDate:endDate calendars:nil];
    NSPredicate *cdPredicate = [NSPredicate predicateWithFormat:@"(startDate >= %@) AND (startDate =< %@)", startDate, endDate];
    return @{@"title":title, @"predicate":cdPredicate, @"calPredicate":calPredicate};
}

- (void)eventDidChange:(NSNotification *)notification
{
    _eventStore = notification.object;
    int selectedCalendarFilterRow = [[NSUserDefaults standardUserDefaults] integerForKey:CTLDefaultSelectedCalendarFilter];
    
    NSDictionary *filter = _filterArray[selectedCalendarFilterRow];
    NSArray *events = [_eventStore eventsMatchingPredicate:filter[@"calPredicate"]];
    __block BOOL hasChanges = NO;
    
    if([events count] > 0){
        for(NSInteger i=0;i<[events count];i++){
            EKEvent *event = events[i];
            if(_events[event.eventIdentifier] != nil){
                hasChanges = YES;
                CTLCDAppointment *appointment = _events[event.eventIdentifier];
                appointment.title = event.title;
                appointment.startDate = event.startDate;
                appointment.endDate = event.endDate;
                appointment.location = event.location;
                appointment.notes = event.notes;
                appointment.wasModifiedValue = YES;
                
                [_events setObject:appointment forKey:event.eventIdentifier];
            }
        }
    }
    
    if([_events count] > 0){
        [_events enumerateKeysAndObjectsUsingBlock:^(NSString *eventID, CTLCDAppointment *appointment, BOOL *stop){
            if(appointment.wasModifiedValue == NO){
                [appointment MR_deleteEntity];
                hasChanges = YES;
            }
        }];
    }
    
    if(hasChanges){
        [[NSManagedObjectContext MR_contextForCurrentThread] MR_saveToPersistentStoreWithCompletion:^(BOOL success, NSError *error){
            [self reloadAppointments:nil];
        }];
    }
}

- (void)rememberAppointmentFilter:(int)index
{
    [[NSUserDefaults standardUserDefaults] setInteger:index forKey:CTLDefaultSelectedCalendarFilter];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (UIView *)buildEmptyView
{
    CGRect viewFrame = self.view.frame;
    
    UIView *emptyView = [[UIView alloc] initWithFrame:viewFrame];
    UIColor *textColor = [UIColor colorFromUnNormalizedRGB:76.0f green:91.0f blue:130.0f alpha:1.0f];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 90.0f, viewFrame.size.width, 25.0f)];
    [titleLabel setBackgroundColor:[UIColor clearColor]];
    [titleLabel setTextAlignment:NSTextAlignmentCenter];
    [titleLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:20.0f]];
    [titleLabel setTextColor:textColor];
    [titleLabel setText:NSLocalizedString(@"NO_APPOINTMENTS", nil)];
       
    UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 120.0f, viewFrame.size.width, 25.0f)];
    [messageLabel setBackgroundColor:[UIColor clearColor]];
    [messageLabel setTextAlignment:NSTextAlignmentCenter];
    [messageLabel setFont:[UIFont fontWithName:@"Helvetica" size:14.0f]];
    [messageLabel setTextColor:textColor];
    [messageLabel setText:NSLocalizedString(@"NO_APPOINTMENTS_FOUND", nil)];
    
    CGFloat buttonCenter = viewFrame.size.width/2 - 70;
    UIButton *addButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    UIImage *buttonImage = [[UIImage imageNamed:@"whiteButton.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(18, 18, 18, 18)];
    UIImage *buttonImageHighlight = [[UIImage imageNamed:@"whiteButtonHighlight.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(18, 18, 18, 18)];
    
    // Set the background for any states you plan to use
    [addButton setBackgroundImage:buttonImage forState:UIControlStateNormal];
    [addButton setTitleColor:[UIColor colorFromUnNormalizedRGB:81.0f green:91.0f blue:130.0f alpha:1.0f] forState:UIControlStateNormal];
    
    [addButton setBackgroundImage:buttonImageHighlight forState:UIControlStateHighlighted];
    [addButton setTitleColor:[UIColor colorFromUnNormalizedRGB:61.0f green:71.0f blue:110.0f alpha:1.0f] forState:UIControlStateHighlighted];
    
    [addButton setFrame:CGRectMake(buttonCenter, 175.0f, 140.0f, 38.0f)];
    [addButton.titleLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:14.0f]];
    [addButton addTarget:self action:@selector(addAppointment:) forControlEvents:UIControlEventTouchUpInside];
    [addButton setTitle:NSLocalizedString(@"ADD_APPOINTMENT", nil) forState:UIControlStateNormal];
    
    addButton.layer.shadowOpacity = 0.2f;
    addButton.layer.shadowRadius = 1.0f;
    addButton.layer.shadowOffset = CGSizeMake(0,0);
    
    [emptyView addSubview:titleLabel];
    [emptyView addSubview:messageLabel];
    [emptyView addSubview:addButton];
    
    return emptyView;
}

- (IBAction)addAppointment:(id)sender
{
    [self performSegueWithIdentifier:CTLAppointmentModalSegueIdentifyer sender:sender];
}

- (void)reloadAppointments:(NSNotification *)notification
{
    self.resultsController = [CTLCDAppointment fetchedResultsController];
    NSDictionary *filter = [_filterArray objectAtIndex:[_filterPickerView selectedRowInComponent:0]];
    _appointments = [[self.resultsController fetchedObjects] filteredArrayUsingPredicate:filter[@"predicate"]];
    [self setEventKeys];
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if([_appointments count] == 0){
        return self.view.bounds.size.height;
    }
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if([_appointments count] == 0){
        return _emptyView;
    }
    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_appointments count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = nil;
    
    CTLCDAppointment *appointment = [_appointments objectAtIndex:indexPath.row];
    
    if(appointment.hasAddressValue){
        cellIdentifier = @"apptCellHasMap";
    }else{
        cellIdentifier = @"apptCellNoMap";
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
    
    CTLCDAppointment *appointment = [_appointments objectAtIndex:indexPath.row];
    [self performSegueWithIdentifier:CTLAppointmentFormSegueIdentifyer sender:appointment];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60.0f;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(editingStyle == UITableViewCellEditingStyleDelete){
        CTLCDAppointment *appointment = [_appointments objectAtIndex:indexPath.row];
        [self deleteAppointment:appointment];
        NSError *error = nil;
        EKEvent *event = [_eventStore eventWithIdentifier:appointment.eventID];
        [_eventStore removeEvent:event span:EKSpanThisEvent error:&error];
    }
}

- (void)changeAppointmentStatus:(CTLAppointmentCell *)cell
{
    ////NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    //CTLCDAppointment *appointment = [_appointments objectAtIndex:indexPath.row];
    /*
    if([appointment compeletedValue]){
        [appointment setCompeleted:@(0)];
        [appointment setCompletedDate:nil];
        
        BOOL isOverDue = [appointment.startDate compare:[NSDate date]] == NSOrderedAscending;
        [cell decorateInCompletedCell:isOverDue];
        
    }else{
        [cell decorateCompletedCell];
        [appointment setCompeleted:@(1)];
        [appointment setCompletedDate:[NSDate date]];
    }
    
    [[NSManagedObjectContext MR_contextForCurrentThread] MR_saveToPersistentStoreAndWait];
     */
}

- (void)deleteAppointment:(CTLCDAppointment *)appointment
{
    [appointment MR_deleteEntity];
    [[NSManagedObjectContext MR_contextForCurrentThread] MR_saveToPersistentStoreWithCompletion:^(BOOL success, NSError *error){
        [self reloadAppointments:nil];
    }];
}

#pragma mark - CTLAppointmentDelegate methods

- (void)configure:(CTLAppointmentCell *)cell withAppointment:(CTLCDAppointment *)appointment
{
    [cell setSelectionStyle:UITableViewCellEditingStyleNone];
    cell.titleLabel.text = appointment.title;
    NSString *timeString = [NSString stringWithFormat:@"%@ - %@", [NSDate formatShortTimeOnly:appointment.startDate], [NSDate formatShortTimeOnly:appointment.endDate]];
    cell.timeLabel.text = [timeString lowercaseString];
    cell.dateLabel.text= [NSDate formatShortDateOnly:appointment.startDate];
    cell.dateLabel.textColor = [UIColor darkGrayColor];
    
    if([appointment.startDate compare:[NSDate date]] == NSOrderedAscending){
        cell.dateLabel.textColor = [UIColor redColor];
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
    CTLCDAppointment *appointment = [_appointments objectAtIndex:indexPath.row];
    
    NSDictionary *addressDict = @{@"address": appointment.address, @"city": appointment.city, @"state": appointment.state, @"zip": appointment.address};
    
    NSArray *addressArray = [addressDict allValues];
    NSMutableArray *addyArray = [[NSMutableArray alloc] init];
    
    for(NSUInteger i=0;i<[addressArray count];i++){
        if([[addressArray objectAtIndex:i] length] > 0){
            [addyArray addObject:[addressArray objectAtIndex:i]];
        }
    }
    
    NSString *addressStr = [addyArray componentsJoinedByString:@", "];
    NSString *encodedAddress = [addressStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
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
            [viewController setCdAppointment:appointment];
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

- (UIButton *)filterPickerButtonWithTitle:(NSString *)selectedFilterName
{
    CTLPickerButton *uiButton = [[CTLPickerButton alloc] initWithTitle:selectedFilterName];
    [uiButton addTarget:self action:@selector(togglePicker:) forControlEvents:UIControlEventTouchUpInside];
    return uiButton;
}

- (void)updateFilterPickerButtonWithTitle:(NSString *)filterName
{
    CTLPickerButton *uiButton = (CTLPickerButton *)self.navigationItem.titleView;
    [uiButton updateTitle:filterName];
    self.navigationItem.titleView = uiButton;
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
    return (touchedView == self.tableView || touchedView == _emptyView);
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
    int selectedIndex = [_filterPickerView selectedRowInComponent:0];
    NSDictionary *filter = [_filterArray objectAtIndex:selectedIndex];
    
    [self updateFilterPickerButtonWithTitle:filter[@"title"]];
    _appointments = [[self.resultsController fetchedObjects] filteredArrayUsingPredicate:filter[@"predicate"]];
    [self.tableView reloadData];
    [self rememberAppointmentFilter:selectedIndex];
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
