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
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"BACK", nil) style:UIBarButtonItemStyleBordered target:nil action:nil];
    [self.navigationItem setBackBarButtonItem: backButton];
    
    //default to show current week
    self.resultsController = [CTLCDAppointment fetchedResultsController];
    
    int selectedCalendarFilterRow = [[NSUserDefaults standardUserDefaults] integerForKey:CTLDefaultSelectedCalendarFilter];
    
    NSPredicate *todayPredicate = [NSPredicate predicateWithFormat:@"(startDate >= %@) AND (startDate  < %@)", [NSDate today], [NSDate tomorrow]];
    NSPredicate *thisWeekPredicate = [NSPredicate predicateWithFormat:@"(startDate > %@) AND (startDate =< %@)", [NSDate firstDayOfCurrentWeek], [NSDate lastDayOfCurrentWeek]];
    NSPredicate *thisMonthPredicate = [NSPredicate predicateWithFormat:@"(startDate >= %@) AND (startDate =< %@)", [NSDate firstDateOfCurrentMonth], [NSDate lastDateOfCurrentMonth]];
    
    NSDictionary *today     = @{@"title":NSLocalizedString(@"TODAY", nil),      @"predicate":todayPredicate};
    NSDictionary *thisWeek  = @{@"title":NSLocalizedString(@"THIS_WEEK", nil),  @"predicate":thisWeekPredicate};
    NSDictionary *thisMonth = @{@"title":NSLocalizedString(@"THIS_MONTH", nil), @"predicate":thisMonthPredicate};
    
    _filterArray = @[today, thisWeek, thisMonth];
    _appointments = [[self.resultsController fetchedObjects] filteredArrayUsingPredicate:_filterArray[selectedCalendarFilterRow][@"predicate"]];
     
     _filterPickerView = [self createFilterPickerView];
    [_filterPickerView selectRow:selectedCalendarFilterRow inComponent:0 animated:NO];
    self.navigationItem.titleView = [self filterPickerButtonWithTitle:_filterArray[selectedCalendarFilterRow][@"title"]];
    self.tableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"groovepaper.png"]];
    
    _emptyView = [self buildEmptyView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadAppointments:) name:CTLReloadAppointmentsNotification object:nil];
    //[self.tableView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissPickerFromTap:)]];
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
    [cell setSelectionStyle:UITableViewCellEditingStyleNone];
    [cell configure:appointment];

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

#pragma mark - Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([[segue identifier] isEqualToString:CTLAppointmentFormSegueIdentifyer]){
        if([sender isKindOfClass:[CTLCDAppointment class]]){
            CTLCDAppointment *appointment = (CTLCDAppointment *)sender;
            CTLAppointmentFormViewController *viewController = [segue destinationViewController];
            [viewController setIsPresentedAsModal:NO];
            [viewController setCdAppointment:appointment];
            return;
        }
    }
    
    if([[segue identifier] isEqualToString:CTLAppointmentModalSegueIdentifyer]){
        UINavigationController *navigationController = [segue destinationViewController];
        CTLAppointmentFormViewController *viewController = (CTLAppointmentFormViewController *)navigationController.topViewController;
        [viewController setIsPresentedAsModal:YES];
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

@end
