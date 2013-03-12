//
//  CTLAppointmentsViewController.h
//  Clientelle
//
//  Created by Kevin Liu on 3/11/13.
//  Copyright (c) 2013 Kevin Liu. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString *const CTLReloadAppointmentsNotification;

@interface CTLAppointmentsViewController : UIViewController<UITableViewDelegate, UITableViewDataSource, CTLSlideMenuDelegate>


@property (nonatomic, weak) CTLSlideMenuController *menuController;
@property (nonatomic, weak) IBOutlet UITableView *tableView;

@end
