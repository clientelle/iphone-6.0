//
//  CTLContactsListViewController.m
//  Clientelle
//
//  Created by Kevin Liu on 1/21/13.
//  Copyright (c) 2013 Kevin Liu. All rights reserved.
//

#import "CTLContactsListViewController.h"

NSString *const CTLAllContactsTitle = @"All Contacts";

NSString *const CTLImporterSegueIdentifyer = @"toImporter";
NSString *const CTLContactListSegueIdentifyer = @"toContacts";
NSString *const CTLContactFormSegueIdentifyer = @"toContactForm";
NSString *const CTLProspectFormSegueIdentifyer = @"toProspectForm";
NSString *const CTLGroupListSegueIdentifyer = @"toGroupList";
NSString *const CTLAppointmentSegueIdentifyer = @"toSetAppointment";

NSString *const CTLContactListReloadNotification = @"com.clientelle.notifications.reloadContacts";
NSString *const CTLGroupWasRenamedNotification = @"com.clientelle.notifications.groupWasRenamed";
NSString *const CTLGroupWasAddedNotification = @"com.clientelle.notifications.groupWasAdded";
NSString *const CTLGroupWasDeletedNotification = @"com.clientelle.notifications.groupWasDeleted";


NSString *const CTLTimestampForRowNotification = @"com.clientelle.com.notifications.timestampChanged";
NSString *const CTLContactRowDidChangeNotification = @"com.clientelle.com.notifications.contactRowDidChange";
NSString *const CTLNewContactWasAddedNotification = @"com.clientelle.com.notifications.contactWasAdded";

@interface CTLContactsListViewController ()

@end

@implementation CTLContactsListViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"contactCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    cell.textLabel.text = NSLocalizedString(@"HELLO", nil);
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

}

@end
