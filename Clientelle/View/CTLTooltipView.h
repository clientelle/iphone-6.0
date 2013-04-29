//
//  CTLTooltipView.h
//  Clientelle
//
//  Created by Kevin Liu on 4/27/13.
//  Copyright (c) 2013 Kevin Liu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CTLTooltipView : UIView<UIGestureRecognizerDelegate>

- (id)initWithFrame:(CGRect)frame;
- (void)setTipText:(NSString *)message;
- (void)fadeOut:(NSTimeInterval)seconds;

@property (nonatomic, strong)UITextView *textView;

@end
