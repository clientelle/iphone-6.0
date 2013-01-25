//
//  CTLContactsListViewController.h
//  Clientelle
//
//  Created by Kevin Liu on 1/21/13.
//  Copyright (c) 2013 Kevin Liu. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString *const CTLContactListReloadNotification;
extern NSString *const CTLGroupWasRenamedNotification;
extern NSString *const CTLGroupWasAddedNotification;
extern NSString *const CTLGroupWasDeletedNotification;

extern NSString *const CTLImporterSegueIdentifyer;
extern NSString *const CTLContactListSegueIdentifyer;
extern NSString *const CTLContactFormSegueIdentifyer;
extern NSString *const CTLGroupListSegueIdentifyer;
extern NSString *const CTLAddGroupSegueIdentifyer;
extern NSString *const CTLTimestampForRowNotification;
extern NSString *const CTLContactRowDidChangeNotification;
extern NSString *const CTLNewContactWasAddedNotification;

@interface CTLContactsListViewController : UITableViewController<CTLSlideMenuDelegate>
@property (nonatomic, weak) CTLSlideMenuController *menuController;

@end
