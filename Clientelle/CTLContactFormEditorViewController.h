//
//  CTLContactFormEditorViewController.h
//  Clientelle
//
//  Created by Kevin Liu on 6/24/12.
//  Copyright (c) 2012 Clientelle Ltd.. All rights reserved.
//

extern NSString *const CTLFormFieldAddedNotification;

@interface CTLContactFormEditorViewController : UIViewController<NSFetchedResultsControllerDelegate, UITableViewDelegate, UITableViewDataSource>{
    NSArray *_fields;
    BOOL _hasChanges;
}

@property (nonatomic, weak) IBOutlet UINavigationBar *navBar;
@property (nonatomic, strong) IBOutlet UITableView *tableView;

@property (nonatomic, strong) IBOutlet UIBarButtonItem *cancelButton;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *editButton;

- (IBAction)save:(id)sender;
- (IBAction)enableReordering:(id)sender;

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;

@end
