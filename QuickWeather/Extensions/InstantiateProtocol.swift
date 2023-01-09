//
//  InstantiateProtocol.swift
//  QuickWeather
//
//  Created by Michał Gruszkiewicz on 06/01/2023.
//

import UIKit

protocol IInstantiate {
    static var storyboardName: String { get }
    static var viewControllerIdentifier: String { get }
    
    static func instantiate() -> Self
}

protocol INavigatedInstantiate: IInstantiate {
    static var navigationControllerIdentifier: String { get }
    
    static func instantiateInNavigationController() -> (UINavigationController, Self)
}

extension IInstantiate where Self: UIViewController {
    static func instantiate() -> Self {
        guard let vc = instantiate(identifier: viewControllerIdentifier, fromStoryboardNamed: storyboardName) as? Self else {
            fatalError("Couldn't instantiate controller with identifier '\(self.viewControllerIdentifier)' from storyboard '\(self.storyboardName)'")
        }
        
        return vc
    }
}

extension INavigatedInstantiate where Self: UIViewController {
    static func instantiateInNavigationController() -> (UINavigationController, Self) {
        guard let nc = instantiate(identifier: navigationControllerIdentifier, fromStoryboardNamed: storyboardName) as? UINavigationController else {
            fatalError("Couldn't instantiate controller with identifier '\(navigationControllerIdentifier)' from storyboard '\(storyboardName)'")
        }
        
        guard nc.viewControllers.count > 0 else {
            fatalError("Navigation controller \(nc) has no root view controller")
        }
        
        guard let vc = nc.viewControllers[0] as? Self else {
            fatalError("Navigation controller \(nc)'s initial view controller is not of type \(type(of: self))")
        }
        
        return (nc, vc)
    }
}
