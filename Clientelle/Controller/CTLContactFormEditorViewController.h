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
    NSArray *_fieldSet;
    NSMutableArray *_enabledFields;
    NSMutableArray *_fieldRows;
}

@property (nonatomic, weak) IBOutlet UINavigationBar *navBar;
@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *doneButton;

@property (nonatomic, strong) CTLABGroup *abGroup;
@property (nonatomic, strong) CTLCDFormSchema *formSchema;
@property (nonatomic, strong) NSArray *fieldsFromPList;

- (IBAction)save:(id)sender;
- (IBAction)cancel:(id)sender;

@end
