//
//  CTLMainMenuViewController.h
//  Clientelle
//
//  Created by Kevin Liu on 1/21/13.
//  Copyright (c) 2013 Kevin Liu. All rights reserved.
//

#import <UIKit/UIKit.h>

extern const CGFloat CTLMainMenuWidth;

@interface CTLMainMenuViewController : UITableViewController

- (void)styleActiveCell:(NSIndexPath *)indexPath;

@property (nonatomic, strong) CTLContainerViewController *containerView;
@property (nonatomic, strong) NSIndexPath *selectedIndexPath;

@end
