//
//  ProposalCell.swift
//  Commun
//
//  Created by Chung Tran on 8/13/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation

protocol ProposalCellDelegate: class {}

class ProposalCell: CommunityManageCell, ListItemCellType {
    // MARK: - Properties
    weak var delegate: ProposalCellDelegate?
    
    // MARK: - Subviews
    lazy var metaView = PostMetaView(height: 40.0)
    lazy var actionTypeLabel = UILabel.with(textSize: 15, weight: .semibold)
    
    override func setUpStackView() {
        super.setUpStackView()
        stackView.insertArrangedSubview(actionTypeLabel.padding(UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)), at: 0)
        stackView.insertArrangedSubview(metaView.padding(UIEdgeInsets(top: 16, left: 16, bottom: 0, right: 16)), at: 0)
    }
    
    func setUp(with item: ResponseAPIContentGetProposal) {
        // meta view
        if item.contentType != "post" {
            metaView.setUp(with: item.community, author: item.proposer, creationTime: item.blockTime!)
        }
        
        var actionColor: UIColor = .appBlackColor
        var typePlainText = ""
        
        switch item.type {
        case "setInfo":
            if item.change?.subType == "remove" { actionColor = .red }
            typePlainText = "\(item.change?.subType ?? "change") \(item.change?.type ?? "")"
        case "banPost":
            typePlainText = "ban \(item.contentType ?? "post")"
        default:
            typePlainText = item.type ?? ""
        }
        
        // actionTypeLabel
        let actionText = NSMutableAttributedString()
            .text(typePlainText.localized().uppercaseFirst, size: 15, weight: .semibold, color: actionColor)
        
        let expiringDate = Date.from(string: item.expiration ?? "")
        if expiringDate < Date() {
            // expired
            actionText
                .text(" (\("expired".localized().uppercaseFirst))", size: 15, weight: .semibold, color: actionColor)
        } else {
            // expiring in
            actionText
                .text(" (\("expiring in".localized().uppercaseFirst) \(Date().intervalToDate(date: expiringDate)))", size: 15, weight: .medium, color: item.change?.subType == "remove" ? .red: .appGrayColor)
        }
        actionTypeLabel.attributedText = actionText
        
        // content view
        mainView.isHidden = false
        switch item.type {
        case "setInfo":
            setInfo(item)
        case "banPost":
            setMessage(item: item)
        default:
            mainView.isHidden = true
        }
        
        // voteLabel
        voteLabel.attributedText = NSMutableAttributedString()
            .text("voted".localized().uppercaseFirst, size: 12, weight: .semibold, color: .appGrayColor)
            .normal("\n")
            .text("\(item.approvesCount ?? 0) \("from".localized()) \(item.approvesNeed ?? 0) \("votes".localized())", size: 14, weight: .semibold)
            .withParagraphStyle(lineSpacing: 4)
    }
    
    @discardableResult
    override func setMessage(item: ResponseAPIContentGetProposal?) -> CMPostView {
        let postView = super.setMessage(item: item)
        postView.headerView.isHidden = true
        if let post = item?.post {
            metaView.setUp(post: post)
        } else if let comment = item?.comment {
            metaView.setUp(comment: comment)
        }
        return postView
    }
    
    private func setInfo(_ item: ResponseAPIContentGetProposal?) {
        let change = item?.change
        switch change?.type {
        case "rules":
            let ruleView = addViewToMainView(type: RuleProposalView.self, contentInsets: UIEdgeInsets(horizontal: 32, vertical: 0))
            ruleView.setUp(with: change?.new?.rules, oldRule: change?.old?.rules, subType: item?.change?.subType, isOldRuleCollapsed: change?.isOldRuleCollapsed ?? true)
            ruleView.collapsingHandler = {
                var item = item
                let value = item?.change?.isOldRuleCollapsed ?? true
                item?.change?.isOldRuleCollapsed = !value
                item?.notifyChanged()
            }
            return
        case "description":
            let descriptionView = addViewToMainView(type: DescriptionProposalView.self, contentInsets: UIEdgeInsets(horizontal: 32, vertical: 0))
            
            descriptionView.setUp(content: item?.change?.new?.string)
            return
        case "avatarUrl":
            let avatarView = addViewToMainView(type: AvatarProposalView.self, contentInsets: UIEdgeInsets(horizontal: 32, vertical: 0))
            avatarView.setUp(newAvatar: item?.change?.new?.string, oldAvatar: item?.change?.old?.string)
            return
        case "coverUrl":
            let coverView = addViewToMainView(type: CoverProposalView.self, contentInsets: UIEdgeInsets(horizontal: 32, vertical: 0))
            coverView.setUp(newCover: item?.change?.new?.string, oldCover: item?.change?.old?.string)
            return
        default:
            mainView.isHidden = true
        }
    }
    
    override func actionButtonDidTouch() {
        // TODO: - Accept
    }
}
