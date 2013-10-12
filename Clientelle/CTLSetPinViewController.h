//
//  CTLSetPinViewController.h
//  Clientelle
//
//  Created by Kevin Liu on 5/13/13.
//  Copyright (c) 2013 Kevin Liu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CTLSetPinViewController : UITableViewController<UITextFieldDelegate>{
    NSUserDefaults *_userDefaults;
    BOOL _inConfirmMode;
}

@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet UILabel *enter4digitLabel;
@property (nonatomic, weak) IBOutlet UITextField *pinTextField;
@property (nonatomic, weak) IBOutlet UITextField *confirmPinTextField;
@property (nonatomic, weak) IBOutlet UISwitch *pinSwitch;
@property (nonatomic, weak) IBOutlet UILabel *switchLabel;
@property (nonatomic, weak) IBOutlet UILabel *switchNoteLabel;

- (IBAction)switchDidChange:(UISwitch *)switchButton;

@end
