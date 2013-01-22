//
//  RWSTwoPanelViewController.h
//  Created by Samuel Goodwin on 1/17/13.
//  Copyright (c) 2013 Roundwall Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RWSPanelController.h"
#import "RWSDetailPanel.h"

@interface RWSTwoPanelViewController : UIViewController

@property (nonatomic, weak) UIViewController<RWSPanelController> *panel;
@property (nonatomic, weak) UINavigationController *navigationController;

- (id)initWithMenu:(UIViewController<RWSPanelController> *)menuPanel andRightPanel:(UINavigationController *)rightPanel;
- (void)setMainView:(UINavigationController *)navController;
- (void)toggleMenu:(id)sender;

@end
