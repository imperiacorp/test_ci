//
//  UIAlertController+App.swift
//  CodingTask
//
//  Created by Dmitriy Gonchar on 6/27/18.
//  Copyright © 2018 Dmitriy Gonchar. All rights reserved.
//

import UIKit

extension UIAlertController {

    static func app_withCancelAction(title: String? = nil,
                                     message: String? = nil,
                                     style: UIAlertControllerStyle = .alert,
                                     cancelTitle: String = "Ok",
                                     cancelStyle: UIAlertActionStyle = .cancel,
                                     cancelAction: ((UIAlertAction) -> Void)? = nil) -> UIAlertController {
        let cancelAction = UIAlertAction(title: cancelTitle, style: cancelStyle, handler: cancelAction)
        let alertController = UIAlertController(title: title, message: message, preferredStyle: style)
        alertController.addAction(cancelAction)

        return alertController
    }

    static func app_alert(forError error: Error,
                          cancelAction: ((UIAlertAction) -> Void)? = nil) -> UIAlertController {
        let message = error.localizedDescription
        let title = NSLocalizedString("Error", comment: "Error")
        let alertController = UIAlertController.app_withCancelAction(title: title,
                                                                     message: message)
        return alertController
    }
}
