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
    
    CTLPickerView *_filterPickerView;
    NSArray *_filterArray;
}


@property (nonatomic, weak) CTLSlideMenuController *menuController;
@property (nonatomic, weak) IBOutlet UITableView *tableView;

- (IBAction)dismissPickerFromTap:(UITapGestureRecognizer *)recognizer;

@end
