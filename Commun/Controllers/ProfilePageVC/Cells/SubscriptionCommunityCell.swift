//
//  CommunityCell.swift
//  Commun
//
//  Created by Chung Tran on 10/29/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation

class SubscriptionCommunityCell: MyCollectionViewCell, CommunityController {
    // MARK: - Properties
    var community: ResponseAPIContentGetCommunity?
    
    // MARK: - Subviews
    lazy var coverImageView: UIImageView = {
        let imageView = UIImageView(cornerRadius: 10)
        imageView.image = .placeholder
        return imageView
    }()
    lazy var avatarImageView: MyAvatarImageView = {
        let avatar = MyAvatarImageView(size: 50)
        avatar.borderWidth = 2
        avatar.borderColor = .white
        return avatar
    }()
    
    lazy var nameLabel = UILabel.with(text: "Behance", textSize: 15, weight: .semibold, textAlignment: .center)
    lazy var membersCountLabel = UILabel.with(text: "12,2k members", textSize: 12, weight: .semibold, textColor: .a5a7bd, textAlignment: .center)
    lazy var joinButton = CommunButton.join
    
    // MARK: - Methods
    override func setUpViews() {
        super.setUpViews()
        contentView.addSubview(coverImageView)
        coverImageView.autoPinEdgesToSuperviewEdges()
        
        let containerView = UIView(backgroundColor: .white, cornerRadius: 10)
        contentView.addSubview(containerView)
        contentView.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 46, left: 5, bottom: 0, right: 5))
        
        contentView.addSubview(avatarImageView)
        avatarImageView.autoPinEdge(toSuperviewEdge: .top, withInset: 20)
        avatarImageView.autoAlignAxis(toSuperviewAxis: .vertical)
        
        containerView.addSubview(nameLabel)
        nameLabel.autoPinEdge(toSuperviewEdge: .top, withInset: 34)
        nameLabel.autoPinEdge(toSuperviewEdge: .leading, withInset: 16)
        nameLabel.autoPinEdge(toSuperviewEdge: .trailing, withInset: 16)
        
        containerView.addSubview(membersCountLabel)
        membersCountLabel.autoPinEdge(.top, to: .bottom, of: nameLabel, withOffset: 5)
        membersCountLabel.autoPinEdge(toSuperviewEdge: .leading, withInset: 16)
        membersCountLabel.autoPinEdge(toSuperviewEdge: .leading, withInset: 16)
        
        containerView.addSubview(joinButton)
        joinButton.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 0, left: 10, bottom: 10, right: 10), excludingEdge: .top)
        
        joinButton.addTarget(self, action: #selector(joinButtonDidTouch), for: .touchUpInside)
    }
    
    override func observe() {
        super.observe()
        observerCommunityChange()
    }
    
    func setUp(with community: ResponseAPIContentGetCommunity) {
        self.community = community
        
    }
    
    @objc func joinButtonDidTouch() {
        toggleJoin()
    }
}
