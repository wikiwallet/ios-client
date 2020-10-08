//
//  CMBanUserBottomSheet.swift
//  Commun
//
//  Created by Chung Tran on 10/8/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation

class CMBanUserBottomSheet: CMBottomSheet {
    override func fittingHeightInContainer(safeAreaFrame: CGRect) -> CGFloat {
        super.fittingHeightInContainer(safeAreaFrame: safeAreaFrame) + 100
    }
    
    let banningUser: ResponseAPIContentGetProfile
    var reason: String? {
        didSet {
            chooseReasonButton.isHidden = reason != nil
            banReasonView.isHidden = reason == nil
            banReasonLabel.text = reason
        }
    }
    
    lazy var stackView = UIStackView(axis: .vertical, spacing: 0, alignment: .fill, distribution: .fill)
    
    lazy var chooseReasonButton: UIView = {
        let view = UIView.withStackView(axis: .horizontal, spacing: 10, alignment: .center, distribution: .fill)
        
        let arrow = UIButton.nextArrow()
        arrow.isUserInteractionEnabled = false
        
        view.innerStackView?.addArrangedSubview(UILabel.with(text: "choose your ban reason".localized().uppercaseFirst, textSize: 15, weight: .semibold, textColor: .appMainColor, numberOfLines: 0))
        view.innerStackView?.addArrangedSubview(arrow)
        return view.onTap(self, action: #selector(selectReasonButtonDidTouch))
    }()
    
    lazy var banReasonView: UIView = {
        let view = UIView.withStackView(axis: .vertical, spacing: 5, alignment: .fill, distribution: .fill)
        view.innerStackView?.addArrangedSubview(UILabel.with(text: "ban reason".localized().uppercaseFirst, textSize: 13, weight: .medium, textColor: .appGrayColor))
        view.innerStackView?.addArrangedSubview(banReasonLabel)
        view.isHidden = true
        return view
    }()
    lazy var banReasonLabel = UILabel.with(textSize: 15, weight: .semibold, numberOfLines: 0)
    
    init(banningUser: ResponseAPIContentGetProfile) {
        self.banningUser = banningUser
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setUp() {
        super.setUp()
        let headerLabel = UILabel.with(text: "ban user".localized().uppercaseFirst, textSize: 15, weight: .bold)
        headerStackView.insertArrangedSubview(headerLabel, at: 0)
        
        // set up action
        scrollView.contentView.addSubview(stackView)
        stackView.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 16, left: 10, bottom: 16, right: 10))
        
        let label = UILabel.with(text: "are you sure want to ban this user?".localized().uppercaseFirst, numberOfLines: 0)
        
        let userWrapper: UIView = {
            let view = UIView(backgroundColor: .appWhiteColor, cornerRadius: 10)
            let stackView = UIStackView(axis: .vertical, spacing: 0, alignment: .fill, distribution: .fill)
            view.addSubview(stackView)
            stackView.autoPinEdgesToSuperviewEdges()
            
            let cell = SubscribersCell(forAutoLayout: ())
            cell.configureToUseAsNormalView()
            cell.setUp(with: banningUser)
            cell.actionButton.isHidden = true
            
            let spacer = UIView.spacer(height: 1, backgroundColor: .appLightGrayColor)
            
            stackView.addArrangedSubviews([cell, spacer, chooseReasonButton, banReasonView])
            
            return view
        }()
        
        let yesButton: UILabel = {
            let yesButton = UILabel.with(text: "yes, propose to ban".localized().uppercaseFirst, textSize: 15, weight: .medium, textColor: .appRedColor, numberOfLines: 0, textAlignment: .center)
            yesButton.backgroundColor = .white
            yesButton.cornerRadius = 10
            yesButton.autoSetDimension(.height, toSize: 50)
            return yesButton.onTap(self, action: #selector(yesButtonDidTouch))
        }()
        
        let noButton: UILabel = {
            let noButton = UILabel.with(text: "no, keep user".localized().uppercaseFirst, textSize: 15, weight: .medium, numberOfLines: 0, textAlignment: .center)
            noButton.backgroundColor = .white
            noButton.cornerRadius = 10
            noButton.autoSetDimension(.height, toSize: 50)
            return noButton.onTap(self, action: #selector(noButtonDidTouch))
        }()
        
        stackView.addArrangedSubviews([label, userWrapper, yesButton, noButton])
        stackView.setCustomSpacing(16, after: label)
        stackView.setCustomSpacing(30, after: userWrapper)
        stackView.setCustomSpacing(10, after: yesButton)
        
        disableSwipeDownToDismiss()
    }
    
    @objc func selectReasonButtonDidTouch() {
        let vc = UserReportVC(user: banningUser)
        vc.completion = { (reasons, otherReason) in
            let reasonCombined = reasons.inlineString(otherReason: otherReason)
            self.reason = reasonCombined
        }
        let nc = SwipeNavigationController(rootViewController: vc)
        
        nc.modalPresentationStyle = .custom
        nc.transitioningDelegate = vc
        present(nc, animated: true, completion: nil)
    }
    
    @objc func yesButtonDidTouch() {
        guard let reason = reason else {
            showAlert(title: "no reason".localized().uppercaseFirst, message: "you must choose at least 1 reason to ban this user".localized().uppercaseFirst)
            return
        }
        
    }
    
    @objc func noButtonDidTouch() {
        back()
    }
}

class UserReportVC: ReportVC {
    let user: ResponseAPIContentGetProfile
    var completion: ((_ reason: [BlockchainManager.ReportReason], _ otherReason: String?) -> Void)?
    
    // MARK: - Initializers
    init(user: ResponseAPIContentGetProfile) {
        self.user = user
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Methods
    override func sendButtonDidTouch() {
        guard checkValues()
        else {
            return
        }
        dismiss(animated: true) {
            self.completion?(self.choosedReasons, self.otherReason?.trimmed.replacingOccurrences(of: "\n", with: " "))
        }
    }
}
