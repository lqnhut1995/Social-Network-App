//
//  Extension.swift
//  ProjectMTB
//
//  Created by Hell Rocky on 8/24/18.
//  Copyright © 2018 Hell Rocky. All rights reserved.
//

import Foundation
import UIKit
import DKImagePickerController

extension UIColor {
    
    convenience init(hex: String, alpha: CGFloat = 1.0) {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if (cString.hasPrefix("#")) { cString.remove(at: cString.startIndex) }
        
        if ((cString.count) != 6) {
            self.init(hex: "ff0000") // return red color for wrong hex input
            return
        }
        
        var rgbValue: UInt32 = 0
        Scanner(string: cString).scanHexInt32(&rgbValue)
        
        self.init(red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
                  green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
                  blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
                  alpha: alpha)
    }
    
    func toHexString() -> String {
        var r:CGFloat = 0
        var g:CGFloat = 0
        var b:CGFloat = 0
        var a:CGFloat = 0
        
        getRed(&r, green: &g, blue: &b, alpha: &a)
        
        let rgb:Int = (Int)(r*255)<<16 | (Int)(g*255)<<8 | (Int)(b*255)<<0
        
        return String(format:"#%06x", rgb)
    }
    static let mainColor = UIColor(hex: "#27ae60")
}
extension CALayer {
    
    enum ViewSide {
        case Left, Right, Top, Bottom
    }
    
    func addBorder(toSide side: ViewSide, withColor color: CGColor, andThickness thickness: CGFloat) {
        
        let border = CALayer()
        border.backgroundColor = color
        border.name = "customLayer"
        
        switch side {
        case .Left: border.frame = CGRect(x: 0, y: 0, width: thickness, height: self.frame.size.height); break
        case .Right: border.frame = CGRect(x: self.frame.size.width - thickness, y: 0, width: thickness, height: self.frame.size.height); break
        case .Top: border.frame = CGRect(x: 0, y: 0, width: self.frame.size.width, height: thickness); break
        case .Bottom: border.frame = CGRect(x: 0, y: self.frame.size.height - thickness, width:  self.frame.size.width, height: thickness); break
        }
        
        self.addSublayer(border)
        self.masksToBounds = true
    }
    
    func addShadow(color: UIColor, offset: CGSize, opacity: Float, radius: CGFloat){
        self.shadowColor = color.cgColor
        self.shadowOffset = offset
        self.shadowOpacity = opacity
        self.shadowRadius = radius
        self.masksToBounds = false
    }
}

extension String {
    func height(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [.font: font], context: nil)
        
        return ceil(boundingBox.height)
    }
    
    func width(withConstrainedHeight height: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [.font: font], context: nil)
        
        return ceil(boundingBox.width)
    }
}

extension UIImageView{
    var contentClippingRect: CGRect {
        guard let image = image else { return bounds }
        guard contentMode == .scaleAspectFit else { return bounds }
        guard image.size.width > 0 && image.size.height > 0 else { return bounds }
        
        let scale: CGFloat
        if image.size.width > image.size.height {
            scale = bounds.width / image.size.width
        } else {
            scale = bounds.height / image.size.height
        }
        
        let size = CGSize(width: image.size.width * scale, height: image.size.height * scale)
        let x = (bounds.width - size.width) / 2.0
        let y = (bounds.height - size.height) / 2.0
        
        return CGRect(x: x, y: y, width: size.width, height: size.height)
    }

    func imageWithImage(scaledToSize newSize:CGSize){
        
        UIGraphicsBeginImageContext( newSize )
        self.image?.draw(in: CGRect(x: self.frame.origin.x,y: self.frame.origin.y,width: newSize.width,height: newSize.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        self.image = newImage!.withRenderingMode(.alwaysTemplate)
        self.tintColor = UIColor.mainColor
    }
    
    func textToImage(drawText text: String, inImage image: UIImage, atPoint point: CGPoint) -> UIImage {
        let textColor = UIColor.white
        let textFont = UIFont(name: "Helvetica Bold", size: 12)!
        
        let scale = UIScreen.main.scale
        UIGraphicsBeginImageContextWithOptions(image.size, false, scale)
        
        let textFontAttributes = [
            NSAttributedStringKey.font: textFont,
            NSAttributedStringKey.foregroundColor: textColor,
            ] as [NSAttributedStringKey : Any]
        image.draw(in: CGRect(origin: CGPoint.zero, size: image.size))
        
        let rect = CGRect(origin: point, size: image.size)
        text.draw(in: rect, withAttributes: textFontAttributes)
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
}

extension Date{
    //Convert String To Datetime
    static func convertstodatetime(lastmodified: String, dateFormat: String)->Date{
        let formatter = DateFormatter()
        formatter.dateFormat = dateFormat
        return formatter.date(from: lastmodified)!
    }
    //Convert Datetime To String
    static func convertdatetimetos(lastmodified: Date, dateFormat: String)->String{
        let formatter = DateFormatter()
        formatter.dateFormat = dateFormat
        return formatter.string(from: lastmodified)
    }
    
    var millisecondsSince1970:Int {
        return Int((self.timeIntervalSince1970 * 1000.0).rounded())
    }
    
    init(milliseconds:Int64) {
        self = Date(timeIntervalSince1970: TimeInterval(milliseconds) / 1000)
    }
}

extension UITableView {
    func reloadData(completion: @escaping ()->()) {
        UIView.animate(withDuration: 0, animations: { self.reloadData() })
        { _ in completion() }
    }
}

extension UICollectionView {
    func reloadData(completion: @escaping ()->()) {
        UIView.animate(withDuration: 0, animations: { self.reloadData() })
        { _ in completion() }
    }
}

class DKImage: DKImagePickerController{
    
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.barStyle = .blackTranslucent
    }
}
