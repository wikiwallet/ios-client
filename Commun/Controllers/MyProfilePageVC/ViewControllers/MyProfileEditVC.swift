//
//  MyProfileEditVC.swift
//  Commun
//
//  Created by Chung Tran on 3/26/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation

class MyProfileEditVC: BaseVerticalStackVC {
    // MARK: - Properties
    var profile: ResponseAPIContentGetProfile?
    
    // MARK: - Subviews
    var spacer: UIView { UIView(height: 2, backgroundColor: .appLightGrayColor)}
    
    // MARK: - Sections
    lazy var generalInfoView = UIView(backgroundColor: .appWhiteColor, cornerRadius: 10)
    
    // MARK: - Methods
    override func setUp() {
        super.setUp()
        title = "my profile".localized().uppercaseFirst
        
        reloadData()
    }
    
    override func bind() {
        super.bind()
        UserDefaults.standard.rx.observe(Data.self, Config.currentUserGetProfileKey)
            .filter {$0 != nil}
            .map {$0!}
            .map {try? JSONDecoder().decode(ResponseAPIContentGetProfile.self, from: $0)}
            .subscribe(onNext: { profile in
                self.profile = profile
                self.reloadData()
            })
            .disposed(by: disposeBag)
    }
    
    override func setUpArrangedSubviews() {
        stackView.addArrangedSubview(generalInfoView)
    }
    
    // MARK: - Data handler
    func reloadData() {
        // general info
        updateGeneralInfo()
    }
    
    func updateGeneralInfo() {
        generalInfoView.removeSubviews()
        let stackView = UIStackView(axis: .vertical, spacing: 0, alignment: .center, distribution: .fill)
        generalInfoView.addSubview(stackView)
        stackView.autoPinEdgesToSuperviewEdges()
        
        let headerView = sectionHeaderView(title: "general info".localized().uppercaseFirst)
        
        let avatarImageView: MyAvatarImageView = {
            let imageView = MyAvatarImageView(size: 120)
            imageView.borderWidth = 5
            imageView.borderColor = .appWhiteColor
            imageView.setToCurrentUserAvatar()
            return imageView
        }()
        
        let coverImageView: UIImageView = {
            let imageView = UIImageView(cornerRadius: 7, contentMode: .scaleAspectFit)
            imageView.borderWidth = 7
            imageView.borderColor = .appWhiteColor
            imageView.setCover(urlString: profile?.coverUrl)
            return imageView
        }()
        
        stackView.addArrangedSubviews([
            headerView,
            avatarImageView,
            coverImageView
        ])
        headerView.widthAnchor.constraint(equalTo: stackView.widthAnchor).isActive = true
        coverImageView.widthAnchor.constraint(equalTo: stackView.widthAnchor, constant: -20).isActive = true
        
        // name
        let spacer1 = spacer
        let nameInfoField = infoField(title: "name".localized().uppercaseFirst, content: Config.currentUser?.name)
        
        stackView.addArrangedSubviews([spacer1, nameInfoField])
        spacer1.widthAnchor.constraint(equalTo: stackView.widthAnchor).isActive = true
        nameInfoField.widthAnchor.constraint(equalTo: stackView.widthAnchor).isActive = true
        
        // username
        let spacer2 = spacer
        let usernameInfoField = infoField(title: "username".localized().uppercaseFirst, content: "@" + (Config.currentUser?.id ?? ""))
        stackView.addArrangedSubviews([spacer2, usernameInfoField])
        spacer2.widthAnchor.constraint(equalTo: stackView.widthAnchor).isActive = true
        usernameInfoField.widthAnchor.constraint(equalTo: stackView.widthAnchor).isActive = true
        
        // bio
        let spacer3 = spacer
        let websiteField = infoField(title: "website".localized().uppercaseFirst, content: nil)
        stackView.addArrangedSubviews([spacer3, websiteField])
        spacer3.widthAnchor.constraint(equalTo: stackView.widthAnchor).isActive = true
        websiteField.widthAnchor.constraint(equalTo: stackView.widthAnchor).isActive = true
        
        // bio
        let spacer4 = spacer
        let bioField = infoField(title: "bio".localized().uppercaseFirst, content: profile?.personal?.biography)
        stackView.addArrangedSubviews([spacer4, bioField])
        spacer4.widthAnchor.constraint(equalTo: stackView.widthAnchor).isActive = true
        bioField.widthAnchor.constraint(equalTo: stackView.widthAnchor).isActive = true
        
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 20, trailing: 0)
    }
    
    // MARK: - View builders
    private func sectionHeaderView(title: String) -> UIStackView {
        let stackView = UIStackView(axis: .horizontal, spacing: 10, alignment: .center, distribution: .fill)
        stackView.autoSetDimension(.height, toSize: 55)
        let label = UILabel.with(text: title, textSize: 17, weight: .semibold)
        let arrow = UIButton.nextArrow()
        stackView.addArrangedSubviews([label, arrow])
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16)
        return stackView
    }
    
    private func infoField(title: String, content: String?) -> UIStackView {
        let stackView = UIStackView(axis: .vertical, spacing: 10, alignment: .leading, distribution: .fill)
        let titleLabel = UILabel.with(text: title, textSize: 12, weight: .medium, textColor: .appGrayColor)
        let contentLabel = UILabel.with(text: content, textSize: 17, weight: .semibold, textColor: .appBlackColor, numberOfLines: 0)
        stackView.addArrangedSubviews([titleLabel, contentLabel])
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 10, leading: 16, bottom: 7, trailing: 16)
        return stackView
    }
}
