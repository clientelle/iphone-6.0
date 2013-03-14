//
//  CTLPickerView.h
//  Clientelle
//
//  Created by Kevin Liu on 3/12/13.
//  Copyright (c) 2013 Kevin Liu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CTLPickerView : UIPickerView

- (id)initWithWidth:(CGFloat)width;

- (void)showPicker;
- (void)hidePicker;

@property(nonatomic, assign) BOOL isVisible;

@end
