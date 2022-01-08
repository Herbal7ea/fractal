//
//  UIImage+Saving.swift
//  Manager
//
//  Created by Anthony Smith on 15/11/2019.
//  Copyright © 2019 nodata. All rights reserved.
//

import Foundation
import UIKit

extension UIImageView {
    public func getImage(from urlString: String) {
        UIImage.get(from: urlString) { [weak self] (downloadedImage) in
            self?.image = downloadedImage
        }
    }
}

extension UIImage {
    
    public static func with(urlName: String) -> UIImage? {
        do {
            if let image = UIImage(named: urlName) { return image }
            guard let url = urlName.fileURL else { return nil }
            let data = try Data(contentsOf: url)
            return UIImage(data: data)
        } catch {
            return nil
        }
    }
    
    public static func get(from urlString: String, completion: @escaping (UIImage?) -> Void) {
    
        print("download from url is untested")
        
        if let image = UIImage.with(urlName: urlString) { completion(image); return }
        
        DispatchQueue.global().async {

            guard let url = URL(string: urlString) else { DispatchQueue.main.async { completion(nil) }; return }
            
            do {
                let data = try Data(contentsOf: url)
                guard let image = UIImage(data: data) else { DispatchQueue.main.async { completion(nil) }; return }
                    
                if urlString.contains(".jpg") || urlString.contains(".jpeg") {
                    image.save(as: urlString, transparency: false)
                } else if urlString.contains(".png") {
                    image.save(as: urlString, transparency: true)
                } else {
                    print("Image not a supported format (png or jpg), couldn't save")
                }
                    
                completion(image)
                
            } catch {
                
                print("Could not download \(urlString)")
                DispatchQueue.main.async { completion(nil) }
            }
        }
    }
 
    public func save(as name: String, transparency: Bool = true, completion: ((Bool) -> Void)? = nil) {
        guard let imageData = transparency ? pngData() : jpegData(compressionQuality: 1.0) else {
            print("Could not render \(name) as Image Data")
            completion?(false)
            return
        }
        
        imageData.save(asImage: name, completion: { data in
            completion?(data != nil)
        })
    }
    
    public func combined(with image: UIImage, size: CGSize? = nil) -> UIImage? {
        
        let contextSize = size ?? self.size
        
        UIGraphicsBeginImageContextWithOptions(contextSize, false, 0.0)

        let rect = CGRect(origin: .zero, size: contextSize)
        draw(in: rect)
        image.draw(in: rect, blendMode: .normal, alpha: 1.0)

        let combination = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return combination
    }
    
    public func tinted(_ color: UIColor) -> UIImage {
        
        let maskImage = cgImage
        let rect = CGRect(origin: .zero, size: size)
        let renderer = UIGraphicsImageRenderer(size: size)
        
        return renderer.image { context in
            let cgContext = context.cgContext
            cgContext.translateBy(x: 0, y: rect.size.height)
            cgContext.scaleBy(x: 1.0, y: -1.0)
            cgContext.clip(to: rect, mask: maskImage!)
            color.setFill()
            cgContext.fill(rect)
        }
    }
}

extension Data {
    fileprivate func save(asImage name: String, completion: ((Data?) -> Void)? = nil) {
        guard let url = name.fileURL else {
            print("could not save as \(name.filename)")
            completion?(nil)
            return
        }
        do {
            try write(to: url)
            completion?(self)
        } catch {
            print("could not save to:", url.absoluteString)
            completion?(nil)
        }
    }
}

extension UIView {
    
    fileprivate func asImageData(transparency: Bool = true, size: CGSize? = nil) -> Data {
         
         let renderer = UIGraphicsImageRenderer(size: size ?? bounds.size)
         let data: Data

         if transparency {
             data = renderer.pngData() { (context) in
                 layer.render(in: context.cgContext)
             }
         } else {
             data = renderer.jpegData(withCompressionQuality: 1.0) { (context) in
                 layer.render(in: context.cgContext)
             }
         }

         return data
     }
    
    public func asImage(transparency: Bool = true) -> UIImage? {
        let data = asImageData(transparency: transparency)
        return UIImage(data: data)
    }
    
//    func asImage(transparency: Bool = true) -> UIImage {
//        let renderer = UIGraphicsImageRenderer(size: bounds.size)
//        let image = renderer.image { ctx in drawHierarchy(in: bounds, afterScreenUpdates: true) }
//        return image
//    }
    
//    func asImage() -> UIImage {
//        UIGraphicsImageRenderer(bounds: bounds).image { context in layer.render(in: context.cgContext) }
//    }
}

extension String {
    fileprivate var filename: String {
        
        // TODO: device name / scalefactor
        
        return replacingOccurrences(of: "/", with: "_").lowercased()
    }
    
    fileprivate var fileURL: URL? {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return documentsDirectory.appendingPathComponent(filename)
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
}
