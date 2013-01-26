//
//  CTLTextInputCell.h
//  Clientelle
//
//  Created by Kevin on 6/22/12.
//  Copyright (c) 2012 Clientelle Leads LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CTLContactFieldCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *fieldLabel;
@property (weak, nonatomic) IBOutlet UITextField *textInput;

@end
