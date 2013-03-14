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
	// Do any additional setup after loading the view.
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStyleBordered target:nil action:nil];
    [self.navigationItem setBackBarButtonItem: backButton];
    
    self.resultsController = [CTLCDAppointment fetchedResultsController];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadAppointments:) name:CTLReloadAppointmentsNotification object:nil];
    
  
    self.tableView.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"groovepaper.png"]];

    
    _filterPickerView = [self createFilterPickerView];
    _filterArray = @[@"Today", @"Tomorrow", @"This Week", @"Last Week"];
    
    self.navigationItem.titleView = [self filterPickerButtonWithTitle:_filterArray[0]];
}


- (void)reloadAppointments:(NSNotification *)notification {
    self.resultsController = [CTLCDAppointment fetchedResultsController];
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id<NSFetchedResultsSectionInfo> info = [[self.resultsController sections] objectAtIndex:section];
    return [info numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"appointmentCell";
    CTLAppointmentCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    [cell setSelectionStyle:UITableViewCellEditingStyleNone];
    
    CTLCDAppointment *appointment = [self.resultsController objectAtIndexPath:indexPath];
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
    CTLCDAppointment *appointment = [self.resultsController objectAtIndexPath:indexPath];
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

- (void)togglePicker:(id)sender {
    if(_filterPickerView.isHidden){
        [_filterPickerView hidePicker];
        
    }else{
        [_filterPickerView showPicker];
    }
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
    NSString *filterName = [_filterArray objectAtIndex:[_filterPickerView selectedRowInComponent:0]];
    [self updateFilterPickerButtonWithTitle:filterName];
    //TODO: filter appointments
    
    
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
     return [_filterArray objectAtIndex:row];
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
	return [_filterArray count];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
