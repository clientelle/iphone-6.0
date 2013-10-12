//
//  CTLMessengerInviteView.h
//  Clientelle
//
//  Created by Kevin Liu on 6/20/13.
//  Copyright (c) 2013 Kevin Liu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CTLMessengerInviteView : UIView

@property (nonatomic, strong) IBOutlet UIButton *closeModalButton;
@property (nonatomic, strong) IBOutlet UILabel *inviteContactViaLabel;
@property (nonatomic, strong) IBOutlet UIButton *inviteViaSMSButton;
@property (nonatomic, strong) IBOutlet UIButton *inviteViaEmailButton;
@property (nonatomic, strong) IBOutlet UILabel *sendLinkLabel;
@property (nonatomic, strong) IBOutlet UILabel *invitationLinkLabel;
@property (nonatomic, strong) IBOutlet UIButton *linkButton;

@end
