//
//  CTLGroupsListViewController.h
//  Clientelle
//
//  Created by Kevin Liu on 1/21/13.
//  Copyright (c) 2013 Kevin Liu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>


@class CTLABGroup;

@interface CTLGroupsListViewController : UITableViewController<UIGestureRecognizerDelegate, UIActionSheetDelegate, MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate, CTLSlideMenuDelegate>{
    ABAddressBookRef _addressBookRef;
    CTLABGroup *_selectedGroup;
    NSMutableArray *_groupRecipients;
    NSIndexPath *_selectedIndexPath;
    NSArray *_abGroups;
    NSArray *_groupIDKeysArray;
    NSMutableDictionary *_groupsDict;
    UIActionSheet *_groupMessageActionSheet;
}

@property (nonatomic, weak) IBOutlet UILabel *footerLabel;
@property (nonatomic, weak) CTLSlideMenuController *menuController;

- (IBAction)newGroupPrompt:(id)sender;

@end
