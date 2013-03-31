//
//  CTLUserCell.h
//  Clientelle
//
//  Created by Kevin on 6/21/12.
//  Copyright (c) 2012 Clientelle Leads LLC. All rights reserved.
//

@class CTLABPerson;

@interface CTLContactCell : UITableViewCell

@property (nonatomic, assign) int row;
@property (nonatomic, assign) BOOL isSearchItem;
@property (nonatomic, weak) IBOutlet UILabel *nameLabel;
@property (nonatomic, weak) IBOutlet UILabel *detailsLabel;
@property (nonatomic, weak) IBOutlet UILabel *timestampLabel;
@property (nonatomic, weak) CALayer *indicatorLayer;

- (void)configure:(CTLABPerson *)person;
- (void)setIndicator;

@end



