//
//  CTLRemindersListViewController.m
//  Clientelle
//
//  Created by Kevin Liu on 4/4/13.
//  Copyright (c) 2013 Kevin Liu. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "NSDate+CTLDate.h"
#import "UIColor+CTLColor.h"

#import "CTLCDReminder.h"
#import "CTLRemindersListViewController.h"
#import "CTLReminderFormViewController.h"

NSString *const CTLReloadRemindersNotification = @"com.clientelle.notifications.reloadReminders";
NSString *const CTLReminderFormSegueIdentifyer = @"toReminderForm";
NSString *const CTLReminderModalSegueIdentifyer = @"toReminderModal";

@interface CTLRemindersListViewController ()
@property (nonatomic, strong) NSFetchedResultsController *resultsController;
@end

@implementation CTLRemindersListViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"BACK", nil) style:UIBarButtonItemStyleBordered target:nil action:nil];
    [self.navigationItem setBackBarButtonItem: backButton];
    
    self.resultsController = [CTLCDReminder fetchedResultsController];

    _eventStore = [[EKEventStore alloc] init];
    
    _reminders = [self.resultsController fetchedObjects];
        
    [self setEventKeys];
    
    self.tableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"groovepaper.png"]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadReminders:) name:CTLReloadRemindersNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(eventDidChange:)
                                                 name:EKEventStoreChangedNotification
                                               object:_eventStore];

}

- (void)setEventKeys
{
    _events = [NSMutableDictionary dictionary];
    if([_reminders count] > 0){
        for(NSInteger i=0;i<[_reminders count]; i++){
            CTLCDReminder *reminder = _reminders[i];
            [_events setObject:reminder forKey:reminder.eventID];
        }
    }
}

- (void)eventDidChange:(NSNotification *)notification
{
    if(_changeDidComeFromApp){
        _changeDidComeFromApp = NO;
        return;
    }
    _eventStore = notification.object;
           
    EKCalendar *calendar = [_eventStore defaultCalendarForNewReminders];
    NSPredicate *predicate = [_eventStore predicateForRemindersInCalendars:@[calendar]];
    __block BOOL hasChanges = NO;
    
    [_eventStore fetchRemindersMatchingPredicate:predicate completion:^(NSArray *reminders) {
        for (EKReminder *reminder in reminders) {
            if(_events[reminder.calendarItemIdentifier] != nil){
                hasChanges = YES;
                CTLCDReminder *cdReminder = _events[reminder.calendarItemIdentifier];
                cdReminder.title = reminder.title;
                cdReminder.compeletedValue = reminder.completed;
                cdReminder.completedDate = reminder.completionDate;
                cdReminder.dueDate = [NSDate dateFromComponents:reminder.dueDateComponents];
                cdReminder.wasModifiedValue = YES;
                
                [_events setObject:cdReminder forKey:reminder.calendarItemIdentifier];
            }
        }
    }];
    
    if([_events count] > 0){
        [_events enumerateKeysAndObjectsUsingBlock:^(NSString *eventID, CTLCDReminder *reminder, BOOL *stop){
            if(reminder.wasModifiedValue == NO){
                [reminder MR_deleteEntity];
                hasChanges = YES;
            }
        }];
    }
    
    if(hasChanges){
        [[NSManagedObjectContext MR_contextForCurrentThread] MR_saveToPersistentStoreWithCompletion:^(BOOL success, NSError *error){
            [self reloadReminders:nil];
        }];
    }
}


- (void)reloadReminders:(NSNotification *)notification
{
    _changeDidComeFromApp = YES;
    self.resultsController = [CTLCDReminder fetchedResultsController];
    _reminders = [self.resultsController fetchedObjects];
    [self.tableView reloadData];
}

- (IBAction)addReminder:(id)sender
{
    [self performSegueWithIdentifier:CTLReminderModalSegueIdentifyer sender:sender];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([[segue identifier] isEqualToString:CTLReminderFormSegueIdentifyer]){
        if([sender isKindOfClass:[CTLCDReminder class]]){
            CTLCDReminder *reminder = (CTLCDReminder *)sender;
            CTLReminderFormViewController *viewController = [segue destinationViewController];
            [viewController setPresentedAsModal:NO];
            [viewController setCdReminder:reminder];
            return;
        }
    }
    
    if([[segue identifier] isEqualToString:CTLReminderModalSegueIdentifyer]){
        UINavigationController *navigationController = [segue destinationViewController];
        CTLReminderFormViewController *viewController = (CTLReminderFormViewController *)navigationController.topViewController;
        [viewController setPresentedAsModal:YES];
        return;
    }
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if([_reminders count] == 0){
        return self.view.bounds.size.height;
    }
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if([_reminders count] == 0){
        CGRect viewFrame = self.view.frame;
        
        UIView *emptyView = [[UIView alloc] initWithFrame:viewFrame];
        UIColor *textColor = [UIColor colorFromUnNormalizedRGB:76.0f green:91.0f blue:130.0f alpha:1.0f];
        
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 90.0f, viewFrame.size.width, 25.0f)];
        [titleLabel setBackgroundColor:[UIColor clearColor]];
        [titleLabel setTextAlignment:NSTextAlignmentCenter];
        [titleLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:20.0f]];
        [titleLabel setTextColor:textColor];
        [titleLabel setText:NSLocalizedString(@"NO_REMINDERS", nil)];
        
        UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 120.0f, viewFrame.size.width, 25.0f)];
        [messageLabel setBackgroundColor:[UIColor clearColor]];
        [messageLabel setTextAlignment:NSTextAlignmentCenter];
        [messageLabel setFont:[UIFont fontWithName:@"Helvetica" size:14.0f]];
        [messageLabel setTextColor:textColor];
        [messageLabel setText:NSLocalizedString(@"NO_REMINDERS_FOUND", nil)];
        
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
        [addButton addTarget:self action:@selector(addReminder:) forControlEvents:UIControlEventTouchUpInside];
        [addButton setTitle:NSLocalizedString(@"ADD_REMINDER", nil) forState:UIControlStateNormal];
        
        addButton.layer.shadowOpacity = 0.2f;
        addButton.layer.shadowRadius = 1.0f;
        addButton.layer.shadowOffset = CGSizeMake(0,0);
        
        [emptyView addSubview:titleLabel];
        [emptyView addSubview:messageLabel];
        [emptyView addSubview:addButton];
        
        return emptyView;
    }
    return nil;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_reminders count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CTLCDReminder *reminder = [_reminders objectAtIndex:indexPath.row];
    static NSString *cellIdentifier = @"reminderCell";
    CTLReminderCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    [self configure:cell withReminder:reminder];
    return cell;
}

- (void)changeReminderStatus:(CTLReminderCell *)cell
{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    CTLCDReminder *reminder = [_reminders objectAtIndex:indexPath.row];
    
    if([reminder compeletedValue]){
        [reminder setCompeleted:@(0)];
        [reminder setCompletedDate:nil];
        
        BOOL isOverDue = [reminder.dueDate compare:[NSDate date]] == NSOrderedAscending;
        [cell decorateInCompletedCell:isOverDue];
        
    }else{
        [cell decorateCompletedCell];
        [reminder setCompeleted:@(1)];
        [reminder setCompletedDate:[NSDate date]];
    }
    
    [[NSManagedObjectContext MR_contextForCurrentThread] MR_saveToPersistentStoreAndWait];
}

- (void)configure:(CTLReminderCell *)cell withReminder:(CTLCDReminder *)reminder
{
    cell.delegate = self;
    [cell setSelectionStyle:UITableViewCellEditingStyleNone];
    
    cell.titleLabel.text = reminder.title;
    cell.titleLabel.layer.sublayers = nil;
    cell.dueDateLabel.text = [NSDate formatDateAndTime:reminder.dueDate];
     
    if(reminder.compeletedValue){
        [cell decorateCompletedCell];
    }else{
        BOOL isOverDue = [reminder.dueDate compare:[NSDate date]] == NSOrderedAscending;
        [cell decorateInCompletedCell:isOverDue];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    CTLCDReminder *reminder = [_reminders objectAtIndex:indexPath.row];
    [self performSegueWithIdentifier:CTLReminderFormSegueIdentifyer sender:reminder];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
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
        CTLCDReminder *reminder = [_reminders objectAtIndex:indexPath.row];
        [self deleteReminder:reminder];
    }
}

- (void)deleteReminder:(CTLCDReminder *)reminder
{
    [reminder MR_deleteEntity];
    [[NSManagedObjectContext MR_contextForCurrentThread] MR_saveToPersistentStoreWithCompletion:^(BOOL success, NSError *error){
        [self reloadReminders:nil];
    }];
}

@end
