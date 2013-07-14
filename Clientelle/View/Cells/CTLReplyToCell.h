//
//  CTLReplyToCell.h
//  Clientelle
//
//  Created by Kevin Liu on 7/13/13.
//  Copyright (c) 2013 Kevin Liu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CTLReplyToCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UILabel *inReplyToLabel;
@property (nonatomic, strong) IBOutlet UILabel *sentAtLabel;
@property (nonatomic, strong) IBOutlet UITextView *inReplyToTextView;

@end
