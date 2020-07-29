//
//  MyProfileDetailVC+Layout.swift
//  Commun
//
//  Created by Chung Tran on 7/23/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation

extension MyProfileDetailVC {
    func updateGeneralInfo() {
        generalInfoView.removeSubviews()
        let stackView = UIStackView(axis: .vertical, spacing: 0, alignment: .center, distribution: .fill)
        generalInfoView.addSubview(stackView)
        stackView.autoPinEdgesToSuperviewEdges()
        
        let headerView = sectionHeaderView(title: "general info".localized().uppercaseFirst, action: #selector(editGeneralInfoButtonDidTouch))
        
        let avatarImageView: MyAvatarImageView = {
            let imageView = MyAvatarImageView(size: 120)
            imageView.setToCurrentUserAvatar()
            return imageView
        }()
        
        let coverImageView: UIImageView = {
            let imageView = UIImageView(cornerRadius: 7, contentMode: .scaleToFill)
            imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor, multiplier: 335 / 150).isActive = true
            imageView.setCover(urlString: profile?.coverUrl, namePlaceHolder: "cover-placeholder")
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
        let spacer1 = separator()
        let nameInfoField = infoField(title: "name".localized().uppercaseFirst, content: profile?.personal?.contacts?.fullName)
        
        stackView.addArrangedSubviews([spacer1, nameInfoField])
        spacer1.widthAnchor.constraint(equalTo: stackView.widthAnchor).isActive = true
        nameInfoField.widthAnchor.constraint(equalTo: stackView.widthAnchor).isActive = true
        
        // username
        let spacer2 = separator()
        let usernameInfoField = infoField(title: "username".localized().uppercaseFirst, content: "@" + (Config.currentUser?.name ?? ""))
        stackView.addArrangedSubviews([spacer2, usernameInfoField])
        spacer2.widthAnchor.constraint(equalTo: stackView.widthAnchor).isActive = true
        usernameInfoField.widthAnchor.constraint(equalTo: stackView.widthAnchor).isActive = true
        
        // bio
        let spacer3 = separator()
        let websiteField = infoField(title: "website".localized().uppercaseFirst, content: profile?.personal?.contacts?.websiteUrl)
        stackView.addArrangedSubviews([spacer3, websiteField])
        spacer3.widthAnchor.constraint(equalTo: stackView.widthAnchor).isActive = true
        websiteField.widthAnchor.constraint(equalTo: stackView.widthAnchor).isActive = true
        
        // bio
        let spacer4 = separator()
        let bioField = infoField(title: "bio".localized().uppercaseFirst, content: profile?.personal?.biography)
        stackView.addArrangedSubviews([spacer4, bioField])
        spacer4.widthAnchor.constraint(equalTo: stackView.widthAnchor).isActive = true
        bioField.widthAnchor.constraint(equalTo: stackView.widthAnchor).isActive = true
        
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 20, trailing: 0)
        
        stackView.setCustomSpacing(29, after: avatarImageView)
        stackView.setCustomSpacing(12, after: coverImageView)
        stackView.setCustomSpacing(0, after: spacer1)
    }
    
    func updateContacts() {
        contactsView.removeSubviews()
        let stackView = UIStackView(axis: .vertical, spacing: 0, alignment: .center, distribution: .fill)
        contactsView.addSubview(stackView)
        stackView.autoPinEdgesToSuperviewEdges()
        
        let headerView = sectionHeaderView(title: "contacts".localized().uppercaseFirst, action: #selector(editContactsButtonDidTouch))
        stackView.addArrangedSubview(headerView)
        headerView.widthAnchor.constraint(equalTo: stackView.widthAnchor).isActive = true
        
        // whatsapp
        addContactField(icon: "whatsapp-icon", serviceName: "Whatsapp", username: profile?.personal?.contacts?.whatsApp?.value, to: stackView)
        
        // telegram
        addContactField(icon: "telegram-icon", serviceName: "Telegram", username: profile?.personal?.contacts?.telegram?.value, to: stackView)
        
        // wechat
        addContactField(icon: "wechat-icon", serviceName: "WeChat", username: profile?.personal?.contacts?.weChat?.value, to: stackView)
    }
    
    func updateLinks() {
        linksView.removeSubviews()
        let stackView = UIStackView(axis: .vertical, spacing: 0, alignment: .center, distribution: .fill)
        linksView.addSubview(stackView)
        stackView.autoPinEdgesToSuperviewEdges()
        
        let headerView = sectionHeaderView(title: "links".localized().uppercaseFirst, action: #selector(editLinksButtonDidTouch))
        stackView.addArrangedSubview(headerView)
        headerView.widthAnchor.constraint(equalTo: stackView.widthAnchor).isActive = true
        
        // twitter
        addContactField(icon: "twitter-icon", serviceName: "Twitter", username: profile?.personal?.contacts?.twitter?.value, to: stackView)
        
        // facebook
        addContactField(icon: "facebook-icon", serviceName: "Facebook", username: profile?.personal?.contacts?.facebook?.value, to: stackView)
        
        // youtube
        addContactField(icon: "youtube-icon", serviceName: "Youtube", username: profile?.personal?.contacts?.youtube?.value, to: stackView)
        
        // instagram
        addContactField(icon: "instagram-icon", serviceName: "Instagram", username: profile?.personal?.contacts?.instagram?.value, to: stackView)
        
        // github
        addContactField(icon: "github-icon", serviceName: "Github", username: profile?.personal?.contacts?.gitHub?.value, to: stackView)
    }
    
    // MARK: - View builders
    private func sectionHeaderView(title: String, action: Selector) -> UIStackView {
        let stackView = UIStackView(axis: .horizontal, spacing: 10, alignment: .center, distribution: .fill)
        stackView.autoSetDimension(.height, toSize: 55)
        let label = UILabel.with(text: title, textSize: 17, weight: .semibold)
        let arrow = UIButton.nextArrow()
        stackView.addArrangedSubviews([label, arrow])
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16)
        
        arrow.addTarget(self, action: action, for: .touchUpInside)
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
    
    private func addContactField(icon: String?, serviceName: String, username: String?, to parentStackView: UIStackView) {
        let stackView = UIStackView(axis: .horizontal, spacing: 16, alignment: .center, distribution: .fill)
        let icon = UIImageView(width: 20, height: 20, imageNamed: icon)
        let label = UILabel.with(textSize: 14, numberOfLines: 2)
        label.attributedText = NSMutableAttributedString()
            .text(serviceName, size: 14, weight: .semibold, color: .appGrayColor)
            .text("\n")
            .text("@" + (username ?? ""), size: 14, weight: .semibold, color: .appMainColor)
            .withParagraphStyle(lineSpacing: 5)
        stackView.addArrangedSubviews([icon, label])
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16)
        
        let spacer1 = separator()
        parentStackView.addArrangedSubviews([spacer1, stackView])
        spacer1.widthAnchor.constraint(equalTo: parentStackView.widthAnchor).isActive = true
        stackView.widthAnchor.constraint(equalTo: parentStackView.widthAnchor).isActive = true
    }
}
