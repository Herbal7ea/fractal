//
//  CGFloat+Extensions.swift
//  DesignSystem
//
//  Created by Anthony Smith on 30/05/2019.
//  Copyright © 2019 mercari. All rights reserved.
//

import Foundation

extension CGFloat {
    public var size: CGSize {
        return CGSize(width: self, height: self)
    }
    
    public func dpString(_ decimalPlaces: Int) -> String {
        return String(format: "%.\(decimalPlaces)f", self)
    }

    public var nodpString: String {
        return String(format: "%.0f", self)
    }
}

extension Double {
    public var size: CGSize {
        return CGSize(width: self, height: self)
    }
}
