//
//  RWSTwoPanelViewController.h
//  Created by Samuel Goodwin on 1/17/13.
//  Copyright (c) 2013 Roundwall Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RWSPanelController.h"
#import "RWSDetailPanel.h"

@interface RWSTwoPanelViewController : UIViewController{
    BOOL _isOpened;
}

@property (nonatomic, assign) BOOL isOpened;
@property (nonatomic, weak) UIViewController<RWSPanelController> *panel;
@property (nonatomic, weak) UINavigationController *detail;

- (id)initWithPanels:(UIViewController<RWSPanelController> *)leftPanel andRightPanel:(UINavigationController *)rightPanel;
- (void)setDetailPanel:(UINavigationController *)detail;
- (void)toggleMenu:(id)sender;

@end
