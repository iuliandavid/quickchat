//
//  UIImage+extensions.swift
//  QuickChat
//
//  Created by iulian david on 11/30/18.
//  Copyright © 2018 iulian david. All rights reserved.
//

import UIKit

//swiftlint:disable trailing_whitespace
extension UIImage {
    
    /// A helper function to create images with text being used as the
    /// image content.
    /// - returns: an image containing a representation of the text
    /// - parameter text: the string you want rendered into the image
    static func createImage(text: String) -> UIImage {
        // Start a drawing canvas
        UIGraphicsBeginImageContext(CGSize(width: 400, height: 400))
        
        // Close the canvas after we return from this function
        defer {
            UIGraphicsEndImageContext()
        }
        
        // Create a label
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 400, height: 400))
        
        var myMutableString = NSMutableAttributedString()
        let fontSize  = CGFloat(200/text.count*4)
        myMutableString = NSMutableAttributedString(string: text, attributes: [
            NSAttributedString.Key.font: UIFont(name: "Helvetica Neue", size: fontSize)
                ?? UIFont.systemFont(ofSize: fontSize)
            ])
        let noOfChars = text.count
        for loc in 0...noOfChars-1 {
            myMutableString.addAttribute(
                NSAttributedString.Key.foregroundColor,
                value: randomColor(),
                range: NSRange(location: loc, length: 1))
        }
        
        label.attributedText = myMutableString
        
        // Draw the label in the current drawing context
        label.drawHierarchy(in: label.frame, afterScreenUpdates: true)
        
        // Return the image
        // (the ! means we either successfully get an image, or we crash)
        return UIGraphicsGetImageFromCurrentImageContext()!
    }
    
    private static func randomColor() -> UIColor {
        let red = CGFloat(arc4random()) / CGFloat(UInt32.max)
        let green = CGFloat(arc4random()) / CGFloat(UInt32.max)
        let blue = CGFloat(arc4random()) / CGFloat(UInt32.max)
        return UIColor(red: red, green: green, blue: blue, alpha: 1.0)
    }
    
    func resizedImage(width: CGFloat, height: CGFloat, scale: CGFloat) -> UIImage {
        let bounds = CGSize(width: width, height: height)
        
        let horizontalRatio = bounds.width / size.width
        let verticalRatio = bounds.height / size.height
        let ratio = min(horizontalRatio, verticalRatio)
        let newSize = CGSize(width: size.width * ratio,
                             height: size.height * ratio)
        
        UIGraphicsBeginImageContextWithOptions(newSize, true, 0)
        draw(in: CGRect(origin: CGPoint.zero, size: newSize))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
    func resizedImageTut(width: CGFloat, height: CGFloat, scale: CGFloat) -> UIImage {
        let bounds = CGSize(width: width, height: height)
        let rect = CGRect(x: 0, y: 0, width: bounds.width, height: bounds.height)
        
        UIGraphicsBeginImageContextWithOptions(bounds, false, scale)
        draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
    //swiftlint:disable identifier_name
    func cropImage(x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat) -> UIImage {
        let rect = CGRect(x: x, y: y, width: width, height: height)
        
        guard let imageRef = self.cgImage?.cropping(to: rect) else {
            fatalError("Cannot crop image")
        }
        
        return UIImage(cgImage: imageRef)
    }
    
    func squareImage(side: CFloat) -> UIImage {
        
        var cropped: UIImage!
        if self.size.height > self.size.width {
            let ypos = (self.size.height - self.size.width) / 2
            cropped = cropImage(x: 0, y: ypos, width: self.size.width, height: self.size.height)
        } else {
            let xpos = (self.size.width - self.size.height) / 2
            cropped = cropImage(x: xpos, y: 0, width: self.size.width, height: self.size.height)
        }
        let resize = cropped.resizedImage(width: CGFloat(side), height: CGFloat(side), scale: 1)
        return resize
    }
}
