//
//  CTLAppointmentsViewController.h
//  Clientelle
//
//  Created by Kevin Liu on 3/11/13.
//  Copyright (c) 2013 Kevin Liu. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString *const CTLReloadAppointmentsNotification;

@class CTLPickerView;

@interface CTLAppointmentsViewController : UIViewController<UITableViewDelegate, UITableViewDataSource, CTLSlideMenuDelegate, UIPickerViewDataSource, UIPickerViewDelegate>{
    UIView *_emptyView;
    CTLPickerView *_filterPickerView;
    NSArray *_filterArray;
    NSArray *_appointments;
}

@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, weak) CTLSlideMenuController *menuController;

- (IBAction)dismissPickerFromTap:(UITapGestureRecognizer *)recognizer;

@end
