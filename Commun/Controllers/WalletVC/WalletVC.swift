//
//  WalletVC.swift
//  Commun
//
//  Created by Chung Tran on 12/19/19.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import Foundation

class WalletVC: TransferHistoryVC {
    // MARK: - Subviews
    lazy var optionsButton = UIButton.option(tintColor: .white, contentInsets: UIEdgeInsets(top: 12, left: 32, bottom: 12, right: 0))
    lazy var headerView = WalletHeaderView(tableView: tableView)
    var sendButton: UIButton {headerView.sendButton}
    var convertButton: UIButton {headerView.convertButton}
    lazy var communIconView: UIView = {
        let view = UIView(width: 40, height: 40, backgroundColor: UIColor.white.withAlphaComponent(0.2), cornerRadius: 20)
        let label = UIImageView(width: 7, height: 16, imageNamed: "slash")
        
        view.addSubview(label)
        label.autoAlignAxis(toSuperviewAxis: .vertical)
        label.autoAlignAxis(toSuperviewAxis: .horizontal)
        return view
    }()
    override func createTableView() -> UITableView {
        let tableView = UITableView(forAutoLayout: ())
        tableView.insetsContentViewsToSafeArea = false
        tableView.contentInsetAdjustmentBehavior = .never
        tableView.showsVerticalScrollIndicator = false
        
        view.addSubview(tableView)
        tableView.autoPinEdgesToSuperviewEdges()
        return tableView
    }
    
    override func setUp() {
        super.setUp()
        
        setLeftNavBarButtonForGoingBack(tintColor: .white)
        
        setRightNavBarButton(with: optionsButton)
        optionsButton.addTarget(self, action: #selector(moreActionsButtonDidTouch(_:)), for: .touchUpInside)
        
        sendButton.addTarget(self, action: #selector(sendButtonDidTouch), for: .touchUpInside)
        convertButton.addTarget(self, action: #selector(convertButtonDidTouch), for: .touchUpInside)
        
        navigationItem.titleView = communIconView
    }
    
    override func bind() {
        super.bind()
        bindControls()
    }
    
    func bindControls() {
        tableView.rx.contentOffset
            .map {$0.y}
            .map {$0 > 16.5 / Config.heightRatio}
            .subscribe(onNext: { showNavBar in
                self.showTitle(showNavBar)
            })
            .disposed(by: disposeBag)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
        navigationController?.navigationBar.isTranslucent = true

        showTitle(tableView.contentOffset.y > 16.5 / Config.heightRatio)
    }
    
    func showTitle(_ show: Bool, animated: Bool = false) {
        showNavigationBar(show, animated: animated) {
            self.optionsButton.tintColor = show ? .black: .white
            self.communIconView.backgroundColor = show ? .appMainColor: UIColor.white.withAlphaComponent(0.2)
        }
    }
    
    // MARK: - Actions
    @objc func sendButtonDidTouch() {
        
    }
    
    @objc func convertButtonDidTouch() {
        
    }
    
    @objc func moreActionsButtonDidTouch(_ sender: CommunButton) {
        
    }
}
