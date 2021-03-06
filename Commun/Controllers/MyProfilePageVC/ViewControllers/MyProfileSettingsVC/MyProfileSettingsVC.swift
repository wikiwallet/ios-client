//
//  MyProfileSettingsVC.swift
//  Commun
//
//  Created by Chung Tran on 11/1/19.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import Foundation
import RxSwift

class MyProfileSettingsVC: BaseViewController {
    // MARK: - Properties

    // MARK: - Subviews
    lazy var scrollView = ContentHuggingScrollView(scrollableAxis: .vertical)
    var stackView: UIStackView!

    lazy var userView: UIView = {
        let view = UIView(height: 80, backgroundColor: .appWhiteColor, cornerRadius: 10)

        let avatarImage = MyAvatarImageView(size: 50)
        avatarImage.observeCurrentUserAvatar().disposed(by: disposeBag)
        view.addSubview(avatarImage)
        avatarImage.autoPinEdge(toSuperviewEdge: .leading, withInset: 16)
        avatarImage.autoAlignAxis(toSuperviewAxis: .horizontal)

        let userLabel = UILabel.with(text: Config.currentUser?.name, textSize: 20, weight: .bold)
        view.addSubview(userLabel)
        userLabel.autoPinEdge(.top, to: .top, of: avatarImage, withOffset: 4)
        userLabel.autoPinEdge(.leading, to: .trailing, of: avatarImage, withOffset: 10)

        let userIdLabel = UILabel.with(text: "@" + (Config.currentUser?.id ?? ""), textSize: 12, textColor: .appMainColor)
        view.addSubview(userIdLabel)
        userIdLabel.autoPinEdge(.top, to: .bottom, of: userLabel, withOffset: 3)
        userIdLabel.autoPinEdge(.leading, to: .trailing, of: avatarImage, withOffset: 10)

        let button = UIButton.nextArrow()
        button.isUserInteractionEnabled = false
        view.addSubview(button)
        button.autoPinEdge(toSuperviewEdge: .trailing, withInset: 16)
        button.autoAlignAxis(toSuperviewAxis: .horizontal)
        button.autoPinEdge(.leading, to: .trailing, of: userLabel, withOffset: 10)

        view.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(showEditProfile))

        view.addGestureRecognizer(tap)

        return view
    }()

    override func setUp() {
        super.setUp()
        view.backgroundColor = .appLightGrayColor
        title = "settings".localized().uppercaseFirst

        // backButton
        setLeftNavBarButtonForGoingBack()

        // scrollView
        view.addSubview(scrollView)
        scrollView.autoPinEdgesToSuperviewEdges()

        scrollView.contentView.addSubview(userView)
        userView.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 20, left: 10, bottom: 0, right: 10), excludingEdge: .bottom)

        // add actions
        stackView = stackViewWithActions(actions: [
            .iconFirst(
                title: "notifications".localized().uppercaseFirst,
                textWeight: .regular,
                iconName: "profile_options_notifications",
                handle: { self.showNotificationSettings() },
                showNextButton: true
            ),
            .iconFirst(
                title: "interface language".localized().uppercaseFirst,
                textWeight: .regular,
                iconName: "profile_options_interface_language",
                handle: { self.selectLanguage() },
                showNextButton: true
            ),
            .iconFirst(
                title: "password".localized().uppercaseFirst,
                textWeight: .regular,
                iconName: "profile_options_password",
                handle: { self.showPassword() },
                showNextButton: true
            )
        ])

        scrollView.contentView.addSubview(stackView)
        stackView.autoPinEdge(toSuperviewEdge: .leading, withInset: 10)
        stackView.autoPinEdge(toSuperviewEdge: .trailing, withInset: 10)
        stackView.autoPinEdge(.top, to: .bottom, of: userView, withOffset: 20)

        let logoutButton = UIButton(height: 50, label: "logout".localized().uppercaseFirst, backgroundColor: .appWhiteColor, textColor: .appRedColor, cornerRadius: 10)
        logoutButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 15)
        logoutButton.addTarget(self, action: #selector(logout), for: .touchUpInside)

        scrollView.contentView.addSubview(logoutButton)
        logoutButton.autoPinEdge(.top, to: .bottom, of: stackView, withOffset: 20)
        logoutButton.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(inset: 10), excludingEdge: .top)

        let versionBuildLabel = UILabel.with(text: Bundle.main.fullVersion, textSize: .adaptive(width: 13.0), textColor: .appGrayColor, textAlignment: .center)

        scrollView.contentView.addSubview(versionBuildLabel)
        versionBuildLabel.autoAlignAxis(.vertical, toSameAxisOf: scrollView.contentView)
        
        let offset: CGFloat = tabBarHeight + 15.0
        versionBuildLabel.autoPinEdge(.bottom, to: .bottom, of: view, withOffset: -offset)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if stackView.arrangedSubviews.count == 1 {
            stackView.arrangedSubviews.first?.roundCorners(UIRectCorner(arrayLiteral: .topLeft, .topRight, .bottomLeft, .bottomRight), radius: 10)
        } else {
            stackView.arrangedSubviews.first?.roundCorners(UIRectCorner(arrayLiteral: .topLeft, .topRight), radius: 10)
            stackView.arrangedSubviews.last?.roundCorners(UIRectCorner(arrayLiteral: .bottomLeft, .bottomRight), radius: 10)
        }
    }

    func stackViewWithActions(actions: [CMActionSheet.Action]) -> UIStackView {
        let stackView = UIStackView(axis: .vertical, spacing: 2, alignment: .fill, distribution: .fill)
        
        for action in actions {
            let actionView = action.view
            actionView.isUserInteractionEnabled = true
            let tap = CMActionSheet.TapGesture(target: self, action: #selector(actionViewDidTouch(_:)))
            tap.action = action
            actionView.addGestureRecognizer(tap)

            stackView.addArrangedSubview(actionView)
        }
        return stackView
    }
}
