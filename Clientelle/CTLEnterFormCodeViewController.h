//
//  CTLEnterFormCodeViewController.h
//  Clientelle
//
//  Created by Kevin Liu on 2/15/13.
//  Copyright (c) 2013 Kevin Liu. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface CTLEnterFormCodeViewController : UIViewController<CTLContainerViewDelegate>

@property (nonatomic, weak) CTLContainerViewController *containerView;

@property (nonatomic, weak) IBOutlet UITextField *formCodeTextField;

- (IBAction)submitFormCode:(id)sender;

@end
