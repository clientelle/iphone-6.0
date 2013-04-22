//
//  CTLMainMenuViewController.h
//  Clientelle
//
//  Created by Kevin Liu on 1/21/13.
//  Copyright (c) 2013 Kevin Liu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CTLMainMenuViewController : UITableViewController{
    NSIndexPath *_selectedIndexPath;
}

- (void)styleActiveCell:(NSIndexPath *)indexPath;

@property (nonatomic, strong) CTLSlideMenuController *menuController;
@property (nonatomic, strong) NSIndexPath *selectedIndexPath;

@end
