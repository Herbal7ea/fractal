//
//  Button.swift
//  Mercari
//
//  Created by Anthony Smith on 31/10/2017.
//  Copyright © 2017 Mercari, Inc. All rights reserved.
//

import Foundation
import UIKit

private class ButtonLayer: CAGradientLayer {

    var borderColors: [UIControl.State: CGColor] = [:]
    var gradientColors: [UIControl.State: [CGColor]] = [:]

    override var borderColor: CGColor? { didSet { borderColors[.normal] = borderColor } }
    override var colors: [Any]? { didSet { gradientColors[.normal] = colors as? [CGColor] } }

    func updateColors(for state: UIControl.State) {
        super.borderColor = borderColors[state] ?? borderColors[.normal]
        super.colors = gradientColors[state] ?? gradientColors[.normal]
    }
}

open class Button: UIButton, Brandable {
    
    public struct Style: Equatable, RawRepresentable {
        public let rawValue: String
        
        public init(_ value: String) {
            self.rawValue = value
        }
        
        public init(rawValue: String) {
            self.rawValue = rawValue
        }
        
        public static func ==(lhs: Style, rhs: Style) -> Bool {
            return lhs.rawValue == rhs.rawValue
        }
    }
    
    public struct Size {
        
        public let width: Width
        public let height: Height
        
        public init(_ width: Width, _ height: Height) {
            self.width = width
            self.height = height
        }
        
        public init(width: Width, height: Height) {
            self.width = width
            self.height = height
        }
        
        public enum Width {
            case full, half, natural, custom(CGFloat)
            
            public var rawValue: String {
                switch self {
                case .full:
                    return "full"
                case .half:
                    return "half"
                case .natural:
                    return "natural"
                case .custom(let constant):
                    return "custom_\(constant)"
                }
            }
        }
        
        public enum Height {
            case small, medium, large, natural, custom(CGFloat)
            
            public var rawValue: String {
                switch self {
                case .small:
                    return "small"
                case .medium:
                    return "medium"
                case .large:
                    return "large"
                case .natural:
                    return "natural"
                case .custom(let constant):
                    return "custom_\(constant)"
                }
            }
        }
    }
    
    public let style: Style
    public let size: Size
        
    public var imageScale: CGFloat = 1.0 { didSet { update() }}
    public var imageTitlePadding: CGFloat = .large { didSet { update() }}

    private let brandManager: BrandManager
    private var images: [UIControl.State: UIImage] = [:]
    private var backgroundColors: [UIControl.State: UIColor] = [:]

    private var overriddeImageConstraints: (top: NSLayoutConstraint, bottom: NSLayoutConstraint,
                                            x: NSLayoutConstraint, y: NSLayoutConstraint)!
    private let overriddeImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    open override func image(for state: UIControl.State) -> UIImage? { nil }
    open override func setImage(_ image: UIImage?, for state: UIControl.State) { images[state] = image; update() }
    
    override public var backgroundColor: UIColor? { didSet { backgroundColors[.normal] = backgroundColor } }
    override public var isSelected: Bool { didSet { update() } }
    override public var isHighlighted: Bool { didSet { update() } }
    override public var isEnabled: Bool { didSet { update() } }
    
    override public class var layerClass: AnyClass { ButtonLayer.self }

    private var buttonLayer: ButtonLayer? { layer as? ButtonLayer }

    var gradientLayer: CAGradientLayer? { layer as? CAGradientLayer }

    public init(style: Style, size: Size, brandManager: BrandManager = .shared) {
        self.size = size
        self.style = style
        self.brandManager = brandManager
        super.init(frame: .zero)
        addImageView()
        setForBrand()
        update()
    }
    
    public init(_ style: Style, _ size: Size, brandManager: BrandManager = .shared) {
        self.size = size
        self.style = style
        self.brandManager = brandManager
        super.init(frame: .zero)
        addImageView()
        setForBrand()
        update()
    }
    
    public init(_ style: Style, _ sizeTuple: (width: Size.Width, height: Size.Height), brandManager: BrandManager = .shared) {
        self.size = Size(width: sizeTuple.width, height: sizeTuple.height)
        self.style = style
        self.brandManager = brandManager
        super.init(frame: .zero)
        addImageView()
        setForBrand()
        update()
    }
    
    public func setForBrand() {
        if let buttonBrand = brandManager.brand as? ButtonBrand {
            contentEdgeInsets = buttonBrand.contentInset(for: size)
            titleLabel?.font = buttonBrand.typography(for: size).font
            buttonBrand.configure(self, with: style)
            print("Set for brand")
            update()
        } else {
            print("BrandManager.brand does not conform to protocol ButtonBrand")
        }
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        update()
    }
    
    @discardableResult public func pin(sizeIn view: UIView) -> [NSLayoutConstraint] {
        pin(to: view, [.width(for: size, brandManager: brandManager),
                       .height(for: size, brandManager: brandManager)])
    }
    
    @discardableResult public func pin(height view: UIView) -> [NSLayoutConstraint] {
        pin(to: view, [.height(for: size, brandManager: brandManager)])
    }
    
    public func setBackgroundColor(_ color: UIColor?, for state: UIControl.State) {
        backgroundColors[state] = color
        updateBackground()
    }

    public func setBorderColor(_ color: UIColor?, for state: UIControl.State) {
        buttonLayer?.borderColors[state] = color?.cgColor
        updateBackground()
    }

    public func setGradientColors(_ colors: [UIColor]?, for state: UIControl.State) {
        buttonLayer?.gradientColors[state] = colors?.map { $0.cgColor }
        updateBackground()
    }

    public func resetColors() {
        backgroundColors = [:]
        buttonLayer?.borderColors = [:]
        buttonLayer?.gradientColors = [:]
        updateBackground()
    }
    
    private func addImageView() {
        imageView?.isHidden = true
        addSubview(overriddeImageView)
        let c = overriddeImageView.pin(to: self, [.top, .bottom, .centerX, .centerY])
        overriddeImageView.pin(to: overriddeImageView, [.widthToHeight])
        overriddeImageConstraints = (c[0], c[1], c[2], c[3])
    }

    private func update() {
        updateImage()
        updateBackground()
    }
    
    private func updateImage() {
        
        let normalImage = images[state] ?? images[.normal]

        if let image = normalImage, image != .none {
            titleEdgeInsets = .zero
            overriddeImageView.isHidden = false
            overriddeImageView.image = image
            overriddeImageView.tintColor = titleColor(for: state) ?? titleColor(for: .normal) ?? .red
            let delta = frame.size.height - (frame.size.height * imageScale)
            overriddeImageConstraints.top.constant = contentEdgeInsets.top + delta/2
            overriddeImageConstraints.bottom.constant = -(contentEdgeInsets.bottom + delta/2)
            
            if let title = title(for: state) {
                let typography = (brandManager.brand as? ButtonBrand)?.typography(for: size) ?? .medium
                let width = title.size(typography: typography, maxLines: 1).width
                let imageHeight = (frame.size.height - (contentEdgeInsets.top + contentEdgeInsets.bottom)) * imageScale
                let delta = imageHeight + imageTitlePadding
                overriddeImageConstraints.x.constant = -width/2 - imageTitlePadding + imageHeight/2
                titleEdgeInsets = UIEdgeInsets(top: 0.0, left: delta, bottom: 0.0, right: 0.0)
            }
        } else {
            overriddeImageView.isHidden = true
            titleEdgeInsets = .zero
        }
    }
    
    private func updateBackground() {
        let backgroundColor = backgroundColors[state] ?? alternativeBackgroundColor
        super.backgroundColor = backgroundColor
        buttonLayer?.updateColors(for: state)
    }

    private var alternativeBackgroundColor: UIColor? {
        let normal = backgroundColors[.normal]
        let selected = backgroundColors[.selected] ?? backgroundColors[.normal]

        switch state {
        case .highlighted, .selected, [.selected, .highlighted]:
            return normal?.darker()
        case .disabled:
            return normal?.alpha()
        case [.selected, .disabled]:
            return selected?.lighter()
        default:
            return normal
        }
    }
}

extension Pin {

    static func width(for size: Button.Size, brandManager: BrandManager) -> Pin {
        switch size.width {
        case .custom(let value):
            return .width(asConstant: value)
        case .full:
            return .width((brandManager.brand as? ButtonBrand)?.widthPadding(for: size) ?? -.keyline*2)
        case .half:
            return .width((brandManager.brand as? ButtonBrand)?.widthPadding(for: size) ?? -.keyline*2, options: [.multiplier(0.5)])
        case .natural:
            return .none
        }
    }
    
    static func height(for size: Button.Size, brandManager: BrandManager) -> Pin {
        
        func defaultPin() -> Pin {
            switch size.height {
            case .natural:
                return .none
            case .small:
                return .height(asConstant: 32.0)
            case .medium:
                return .height(asConstant: 44.0)
            case .large:
                return .height(asConstant: 52.0)
            case .custom(let value):
                return .height(asConstant: value)
            }
        }
        
        if let brand = brandManager.brand as? ButtonBrand {
            let floatValue = brand.height(for: size)
            return floatValue == 0.0 ? .none : .height(asConstant: floatValue)
        }
        
        return defaultPin()
    }
}
