//
//  CTLContactHeaderView.h
//  Clientelle
//
//  Created by Kevin Liu on 9/22/12.
//  Copyright (c) 2012 Clientelle Leads LLC. All rights reserved.
//

@class CTLCDContact;

@class UIMenuController;

extern NSString *const CTLShareContactNotification;
extern CGFloat const CTLContactViewHeaderHeight;

@interface CTLContactHeaderView : UIView{
    BOOL _menuIsVisible;
    UIMenuController * _menuController;
}

@property (nonatomic, weak) UILabel *nameLabel;
@property (nonatomic, weak) UILabel *phoneLabel;
@property (nonatomic, weak) UIImageView *pictureView;
@property (nonatomic, weak) UIButton *editButton;
@property (nonatomic, weak) UIImageView *indicator;

- (void)populateViewData:(CTLCDContact *)contact;

- (void)reset;

@end
