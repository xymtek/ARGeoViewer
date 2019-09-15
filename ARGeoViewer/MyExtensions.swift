//
//  MyExtensions.swift
//  ARGeoViewer
//
//  Created by Andy Martushev on 9/14/19.
//  Copyright © 2019 Andy Martushev. All rights reserved.
//

import Foundation
import ARKit

extension FloatingPoint {
    func toRadians() -> Self {
        return self * .pi / 180
    }
    
    func toDegrees() -> Self {
        return self * 180 / .pi
    }
}


import UIKit

extension String {
    func image(backgroundColor:UIColor = UIColor.clear) -> UIImage? {
        let size = CGSize(width: 100 * self.count, height: 100)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        
        backgroundColor.set()
        let rect = CGRect(origin: CGPoint(), size: size)
        UIRectFill(CGRect(origin: CGPoint(), size: size))
        (self as NSString).draw(in: rect, withAttributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 90)])
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}


