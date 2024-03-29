//
//  CTLMessageCell.h
//  Clientelle
//
//  Created by Kevin Liu on 5/28/13.
//  Copyright (c) 2013 Kevin Liu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CTLConversationCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *senderLabel;
@property (nonatomic, weak) IBOutlet UILabel *timeLabel;
@property (nonatomic, weak) IBOutlet UILabel *messageLabel;
@property (nonatomic, weak) IBOutlet UIButton *inviteButton;

@end
