//
//  MainMenuViewController.swift
//  DesignSystemApp
//
//  Created by anthony on 21/11/2018.
//  Copyright © 2018 mercari. All rights reserved.
//

import Foundation
import DesignSystem

class MainMenuViewController: SectionTableViewController, SectionBuilder {

    private var presenter: MainMenuPresenter!
    private var notificationObject: NSObjectProtocol?

    var cardHeight: CGFloat = 400.0

    init() {
        super.init(useRefreshControl: true)
    }

    override func viewDidLoad() {
        title = "Fractal"
        super.viewDidLoad()
        DependencyRegistry.shared.prepare(viewController: self)
        didPullDownToRefreshClosure = { [weak self] in self?.reload() }
        notificationObject = NotificationCenter.default.addObserver(forName: Notification.Name(rawValue: BrandingManager.didChange), object: nil, queue: nil) { [weak self] (_) in
            self?.setupUI()
            self?.reload()
        }
        
        setupUI()
        reload()
    }
    
    func setupUI() {
        setSections()
        setupTableView()
        view.backgroundColor = .background
    }

    func setSections() {
        dataSource.sections = [
            spacing(52.0),
            group([
                navigationOptions(presenter.systemOptions, style: .default, selectionClosure: selection)
                ]),
            seperator(),
            group([
                navigationOptions(presenter.exampleOptions, style: .default, selectionClosure: selection)
                ]),
            seperator(),
            group([
                navigationOptions(presenter.demoOptions, style: .default, selectionClosure: selection)
                ]),
            spacing(10.0),
            headline(BrandingManager.brand.id),
        ]
    }
    
    func inject(presenter: MainMenuPresenter) {
        self.presenter = presenter
    }

    var selection: (Int, NavigationOption) -> Void {
        return { [weak self] (index, option)  in
            guard let `self` = self else { return }
            self.presenter.selection(index, option, self)
        }
    }
}

extension MainMenuViewController: CardViewContentDelegate {
    var contentScrollView: UIScrollView? { return tableView }
    var isBackgroundDismissable: Bool { return true }
    func heightConstraint(for cardViewHeightAnchor: NSLayoutDimension) -> NSLayoutConstraint? {
        return cardViewHeightAnchor.constraint(equalToConstant: cardHeight)
    }
}
