//
//  CTLAppointmentsViewController.m
//  Clientelle
//
//  Created by Kevin Liu on 3/11/13.
//  Copyright (c) 2013 Kevin Liu. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "NSDate+CTLDate.h"
#import "NSDate+TimeAgo.h"
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

@interface CTLAppointmentsListViewController()
@property (nonatomic, strong) EKEventStore *eventStore;
@property (nonatomic, strong) UIView *emptyView;
@end

@implementation CTLAppointmentsListViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
       
    self.tableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"groovepaper"]];

    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"BACK", nil) style:UIBarButtonItemStyleBordered target:nil action:nil];

    [self.navigationItem setBackBarButtonItem: backButton];

    self.emptyView = [self buildEmptyView];
    self.eventStore = [[EKEventStore alloc] init];

    [self loadAllAppointments];
    
    self.navigationItem.title = NSLocalizedString(@"APPOINTMENTS", nil);
}

- (void)loadAllAppointments
{
    self.resultsController = [CTLCDAppointment fetchAllSortedBy:@"startDate" ascending:YES withPredicate:nil groupBy:nil delegate:self];
    [self.resultsController performFetch:nil];
    [self.tableView reloadData];
}

- (UIView *)buildEmptyView
{
    CGRect viewFrame = self.view.frame;
    
    UIView *emptyView = [[UIView alloc] initWithFrame:viewFrame];
    UIColor *textColor = [UIColor colorFromUnNormalizedRGB:76.0f green:91.0f blue:130.0f alpha:1.0f];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 90.0f, viewFrame.size.width, 25.0f)];
    [titleLabel setBackgroundColor:[UIColor clearColor]];
    [titleLabel setTextAlignment:NSTextAlignmentCenter];
    [titleLabel setFont:[UIFont fontWithName:kCTLAppFontMedium size:20.0f]];
    [titleLabel setTextColor:textColor];
    [titleLabel setText:NSLocalizedString(@"NO_APPOINTMENTS", nil)];
    
    UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 120.0f, viewFrame.size.width, 25.0f)];
    [messageLabel setBackgroundColor:[UIColor clearColor]];
    [messageLabel setTextAlignment:NSTextAlignmentCenter];
    [messageLabel setFont:[UIFont fontWithName:kCTLAppFont size:14.0f]];
    [messageLabel setTextColor:textColor];
    [messageLabel setText:NSLocalizedString(@"START_BY_ADDING_APPOINTMENTS", nil)];
    
    
    UIButton *addButton = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *buttonImage = [[UIImage imageNamed:@"whiteButton"] resizableImageWithCapInsets:UIEdgeInsetsMake(18, 18, 18, 18)];
    UIImage *buttonImageHighlight = [[UIImage imageNamed:@"whiteButtonHighlight"] resizableImageWithCapInsets:UIEdgeInsetsMake(18, 18, 18, 18)];
    
    // Set the background for any states you plan to use
    [addButton setBackgroundImage:buttonImage forState:UIControlStateNormal];
    [addButton setTitleColor:[UIColor colorFromUnNormalizedRGB:81.0f green:91.0f blue:130.0f alpha:1.0f] forState:UIControlStateNormal];
    
    [addButton setBackgroundImage:buttonImageHighlight forState:UIControlStateHighlighted];
    [addButton setTitleColor:[UIColor colorFromUnNormalizedRGB:61.0f green:71.0f blue:110.0f alpha:1.0f] forState:UIControlStateHighlighted];
    
    UIFont *buttonFont = [UIFont fontWithName:kCTLAppFontMedium size:14.0f];
    NSString *buttonString = NSLocalizedString(@"ADD_APPOINTMENT", nil);
    CGSize buttonSize = [buttonString sizeWithFont:buttonFont];
    CGFloat buttonWidth = buttonSize.width + 20.0f;
    CGFloat buttonCenter = (viewFrame.size.width/2) - (buttonWidth/2);
    
    [addButton setFrame:CGRectMake(buttonCenter, 175.0f, buttonWidth, 38.0f)];
    [addButton.titleLabel setFont:buttonFont];
    [addButton addTarget:self action:@selector(addAppointment:) forControlEvents:UIControlEventTouchUpInside];
    [addButton setTitle:buttonString forState:UIControlStateNormal];
    
    addButton.layer.shadowOpacity = 0.2f;
    addButton.layer.shadowRadius = 1.0f;
    addButton.layer.shadowOffset = CGSizeMake(0,0);
    
    [emptyView addSubview:titleLabel];
    [emptyView addSubview:messageLabel];
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
    [label setFont:[UIFont fontWithName:kCTLAppFont size:15.0f]];
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
    if([[self.resultsController fetchedObjects] count] == 0){
        return CTLAppointmentRowHeight;
    }
    
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
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
    noCompletedItemsLabel.font = [UIFont fontWithName:kCTLAppFont size:15];
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
        EKEvent *event = [self.eventStore eventWithIdentifier:appointment.eventID];
        [self.eventStore removeEvent:event span:EKSpanThisEvent error:&error];
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
        [cell decorateInCompletedCell:appointment.startDate];
        
    }else{
        [cell decorateCompletedCell:appointment.startDate];
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
    
    cell.dateLabel.text= [NSDate formatShortDateOnly:appointment.startDate];
    cell.descLabel.text = appointment.title;
    cell.feeLabel.text = [appointment formattedFee];
    
    if([appointment.completed isEqual:@YES]){
        [cell decorateCompletedCell:appointment.startDate];
    }else{
        [cell decorateInCompletedCell:appointment.startDate];
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

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    CGPoint touchPoint = [gestureRecognizer locationInView:self.view];
    UIView *touchedView = [self.view hitTest:touchPoint withEvent:nil];
    return (touchedView == self.tableView || touchedView == self.emptyView);
}

#pragma mark - Filter Picker Delegate

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
	return 1;
}

- (void)markAsCompleted:(id)sender
{
    //[self.cdAppointment setCompeleted:@(1)];
    //[self.cdAppointment setCompletedDate:[NSDate date]];
    //[self saveAppointment:sender];
}

@end
