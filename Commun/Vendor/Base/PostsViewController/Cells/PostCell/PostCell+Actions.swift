//
//  PostCell+Actions.swift
//  Commun
//
//  Created by Chung Tran on 10/21/19.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import Foundation

extension PostCell {
    @objc func menuButtonTapped(button: UIButton) {
        guard let post = post else {return}
        self.delegate?.menuButtonDidTouch(post: post)
    }
    
    @objc func upVoteButtonTapped(button: UIButton) {
        guard let post = post else {return}
        if post.contentId.userId == Config.currentUser?.id {
            self.parentViewController?.showAlert(title: "error".localized().uppercaseFirst, message: "can't cancel vote on own publication".localized().uppercaseFirst)
            return
        }
        voteContainerView.animateUpVote {
            self.delegate?.upvoteButtonDidTouch(post: post)
        }
    }
    
    @objc func downVoteButtonTapped(button: UIButton) {
        guard let post = post else {return}
        if post.contentId.userId == Config.currentUser?.id {
            self.parentViewController?.showAlert(title: "error".localized().uppercaseFirst, message: "can't cancel vote on own publication".localized().uppercaseFirst)
            return
        }
        voteContainerView.animateDownVote {
            self.delegate?.downvoteButtonDidTouch(post: post)
        }
    }

    @objc func shareButtonTapped(button: UIButton) {
        guard let post = post else {return}
        ShareHelper.share(post: post)
    }
    
    @objc func commentCountsButtonDidTouch() {
        guard let post = post else {return}
        let postPageVC = PostPageVC(post: post)
        postPageVC.scrollToTopAfterLoadingComment = true
        parentViewController?.show(postPageVC, sender: nil)
    }
}
