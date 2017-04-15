//
//  QCOMockAlertVerifier.swift
//  MockUIAlertController
//
//  Created by Bernd Rabe on 15.04.17.
//  Copyright © 2017 Jon Reid. All rights reserved.
//

import UIKit

public class QCOMockAlertVerifier: NSObject {
    private(set) var actions = [UIAlertAction]()
    private var _popover: AnyObject?
    
    public private(set) var presentedCount = 0
    public private(set) var title: String?
    public private(set) var message: String?
    public private(set) var animated: Bool = false
    public private(set) var preferredStyle: UIAlertControllerStyle = .alert

    public var actionTitles: [String] {
        return actions.flatMap({ $0.title })
    }
    
    public var popover: QCOMockPopoverPresentationController? {
        return _popover as? QCOMockPopoverPresentationController
    }
    
    public func executeActionForButton(withTitle title: String) {
        if let action = action(withTitle: title), let handler = action.qcoHandler {
            handler(action)
        }
    }

    public func styleForButton(withTitle title: String) -> UIAlertActionStyle? {
        return action(withTitle: title)?.style
    }
    
    override public init() {
        super.init()
        swizzle()
        let sel = #selector(alertControllerWasPresented(_:))
        NotificationCenter.default.addObserver(self, selector: sel, name: .QCOMockAlertControllerPresented, object: nil)
    }
    
    deinit {
        swizzle()
        NotificationCenter.default.removeObserver(self)
    }
    
    func alertControllerWasPresented(_ notification: Notification) {
        guard let alertController = notification.object as? UIAlertController else {
            return
        }
        
        animated = (notification.userInfo?[UIViewController.Constants.qcoViewControllerAnimatedKey] as? Bool) ?? false
        presentedCount += 1
        title = alertController.title
        message = alertController.message
        preferredStyle = alertController.preferredStyle
        actions = alertController.actions
        _popover = alertController.popoverPresentationController
    }
}

private extension QCOMockAlertVerifier {
    func swizzle() {
        UIAlertController.qcoSwizzle()
        UIViewController.qcoVCSwizzle()
        UIAlertAction.qcoSwizzle()
    }
    
    func action(withTitle title: String) -> UIAlertAction? {
        if let index = actions.index(where: { $0.title == title }) {
            return actions[index]
        } else {
            return nil
        }
    }
}
