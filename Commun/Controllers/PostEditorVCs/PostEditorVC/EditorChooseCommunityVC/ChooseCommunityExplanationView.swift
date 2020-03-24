//
//  ChooseCommunityExplanationView.swift
//  Commun
//
//  Created by Chung Tran on 3/19/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation

class ChooseCommunityExplanationView: MyTableHeaderView {
    lazy var closeButton = UIButton.close(size: 26, imageName: "close-x", backgroundColor: .clear, tintColor: .a5a7bd)
    lazy var learnMoreButton = UIButton(width: 20, height: 20)
    
    override func commonInit() {
        super.commonInit()
        
        let containerView = UIView(backgroundColor: .white)
        containerView.backgroundColor = .white
        containerView.cornerRadius = 6
        addSubview(containerView)
        containerView.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 0, left: 0, bottom: 10, right: 0))
        
        containerView.addSubview(closeButton)
        closeButton.autoPinTopAndTrailingToSuperView(inset: 6)
        
        let headerLabel = UILabel.with(text: "communiries".localized().uppercaseFirst, textSize: 15, weight: .bold)
        containerView.addSubview(headerLabel)
        headerLabel.autoPinEdge(toSuperviewEdge: .leading, withInset: 15)
        headerLabel.autoPinEdge(toSuperviewEdge: .top, withInset: 12)
        
        learnMoreButton.setImage(UIImage(named: "choose-community-learn-more"), for: .normal)
        containerView.addSubview(learnMoreButton)
        learnMoreButton.autoPinEdge(.leading, to: .trailing, of: headerLabel, withOffset: 10)
        learnMoreButton.autoAlignAxis(.horizontal, toSameAxisOf: headerLabel)
        
        let descriptionLabel = UILabel.with(text: "choose community in which you want to create a post".localized().uppercaseFirst, textSize: 12, weight: .medium, textColor: .a5a7bd, numberOfLines: 0)
        containerView.addSubview(descriptionLabel)
        descriptionLabel.autoPinEdge(toSuperviewEdge: .leading, withInset: 15)
        descriptionLabel.autoPinEdge(toSuperviewEdge: .trailing, withInset: 15)
        
        descriptionLabel.autoPinEdge(.top, to: .bottom, of: headerLabel, withOffset: 6)
        descriptionLabel.autoPinEdge(toSuperviewEdge: .bottom, withInset: 15)
    }
}