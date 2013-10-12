//
//  CTLContactHeaderView.h
//  Clientelle
//
//  Created by Kevin Liu on 9/22/12.
//  Copyright (c) 2012 Clientelle Leads LLC. All rights reserved.
//

@class CTLCDContact;
@class CTLContactHeaderView;
@class UIMenuController;

extern NSString *const CTLShareContactNotification;
extern CGFloat const CTLContactViewHeaderHeight;

@protocol CTLContactHeaderDelegate <NSObject>
- (void)populateViewData:(CTLContactHeaderView *)headerView withContact:(CTLCDContact *)contact;
@end

@interface CTLContactHeaderView : UIView{
    BOOL _menuIsVisible;
    UIMenuController * _menuController;
}

@property (nonatomic, assign) id<CTLContactHeaderDelegate>delegate;
@property (nonatomic, weak) UILabel *nameLabel;
@property (nonatomic, weak) UILabel *phoneLabel;
@property (nonatomic, weak) UIImageView *pictureView;

- (void)removeHighlight;

@end
