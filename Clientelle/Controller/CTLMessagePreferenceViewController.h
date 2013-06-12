//
//  CTLMessagePreferenceViewController.h
//  Clientelle
//
//  Created by Kevin Liu on 6/6/13.
//  Copyright (c) 2013 Kevin Liu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CTLContactToolbarView.h"

@interface CTLMessagePreferenceViewController : UITableViewController{
    CTLMessagePreferenceType _preference;
    NSIndexPath *_checkedIndexPath;
}

@property (nonatomic, assign) BOOL isModal;
@property (nonatomic, strong) UINavigationBar *navbar;

@end
