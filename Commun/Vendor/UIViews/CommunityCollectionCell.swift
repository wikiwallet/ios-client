//
//  CommunityCollectionCell.swift
//  Commun
//
//  Created by Chung Tran on 11/26/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation
import RxSwift

protocol CommunityCollectionCellDelegate: class {
    func buttonFollowDidTouch<T: CommunityType>(community: T)
    func forceFollow<T: CommunityType>(_ value: Bool, community: T)
}

class CommunityCollectionCell<T: CommunityType>: MyCollectionViewCell {
    // MARK: - Properties
    var community: T?
    weak var delegate: CommunityCollectionCellDelegate?
    
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
    lazy var descriptionLabel = UILabel.with(text: "12,2k members", textSize: 12, weight: .semibold, textColor: .a5a7bd, numberOfLines: 0, textAlignment: .center)
    lazy var joinButton = CommunButton.join
    
    // MARK: - Methods
    override func setUpViews() {
        super.setUpViews()
        contentView.addSubview(coverImageView)
        coverImageView.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 0, left: 0, bottom: 16, right: 0))
        
        let containerView = UIView(backgroundColor: .white, cornerRadius: 10)
        contentView.addSubview(containerView)
        containerView.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 46, left: 5, bottom: 16, right: 5))
        
        contentView.addSubview(avatarImageView)
        avatarImageView.autoPinEdge(toSuperviewEdge: .top, withInset: 20)
        avatarImageView.autoAlignAxis(toSuperviewAxis: .vertical)
        
        containerView.addSubview(nameLabel)
        nameLabel.autoPinEdge(toSuperviewEdge: .top, withInset: 34)
        nameLabel.autoPinEdge(toSuperviewEdge: .leading, withInset: 16)
        nameLabel.autoPinEdge(toSuperviewEdge: .trailing, withInset: 16)
        
        containerView.addSubview(descriptionLabel)
        descriptionLabel.autoPinEdge(.top, to: .bottom, of: nameLabel, withOffset: 5)
        descriptionLabel.autoPinEdge(toSuperviewEdge: .leading, withInset: 16)
        descriptionLabel.autoPinEdge(toSuperviewEdge: .trailing, withInset: 16)
        
        containerView.addSubview(joinButton)
        joinButton.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 0, left: 10, bottom: 10, right: 10), excludingEdge: .top)

        containerView.addShadow(ofColor: UIColor(red: 176, green: 176, blue: 204)!, radius: 25, offset: CGSize(width: 0, height: 10), opacity: 0.25)
        
        joinButton.addTarget(self, action: #selector(joinButtonDidTouch), for: .touchUpInside)
    }
    
    // MARK: - Methods
    func setUp(with community: T) {
        self.community = community
        self.avatarImageView.setAvatarDetectGif(with: community.avatarUrl, placeholderName: community.name)
        self.coverImageView.setImageDetectGif(with: community.coverUrl)
        
        nameLabel.text = community.name
        
        descriptionLabel.text = "\(Double(community.subscribersCount ?? 0).kmFormatted) " + "members".localized().uppercaseFirst
        
        // joinButton
        let joined = community.isSubscribed ?? false
        joinButton.backgroundColor = joined ? #colorLiteral(red: 0.9525656104, green: 0.9605062604, blue: 0.9811610579, alpha: 1): .appMainColor
        joinButton.setTitleColor(joined ? .appMainColor: .white , for: .normal)
        joinButton.setTitle((joined ? "following" : "follow").localized().uppercaseFirst, for: .normal)
        joinButton.isEnabled = !(community.isBeingJoined ?? false)
    }
    
    @objc func joinButtonDidTouch() {
        guard let community = community else {return}
        delegate?.buttonFollowDidTouch(community: community)
    }
}

extension CommunityCollectionCellDelegate where Self: BaseViewController {
    func buttonFollowDidTouch<T: CommunityType>(community: T) {
        var community = community
        // for reverse
        let originIsSubscribed = community.isSubscribed ?? false
        
        // set value
        community.setIsSubscribed(!originIsSubscribed)
        community.isBeingJoined = true
        
        // notify changes
        community.notifyChanged()
        
        let request: Completable
        
        if originIsSubscribed {
            request = RestAPIManager.instance.unfollowCommunity(community.communityId)
                .flatMapToCompletable()
        }
        else {
            request = RestAPIManager.instance.followCommunity(community.communityId)
                .flatMapToCompletable()
        }
        
        request
            .subscribe(onCompleted: {
                // re-enable state
                community.isBeingJoined = false
                community.notifyChanged()
                
            }) { [weak self] (error) in
                // reverse change
                community.setIsSubscribed(originIsSubscribed)
                community.isBeingJoined = false
                community.notifyChanged()
                
                // show error
                self?.showError(error)
            }
            .disposed(by: disposeBag)
    }
    
    func forceFollow<T: CommunityType>(_ value: Bool, community: T) {
        var community = community
        
        community.isSubscribed = !value
        
        buttonFollowDidTouch(community: community)
    }
}
