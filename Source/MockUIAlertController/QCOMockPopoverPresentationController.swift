//
//  QCOMockPopoverPresentationController.swift
//  MockUIAlertController
//
//  Created by Bernd Rabe on 15.04.17.
//  Copyright © 2017 Jon Reid. All rights reserved.
//

import UIKit

/// UIPopoverPresentationController replacement
public class QCOMockPopoverPresentationController: NSObject {
    weak open var delegate: UIPopoverPresentationControllerDelegate?
    
    
    open var permittedArrowDirections: UIPopoverArrowDirection = .unknown
    
    
    open var sourceView: UIView?
    
    open var sourceRect: CGRect = .zero
    
    
    // By default, a popover is not allowed to overlap its source view rect.
    // When this is set to YES, popovers with more content than available space are allowed to overlap the source view rect in order to accommodate the content.
    open var canOverlapSourceViewRect: Bool = false
    
    
    open var barButtonItem: UIBarButtonItem?
    
    
    // Returns the direction the arrow is pointing on a presented popover. Before presentation, this returns UIPopoverArrowDirectionUnknown.
    open var arrowDirection: UIPopoverArrowDirection = .unknown
    
    
    // By default, a popover disallows interaction with any view outside of the popover while the popover is presented.
    // This property allows the specification of an array of UIView instances which the user is allowed to interact with
    // while the popover is up.
    open var passthroughViews: [UIView]?
    
    
    // Set popover background color. Set to nil to use default background color. Default is nil.
    @NSCopying open var backgroundColor: UIColor?
    
    
    // Clients may wish to change the available area for popover display. The default implementation of this method always
    // returns insets which define 10 points from the edges of the display, and presentation of popovers always accounts
    // for the status bar. The rectangle being inset is always expressed in terms of the current device orientation; (0, 0)
    // is always in the upper-left of the device. This may require insets to change on device rotation.
    open var popoverLayoutMargins: UIEdgeInsets = .zero
    
    
    // Clients may customize the popover background chrome by providing a class which subclasses `UIPopoverBackgroundView`
    // and which implements the required instance and class methods on that class.
    open var popoverBackgroundViewClass: UIPopoverBackgroundViewMethods.Type?
}
