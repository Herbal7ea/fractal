//
//  UIImage+Extensions.swift
//  DesignSystem
//
//  Created by Anthony Smith on 02/07/2021.
//  Copyright © 2021 mercari. All rights reserved.
//

import Foundation

public extension UIImage {
    
    func colorized(with color: UIColor) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        defer { UIGraphicsEndImageContext() }
        guard let context = UIGraphicsGetCurrentContext(), let cgImage = cgImage else { return self }
        let rect = CGRect(origin: .zero, size: size)
        color.setFill()
        context.translateBy(x: 0, y: size.height)
        context.scaleBy(x: 1.0, y: -1.0)
        context.clip(to: rect, mask: cgImage)
        context.fill(rect)
        guard let colored = UIGraphicsGetImageFromCurrentImageContext() else { return self }
        return colored
    }
    
    func stroked(with color: UIColor, thickness: CGFloat, quality: CGFloat = 0.0, plusOriginal: Bool = true) -> UIImage {
        
        guard let cgImage = cgImage else { return self }
        
        let strokeImage = colorized(with: color)
        guard let strokeCGImage = strokeImage.cgImage else { return self }
        
        let step = quality == 0.0 ? 10.0 : abs(quality)
        let oldRect = CGRect(x: thickness, y: thickness, width: size.width, height: size.height).integral
        let newSize = CGSize(width: size.width + 2.0 * thickness, height: size.height + 2.0 * thickness)
        let translationVector = CGPoint(x: thickness, y: thickness)
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, scale)
        guard let context = UIGraphicsGetCurrentContext() else { return self }
        defer { UIGraphicsEndImageContext() }
        
        context.translateBy(x: 0, y: newSize.height)
        context.scaleBy(x: 1.0, y: -1.0)
        context.interpolationQuality = .high
        
        for angle: CGFloat in stride(from: 0, to: 360, by: step) {
            let vector = translationVector.rotated(around: .zero, byDegrees: angle)
            let transform = CGAffineTransform(translationX: vector.x, y: vector.y)
            
            context.concatenate(transform)
            context.draw(strokeCGImage, in: oldRect)
            
            let resetTransform = CGAffineTransform(translationX: -vector.x, y: -vector.y)
            context.concatenate(resetTransform)
        }
        
        if plusOriginal {
            context.draw(cgImage, in: oldRect)
        }
        
        guard let stroked = UIGraphicsGetImageFromCurrentImageContext() else { return self }
        return stroked
    }
}

fileprivate extension CGPoint {
    func rotated(around origin: CGPoint, byDegrees: CGFloat) -> CGPoint {
        let dx = x - origin.x
        let dy = y - origin.y
        let radius = sqrt(dx * dx + dy * dy)
        let azimuth = atan2(dy, dx) // in radians
        let newAzimuth = azimuth + byDegrees * .pi / 180.0 // to radians
        let x = origin.x + radius * cos(newAzimuth)
        let y = origin.y + radius * sin(newAzimuth)
        return CGPoint(x: x, y: y)
    }
}
