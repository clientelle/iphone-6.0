//
//  CTLLoginViewController.h
//  Clientelle
//
//  Created by Kevin Liu on 2/21/13.
//  Copyright (c) 2013 Kevin Liu. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CTLAPI;

@interface CTLLoginViewController : UITableViewController<CTLContainerViewDelegate>{
    CTLAPI *_api;
}

@property (nonatomic, weak) CTLContainerViewController *containerView;

@property (nonatomic, strong) NSString *emailAddress;

@property (nonatomic, weak) IBOutlet UITextField *emailTextField;
@property (nonatomic, weak) IBOutlet UITextField *passwordTextField;

- (IBAction)loginAndSyncAccount:(id)sender;

- (IBAction)forgotPassword:(id)sender;

@end
