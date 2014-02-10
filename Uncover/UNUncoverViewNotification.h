//
//  UNUncoverViewNotification.h
//  KeyboardAware
//
//  Created by Arnaud Leene on 08/02/14.
//  Copyright (c) 2014 Hovering Above. All rights reserved.
//

#ifndef KeyboardAware_UNUncoverViewNotification_h
#define KeyboardAware_UNUncoverViewNotification_h

//  The scroll positions where the field can be scrolled to
typedef enum {
    UNScrollPositionNone,   // no scrolling (default)
    UNScrollPositionTop,    // view top will be but at the top
    UNScrollPositionMiddle, // view top will be put in the middle between the top of the scroll view and the top of the scrolled view
    UNScrollPositionBottom  // view bottom will be put above the top keyboard
} UNScrollPosition;

//  The name of the notification
#define UN_UNCOVER_VIEW_NOTIFICATION @"UN Uncover View Set"
//  The key of the desired scroll position of the notification info dictionary
#define UN_SCROLL_POSITION @"UN Scroll Position"
//  The key of the view that needs to be uncovered in the notification info dictionary
#define UN_VIEW_TO_UNCOVER @"UN View To Uncover"
//  The scrolling margin used
//  either the distance between the top of the keyboard and the bottom of the uncovered view (UNScrollPositionBottom)
//  or the the distance between the top of the scrollview ad the top of the uncoverd view (UNScrollPositionTop)
#define UN_SCROLLING_MARGIN 50

#endif
