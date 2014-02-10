//
//  UNCoveredFieldsViewController.m
//  Uncover
//
//  Created by Arnaud Leene on 10/02/14.
//  Copyright (c) 2014 Hovering Above. All rights reserved.
//

#import "UNCoveredFieldsViewController.h"
//  Import the definitions for uncovering
#import "UNUncoverViewNotification.h"


@interface UNCoveredFieldsViewController () <UITextFieldDelegate, UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UITextField *firstTextField;
@property (weak, nonatomic) IBOutlet UITextField *secondTextField;
@property (weak, nonatomic) IBOutlet UITextField *thirdTextField;
@property (weak, nonatomic) IBOutlet UITextField *fourthTextField;
@property (weak, nonatomic) IBOutlet UITextView *aTextView;

@end

@implementation UNCoveredFieldsViewController

//  this method must be implemented to have the uncovering working.
//  This method must be called for each view that might be covered by an appearing keyboard
//  These calls are made in the textField delegate method textFieldDidBeginEditing: and
//  in the textView delegate method textViewDidBeginEditing:
//
- (void)sendUncoverNotificationForView:(UIView *)view
{
    //  set the desired scroll position
    NSNumber *UNScrollPositionAsNumber = [NSNumber numberWithInt:UNScrollPositionBottom];
    //  setup the notification info
    NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:view, UN_VIEW_TO_UNCOVER,
                              UNScrollPositionAsNumber, UN_SCROLL_POSITION, nil];
    //  send the notification with the userInfo
    [[NSNotificationCenter defaultCenter] postNotificationName:UN_UNCOVER_VIEW_NOTIFICATION object:self userInfo:userInfo];
}

#pragma mark - TextView delegate methods

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    //  have a notication send for a textView, which might be uncovered
    [self sendUncoverNotificationForView:(UIView *)textView];
}

#pragma mark - TextField delegate methods

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    //  have a notication send for a textField, which might be uncovered
    [self sendUncoverNotificationForView:(UIView *)textField];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    
    // If I am ready prepare the output
    if ([textField.text length]) {
        //
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if ([textField.text length]) {
        [textField resignFirstResponder];
        {
            return YES;
        }
    } else
        return NO;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    //  set the delegates for the contained textfields
    self.firstTextField.delegate = self;
    self.secondTextField.delegate = self;
    self.thirdTextField.delegate = self;
    self.fourthTextField.delegate = self;
    self.aTextView.delegate = self;
}

@end
