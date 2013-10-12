//
//  UITableViewCell+CellShadows.h
//  Clientelle
//
//  Created by Kevin Liu on 3/17/13.
//  Copyright (c) 2013 Kevin Liu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITableViewCell (CellShadows)

- (void)addShadowToCellInTableView:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath;
- (void)addShadowToCellInGroupedTableView:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath;

@end
