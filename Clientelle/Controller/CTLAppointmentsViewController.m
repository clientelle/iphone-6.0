//
//  CTLAppointmentsViewController.m
//  Clientelle
//
//  Created by Kevin Liu on 3/11/13.
//  Copyright (c) 2013 Kevin Liu. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "CTLCDAppointment.h"
#import "CTLAppointmentsViewController.h"
#import "CTLAddEventViewController.h"
#import "CTLAppointmentCell.h"
#import "NSDate+CTLDate.h"
#import "UIColor+CTLColor.h"
#import "CTLPickerView.h"
#import "CTLPickerButton.h"

NSString *const CTLReloadAppointmentsNotification = @"com.clientelle.notifications.reloadAppointments";
NSString *const CTLAppointmentFormSegueIdentifyer = @"toAppointmentForm";

@interface CTLAppointmentsViewController ()
@property (nonatomic, strong) NSFetchedResultsController *resultsController;
@end

@implementation CTLAppointmentsViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"BACK", nil) style:UIBarButtonItemStyleBordered target:nil action:nil];
    [self.navigationItem setBackBarButtonItem: backButton];
    
    //default to show current week
    self.resultsController = [CTLCDAppointment fetchedResultsController];
    
    NSLog(@"TODAY: (startDate >= %@) AND (startDate  < %@)", [NSDate today], [NSDate tomorrow]);
    NSLog(@"WEEK:  (startDate >= %@) AND (startDate  < %@)", [NSDate firstDayOfCurrentWeek], [NSDate lastDayOfCurrentWeek]);
    NSLog(@"MONTH: (startDate >= %@) AND (startDate  < %@)", [NSDate firstDateOfCurrentMonth], [NSDate lastDateOfCurrentMonth]);

    NSPredicate *todayPredicate = [NSPredicate predicateWithFormat:@"(startDate >= %@) AND (startDate  < %@)", [NSDate today], [NSDate tomorrow]];

    NSPredicate *thisWeekPredicate = [NSPredicate predicateWithFormat:@"(startDate > %@) AND (startDate =< %@)", [NSDate firstDayOfCurrentWeek], [NSDate lastDayOfCurrentWeek]];
    
    NSPredicate *thisMonthPredicate = [NSPredicate predicateWithFormat:@"(startDate >= %@) AND (startDate =< %@)", [NSDate firstDateOfCurrentMonth], [NSDate lastDateOfCurrentMonth]];
    
    NSDictionary *today     = @{@"title":NSLocalizedString(@"TODAY", nil),      @"predicate":todayPredicate};
    NSDictionary *thisWeek  = @{@"title":NSLocalizedString(@"THIS_WEEK", nil),  @"predicate":thisWeekPredicate};
    NSDictionary *thisMonth = @{@"title":NSLocalizedString(@"THIS_MONTH", nil), @"predicate":thisMonthPredicate};
    
    _filterArray = @[today, thisWeek, thisMonth];
    _appointments = [[self.resultsController fetchedObjects] filteredArrayUsingPredicate:thisWeek[@"predicate"]];
 
    //TODO: Remember last setting
    int defaultRow = 1;
     _filterPickerView = [self createFilterPickerView];
    [_filterPickerView selectRow:defaultRow inComponent:0 animated:NO];
    self.navigationItem.titleView = [self filterPickerButtonWithTitle:_filterArray[defaultRow][@"title"]];
    self.tableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"groovepaper.png"]];
    
    _emptyView = [self buildEmptyView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadAppointments:) name:CTLReloadAppointmentsNotification object:nil];
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
    
    [emptyView addSubview:titleLabel];
    [emptyView addSubview:messageLabel];
    
    return emptyView;
}

- (void)reloadAppointments:(NSNotification *)notification
{
    self.resultsController = [CTLCDAppointment fetchedResultsController];
    NSInteger selectedRow = [_filterPickerView selectedRowInComponent:0];
    NSDictionary *filter = [_filterArray objectAtIndex:selectedRow];
    _appointments = [[self.resultsController fetchedObjects] filteredArrayUsingPredicate:filter[@"predicate"]];
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
    static NSString *CellIdentifier = @"appointmentCell";
    CTLAppointmentCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    [cell setSelectionStyle:UITableViewCellEditingStyleNone];
    
    CTLCDAppointment *appointment = [_appointments objectAtIndex:indexPath.row];
    cell.titleLabel.text = appointment.title;
    
    NSString *location = [NSString stringWithFormat:@"%@", [NSDate dateToString:appointment.startDate]];
    if([appointment.location length]){
        location = [location stringByAppendingFormat:@" @ %@", appointment.location];
    }
    
    //if appointment is past due, decorate label with redColor
    if([appointment.startDate compare:[NSDate date]] == NSOrderedAscending){
        cell.locationLabel.textColor = [UIColor redColor];
    }else{
        cell.locationLabel.textColor = [UIColor ctlLightGreen];
    }
    
    cell.locationLabel.text = location;
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

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([[segue identifier] isEqualToString:CTLAppointmentFormSegueIdentifyer]){
        if([sender isKindOfClass:[CTLCDAppointment class]]){
            CTLCDAppointment *appointment = sender;
            CTLAddEventViewController *viewController = [segue destinationViewController];
            [viewController setCdAppointment:appointment];
        }
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
    if(_filterPickerView.isHidden){
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
    [_filterPickerView hidePicker];
}


#pragma mark - Filter Picker Delegate

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
	return 1;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    NSDictionary *filter = [_filterArray objectAtIndex:[_filterPickerView selectedRowInComponent:0]];
    [self updateFilterPickerButtonWithTitle:filter[@"title"]];
        
    _appointments = [[self.resultsController fetchedObjects] filteredArrayUsingPredicate:filter[@"predicate"]];
    [self.tableView reloadData];
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
     return [_filterArray objectAtIndex:row][@"title"];
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
	return [_filterArray count];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
