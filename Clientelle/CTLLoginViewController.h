//
//  CTLLoginViewController.h
//  Clientelle
//
//  Created by Kevin Liu on 2/21/13.
//  Copyright (c) 2013 Kevin Liu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CTLLoginViewController : UITableViewController<CTLContainerViewDelegate>

@property (nonatomic, strong) CTLContainerViewController *containerView;

@property (nonatomic, weak) IBOutlet UITextField *emailTextField;
@property (nonatomic, weak) IBOutlet UITextField *passwordTextField;
@property (nonatomic, strong) NSString *emailAddress;

- (IBAction)login:(id)sender;
- (IBAction)forgotPassword:(id)sender;

@end
