//
//  UIViewControllerEx.swift
//  QuickWeather
//
//  Created by Michał Gruszkiewicz on 06/01/2023.
//

import UIKit

// MARK: Instantiate
public extension UIViewController {
    static func instantiate(identifier: String, fromStoryboardNamed storyboardName: String) -> UIViewController {
        let storyboard = UIStoryboard(name: storyboardName, bundle: nil)
        return storyboard.instantiateViewController(withIdentifier: identifier)
    }

    static func instantiate(navigationIdentifier: String, fromStoryboardNamed storyboardName: String) -> (UINavigationController, UIViewController) {
        let nc = instantiate(identifier: navigationIdentifier, fromStoryboardNamed: storyboardName) as! UINavigationController
        guard nc.viewControllers.count > 0 else {
            fatalError("Navigation controller \(nc) has no root view controller")
        }
        
        return (nc, nc.viewControllers[0])
    }
}

// MARK: Keyboard dismiss
extension UIViewController {
    // Call when textfields in view and keyboard needs to be dismissed
    public func setupKeyboardDismiss() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

// MARK: Show system alert
extension UIViewController {
    func showSimpleAlert(title: String?, description: String?) {
        let alert = UIAlertController(title: title ?? "", message: description ?? "", preferredStyle: UIAlertController.Style.alert)
        
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: { _ in }))
        self.present(alert, animated: true, completion: nil)
    }
}
