//
//  QCOExtensions.swift
//  MockUIAlertController
//
//  Created by Bernd Rabe on 15.04.17.
//  Copyright © 2017 Jon Reid. All rights reserved.
//

import UIKit

// MARK: - Swizzle

extension NSObject {
    static func replace(classMethodWithSelector orgSelector: Selector, withSelector swizzledSelector: Selector) {
        let orgMethod = class_getClassMethod(self, orgSelector)
        let swizzledMethod = class_getClassMethod(self, swizzledSelector)
        method_exchangeImplementations(orgMethod!, swizzledMethod!)
    }

    static func replace(instanceMethodWithSelector orgSelector: Selector, withSelector swizzledSelector: Selector) {
        let orgMethod = class_getInstanceMethod(self, orgSelector)
        let swizzledMethod = class_getInstanceMethod(self, swizzledSelector)
        method_exchangeImplementations(orgMethod!, swizzledMethod!)
    }
}

// MARK: - UIViewController

extension NSNotification.Name {
    static let QCOMockAlertControllerPresented = Notification.Name("QCOMockAlertControllerPresented")
}

extension UIViewController {
    struct Constants {
        static let qcoViewControllerAnimatedKey = "QCOViewControllerAnimatedKey"
    }
    
    static func qcoVCSwizzle () {
        let orgSel = #selector(present(_:animated:completion:))
        let swizzleSel = #selector(qcoPresent(_:animated:completion:))
        replace(instanceMethodWithSelector: orgSel, withSelector: swizzleSel)
    }
    
    @objc dynamic func qcoPresent(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)? = nil) {
        guard  let ctrl = viewControllerToPresent as? UIAlertController else {
            return
        }
        NotificationCenter.default.post(name: .QCOMockAlertControllerPresented,
                                        object: ctrl,
                                        userInfo: [Constants.qcoViewControllerAnimatedKey: flag])
        
        if let completion = completion {
            completion()
        }
    }
}

// MARK: - UIAlertController

extension UIAlertController {
    struct QCOAssociatedObj {
        static var preferredAlertControllerStyle: Int = 0
        static var popoverPresentationController: Int = 0
    }
    
    static func qcoSwizzle () {
        var orgSel = #selector(getter: popoverPresentationController)
        var swizzleSel = #selector(getter: qcoPopover)
        replace(instanceMethodWithSelector: orgSel, withSelector: swizzleSel)
        
        orgSel = #selector(getter: preferredStyle)
        swizzleSel = #selector(getter: qcoStyle)
        replace(instanceMethodWithSelector: orgSel, withSelector: swizzleSel)

        orgSel = #selector(UIAlertController.init(title:message:preferredStyle:))
        swizzleSel = #selector(UIAlertController.initWith(title:message:preferredStyle:))
        replace(classMethodWithSelector: orgSel, withSelector: swizzleSel)
    }

    @objc var qcoStyle: UIAlertControllerStyle {
        get {
            return objc_getAssociatedObject(self, &QCOAssociatedObj.preferredAlertControllerStyle) as! UIAlertControllerStyle
        }
        set {
            objc_setAssociatedObject(self, &QCOAssociatedObj.preferredAlertControllerStyle, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    @objc var qcoPopover: QCOMockPopoverPresentationController {
        get {
            return objc_getAssociatedObject(self, &QCOAssociatedObj.popoverPresentationController) as! QCOMockPopoverPresentationController
        }
        set {
            objc_setAssociatedObject(self, &QCOAssociatedObj.popoverPresentationController, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    @objc dynamic static func initWith(title: String?, message: String?, preferredStyle: UIAlertControllerStyle) -> UIAlertController {
        let ctrl = self.init()
        ctrl.title = title
        ctrl.message = message
        ctrl.qcoPopover = QCOMockPopoverPresentationController()
        ctrl.qcoStyle = preferredStyle
        
        return ctrl
    }
}

// MARK: - UIAlertAction

public typealias QCOAlertActionHandler = ((UIAlertAction) -> Void)

extension UIAlertAction {
    struct QCOAssociatedObj {
        static var handler: Int = 0
        static var title: Int = 0
        static var style: Int = 0
    }
    
    static func qcoSwizzle () {
        var orgSel = #selector(getter: title)
        var swizzleSel = #selector(getter: qcoTitle)
        replace(instanceMethodWithSelector: orgSel, withSelector: swizzleSel)
        
        orgSel = #selector(getter: style)
        swizzleSel = #selector(getter: qcoStyle)
        replace(instanceMethodWithSelector: orgSel, withSelector: swizzleSel)
        
        orgSel = #selector(UIAlertAction.init(title:style:handler:))
        swizzleSel = #selector(UIAlertAction.initWith(title:style:handler:))
        replace(classMethodWithSelector: orgSel, withSelector: swizzleSel)
    }
    
    var qcoHandler: QCOAlertActionHandler? {
        get {
            return objc_getAssociatedObject(self, &QCOAssociatedObj.handler) as? QCOAlertActionHandler
        }
        set {
            objc_setAssociatedObject(self, &QCOAssociatedObj.handler, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
    }
    
    @objc var qcoTitle: String? {
        get {
            return objc_getAssociatedObject(self, &QCOAssociatedObj.title) as? String
        }
        set {
            objc_setAssociatedObject(self, &QCOAssociatedObj.title, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
    }
    
    @objc var qcoStyle: UIAlertActionStyle {
        get {
            return objc_getAssociatedObject(self, &QCOAssociatedObj.style) as! UIAlertActionStyle
        }
        set {
            objc_setAssociatedObject(self, &QCOAssociatedObj.style, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
    }
    
    @objc dynamic static func initWith(title: String?, style: UIAlertActionStyle, handler: QCOAlertActionHandler? = nil) -> UIAlertAction {
        let action = self.init()
        action.qcoTitle = title
        action.qcoStyle = style
        action.qcoHandler = handler
        
        return action
    }
}

