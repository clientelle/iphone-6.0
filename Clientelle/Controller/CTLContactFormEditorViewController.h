//
//  CTLContactFormEditorViewController.h
//  Clientelle
//
//  Created by Kevin Liu on 6/24/12.
//  Copyright (c) 2012 Clientelle Ltd.. All rights reserved.
//

extern NSString *const CTLFormFieldAddedNotification;

@class CTLCDFormSchema;

@interface CTLContactFormEditorViewController : UIViewController<UITableViewDelegate, UITableViewDataSource>{
    NSMutableArray *_fields;
    CTLCDFormSchema *_formSchema;
}

@property (nonatomic, weak) IBOutlet UINavigationBar *navBar;
@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *doneButton;
@property (nonatomic, strong) NSMutableArray *fields;
@property (nonatomic, strong) CTLCDFormSchema *formSchema;

- (IBAction)save:(id)sender;
- (IBAction)cancel:(id)sender;

@end
