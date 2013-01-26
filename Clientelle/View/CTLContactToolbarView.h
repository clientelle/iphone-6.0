//
//  CTLContactToolbarView.h
//  Clientelle
//
//  Created by Kevin Liu on 9/27/12.
//  Copyright (c) 2012 Clientelle Leads LLC. All rights reserved.
//

extern CGFloat const CTLContactModeToolbarViewHeight;

@interface CTLContactToolbarView : UIView

@property(nonatomic, weak) UIButton *appointmentButton;
@property(nonatomic, weak) UIButton *emailButton;
@property(nonatomic, weak) UIButton *callButton;
@property(nonatomic, weak) UIButton *smsButton;
@property(nonatomic, weak) UIButton *mapButton;

@end
