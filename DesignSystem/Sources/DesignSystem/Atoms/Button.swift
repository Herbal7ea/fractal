//
//  Button.swift
//  DesignSystem
//
//  Created by Anthony Smith on 18/01/2022.
//  Copyright © 2022 no data. All rights reserved.
//

import Foundation
import UIKit

public protocol ButtonBrand {
    func typography(for size: Button.Size) -> Typography
    func widthPadding(for size: Button.Size) -> CGFloat
    func contentInset(for size: Button.Size) -> UIEdgeInsets
    func height(for size: Button.Size) -> CGFloat
    func configure(_ button: Button, with style: Key)
}

public class Button: UIControl, Brandable {
        
    public struct Size {
        
        public enum Width {
            case full, half, natural, custom(CGFloat)
            
            public var rawValue: String {
                switch self {
                case .full:    return "full"
                case .half:    return "half"
                case .natural: return "natural"
                case .custom(let constant): return "custom_\(constant)"
                }
            }
        }
        
        public enum Height {
            case small, medium, large, natural, custom(CGFloat)
            
            public var rawValue: String {
                switch self {
                case .small:   return "small"
                case .medium:  return "medium"
                case .large:   return "large"
                case .natural: return "natural"
                case .custom(let constant): return "custom_\(constant)"
                }
            }
        }
        
        public let width: Width
        public let height: Height
        
        public init(_ width: Width, _ height: Height) {
            self.width = width
            self.height = height
        }
    }
    
    override public var state: UIControl.State {
        guard !isSelected else { return .selected }
        guard !isHighlighted else { return .highlighted }
        guard !isEnabled else { return .normal }
        return .disabled
    }
    
    public var title: String? {
        get { titles[.normal] }
        set { titles[.normal] = newValue; updateTitle() }
    }
    
    override public var backgroundColor: UIColor? {
        get { backgroundColors[.normal] }
        set { backgroundColors[.normal] = newValue; updateBackground() }
    }

    override public var isSelected: Bool { didSet { observedIsSelected.value = isSelected; update() } }
    override public var isHighlighted: Bool { didSet { observedIsHighlighted.value = isHighlighted; update() } }
    override public var isEnabled: Bool { didSet { observedIsEnabled.value = isEnabled; update() } }
    override public var tintColor: UIColor! { didSet { updateTitleColor() } }
    
    public lazy var observedIsSelected: Observable<Bool> = {
        let observed = Observable<Bool>(self.isSelected)
        observed.ignoreSame = true
        return observed
    }()
    
    public lazy var observedIsHighlighted: Observable<Bool> = {
        let observed = Observable<Bool>(self.isHighlighted)
        observed.ignoreSame = true
        return observed
    }()
    
    public lazy var observedIsEnabled: Observable<Bool> = {
        let observed = Observable<Bool>(self.isEnabled)
        observed.ignoreSame = true
        return observed
    }()

    public var isAnimated = false
    public var imageTitlePadding: CGFloat { get { contentView.spacing } set { contentView.spacing = newValue } }
    public var imageScale: CGFloat { get { contentView.imageScale } set { contentView.imageScale = newValue } }
    
    public let style: Key
    public let size: Size
     
    public convenience init(_ style: Key, _ size: Size = Size(.full, .large), tapped: @escaping (Button) -> Void) {
        self.init(style, size, brandManager: .shared, tapped: tapped)
    }
    
    public convenience init(_ style: Key,
                _ width: Size.Width = .full,
                _ height: Size.Height = .large,
                tapped: @escaping (Button) -> Void) {
        self.init(style, Size(width, height), brandManager: .shared, tapped: tapped)
    }
    
    init(_ style: Key, _ size: Size, brandManager: BrandManager,
        tapped: @escaping (Button) -> Void) {
        self.size = size
        self.style = style
        self.brandManager = brandManager
        self.tapped = tapped
        super.init(frame: .zero)

        if #available(iOS 13.0, *) { layer.cornerCurve = .continuous }

        addSubview(contentView)
        
        let constraints = contentView.pin(to: self, [.leading(options: [.relation(.greaterThanOrEqual)]),
                                                     .trailing(options: [.relation(.lessThanOrEqual)]),
                                                     .top,
                                                     .bottom,
                                                     .centerX,
                                                     .centerY])
        
        contentViewConstrants = (constraints[0], constraints[1], constraints[2], constraints[3])
        setForBrand()
        
        addTarget(self, action: #selector(didTouchDown), for: [.touchDownRepeat, .touchDown])
        addTarget(self, action: #selector(didTouchUpInside), for: .touchUpInside)
        addTarget(self, action: #selector(didDragOutside), for: [.touchDragExit, .touchCancel])
        addTarget(self, action: #selector(didDragInside), for: .touchDragEnter)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        update()
    }
    
    // MARK: - Touches
    
    @objc private func didTouchDown() {
        isHighlighted = true
    }
    
    @objc private func didDragInside() {
        isHighlighted = true
    }
    
    @objc private func didTouchUpInside() {
        isHighlighted = false
        sendActions(for: .primaryActionTriggered)
        tapped(self)
    }
    
    @objc private func didDragOutside() {
        isHighlighted = false
    }
    
    // MARK: - Rendering
    
    public func setForBrand() {
        if let buttonBrand = brandManager.brand as? ButtonBrand {
            let insets = buttonBrand.contentInset(for: size)
            contentViewConstrants.leading.constant = insets.left
            contentViewConstrants.trailing.constant = -insets.right
            contentViewConstrants.top.constant = insets.top
            contentViewConstrants.bottom.constant = -insets.bottom
            label.typography = buttonBrand.typography(for: size)
            buttonBrand.configure(self, with: style)
            update()
        } else {
            print("BrandManager.brand does not conform to protocol ButtonBrand")
        }
    }
    
    private func update() {

        updateTitle()
        updateImage()
        
        guard renderedState != state else { return }
            
        guard isAnimated else {
            updateTitleColor()
            updateBackground()
            updateGradientBackground()
            updateScale()
            return
        }
        
        renderedState = state

        UIView.animate(withDuration: 0.1, delay: 0.0, options: [.beginFromCurrentState, .curveEaseInOut]) {
            self.updateTitleColor()
            self.updateBackground()
        } completion: { _ in }
        
        let locationsA = CABasicAnimation(keyPath: "locations")
        locationsA.duration = 0.1
        locationsA.fromValue = gradientLocations[renderedState] ?? []
        locationsA.toValue = gradientLocations[state] ?? gradientLocations[.normal] ?? []
        gradientLayer.add(locationsA, forKey: locationsA.keyPath)
 
        let colorsA = CABasicAnimation(keyPath: "colors")
        colorsA.duration = 0.1
        colorsA.fromValue = gradientColors[renderedState] ?? []
        colorsA.toValue = gradientColors[state] ?? gradientColors[.normal] ?? []
        gradientLayer.add(colorsA, forKey: colorsA.keyPath)
        
        switch state {
        case .normal, .selected:
            UIView.animate(withDuration: 0.4,
                           delay: 0.0,
                           usingSpringWithDamping: 0.85,
                           initialSpringVelocity: 0.0,
                           options: [.beginFromCurrentState, .curveEaseOut]) {
                self.updateScale()
            } completion: { _ in }
        default:
            UIView.animate(withDuration: 0.1, delay: 0.0, options: [.beginFromCurrentState, .curveEaseInOut]) {
                self.updateScale()
            } completion: { _ in }
        }
    }
    
    private func updateBackground() {
        super.backgroundColor = backgroundColors[state] ?? computedBackgroundColor
        gradientLayer.borderColor = borderColors[state]
    }
    
    private func updateGradientBackground() {
        gradientLayer.colors = gradientColors[state]
        gradientLayer.locations = gradientLocations[state]
    }
    
    private func updateTitle() {
        label.text = titles[state] ?? titles[.normal]
        contentView.prepareForRedraw()
    }
    
    private func updateImage() {
        let image = images[state] ?? images[.normal]
        imageView.image = image
        contentView.prepareForRedraw()
    }
    
    private func updateTitleColor() {
        let color = titleColors[state] ?? titleColors[.normal] ?? tintColor
        label.textColor = color
        imageView.tintColor = imageColors[state] ?? color
    }
    
    private func updateScale() {
        transform = (scales[state] ?? false) ? CGAffineTransform(scaleX: 0.97, y: 0.97) : .identity
    }
    
    // MARK: - Setters

    public func setTitle(_ title: String?, for state: UIControl.State) {
        titles[state] = title
        if self.state == state { updateTitle() }
    }
    
    public func setTitleColor(_ color: UIColor?, for state: UIControl.State) {
        titleColors[state] = color
        if self.state == state { updateTitleColor() }
    }
    
    public func setImageColor(_ color: UIColor?, for state: UIControl.State) {
        imageColors[state] = color
        if self.state == state { updateTitleColor() }
    }
    
    public func setImage(_ image: UIImage?, for state: UIControl.State) {
        images[state] = image
        if self.state == state { updateImage() }
    }
    
    public func setBackgroundColor(_ color: UIColor?, for state: UIControl.State) {
        backgroundColors[state] = color
        if self.state == state { updateBackground() }
    }

    public func setBorderColor(_ color: UIColor?, for state: UIControl.State) {
        borderColors[state] = color?.cgColor
        if self.state == state { updateBackground() }
    }

    public func setGradientColors(_ colors: [(UIColor, CGFloat)]?, for state: UIControl.State) {
        gradientColors[state] = colors?.map { $0.0.cgColor }
        gradientLocations[state] = colors?.map { NSNumber(value: $0.1) }
        if self.state == state { updateBackground() }
    }
    
    public func setDoesScale(_ doesScale: Bool, for state: UIControl.State) {
        scales[state] = doesScale
    }
    
    // MARK: - Accessors
    
    override public class var layerClass: AnyClass { CAGradientLayer.self }

    override public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool { false }

    private var gradientLayer: CAGradientLayer { layer as! CAGradientLayer }
    
    private var label: Label { contentView.label }

    private var imageView: ImageView { contentView.imageView }

    private var computedBackgroundColor: UIColor? {
        let normal = backgroundColors[.normal]
        let selected = backgroundColors[.highlighted] ?? normal
        switch state {
        case .highlighted, .selected,
            [.selected, .highlighted]: return normal?.darker()
        case .disabled:                return normal?.alpha()
        case [.selected, .disabled]:   return selected?.lighter()
        default:                       return normal
        }
    }
    
    // MARK: - Properties
    
    private let brandManager: BrandManager
    private let tapped: (Button) -> Void
    
    private var titles: [UIControl.State: String] = [:]
    private var images: [UIControl.State: UIImage] = [:]
    private var scales: [UIControl.State: Bool] = [:]
    private var borderColors: [UIControl.State: CGColor] = [:]
    private var titleColors: [UIControl.State: UIColor] = [:]
    private var imageColors: [UIControl.State: UIColor] = [:]
    private var backgroundColors: [UIControl.State: UIColor] = [:]
    private var gradientColors: [UIControl.State: [CGColor]] = [:]
    private var gradientLocations: [UIControl.State: [NSNumber]] = [:]

    private var contentViewConstrants: (leading: NSLayoutConstraint, trailing: NSLayoutConstraint, top: NSLayoutConstraint, bottom: NSLayoutConstraint)!
    private var renderedState: UIControl.State = .normal
    
    private let contentView = ContentView()
}

private class ContentView: UIView {
    
    var spacing: CGFloat = .keyline { didSet { prepareForRedraw() } }
    
    var imageScale: CGFloat = 1.0 {
        didSet {
            imageView.transform = imageScale == 1.0 ? .identity : CGAffineTransform(scaleX: imageScale, y: imageScale)
            prepareForRedraw()
        }
    }

    private var labelXConstraint: NSLayoutConstraint!

    init() {
        super.init(frame: .zero)
        isUserInteractionEnabled = false
        addSubviews([imageView, label])
        imageView.pin(to: self, [.leading,
                                 .centerY,
                                 .top,
                                 .bottom,
                                 .widthToHeight])
        labelXConstraint = label.pin(to: self, [.leading, .trailing, .top, .bottom])[0]
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var intrinsicContentSize: CGSize {

        var width: CGFloat = 0.0
        
        if let text = label.text {
            width += text.size(typography: label.typography, maxLines: 1).width
        }
        
        if !imageView.isHidden {
            width += imageWidth
            
            if !(label.text?.isEmpty ?? true) {
                width += spacing
            }
        }
        
        return CGSize(width: width, height: 0.0)
    }
    
    func prepareForRedraw() {
        
        if let image = imageView.image {
            imageView.isHidden = image == .none
        } else {
            imageView.isHidden = true
        }
        
        label.isHidden = (label.text?.isEmpty ?? true)
        invalidateIntrinsicContentSize()
        
        labelXConstraint.constant = imageView.isHidden ? 0.0 : imageWidth + spacing
    }
    
    private var imageWidth: CGFloat { bounds.size.height * imageScale }
    
    let imageView: ImageView = {
        let imageView = ImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    let label: Label = {
        let label = Label()
        label.textAlignment = .center
        return label
    }()
}

extension UIControl.State: Hashable {
    public var hashValue: Int { Int(rawValue) }
}

extension UIImage.Key {
    public static let none = UIImage.Key("none")
}

extension UIImage {
    public static var none: UIImage {
        UIImage.with(.none) ?? UIView(frame: CGRect(origin: .zero, size: CGSize(width: 1.0, height: 1.0))).asImage()!
    }
}

extension Button {
    @discardableResult public func pin(sizeIn view: UIView) -> [NSLayoutConstraint] {
        pin(to: view, [.width(for: size, brandManager: brandManager),
                       .height(for: size, brandManager: brandManager)])
    }
    
    @discardableResult public func pin(height view: UIView) -> [NSLayoutConstraint] {
        pin(to: view, [.height(for: size, brandManager: brandManager)])
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
