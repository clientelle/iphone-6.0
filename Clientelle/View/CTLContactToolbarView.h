//
//  CTLContactToolbarView.h
//  Clientelle
//
//  Created by Kevin Liu on 9/27/12.
//  Copyright (c) 2012 Clientelle Leads LLC. All rights reserved.
//

typedef enum{
    CTLMessagePreferenceTypeUndetermined= 0,
    CTLMessagePreferenceTypeEmail = 1,
    CTLMessagePreferenceTypeSms = 2,
    CTLMessagePreferenceTypeCtl = 3,
    CTLMessagePreferenceTypeAsk = 4
}CTLMessagePreferenceType;

extern CGFloat const CTLContactModeToolbarViewHeight;

@class CTLCDContact;

@protocol CTLContactToolbarDelegate
- (void)configureContactToolbar:(UIView *)toolbar forContact:(CTLCDContact *)contact;
@end

@interface CTLContactToolbarView : UIView

@property (nonatomic, assign) id<CTLContactToolbarDelegate>delegate;
@property (nonatomic, assign) CTLMessagePreferenceType messagePreference;
@property (nonatomic, weak) UIButton *appointmentButton;
@property (nonatomic, weak) UIButton *callButton;
@property (nonatomic, weak) UIButton *messageButton;

@end
