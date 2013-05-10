//
//  CTLContactToolbarView.h
//  Clientelle
//
//  Created by Kevin Liu on 9/27/12.
//  Copyright (c) 2012 Clientelle Leads LLC. All rights reserved.
//

extern CGFloat const CTLContactModeToolbarViewHeight;

@class CTLCDContact;
@class CTLContactToolbarView;

@protocol CTLContactToolbarDelegate
- (void)configureForContact:(UIView *)toolbar withContact:(CTLCDContact *)contact;
@end

@interface CTLContactToolbarView : UIView

@property (nonatomic, assign) id<CTLContactToolbarDelegate>delegate;

@property(nonatomic, weak) UIButton *appointmentButton;
@property(nonatomic, weak) UIButton *emailButton;
@property(nonatomic, weak) UIButton *callButton;
@property(nonatomic, weak) UIButton *smsButton;
@property(nonatomic, weak) UIButton *mapButton;

@end
