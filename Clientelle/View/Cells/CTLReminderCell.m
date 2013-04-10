//
//  CTLReminderCell.m
//  Clientelle
//
//  Created by Kevin Liu on 4/4/13.
//  Copyright (c) 2013 Kevin Liu. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "UIColor+CTLColor.h"
#import "NSDate+CTLDate.h"
#import "CTLViewDecorator.h"

#import "CTLReminderCell.h"
#import "CTLCDReminder.h"

@implementation CTLReminderCell

- (void)configure:(CTLCDReminder *)reminder
{
    self.reminder = reminder;
    self.titleLabel.text = reminder.title;
    self.dueDateLabel.text = [NSDate formatDateAndTime:reminder.dueDate];
}

- (IBAction)markAsComplete:(id)sender
{
    if([self.reminder compeletedValue]){
        [self.reminder setCompeleted:@(0)];
        [self.reminder setCompletedDate:nil];
        
        if([self.reminder.dueDate compare:[NSDate date]] == NSOrderedAscending){
            self.dueDateLabel.textColor = [UIColor redColor];
        }
        
        [self decorateInCompletedCell];
        
    }else{
        [self decorateCompletedCell];
        [self.reminder setCompeleted:@(1)];
        [self.reminder setCompletedDate:[NSDate date]];
    }
    
    [[NSManagedObjectContext MR_contextForCurrentThread] MR_saveToPersistentStoreAndWait];
}

- (void)drawRect:(CGRect)rect
{
    self.contentView.backgroundColor = [UIColor clearColor];
    CTLViewDecorator *decorator = [[CTLViewDecorator alloc] init];
    CAShapeLayer *dottedLine = [decorator createDottedLine:self.frame];
    [self.contentView.layer addSublayer:dottedLine];
    
    if([self.reminder compeletedValue]){
        [self decorateCompletedCell];
    }else if([self.reminder.dueDate compare:[NSDate date]] == NSOrderedAscending){
        self.dueDateLabel.textColor = [UIColor redColor];
    }
}

- (void)decorateInCompletedCell
{
    self.titleLabel.layer.sublayers = nil;
    [self.doneButton setImage:nil forState:UIControlStateNormal];
    
    if([self.reminder.dueDate compare:[NSDate date]] == NSOrderedAscending){
        self.dueDateLabel.textColor = [UIColor redColor];
    }
}

- (void)decorateCompletedCell
{
    UIImage *checkMark = [UIImage imageNamed:@"26-checkmark-gray.png"];
    [self.doneButton setImage:checkMark forState:UIControlStateNormal];
    
    CGSize titleLabelSize = [self.titleLabel.text sizeWithFont:self.titleLabel.font];
    CALayer *strikeThru = [CALayer layer];
    strikeThru.borderWidth = 1;
    strikeThru.borderColor = [UIColor darkGrayColor].CGColor;
    strikeThru.frame = CGRectMake(-5.0f, (titleLabelSize.height/2) + 1, titleLabelSize.width+10.0f, 1.0f);
    
    [self.titleLabel.layer addSublayer:strikeThru];
    [self.dueDateLabel setTextColor:[UIColor darkGrayColor]];
}

@end
