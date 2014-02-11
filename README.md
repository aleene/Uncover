Uncover
=======

H1 Abstract
IOS solution to make fields scroll in response to an appearing keyboard.

H Problem
If the keyboard appears due to the selection of a textfield or textview, these fields might stay under the keyboard and can no longer be seen. Editing these fields is thus very difficult. The fields need to move up, above the keyboard, so that they are visible again.

H1 Solution
The solution has been gobbled together from ideas found on the Internet. I am not the only one that needs a solution. This solution is based on the followig ideas:

the scrolling is done by a scrollView with the method setContentOffset:.
the scrollView can be in another viewController than the UITextfield or UITextView fields.
the communication between the scrollView viewController and the textfields viewController is done by NSNotifications.
the user can set the scrollposition (none, top, middle or bottom).
half hidden textfields will be scrolled correctly.
the user can specify how far the fields should stay from the top or bottom.
the scrollView can have any height.
an app can have multiple scrollviews, which act upon their child textfields.
# How to implement
Essentially this solution can be used by copying the relevant code into your own code. This concerns three files:

## UNUncoverViewNotification.h file
copy this file into your project
## SecondViewController.m
parts of this file should be added to the viewController that contains the textfields and/or textviews
add #import "UNUncoverViewNotification.h"
copy the sendUncoverNotificationForView: method into your viewController
add [self sendUncoverNotificationForView:(UIView *)textView]; to your textViewDidBeginEditing: delegate method.
add [self sendUncoverNotificationForView:(UIView *)textField]; to your textFieldDidBeginEditing: delegate method.
do not forget to set the textfield and textview delegates to self in your viewDidLoad method.
## UNViewController.m
parts of this file should be added to the ViewController that contains the scrollView.
add the line #import "UNUncoverViewNotification.h"
add all the properties between START ADD and END ADD.
add all the methods between START ADD and END ADD.
add the line [self UNsetupReceptionOfUncoverViewNotification]; to your viewDidLoad method.
## How to use
do not forget to link the scrollview with the UNscrollView property in the scrollView viewController that must be scrolled.
adjust the UN_SCROLLING_MARGIN to fit your needs in the UNUncoverViewNotification.h file
set the desired scrolling position in the sendUncoverNotificationForView: method. Options are: KAScrollPositionNone, UNScrollPositionTop, UNScrollPositionMiddle and UNScrollPositionBottom.
if you need multiple scrollers, then you could duplicate (and rename) UNUncoverViewNotification.h. Change the imports. I did not try this yet, so this is just theory.
## Limitations
This solution works only if the viewControllers are in the same hierarchy, i.e. the ScrolViewViewController is a (grand-...)parent of the textFieldsViewController.
the scrollView and the textFields are in the same hierarchy, i.e. the scrollView is a (grand-...)parent view of the textFields.
When the keyboard appears the top part of the scrollview should still be visible.
## To be done
No issues known at the moment.
I wonder though if there is a better solution with subclasses.
