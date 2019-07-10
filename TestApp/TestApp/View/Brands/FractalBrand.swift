//
//  FractalBrand.swift
//  TestApp
//
//  Created by anthony on 28/05/2019.
//  Copyright © 2019 Mercari. All rights reserved.
//

import Foundation
import DesignSystem

public extension BrandingManager.Color.Key {
    static let check = BrandingManager.Color.Key("check")
}

class FractalBrand: Brand {

    var id: String = "FractalBrand"

    var keyboardAppearance: UIKeyboardAppearance = .light

    var preferredStatusBarStyle: UIStatusBarStyle { return .lightContent }

    var defaultCellHeight: CGFloat = 52.0

    public func setAppearance() {

        let attributes: [NSAttributedString.Key: AnyObject] = [
            NSAttributedString.Key.font: BrandingManager.Typography.large.font,
            NSAttributedString.Key.foregroundColor: UIColor.brand()]

        let largeAttributes: [NSAttributedString.Key: AnyObject] = [
            NSAttributedString.Key.font: BrandingManager.Typography.xxlarge.font,
            NSAttributedString.Key.foregroundColor: UIColor.brand()]

        UINavigationBar.appearance().titleTextAttributes = attributes
        UINavigationBar.appearance().largeTitleTextAttributes = largeAttributes
        UINavigationBar.appearance().shadowImage = UIImage(color: .brand())
        UINavigationBar.appearance().isTranslucent = false
        UINavigationBar.appearance().barTintColor = .background()
        UINavigationBar.appearance().tintColor = .brand()

        UITabBar.appearance().shadowImage = UIImage(color: .divider())
        UITabBar.appearance().isOpaque = true
        UITabBar.appearance().barTintColor = .background()
        UITabBar.appearance().tintColor = .brand()

        let tabFont = BrandingManager.Typography.xsmall.font
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.font: tabFont],
                                                         for: .normal)
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.font: tabFont],
                                                         for: .selected)
    }

    func value(for spacing: BrandingManager.Spacing) -> CGFloat {
        switch spacing {
        case .xxsmall:
            return 1.0
        case .xsmall:
            return 2.0
        case .small:
            return 4.0
        case .medium:
            return 8.0
        case .large:
            return 16.0
        case .xlarge:
            return 32.0
        case .xxlarge:
            return 64.0
        case .xxxlarge:
            return 128.0
        case .keyline:
            return 16.0
        case .divider:
            return 1.0
        }
    }

    func value(for size: BrandingManager.IconSize) -> CGSize {
        switch size {
        case .xsmall:
            return CGSize(width: 20.0, height: 20.0)
        case .small:
            return CGSize(width: 28.0, height: 28.0)
        case .medium:
            return CGSize(width: 40.0, height: 40.0)
        case .large:
            return CGSize(width: 64.0, height: 64.0)
        case .xlarge:
            return CGSize(width: 96.0, height: 96.0)
        case .xxlarge:
            return CGSize(width: 128.0, height: 128.0)
        }
    }

    func value(for color: BrandingManager.Color) -> UIColor {
        switch color {
        case .atom(let key):
            switch key {
            case .shadow:
                return Palette.shadow.color
            case .warning:
                return Palette.pink1.color
            case .sliderPositiveTint:
                return Palette.blue.color
            case .sliderNegativeTint:
                return Palette.mono3.color
            case .switchPositiveTint:
                return Palette.blue.color
            case .switchNegativeTint:
                return Palette.mono6.color
            case .check:
                return Palette.pink1.color
            default:
                return Palette.blue.color
            }
        case .brand(let key):
            switch key {
            case .secondary:
                return Palette.pink1.color
            case .tertiary:
                return Palette.pink2.color
            default:
                return Palette.blue.color
            }
        case .background(_):
            return Palette.mono5.color
        case .divider(_):
            return Palette.mono4.color
        case .text(let key):
            switch key {
            case .light:
                return Palette.mono.color
            case .information:
                return .brand(.secondary)
            default:
                return Palette.mono.color
            }
        }
    }

    public func fontSize(for typography: BrandingManager.Typography) -> CGFloat {
        var size: CGFloat

        switch typography {
        case .xxlarge:
            size = 32.0
        case .xlarge:
            size = 28.0
        case .large:
            size = 20.0
        case .medium:
            size = 16.0
        case .small:
            size = 14.0
        case .xsmall:
            size = 12.0
        case .xxsmall:
            size = 10.0
        default:
            size = 16.0
        }

        if typography.useAccessibility {
            size += fontSizeAdjustment(for: typography)
        }

        return size
    }

    private func fontSizeAdjustment(for typography: BrandingManager.Typography) -> CGFloat {
        switch (typography, BrandingManager.contentSizeCategory) {
        case (.xxsmall, .extraSmall),
             (.xxsmall, .small):
            return 0.0
        case (_, .extraSmall):
            return -2.0
        case (_, .small):
            return -1.0
        case (_, .extraLarge):
            return 1.0
        case (_, .extraExtraLarge):
            return 2.0
        case (_, .extraExtraExtraLarge):
            return 3.0
        case (_, .accessibilityMedium):
            return 4.0
        case (_, .accessibilityLarge):
            return 5.0
        case (_, .accessibilityExtraLarge):
            return 6.0
        case (_, .accessibilityExtraExtraLarge), (_, .accessibilityExtraExtraExtraLarge):
            return 7.0
        default: // unspecified, medium & large
            return 0.0
        }
    }

    func fontName(for fontWeight: UIFont.Weight) -> String? {
        switch fontWeight {
        case .black:
            return "Avenir-Black"
        case .medium:
            return "Avenir-Medium"
        default:
            return "Avenir"
        }
    }

    // ultraLight, thin, light, regular, medium, semibold, bold, heavy, strong, black
    public func fontWeight(for typography: BrandingManager.Typography) -> UIFont.Weight {
        if typography.isStrong {
            switch typography {
            case .xxlarge, .xlarge, .large:
                return .black
            default:
                return .medium
            }
        }
        return .regular
    }

    internal enum Palette: String, CaseIterable {

        case blue, pink1, pink2, pink3,
        mono6, mono5, mono4, mono3, mono2, mono,
        shadow

        var color: UIColor {
            switch self {
            case .pink1:
                return #colorLiteral(red: 0.973, green: 0.522, blue: 0.502, alpha: 1)
            case .pink2:
                return #colorLiteral(red: 0.976, green: 0.725, blue: 0.714, alpha: 1)
            case .pink3:
                return #colorLiteral(red: 0.961, green: 0.890, blue: 0.890, alpha: 1)
            case .blue:
                return #colorLiteral(red: 0.659, green: 0.871, blue: 0.878, alpha: 1)
            case .mono6:
                return #colorLiteral(red: 0.0, green: 0.0, blue: 0.0, alpha: 1)
            case .mono5:
                return #colorLiteral(red: 0.1, green: 0.1, blue: 0.1, alpha: 1)
            case .mono4:
                return #colorLiteral(red: 0.2, green: 0.2, blue: 0.2, alpha: 1)
            case .mono3:
                return #colorLiteral(red: 0.9, green: 0.9, blue: 0.9, alpha: 1)
            case .mono2:
                return #colorLiteral(red: 0.95, green: 0.95, blue: 0.95, alpha: 1)
            case .mono:
                return #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1)
            case .shadow:
                return #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.18)
            }
        }
    }

    var rawPalette: [BrandingManager.PaletteOption] {
        return Palette.allCases.map { BrandingManager.PaletteOption(name: $0.rawValue, color: $0.color) }
    }
}

extension FractalBrand: ButtonBrand {

    func widthPin(for size: Button.Size) -> Pin {
        return .width(-.keyline*2)
    }

    func heightPin(for size: Button.Size) -> Pin {
        return .height(asConstant: 48.0)
    }

    func configure(_ button: Button, with style: Button.Style) {

        button.layer.cornerRadius = 8.0
        button.setTypography(.large)

        switch style {
        case .primary:
            button.setTitleColor(.text(.light), for: .normal)
            button.setBackgroundColor(.brand(), for: .normal)
            button.setBackgroundColor(UIColor.brand().lighter(0.1), for: .highlighted)
            button.layer.borderWidth = 0.0
        case .secondary:
            button.setTitleColor(.atom(.warning), for: .normal)
            button.setTitleColor(.text(.light), for: .highlighted)
            button.setBackgroundColor(.clear, for: .normal)
            button.setBackgroundColor(UIColor.atom(.warning), for: .highlighted)
            button.layer.borderWidth = 2.0
            button.layer.borderColor = UIColor.atom(.warning).cgColor
        case .attention:
            button.setTitleColor(.text(.light), for: .normal)
            button.setBackgroundColor(.atom(.warning), for: .normal)
            button.setBackgroundColor(UIColor.atom(.warning).lighter(), for: .highlighted)
            button.layer.borderWidth = 0.0
        case .toggle:
            button.setTitleColor(.text(.light), for: .normal)
            button.setBackgroundColor(.brand(), for: .normal)
            button.setBackgroundColor(UIColor.brand().lighter(0.1), for: .highlighted)
            button.setBackgroundColor(UIColor.brand().lighter(0.1), for: .selected)
            button.layer.borderWidth = 0.0
        default:
            button.setTitleColor(.text(.light), for: .normal)
            button.setBackgroundColor(.text(), for: .normal)
            button.setBackgroundColor(UIColor.text().lighter(0.1), for: .highlighted)
            button.layer.borderWidth = 0.0
        }
    }
}
