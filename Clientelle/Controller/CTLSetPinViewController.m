//
//  CTLSetPinViewController.m
//  Clientelle
//
//  Created by Kevin Liu on 5/13/13.
//  Copyright (c) 2013 Kevin Liu. All rights reserved.
//
#import "UITableViewCell+CellShadows.h"
#import "UIColor+CTLColor.h"
#import "CTLSetPinViewController.h"

@implementation CTLSetPinViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    _inConfirmMode = NO;
    _userDefaults = [NSUserDefaults standardUserDefaults];
    
    self.navigationItem.title = NSLocalizedString(@"ENABLE_APP_LOCK", nil);
    
    self.titleLabel.text = NSLocalizedString(@"SET_A_PIN", nil);
    self.enter4digitLabel.text = NSLocalizedString(@"ENTER_FOUR_DIGIT_CODE", nil);
    self.switchNoteLabel.text = NSLocalizedString(@"REQUIRES_A_PASSCODE", nil);
    
    self.tableView.backgroundColor = [UIColor colorFromUnNormalizedRGB:206.0f green:206.0f blue:206.0f alpha:1.0f];
    [self.tableView setSeparatorColor:[UIColor colorFromUnNormalizedRGB:247.0f green:247.0f blue:247.0f alpha:1.0f]];
   
    NSString *savedPinNumber = [_userDefaults valueForKey:@"PIN_NUMBER"];
    BOOL pinSwitchEnabled = [_userDefaults boolForKey:@"PIN_ENABLED"];
    
    [self.pinSwitch setOn:pinSwitchEnabled animated:NO];
       
    if(savedPinNumber){
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"RESET", nil) style:UIBarButtonItemStylePlain target:self action:@selector(resetPIN:)];
        
        self.pinTextField.backgroundColor = [UIColor lightGrayColor];
        self.pinTextField.textColor = [UIColor darkGrayColor];
        self.pinTextField.text = savedPinNumber;
        self.pinTextField.enabled = NO;
        [self.pinSwitch setEnabled:YES];
    }else{
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneButtonWasTapped:)];
        [self.pinSwitch setEnabled:NO];
    }
    
    if(pinSwitchEnabled){
        self.switchLabel.textColor = [UIColor ctlGreen];
        self.switchLabel.text = NSLocalizedString(@"LOCK_ENABLED", nil);
    }else{
        self.switchLabel.textColor = [UIColor ctlRed];
        self.switchLabel.text = NSLocalizedString(@"LOCK_DISABLED", nil);
    }
}

- (void)resetPIN:(id)sender
{
    UIAlertView *confirmPinAlert = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"ENTER_CURRENT_PIN", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"CANCEL", nil) otherButtonTitles:@"OK", nil];
    
    confirmPinAlert.alertViewStyle = UIAlertViewStyleSecureTextInput;
    
    UITextField *textField = [confirmPinAlert textFieldAtIndex:0];
    textField.keyboardType = UIKeyboardTypeNumberPad;
    textField.delegate = self;
    [confirmPinAlert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *pinNumber = [_userDefaults valueForKey:@"PIN_NUMBER"];
    if(buttonIndex == 1){
        
        if([[alertView textFieldAtIndex:0].text isEqualToString:pinNumber]){
            self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneButtonWasTapped:)];
            
            self.navigationItem.rightBarButtonItem.enabled = NO;
            
            self.pinTextField.text = @"";
            self.pinTextField.placeholder = NSLocalizedString(@"NEW_PIN", nil);
            self.pinTextField.enabled = YES;
            self.pinTextField.backgroundColor = [UIColor whiteColor];
            self.pinTextField.textColor = [UIColor blackColor];
            
            self.titleLabel.text = NSLocalizedString(@"RESET_PIN_CODE", nil);
            self.enter4digitLabel.text = NSLocalizedString(@"ENTER_A_NEW_FOUR_DIGIT_CODE", nil);
            self.enter4digitLabel.textColor = [UIColor ctlGreen];
            
            _inConfirmMode = YES;
            
            self.confirmPinTextField.hidden = NO;
            
            [self.tableView reloadData];

        }else{
            self.navigationItem.rightBarButtonItem.style = UIBarButtonItemStyleDone;
            self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"TRY_AGAIN", nil) style:UIBarButtonItemStylePlain target:self action:@selector(resetPIN:)];
            
            self.enter4digitLabel.text = NSLocalizedString(@"WRONG_PIN_ENTERED", nil);
            self.enter4digitLabel.textColor = [UIColor ctlRed];
            self.pinTextField.backgroundColor = [UIColor colorFromUnNormalizedRGB:224.0f green:190.0f blue:193.0f alpha:1.0f];
        }
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSUInteger newLength = [textField.text length] + [string length] - range.length;

    if([textField.text length] == 3){
        if(_inConfirmMode){
            if([self.pinTextField.text length] > 0 && [self.confirmPinTextField.text length] > 0){
                self.navigationItem.rightBarButtonItem.enabled = YES;
            }
        }else{
            self.navigationItem.rightBarButtonItem.enabled = YES;
        }
    }
    
    return (newLength > 4) ? NO : YES;
}

- (BOOL)textFieldShouldReturn: (UITextField*) textField
{
    return NO;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    self.pinSwitch.enabled = NO;
    [self.pinSwitch setOn:NO animated:YES];
    return YES;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row == 0){
        if(_inConfirmMode){
            return 170.0f;
        }else{
            return 126.0f;
        }
    }
    
    if(indexPath.row == 1){
        return 103.0f;
    }
    
    return 100.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    [cell addShadowToCellInGroupedTableView:self.tableView atIndexPath:indexPath];
    return cell;
}

- (IBAction)switchDidChange:(UISwitch *)switchButton
{
    if(switchButton.on){
        self.switchLabel.textColor = [UIColor ctlGreen];
        self.switchLabel.text = NSLocalizedString(@"LOCK_ENABLED", nil);
    }else{
        self.switchLabel.textColor = [UIColor ctlRed];
        self.switchLabel.text = NSLocalizedString(@"LOCK_DISABLED", nil);
    }
    
    [_userDefaults setBool:switchButton.on forKey:@"PIN_ENABLED"];
    [_userDefaults synchronize];
}

- (void)doneButtonWasTapped:(id)sender
{
    NSString *pinNumber = self.pinTextField.text;
    
    if([pinNumber length] == 4){
        if(_inConfirmMode){
            if([pinNumber isEqualToString:self.confirmPinTextField.text]){
                [self savePin:pinNumber];
            }else{
                self.enter4digitLabel.text = NSLocalizedString(@"PIN_DOES_NOT_MATCH", nil);
                self.enter4digitLabel.textColor = [UIColor ctlRed];
            }
        }else{
            [self savePin:pinNumber];
        }
        
    }else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"MUST_BE_FOUR_DIGITS", nil) delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        
        [alert show];
        
        [self.pinSwitch setOn:NO animated:YES];
    }
}

- (void)savePin:(NSString *)pinNumber
{
    if([_userDefaults valueForKey:@"PIN_NUMBER"]){
        self.enter4digitLabel.textColor = [UIColor ctlGreen];
        self.enter4digitLabel.text = NSLocalizedString(@"PIN_HAS_BEEN_RESET", nil);
    }else{
        self.enter4digitLabel.textColor = [UIColor ctlGreen];
        self.enter4digitLabel.text = NSLocalizedString(@"PIN_IS_NOW_SET", nil);
    }
    
    [_userDefaults setValue:pinNumber forKey:@"PIN_NUMBER"];
    [_userDefaults synchronize];
    
    self.navigationItem.rightBarButtonItem.style = UIBarButtonItemStylePlain;
    [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(dismiss:) userInfo:nil repeats:NO];
}

- (void)dismiss:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
