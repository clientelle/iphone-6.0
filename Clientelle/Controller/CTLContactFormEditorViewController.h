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
}

@property (nonatomic, weak) IBOutlet UINavigationBar *navBar;
@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *doneButton;

- (IBAction)save:(id)sender;
- (IBAction)cancel:(id)sender;

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;

@end
