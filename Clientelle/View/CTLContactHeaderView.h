//
//  CTLContactHeaderView.h
//  Clientelle
//
//  Created by Kevin Liu on 9/22/12.
//  Copyright (c) 2012 Clientelle Leads LLC. All rights reserved.
//

@class CTLABPerson;

extern CGFloat const CTLContactViewHeaderHeight;

@interface CTLContactHeaderView : UIView

@property (nonatomic, weak) IBOutlet UILabel *nameLabel;
@property (nonatomic, weak) IBOutlet UILabel *phoneLabel;
@property (nonatomic, weak) IBOutlet UIImageView *pictureView;
@property(nonatomic, weak)IBOutlet UIButton *editButton;

- (void)populateViewData:(CTLABPerson *)abPerson;

@end
