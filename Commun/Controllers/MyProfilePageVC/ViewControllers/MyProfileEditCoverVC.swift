//
//  MyProfileEditCoverVC.swift
//  Commun
//
//  Created by Chung Tran on 3/26/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation

class MyProfileEditCoverVC: BaseViewController {
    // MARK: - Properties
    var joinedDateString: String?
    var coverImageViewAspectRatioConstraint: NSLayoutConstraint?
    var completion: ((UIImage?) -> Void)?
    
    // MARK: - Subviews
    lazy var scrollView = ContentHuggingScrollView(scrollableAxis: .vertical)
    lazy var coverImage = UIImageView(imageNamed: "dankmeme_facebook")
    
    // MARK: - Methods
    override func setUp() {
        super.setUp()
        title = "change position".localized().uppercaseFirst
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelButtonDidTap(_:)))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButtonDidTap(_:)))
        
        scrollView.showsVerticalScrollIndicator = false
        view.addSubview(scrollView)
        scrollView.autoPinEdgesToSuperviewEdges(with: .zero, excludingEdge: .bottom)
        scrollView.widthAnchor.constraint(equalTo: scrollView.heightAnchor, multiplier: 414 / 158)
            .isActive = true
        
        scrollView.contentView.addSubview(coverImage)
        coverImage.autoPinEdgesToSuperviewEdges()
        
        coverImageViewAspectRatioConstraint = coverImage.heightAnchor.constraint(equalTo: coverImage.widthAnchor, multiplier: coverImage.image!.size.height / coverImage.image!.size.width)
        coverImageViewAspectRatioConstraint?.isActive = true
        
        coverImage.widthAnchor.constraint(equalTo: view.widthAnchor)
            .isActive = true
        
        let dragToMoveTipView: UIView = {
            let view = UIView(backgroundColor: UIColor.appBlackColor.withAlphaComponent(0.2), cornerRadius: 4)
            let imageView = UIImageView(width: 16, height: 16, imageNamed: "ProfilePageCoverDragIcon")
            view.addSubview(imageView)
            imageView.autoPinEdge(toSuperviewEdge: .leading, withInset: 12)
            imageView.autoAlignAxis(toSuperviewAxis: .horizontal)
            
            let label = UILabel.with(text: "drag to move cover photo".localized().uppercaseFirst, textSize: 15, textColor: .appWhiteColor)
            view.addSubview(label)
            label.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 12), excludingEdge: .leading)
            label.autoPinEdge(.leading, to: .trailing, of: imageView, withOffset: 6)
            return view
        }()
        view.addSubview(dragToMoveTipView)
        dragToMoveTipView.autoAlignAxis(.horizontal, toSameAxisOf: scrollView)
        dragToMoveTipView.autoAlignAxis(.vertical, toSameAxisOf: scrollView)
        
        let avatarImageView = MyAvatarImageView(size: 50)
        avatarImageView.setToCurrentUserAvatar()
        
        view.addSubview(avatarImageView)
        avatarImageView.autoPinEdge(.top, to: .bottom, of: scrollView, withOffset: 16)
        avatarImageView.autoPinEdge(toSuperviewEdge: .leading, withInset: 16)
        
        let userNameLabel = UILabel.with(text: Config.currentUser?.name, textSize: 19, weight: .bold)
        view.addSubview(userNameLabel)
        userNameLabel.autoPinEdge(.top, to: .top, of: avatarImageView)
        userNameLabel.autoPinEdge(.leading, to: .trailing, of: avatarImageView, withOffset: 10)
        
        let joinDateLabel = UILabel.with(text: Formatter.joinedText(with: joinedDateString), textSize: 12, weight: .semibold, textColor: .appGrayColor)
        view.addSubview(joinDateLabel)
        joinDateLabel.autoPinEdge(.top, to: .bottom, of: userNameLabel, withOffset: 4)
        joinDateLabel.autoPinEdge(.leading, to: .trailing, of: avatarImageView, withOffset: 10)
    }
    
    func updateWithImage(_ image: UIImage) {
        coverImage.image = image
        coverImageViewAspectRatioConstraint?.isActive = false
        
        coverImageViewAspectRatioConstraint = coverImage.heightAnchor.constraint(equalTo: coverImage.widthAnchor, multiplier: image.size.height / image.size.width)
        coverImageViewAspectRatioConstraint?.isActive = true
    }
    
    @objc func cancelButtonDidTap(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func doneButtonDidTap(_ sender: Any) {
        let image = scrollView.cropImageView(coverImage, disableHorizontal: true)
        completion?(image)
    }
}
