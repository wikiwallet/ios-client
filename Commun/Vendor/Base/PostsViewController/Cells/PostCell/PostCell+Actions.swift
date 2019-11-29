//
//  PostCell+Actions.swift
//  Commun
//
//  Created by Chung Tran on 10/21/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation

extension PostCell {
    @objc func menuButtonTapped(button: UIButton) {
        openMorePostActions()
    }
    
    @objc func upVoteButtonTapped(button: UIButton) {
        upVote()
    }
    
    @objc func downVoteButtonTapped(button: UIButton) {
        downVote()
    }

    @objc func shareButtonTapped(button: UIButton) {
        openShareActions()
    }
    
    @objc func commentCountsButtonDidTouch() {
        guard let post = post else {return}
        let postPageVC = PostPageVC(post: post)
        postPageVC.scrollToTopAfterLoadingComment = true
        parentViewController?.show(postPageVC, sender: nil)
    }
}
