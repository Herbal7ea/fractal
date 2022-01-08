//
//  NavigationController.swift
//
//  Created by anthony on 20/08/2019.
//  Copyright © 2019 Mercari. All rights reserved.
//

import Foundation

public protocol NavigationControllerBrand {
    func applyBrand(to navigationBar: UINavigationBar)
}

public class NavigationController: UINavigationController, Brandable {

    private let brandManager: BrandManager
    
    public override init(rootViewController: UIViewController) {
        self.brandManager = .shared
        super.init(rootViewController: rootViewController)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        setForBrand()
    }

    public func setForBrand() {
        guard let brand = brandManager.brand as? NavigationControllerBrand else {
            print("BrandingManager.brand does not conform to NavigationControllerBrand")
            return
        }
        brand.applyBrand(to: navigationBar)
    }
}
