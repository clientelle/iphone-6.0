//
//  CTLContactFormEditorViewController.h
//  Clientelle
//
//  Created by Kevin Liu on 6/24/12.
//  Copyright (c) 2012 Clientelle Ltd.. All rights reserved.
//

extern NSString *const CTLFormFieldAddedNotification;

@class CTLABGroup;
@class CTLCDFormSchema;

@interface CTLContactFormEditorViewController : UIViewController<UITableViewDelegate, UITableViewDataSource>{
    CTLCDFormSchema *_formSchema;
    NSArray *_fieldSet;
    NSMutableArray *_enabledFields;
    NSMutableArray *_fieldRows;
}

@property (nonatomic, strong) CTLABGroup *abGroup;
@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *doneButton;

- (IBAction)save:(id)sender;
- (IBAction)cancel:(id)sender;

@end