//
//  CTLInviteContactViewController.h
//  Clientelle
//
//  Created by Kevin Liu 9/3/12.
//  Copyright (c) 2012 Clientelle Ltd.. All rights reserved.
//

#import <MessageUI/MessageUI.h>
#import <UIKit/UIKit.h>

@class CTLCDContact;

typedef void (^CTLCompletionWithInvitedContactBlock)(CTLCDContact *invitedContact);

@interface CTLInviteContactViewController: UIViewController<UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, CTLContainerViewDelegate,MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate, UIActionSheetDelegate>

@property (nonatomic, weak) CTLContainerViewController *containerView;
@property (nonatomic, weak) IBOutlet UIView *flashView;
@property (nonatomic, weak) IBOutlet UILabel *flashLabel;
@property (nonatomic, weak) IBOutlet UITableView *tableView;

- (IBAction)cancel:(id)sender;

@end
