//
//  WelcomeItemVC.swift
//  Commun
//
//  Created by Chung Tran on 3/25/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation

class WelcomeItemVC: BaseViewController {
    override var prefersNavigationBarStype: BaseViewController.NavigationBarStyle {.embeded}
    // MARK: - Constants
    let spacing: CGFloat = 16
    
    // MARK: - Properties
    let index: Int
    var imageViewHeightConstraint: NSLayoutConstraint?
    
    // MARK: - Subviews
    lazy var imageView = UIImageView(imageNamed: "image-welcome-item-\(index)", contentMode: .scaleAspectFit)
    lazy var titleLabel = UILabel.with(textSize: 36, numberOfLines: 0, textAlignment: .center)
    lazy var descriptionLabel = UILabel.with(textSize: 17, weight: .medium, textColor: .a5a7bd, numberOfLines: 0, textAlignment: .center)
    
    // MARK: - Initializers
    init(index: Int) {
        self.index = index
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Methods
    override func setUp() {
        super.setUp()
        
        view.addSubview(imageView)
        imageView.autoPinEdgesToSuperviewEdges(with: .zero, excludingEdge: .bottom)
        imageView.setContentHuggingPriority(.defaultLow, for: .vertical)
        
        view.addSubview(titleLabel)
        titleLabel.autoPinEdge(.top, to: .bottom, of: imageView, withOffset: spacing)
        titleLabel.autoAlignAxis(toSuperviewAxis: .vertical)
        
        titleLabel.autoPinEdge(toSuperviewEdge: .leading, withInset: 60, relation: .greaterThanOrEqual)
        titleLabel.autoPinEdge(toSuperviewEdge: .trailing, withInset: 60, relation: .greaterThanOrEqual)
        titleLabel.setContentHuggingPriority(.required, for: .vertical)
        
        let titleAString: NSAttributedString
        switch index {
        case 1:
            titleAString = NSMutableAttributedString()
                .text("all-in-one".localized().uppercaseFirst, size: .adaptive(height: 36), weight: .bold)
                .text("\n")
                .text("social network".localized().uppercaseFirst, size: .adaptive(height: 36))
        case 2:
            titleAString = NSMutableAttributedString()
                .text("owned".localized().uppercaseFirst, size: .adaptive(height: 36), weight: .bold)
                .text(" ", size: .adaptive(height: 36))
                .text("by users".localized().uppercaseFirst, size: .adaptive(height: 36))
        default:
            titleAString = NSMutableAttributedString()
                .text("welcome".localized().uppercaseFirst, size: .adaptive(height: 36))
                .text("\n")
                .text("to".localized().uppercaseFirst, size: .adaptive(height: 36))
                .text(" ")
                .text("Commun /", size: .adaptive(height: 36), weight: .bold, color: .appMainColor)
        }
        titleLabel.attributedText = titleAString
        
        view.addSubview(descriptionLabel)
        descriptionLabel.autoPinEdge(.top, to: .bottom, of: titleLabel, withOffset: spacing)
        descriptionLabel.autoAlignAxis(toSuperviewAxis: .vertical)
        
        descriptionLabel.autoPinEdge(toSuperviewEdge: .leading, withInset: 16, relation: .greaterThanOrEqual)
        descriptionLabel.autoPinEdge(toSuperviewEdge: .trailing, withInset: 16, relation: .greaterThanOrEqual)
        descriptionLabel.setContentHuggingPriority(.required, for: .vertical)
        
        let descriptionColor = UIColor.init(hexString: "#626371")!
        let descriptionAS: NSAttributedString
        switch index {
        case 1:
            descriptionAS = NSMutableAttributedString()
                .semibold("choose communities of interest and".localized().uppercaseFirst, color: descriptionColor)
                .text("\n")
                .semibold("be".localized().uppercaseFirst, color: descriptionColor)
                .text(" ")
                .bold("rewarded".localized(), color: .appMainColor)
                .text(" ")
                .semibold("for your actions".localized(), color: descriptionColor)
                .text("\n")
                .text(" ")
                .withParagraphSpacing(26, alignment: .center)
        case 2:
            descriptionAS = NSMutableAttributedString()
                .semibold("communities has no single owner\nand fully belongs to its members".localized().uppercaseFirst, color: descriptionColor)
                .withParagraphSpacing(26, alignment: .center)
        default:
            descriptionAS = NSMutableAttributedString()
                .semibold("blockchain-based social network".localized().uppercaseFirst, color: descriptionColor)
                .text("\n")
                .semibold("where you get".localized(), color: descriptionColor)
                .text(" ")
                .bold("rewards".localized(), color: .appMainColor)
                .text("\n")
                .semibold("for posts, comments and likes".localized(), color: descriptionColor)
                .withParagraphSpacing(26, alignment: .center)

        }
        descriptionLabel.attributedText = descriptionAS
        
        descriptionLabel.autoPinEdge(toSuperviewEdge: .bottom)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let titleHeight = titleLabel.intrinsicContentSize.height
        let descriptionHeight = descriptionLabel.intrinsicContentSize.height
        let height = view.height - titleHeight - descriptionHeight - 2 * spacing
        
        if let constraint = imageViewHeightConstraint {
            constraint.constant = height
            view.layoutIfNeeded()
        } else {
            imageViewHeightConstraint = imageView.autoSetDimension(.height, toSize: height)
        }
    }
}