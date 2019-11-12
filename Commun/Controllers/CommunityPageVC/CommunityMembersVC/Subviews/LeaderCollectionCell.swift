//
//  LeaderCollectionCell.swift
//  Commun
//
//  Created by Chung Tran on 11/7/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation

class LeaderCollectionCell: MyCollectionViewCell, LeaderController {
    // MARK: - Properties
    var leader: ResponseAPIContentGetLeader?
    
    // MARK: - Subviews
    lazy var avatarImageView = LeaderAvatarImageView(size: 56)
    lazy var nameLabel = UILabel.with(text: "bluesnake260", textSize: 15, weight: .semibold, textAlignment: .center)
    lazy var statsLabel = UILabel.with(text: "12,2k points • 50%", textSize: 12, textAlignment: .center)
    lazy var voteButton = CommunButton.default(height: 30, label: "vote".localized().uppercaseFirst)
    
    // MARK: - Methods
    override func setUpViews() {
        super.setUpViews()
        let containerView = UIView(backgroundColor: .white, cornerRadius: 10)
        contentView.addSubview(containerView)
        containerView.autoPinEdgesToSuperviewEdges()
        
        containerView.addSubview(avatarImageView)
        avatarImageView.autoAlignAxis(toSuperviewAxis: .vertical)
        avatarImageView.autoPinEdge(toSuperviewEdge: .top, withInset: 16)
        
        containerView.addSubview(nameLabel)
        nameLabel.autoPinEdge(.top, to: .bottom, of: avatarImageView, withOffset: 10)
        nameLabel.autoPinEdge(toSuperviewEdge: .leading, withInset: 10)
        nameLabel.autoPinEdge(toSuperviewEdge: .trailing, withInset: 10)
        
        containerView.addSubview(statsLabel)
        statsLabel.autoPinEdge(.top, to: .bottom, of: nameLabel, withOffset: 2)
        statsLabel.autoPinEdge(toSuperviewEdge: .leading, withInset: 10)
        statsLabel.autoPinEdge(toSuperviewEdge: .trailing, withInset: 10)
        
        containerView.addSubview(voteButton)
        voteButton.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(inset: 10), excludingEdge: .top)
        voteButton.addTarget(self, action: #selector(voteButtonDidTouch), for: .touchUpInside)
    }
    
    func setUp(with leader: ResponseAPIContentGetLeader) {
        self.leader = leader
        avatarImageView.setAvatar(urlString: leader.avatarUrl, namePlaceHolder: leader.username ?? leader.userId)
        avatarImageView.percent = leader.ratingPercent
        
        nameLabel.text = leader.username ?? leader.userId
        
        let pointsText = NSMutableAttributedString(
            string: "\(leader.rating.kmFormatted) " + "points".localized().uppercaseFirst + " • ",
            attributes: [
                .foregroundColor: UIColor.a5a7bd,
                .font: UIFont.boldSystemFont(ofSize: 12)
            ])
        
        pointsText.append(NSAttributedString(
            string: "\((leader.ratingPercent * 100).rounded(numberOfDecimalPlaces: 0, rule: .up))%",
            attributes: [
                .foregroundColor: UIColor.appMainColor,
                .font: UIFont.boldSystemFont(ofSize: 12)
            ]))
        
        statsLabel.attributedText = pointsText
        
        // joinButton
        let voted = leader.isVoted
        voteButton.backgroundColor = voted ? #colorLiteral(red: 0.9525656104, green: 0.9605062604, blue: 0.9811610579, alpha: 1): .appMainColor
        voteButton.setTitleColor(voted ? .appMainColor: .white , for: .normal)
        voteButton.setTitle(voted ? "voted".localized().uppercaseFirst : "vote".localized().uppercaseFirst, for: .normal)
    }
    
    @objc func voteButtonDidTouch() {
        toggleVote()
    }
}
