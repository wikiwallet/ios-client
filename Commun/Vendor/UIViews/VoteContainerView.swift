//
//  VoteContainerView.swift
//  Commun
//
//  Created by Chung Tran on 11/8/19.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import Foundation
import CyberSwift

class VoteContainerView: MyView {
    // MARK: - Properties
    var votes: ResponseAPIContentVotes?
    
    // MARK: - Subviews
    lazy var upVoteButton = voteButton(type: .upvote)
    lazy var downVoteButton = voteButton(type: .downvote)
    lazy var likeCountLabel = CMLabel.with(textSize: 12, weight: .bold, textColor: .appGrayColor, textAlignment: .center)
    
    // MARK: - Methods
    override func commonInit() {
        super.commonInit()
        backgroundColor = .appLightGrayColor
        setContentHuggingPriority(.defaultHigh, for: .horizontal)

        addSubview(upVoteButton)
        upVoteButton.autoPinEdgesToSuperviewEdges(with: .zero, excludingEdge: .trailing)
        
        addSubview(downVoteButton)
        downVoteButton.autoPinEdgesToSuperviewEdges(with: .zero, excludingEdge: .leading)
        
        addSubview(likeCountLabel)
        likeCountLabel.autoPinEdge(.leading, to: .trailing, of: upVoteButton)
        likeCountLabel.autoPinEdge(.trailing, to: .leading, of: downVoteButton)
        likeCountLabel.autoPinEdge(toSuperviewEdge: .top)
        likeCountLabel.autoPinEdge(toSuperviewEdge: .bottom)
        likeCountLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        
        likeCountLabel.contentInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
    }
    
    func setUp(with votes: ResponseAPIContentVotes, userID: String?) {
        self.votes = votes
        
        upVoteButton.tintColor         = votes.hasUpVote ?? false ? .appMainColor : .appGrayColor
        likeCountLabel.text            = "\(((votes.upCount ?? 0) - (votes.downCount ?? 0)).kmFormatted)"
        downVoteButton.tintColor       = votes.hasDownVote ?? false ? .appMainColor : .appGrayColor
        upVoteButton.isEnabled         = !(votes.isBeingVoted ?? false)
        downVoteButton.isEnabled       = !(votes.isBeingVoted ?? false)
        likeCountLabel.textColor = votes.hasUpVote ?? false || votes.hasDownVote ?? false ? .appMainColor : .appGrayColor
    }
    
    func animateUpVote(completion: @escaping () -> Void) {
        CATransaction.begin()
        CATransaction.setCompletionBlock(completion)

        let moveUpAnim = CABasicAnimation(keyPath: "position.y")
        moveUpAnim.byValue = -16
        moveUpAnim.autoreverses = true
        self.upVoteButton.layer.add(moveUpAnim, forKey: "moveUp")

        let fadeAnim = CABasicAnimation(keyPath: "opacity")
        fadeAnim.byValue = -1
        fadeAnim.autoreverses = true
        self.upVoteButton.layer.add(fadeAnim, forKey: "Fade")

        CATransaction.commit()
    }
    
    func animateDownVote(completion: @escaping () -> Void) {
        CATransaction.begin()
        CATransaction.setCompletionBlock(completion)
        
        let moveDownAnim = CABasicAnimation(keyPath: "position.y")
        moveDownAnim.byValue = 16
        moveDownAnim.autoreverses = true
        self.downVoteButton.layer.add(moveDownAnim, forKey: "moveDown")
        
        let fadeAnim = CABasicAnimation(keyPath: "opacity")
        fadeAnim.byValue = -1
        fadeAnim.autoreverses = true
        self.downVoteButton.layer.add(fadeAnim, forKey: "Fade")
        
        CATransaction.commit()
    }
    
    func fill(_ fill: Bool = true) {
        guard let votes = votes else {return}
        backgroundColor = fill ? .appMainColor : .appLightGrayColor
        
        let voteActiveColor: UIColor = fill ? .appLightGrayColor : .appMainColor
        let voteInactiveColor: UIColor = fill ? UIColor.appLightGrayColor.withAlphaComponent(0.5) : .appGrayColor
        
        upVoteButton.tintColor         = votes.hasUpVote ?? false ? voteActiveColor : voteInactiveColor
        likeCountLabel.text            = "\(((votes.upCount ?? 0) - (votes.downCount ?? 0)).kmFormatted)"
        downVoteButton.tintColor       = votes.hasDownVote ?? false ? voteActiveColor : voteInactiveColor
        likeCountLabel.textColor = votes.hasUpVote ?? false || votes.hasDownVote ?? false ? voteActiveColor : voteInactiveColor
    }
    
    private func voteButton(type: VoteActionType) -> UIButton {
        let button = UIButton(width: 30)
        button.imageEdgeInsets = UIEdgeInsets(top: 10.5, left: 10, bottom: 10.5, right: 10)
        button.setImage(UIImage(named: type == .upvote ? "upVote" : "downVote"), for: .normal)
        button.touchAreaEdgeInsets = UIEdgeInsets(inset: -3)
        return button
    }
}
