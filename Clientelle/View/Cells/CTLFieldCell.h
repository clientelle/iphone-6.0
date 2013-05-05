//
//  CTLTextInputCell.h
//  Clientelle
//
//  Created by Kevin on 6/22/12.
//  Copyright (c) 2012 Clientelle Leads LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

//@protocol CTLFieldCellDelegate
//
//@property (nonatomic, weak) UITextField *focusedTextField;
//
//- (IBAction)highlightTextField:(UITextField *)textField;
//- (IBAction)textFieldDidChange:(UITextField *)textField;
//
//@end

@interface CTLFieldCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UITextField *textInput;

@end
