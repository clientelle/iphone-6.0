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
        
    if([reminder.dueDate compare:[NSDate date]] == NSOrderedAscending){
        self.dueDateLabel.textColor = [UIColor redColor];
    }
    
    self.dueDateLabel.text = [self generateDateStamp:reminder.dueDate];
}

- (UIButton *)createDoneButton
{
    UIButton *doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [doneButton setFrame:CGRectMake(0, 0, 30.0f, 30.f)];
    [doneButton setImage:[UIImage imageNamed:@"26-checkmark-gray.png"] forState:UIControlStateNormal];
    
    
    
    
    UIImage *buttonImage = [[UIImage imageNamed:@"whiteButton.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(18, 18, 18, 18)];
    UIImage *buttonImageHighlight = [[UIImage imageNamed:@"whiteButtonHighlight.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(18, 18, 18, 18)];
    
    // Set the background for any states you plan to use
    [doneButton setBackgroundImage:buttonImage forState:UIControlStateNormal];
    [doneButton setBackgroundImage:buttonImageHighlight forState:UIControlStateHighlighted];

    [doneButton addTarget:self action:@selector(markAsComplete:) forControlEvents:UIControlEventTouchUpInside];
    
    
    return doneButton;
}

- (IBAction)markAsComplete:(id)sender
{
    NSLog(@"MARKED AS COMPLETE");
    [self.doneButton setImage:[UIImage imageNamed:@"26-checkmark-gray.png"] forState:UIControlStateNormal];
}

- (NSString *)generateDateStamp:(NSDate *)date
{
    NSString *timestampDate = [NSDate formatShortDateOnly:date];
    NSString *currentDate = [NSDate formatShortDateOnly:[NSDate date]];
    
    if([timestampDate isEqualToString:currentDate]){
        timestampDate = [NSDate formatShortTimeOnly:date];
    }else{
        timestampDate = [NSDate formatDateAndTime:date];
    }
    
    return timestampDate;
}

- (void)drawRect:(CGRect)rect
{
    self.contentView.backgroundColor = [UIColor clearColor];
    CTLViewDecorator *decorator = [[CTLViewDecorator alloc] init];
    CAShapeLayer *dottedLine = [decorator createDottedLine:self.frame];
    [self.contentView.layer addSublayer:dottedLine];
    
    UIImage *buttonImage = [[UIImage imageNamed:@"whiteButton.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(18, 18, 18, 18)];
    UIImage *buttonImageHighlight = [[UIImage imageNamed:@"whiteButtonHighlight.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(18, 18, 18, 18)];
    
    // Set the background for any states you plan to use
    [self.doneButton setBackgroundImage:buttonImage forState:UIControlStateNormal];
    [self.doneButton setBackgroundImage:buttonImageHighlight forState:UIControlStateHighlighted];
}

@end
