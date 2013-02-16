//
//  CTLEnterFormCodeViewController.h
//  Clientelle
//
//  Created by Kevin Liu on 2/15/13.
//  Copyright (c) 2013 Kevin Liu. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface CTLEnterFormCodeViewController : UIViewController<CTLSlideMenuDelegate>

@property (nonatomic, weak) CTLSlideMenuController *menuController;

@property (nonatomic, weak) IBOutlet UITextField *formCodeTextField;

- (IBAction)submitFormCode:(id)sender;

@end
