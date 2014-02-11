//
//  UNViewController.m
//  Uncover
//
//  Created by Arnaud Leene on 10/02/14.
//  Copyright (c) 2014 Hovering Above. All rights reserved.
//

#import "UNViewController.h"
//  Import the definitions corresponding to the uncover view notification
#import "UNUncoverViewNotification.h"

#define CONTAINER_SEGUE @"Embed Segue"

@interface UNViewController ()
/////////// S T A R T   A D D ///////////

//  this is the view that can be scrolled upon demand
//  !!!!!!!! DO NOT FORGET to link it to your scrollview in the storyboard !!!!!!!!
@property (strong, nonatomic) IBOutlet UIScrollView *UNscrollView;
//  The desired scroll position (UNScrollPositionNone, UNScrollPositionTop, UNScrollPositionMiddle, UNScrollPositionBottom)
//  default is UNScrollPositionBottom
//  this is passed on by the sender of the notification UN_UNCOVER_VIEW_NOTIFICATION
@property (nonatomic, assign) UNScrollPosition UNscrollPosition;
//  the field that must be uncovered if needed
//  this is passed on by the sender of the notification UN_UNCOVER_VIEW_NOTIFICATION
@property (nonatomic, strong) UIView *UNviewToUncover;
//  state of the keyboard
@property (nonatomic) BOOL UNkeyboardIsOnScreen;
//  height of the keyboard in the current orientation
@property (nonatomic) int keyboardHeight;
/////////// E N D   A D D ///////////

@end

@implementation UNViewController
/////////// S T A R T   A D D ///////////
#pragma mark UNUncoverViewNotification methods

//  The method UNresetPropertiesForUncoverViewNotification resets all properties related to UNUncoverViewNotification
- (void)UNresetPropertiesForUncoverViewNotification
{
    //  reset the view to uncover
    self.UNviewToUncover = nil;
    //  reset the scroll position to the default
    self.UNscrollPosition = UNScrollPositionBottom;
    //  reset the keyboard height
    self.keyboardHeight = 0;
}

//  The method UNaddCoordinatesOfView: traverses the view hierarchy recursively until the scrollview of the UNviewToUncover has been found
//  The coordinates of the UNviewToUncover relative to the UNviewToUncover coordinate system are calculated
- (CGPoint)UNaddCoordinatesOfView:(UIView *)view
{
    //  start with the origin of the passed view
    CGPoint point = CGPointMake(view.frame.origin.x, view.frame.origin.y);
    //  did we NOT arrrive at the scrollView of this viewController?
    if (![view isEqual:self.UNscrollView]) {
        //  find the coordinates of the superview of the passed view recursively
        CGPoint addToPoint = [self UNaddCoordinatesOfView:view.superview];
        //  add the superview coordinates to the current point
        point = CGPointMake(point.x + addToPoint.x, point.y + addToPoint.y);
        return point;
    }
    else
        return point;
}

//  set the view that must be uncovered
- (void)UNsetViewThatMustBeUncovered:(NSNotification*)aNotification
{
    //  get the userInfo dictionary that encodes
    //  the view that might be uncovered
    //  and the desired scrool position of that view's owner
    NSDictionary* info = [aNotification userInfo];
    //  get the view that might be covered by the keyboard from the notification info
    self.UNviewToUncover = [info objectForKey:UN_VIEW_TO_UNCOVER];
    //  get the desired scroll position from the notification info
    self.UNscrollPosition = [[info objectForKey:UN_SCROLL_POSITION] integerValue];
    //  is the keyboard already on screen?
    if (self.UNkeyboardIsOnScreen)
        // shift scrollview for newly selected field
        [self UNshiftScrollView];
    //  if not, wait for the keyboard notification
    //  no action needs to be taken yet
}

//  determine the coordinated that needs to be uncovered
- (CGPoint)UNfindObscuredPoint
{
    CGPoint UNpointToUncover = CGPointZero;
    
    //  has a scroll position been defined
    if (self.UNscrollView) {
        // do we have a view to uncover?
        if (self.UNviewToUncover != nil) {
            //  define the point that must be uncovered
            if (self.UNscrollPosition == UNScrollPositionTop)
                //  The top point of the view must be at the top of the scrollview
                UNpointToUncover = CGPointMake(self.UNviewToUncover.frame.origin.x, self.UNviewToUncover.frame.origin.y);
            else if (self.UNscrollPosition == UNScrollPositionMiddle)
                UNpointToUncover = CGPointMake(self.UNviewToUncover.frame.origin.x, self.UNviewToUncover.frame.origin.y + self.UNviewToUncover.frame.size.height/2);

            else if (self.UNscrollPosition == UNScrollPositionBottom)
                //  The bottom point of the view must be at the bottom of the visible scroll view, above the keyboard
                //  This takes into account the current scroll position, which prevents to much scrolling
                UNpointToUncover = CGPointMake(self.UNviewToUncover.frame.origin.x, self.UNviewToUncover.frame.origin.y + self.UNviewToUncover.frame.size.height - self.UNscrollView.contentOffset.y);
            
            //  determine the hierarchy offset between the view to uncover and the UNscrollview
            CGPoint hierachyOffset = [self UNaddCoordinatesOfView:self.UNviewToUncover.superview];
            //  the position the textfield in the scrollview coordinate system
            UNpointToUncover = CGPointMake(UNpointToUncover.x + hierachyOffset.x,
                                           UNpointToUncover.y + hierachyOffset.y);
            
        }
        else {
            //  no view to be uncovered was passed in the notification info
            //  not sure if this could happen
            NSLog(@"UNUncoverViewNotification: no view to uncover available");
        }
    }
    else {
        //  no scrollview has been defined.
        //  check if the properties related to UNUncoverViewNotification are added to this viewController
        //  check if the scrollView has been linked up to the scrollView in the Storyboard
        NSLog(@"UNUncoverViewNotification: no scrollview has been defined");
    }
    return UNpointToUncover;
}

- (void)UNshiftScrollView
{
    //  this is the position of the obscured point, when the scrollview has yet not scrolled
    CGPoint UNpointToUncover = [self UNfindObscuredPoint];
    //  The verticalScrollOffset determines how much the scrollView should be scrolled
    //  It is initialised with the coordinate of the view that must be uncovered
    CGPoint verticalScrollOffset = UNpointToUncover;
    if (UN_DEBUG) NSLog(@"Vertical scroll offset required by obscured point %f", verticalScrollOffset.y);
    
    //  do we need to scroll at all? (is this check usefull?)
    if (verticalScrollOffset.y != 0.0) {
        if (UN_DEBUG) NSLog(@"Scrolling required");
        //  define the rectangle that the keyboard obscures
        //  in the coordinates of the superview of the scrollview
        CGRect obscuringRect = CGRectMake(0, self.UNscrollView.frame.size.height + self.UNscrollView.frame.origin.y - self.keyboardHeight, self.UNscrollView.frame.size.width, self.keyboardHeight);
        if (UN_DEBUG) NSLog(@"Keyboard obscured %f to %f", self.UNscrollView.frame.size.height + self.UNscrollView.frame.origin.y - self.keyboardHeight, self.UNscrollView.frame.size.height + self.UNscrollView.frame.origin.y);

        //  it should be corrected by the current scrollposition
        UNpointToUncover.y += self.UNscrollView.contentOffset.y;
        if (UN_DEBUG) NSLog(@"Point to uncover %f", UNpointToUncover.y);

        if (UN_DEBUG) NSLog(@"Current scroll offset %f", self.UNscrollView.contentOffset.y);
        if (UN_DEBUG) NSLog(@"Scroll offset corrected for current scroll position %f", verticalScrollOffset.y);
        if (UN_DEBUG) NSLog(@"Keyboard height %d", self.keyboardHeight);
        if (UN_DEBUG) NSLog(@"Scrollview origin %f", self.UNscrollView.frame.origin.y);
        if (UN_DEBUG) NSLog(@"Scrollview height %f", self.UNscrollView.frame.size.height);

        //  check if the point is covered by the keyboard
        if (CGRectContainsPoint(obscuringRect, UNpointToUncover) ) {
            if (UN_DEBUG) NSLog(@"Point is covered by the Keyboard");

            //  should we scroll to the top?  (note we will only scroll vertically)
            if (self.UNscrollPosition == UNScrollPositionTop)
                //  correct for the scrolling margin
                verticalScrollOffset = CGPointMake(0.0, verticalScrollOffset.y - UN_SCROLLING_MARGIN);
            //  should we scroll to the middle? (note we will only scroll vertically)
            else if (self.UNscrollPosition == UNScrollPositionMiddle)
                //  scroll only half of the distance between the top of the scrollview and the viewToUncover
                verticalScrollOffset = CGPointMake(0.0, verticalScrollOffset.y / 2);
            //  should we scroll to the bottom? (note we will only scroll vertically)
            else if (self.UNscrollPosition == UNScrollPositionBottom)
                //  determine the point just above the keyboard
                verticalScrollOffset = CGPointMake(0.0, self.keyboardHeight - self.UNscrollView.frame.size.height - self.UNscrollView.frame.origin.y + verticalScrollOffset.y + UN_SCROLLING_MARGIN + self.UNscrollView.contentOffset.y);
            
            if (UN_DEBUG) NSLog(@"Final vertical scroll offset %f", verticalScrollOffset.y);
            
            if (UN_DEBUG) NSLog(@"SCROLLING");
            //  make the point hidden by the keyboard visible
            [self.UNscrollView setContentOffset:verticalScrollOffset animated:YES];
        }
        else
            if (UN_DEBUG) NSLog(@"Point is NOT covered by the Keyboard");

    }
    else
        if (UN_DEBUG) NSLog(@"NO scrolling required");

}
- (void)UNkeyboardWasShown:(NSNotification*)aNotification
{
    self.UNkeyboardIsOnScreen = YES;
    //  get the information about the keyboard size
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    //  and adjust to the interface orientation
    if ([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationLandscapeLeft ||
        [UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationLandscapeRight )
        self.keyboardHeight = kbSize.width;
    else
        self.keyboardHeight = kbSize.height;
    
    //  Shift obscured view if any
    [self UNshiftScrollView];
}

- (void)UNkeyboardWillBeHidden:(NSNotification*)aNotification
{
    self.UNkeyboardIsOnScreen = NO;
    //  if a keyboard hides notification is received
    //  the scrollView is reset so that the origin (0,0) will be visible again
    [self.UNscrollView setContentOffset:CGPointZero animated:YES];
    // reset all properties related to the keyboard notification handling
    [self UNresetPropertiesForUncoverViewNotification];
}

- (void)UNsetupReceptionOfUncoverViewNotification
{
    //  Listen to keyboard shown notification
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(UNkeyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    //  Listen to keyboard hides notification
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(UNkeyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
    //  Listen to view that needs to be uncovered notification
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(UNsetViewThatMustBeUncovered:)
                                                 name:UN_UNCOVER_VIEW_NOTIFICATION object:nil];
    //  Initialise the fields used in these notification
    [self UNresetPropertiesForUncoverViewNotification];
}
/////////// E N D   A D D ///////////

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    /////////// S T A R T   A D D ///////
    //  Initialise for the UNUncoverViewNotification
    [self UNsetupReceptionOfUncoverViewNotification];
    /////////// E N D   A D D ///////////
}

@end
