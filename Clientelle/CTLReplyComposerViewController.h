//
//  CTLReplyComposerViewController.h
//  Clientelle
//
//  Created by Kevin Liu on 6/17/13.
//  Copyright (c) 2013 Kevin Liu. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CTLCDConversation;

@interface CTLReplyComposerViewController : UIViewController<UITableViewDelegate>

@property (nonatomic, strong) CTLCDConversation *conversation;
@property (nonatomic, strong) IBOutlet UITableView *tableView;

- (IBAction)sendReply:(id)sender;
- (IBAction)dismiss:(id)sender;

@end
