//
//  ArticleCardView.swift
//  Commun
//
//  Created by Chung Tran on 8/13/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation

class ArticleCardView: MyView {
    // MARK: - Subviews
    lazy var cardImageView: UIImageView = {
        let imageView = UIImageView(forAutoLayout: ())

        let blackoutView = UIView(forAutoLayout: ())
        imageView.addSubview(blackoutView)
        blackoutView.backgroundColor = UIColor.appBlackColor.withAlphaComponent(0.2)
        blackoutView.autoPinEdgesToSuperviewEdges()

        imageView.cornerRadius = 10
        imageView.contentMode = .scaleAspectFill
        
        // dim card image
        let maskView = UIView(forAutoLayout: ())
        maskView.cornerRadius = 10
        maskView.backgroundColor = .appBlackColor
        maskView.alpha = 0.4
        imageView.addSubview(maskView)
        maskView.autoPinEdgesToSuperviewEdges()
        return imageView
    }()
    
    lazy var titleLabel: UILabel = {
        let label = UILabel.with(textSize: 21, weight: .bold, textColor: .appWhiteColor, numberOfLines: 2)
        label.textAlignment = .center
        return label
    }()
    
    lazy var readButton: UIView = {
        let button = UIView(height: 34)
        button.backgroundColor = .appWhiteColor
        button.cornerRadius = 17
        
        let imageView = UIImageView(width: 24, height: 24)
        imageView.image = UIImage(named: "fire")
        button.addSubview(imageView)
        
        imageView.autoAlignAxis(toSuperviewAxis: .horizontal)
        imageView.autoPinEdge(toSuperviewEdge: .left, withInset: 10)
        imageView.autoPinEdge(toSuperviewEdge: .top, withInset: 5)
        imageView.autoPinEdge(toSuperviewEdge: .bottom, withInset: 5)
        
        let label = UILabel.with(text: "read".localized().uppercaseFirst, textSize: 15, weight: .semibold)
        button.addSubview(label)
        label.autoAlignAxis(toSuperviewAxis: .horizontal)
        label.autoPinEdge(toSuperviewEdge: .trailing, withInset: 12)
        
        label.autoPinEdge(.leading, to: .trailing, of: imageView, withOffset: 6)
        
        return button
    }()

    // MARK: - Methods
    
    override func commonInit() {
        super.commonInit()
        // card imageview
        cardImageView.widthAnchor.constraint(equalTo: cardImageView.heightAnchor, multiplier: 345/200)
            .isActive = true
        addSubview(cardImageView)
        cardImageView.autoPinEdgesToSuperviewEdges()
        
        let titleButtonContainerView = UIView(forAutoLayout: ())
        titleButtonContainerView.backgroundColor = .clear
        addSubview(titleButtonContainerView)
        
        titleButtonContainerView.autoAlignAxis(.horizontal, toSameAxisOf: cardImageView)
        titleButtonContainerView.autoAlignAxis(.vertical, toSameAxisOf: cardImageView)
        titleButtonContainerView.autoPinEdge(.leading, to: .leading, of: cardImageView, withOffset: 16)
        titleButtonContainerView.autoPinEdge(.trailing, to: .trailing, of: cardImageView, withOffset: -16)
        
        titleButtonContainerView.addSubview(titleLabel)
        titleLabel.autoPinEdgesToSuperviewEdges(with: .zero, excludingEdge: .bottom)
        
        titleButtonContainerView.addSubview(readButton)
        readButton.autoAlignAxis(toSuperviewAxis: .vertical)
        readButton.autoPinEdge(toSuperviewEdge: .bottom)
        
        readButton.autoPinEdge(.top, to: .bottom, of: titleLabel, withOffset: 16)
    }
    
    func setUp(with post: ResponseAPIContentGetPost) {
        cardImageView.image = UIImage(named: "article-placeholder")

        titleLabel.text = post.document?.attributes?.title

        if let coverString = post.document?.attributes?.coverUrl,
            let coverURL = URL(string: coverString) {
            cardImageView.sd_setImageCachedError(with: coverURL, completion: nil)
        }
    }
}
