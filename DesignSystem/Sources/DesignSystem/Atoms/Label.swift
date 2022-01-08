//
//  Label.swift
//  Mercari
//
//  Created by Shinichiro Oba on 21/06/2018.
//  Copyright © 2018 Mercari, Inc. All rights reserved.
//

import UIKit

open class Label: UILabel, Brandable {

    public var typography: Typography { didSet { lineHeight = numberOfLines == 1 ? 0.0 : typography.lineHeight } }
    public var actualLineHeight: CGFloat { return max(lineHeight, font.lineHeight) }
    public var underlineStyle: NSUnderlineStyle = [] { didSet { update() } }
    public var letterSpace: CGFloat = 0.0 { didSet { update() } }
    public var lineHeight: CGFloat = 0.0 { didSet { update() } }
    public var strokeColor: UIColor? { didSet { update() } }
    public var strokeWidth: CGFloat = 0.0 { didSet { update() } }

    override public var font: UIFont! { get { return typography.font } set { } }
    override public var text: String? { didSet { update() } }
    override public var textAlignment: NSTextAlignment { didSet { update() } }

    public init(typography: Typography = .medium, textColor: UIColor = .text) {
        self.typography = typography
        super.init(frame: .zero)
        self.textColor = textColor
    }
    
    public override init(frame: CGRect) {
        self.typography = .medium
        super.init(frame: frame)
        self.textColor = .text
    }

    public required init?(coder aDecoder: NSCoder) {
        self.typography = .medium
        super.init(coder: aDecoder)
        self.textColor = .text
    }

    public func set(typography: Typography, color: UIColor? = nil) {
        self.typography = typography
        textColor = color ?? typography.defaultColor
    }

    public func setForBrand() {
        update()
    }
    
    private func update() {
        guard let text = text else { attributedText = nil; return }
        let attributedString = NSMutableAttributedString(string: text, attributes: attributes)
        attributedText = attributedString
    }

    override public func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        update()
    }
    
    public func add(_ extraAttributes: [(font: UIFont?, color: UIColor?, substring: String)]) {
        guard let t = text else { return }
        
        let attributedString = NSMutableAttributedString(string: t, attributes: attributes)

        for a in extraAttributes {
            let range = (t as NSString).range(of: a.substring)
            attributedString.addAttribute(NSAttributedString.Key.font, value: font ?? typography.font, range: range)
            if let c = a.color {
                attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: c, range: range)
            }
        }

        attributedText = attributedString
    }
    
    private var attributes: [NSAttributedString.Key: Any] {

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = textAlignment
        paragraphStyle.lineBreakMode = .byTruncatingTail
        
        var attr = [NSAttributedString.Key: Any]()
        attr[.font] = typography.font
        attr[.foregroundColor] = textColor ?? typography.defaultColor
        attr[.paragraphStyle] = paragraphStyle
        attr[.underlineStyle] = underlineStyle.rawValue
        attr[.strokeColor] = strokeColor
        attr[.strokeWidth] = strokeWidth
        attr[.kern] = letterSpace
        
        return attr
    }
}
