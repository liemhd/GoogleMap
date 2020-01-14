//
//  Extension + UIView.swift
//  GoogleMap
//
//  Created by Duy Liêm on 10/18/19.
//  Copyright © 2019 DuyLiem. All rights reserved.
//

import Foundation
import UIKit

extension NSObject {
    
    class var name: String {
        return String(describing: self)
    }
    
    var name: String {
        return String(describing:self)
    }
}

extension UIView {
    
    class func fromNib<T: UIView>() -> T {
        guard let view = Bundle.main.loadNibNamed(String(describing: T.self), owner: nil, options: nil)?.first as? T else {
            return T()
        }
        return view
    }
    
    func getParentViewController(_ current: UIView) -> UIViewController? {
        var parentController: UIViewController?
        var responder: UIResponder? = current
        while true {
            responder = responder?.next
            if responder == nil {
                break
            }
            parentController = responder as? UIViewController
            if parentController != nil {
                break
            }
        }
        return parentController
    }
    
    func screenshot() -> UIImage? {
        let croppingRect = self.bounds
        UIGraphicsBeginImageContextWithOptions(croppingRect.size, false, UIScreen.main.scale)
        // Create a graphics context and translate it the view we want to crop so that even in grabbing (0,0), that origin point now represents the actual cropping origin desired:
        guard let context = UIGraphicsGetCurrentContext() else {
            return nil
        }
        context.translateBy(x: -croppingRect.origin.x, y: -croppingRect.origin.y)
        layoutIfNeeded()
        layer.render(in: context)
        let screenshotImage: UIImage? = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return screenshotImage ?? UIImage()
    }
    
    @IBInspectable
    var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        
        set {
            layer.cornerRadius = newValue
        }
    }
    
    @IBInspectable
    var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        
        set {
            layer.borderWidth = newValue
        }
    }
    
    @IBInspectable
    var borderColor: UIColor? {
        get {
            if let color = layer.borderColor {
                return UIColor(cgColor: color)
            }
            return nil
        }
        
        set {
            if let color = newValue {
                layer.borderColor = color.cgColor
            } else {
                layer.borderColor = nil
            }
        }
    }
    
    @IBInspectable
    var shadowRadius: CGFloat {
        get {
            return layer.shadowRadius
        }
        
        set {
            layer.shadowRadius = newValue
        }
    }
    
    @IBInspectable
    var shadowOpacity: Float {
        get {
            return layer.shadowOpacity
        }
        
        set {
            layer.shadowOpacity = newValue
        }
    }
    
    @IBInspectable
    var shadowOffset: CGSize {
        get {
            return layer.shadowOffset
        }
        
        set {
            layer.shadowOffset = newValue
        }
    }
    
    @IBInspectable
    var shadowColor: UIColor? {
        get {
            if let color = layer.shadowColor {
                return UIColor(cgColor: color)
            }
            return nil
        }
        
        set {
            if let color = newValue {
                layer.shadowColor = color.cgColor
            } else {
                layer.shadowColor = nil
            }
        }
    }
}

