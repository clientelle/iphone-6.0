//
//  CTLContactImportViewController.h
//  Clientelle
//
//  Created by Kevin Liu 9/3/12.
//  Copyright (c) 2012 Clientelle Ltd.. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CTLContactImportViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>

@property(nonatomic, strong) IBOutlet UITableView *tableView;
@property(nonatomic, strong) IBOutlet UIBarButtonItem *doneButton;
@property(nonatomic, strong) IBOutlet UIActivityIndicatorView *busyIndicator;

- (IBAction)importContacts:(id)sender;
- (IBAction)cancelImport:(id)sender;

@end
