//
//  CTLContactsListViewController.m
//  Clientelle
//
//  Created by Kevin Liu on 1/21/13.
//  Copyright (c) 2013 Kevin Liu. All rights reserved.
//

#import "CTLContactsListViewController.h"
#import "RWSTwoPanelViewController.h"

@interface CTLContactsListViewController ()

@end

@implementation CTLContactsListViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

     
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"38-house.png"] style:UIBarButtonItemStyleBordered target:self action:@selector(showMenu:)];

}


- (void)viewWillAppear:(BOOL)animate
{
    //if([self.twoPanelViewController isOpened]){
    //    [self showMenu:nil];
    //}
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"contactCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    cell.textLabel.text = @"hello";
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

}

- (IBAction)showMenu:(id)sender
{
    [self.twoPanelViewController toggleMenu:sender];
}

@end
