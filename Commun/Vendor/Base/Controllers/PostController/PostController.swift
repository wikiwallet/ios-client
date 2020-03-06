//
//  FeedPageVC+PostCardCellDelegate.swift
//  Commun
//
//  Created by Maxim Prigozhenkov on 19/03/2019.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import UIKit
import RxSwift
import CyberSwift

protocol PostController: class {
    var disposeBag: DisposeBag {get}
    var voteContainerView: VoteContainerView {get set}
    var post: ResponseAPIContentGetPost? {get set}
    func setUp(with post: ResponseAPIContentGetPost)
}

extension ResponseAPIContentMessageType {
    mutating func setHasVote(_ value: Bool, for type: VoteActionType) {
        // return if nothing changes
        if type == .upvote && value == votes.hasUpVote {return}
        if type == .downvote && value == votes.hasDownVote {return}
        
        if type == .upvote {
            let voted = !(votes.hasUpVote ?? false)
            votes.hasUpVote = voted
            votes.upCount = (votes.upCount ?? 0) + (voted ? 1: -1)
        }
        
        if type == .downvote {
            let downVoted = !(votes.hasDownVote ?? false)
            votes.hasDownVote = downVoted
            votes.downCount = (votes.downCount ?? 0) + (downVoted ? 1: -1)
        }
    }
}

extension PostController {
    func observePostChange() {
        ResponseAPIContentGetPost.observeItemChanged()
            .filter {$0.identity == self.post?.identity}
            .subscribe(onNext: {newPost in
                guard let newPost = self.post?.newUpdatedItem(from: newPost) else {return}
                self.setUp(with: newPost)
            })
            .disposed(by: disposeBag)
    }
    
    func openMorePostActions() {
        guard let topController = UIApplication.topViewController(),
            let post = post
        else {return}
        
        var actions = [CommunActionSheet.Action]()

        actions.append(
            CommunActionSheet.Action(title: "share".localized().uppercaseFirst, icon: UIImage(named: "share"), handle: {
                self.sharePost()
            })
        )

        if post.author?.userId != Config.currentUser?.id {
            actions.append(
                CommunActionSheet.Action(title: "send report".localized().uppercaseFirst,
                                         icon: UIImage(named: "report"),
                                         tintColor: UIColor(hexString: "#ED2C5B")!,
                                         handle: {
                                            self.reportPost()
                })
            )
        } else {
            actions.append(
                CommunActionSheet.Action(title: "edit".localized().uppercaseFirst,
                                         icon: UIImage(named: "edit"),
                                         handle: {
                                            self.editPost()
                })
            )
            
            actions.append(
                CommunActionSheet.Action(title: "delete".localized().uppercaseFirst,
                                         icon: UIImage(named: "delete"),
                                         tintColor: UIColor(hexString: "#ED2C5B")!,
                                         handle: {
                                            self.deletePost()
                })
            )
        }
        
        // headerView for actionSheet
        let headerView = PostMetaView(frame: .zero)
        headerView.isUserNameTappable = false
        
        topController.showCommunActionSheet(headerView: headerView, actions: actions) {
            headerView.setUp(post: post)
        }
    }
    
    // MARK: - Voting
    
    func upVote() {
        guard let post = post else {return}
        if post.contentId.userId == Config.currentUser?.id {
            UIApplication.topViewController()?.showAlert(title: "error".localized().uppercaseFirst, message: "can't cancel vote on own publication".localized().uppercaseFirst)
            return
        }
        // animate
        voteContainerView.animateUpVote {
            NetworkService.shared.upvoteMessage(message: post)
                .subscribe { (error) in
                    UIApplication.topViewController()?.showError(error)
                }
                .disposed(by: self.disposeBag)
        }
    }
    
    func downVote() {
        guard let post = post else {return}
        if post.contentId.userId == Config.currentUser?.id {
            UIApplication.topViewController()?.showAlert(title: "error".localized().uppercaseFirst, message: "can't cancel vote on own publication".localized().uppercaseFirst)
            return
        }
        // animate
        voteContainerView.animateDownVote {
            NetworkService.shared.downvoteMessage(message: post)
                .subscribe { (error) in
                    UIApplication.topViewController()?.showError(error)
                }
                .disposed(by: self.disposeBag)
        }
    }
    
    // MARK: - Other actions
    func sharePost() {
        ShareHelper.share(post: post)
    }
    
    func reportPost() {
        guard let post = post else {return}
        let vc = ContentReportVC(content: post)
        let nc = BaseNavigationController(rootViewController: vc)
        
        nc.modalPresentationStyle = .custom
        nc.transitioningDelegate = vc
        UIApplication.topViewController()?
            .present(nc, animated: true, completion: nil)
    }
    
    func deletePost() {
        guard let post = post,
            let topController = UIApplication.topViewController()
        else {return}
        
        topController.showAlert(
            title: "delete".localized().uppercaseFirst,
            message: "do you really want to delete this post".localized().uppercaseFirst + "?",
            buttonTitles: [
                "yes".localized().uppercaseFirst,
                "no".localized().uppercaseFirst],
            highlightedButtonIndex: 1) { (index) in
                if index == 0 {
                    topController.showIndetermineHudWithMessage("deleting post".localized().uppercaseFirst)
                    NetworkService.shared.deleteMessage(message: post)
                        .subscribe(onCompleted: {
                            topController.hideHud()
                        }, onError: { error in
                            topController.hideHud()
                            topController.showError(error)
                        })
                        .disposed(by: self.disposeBag)
                }
            }
    }
    
    func editPost() {
        guard let post = post,
            let topController = UIApplication.topViewController() else {return}
        
        topController.showIndetermineHudWithMessage("loading post".localized().uppercaseFirst)
        // Get full post
        RestAPIManager.instance.loadPost(userId: post.contentId.userId, permlink: post.contentId.permlink, communityId: post.contentId.communityId ?? "")
            .subscribe(onSuccess: {post in
                topController.hideHud()
                if post.document?.attributes?.type == "basic" {
                    let vc = BasicEditorVC(post: post)
                    topController.present(vc, animated: true, completion: nil)
                    return
                }
                
                if post.document?.attributes?.type == "article" {
                    let vc = ArticleEditorVC(post: post)
                    topController.present(vc, animated: true, completion: nil)
                    return
                }
                topController.hideHud()
                topController.showError(CMError.invalidRequest(message: ErrorMessage.unsupportedTypeOfPost.rawValue))
            }, onError: {error in
                topController.hideHud()
                topController.showError(error)
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: - Commented
    func postDidComment() {
        guard post != nil else {return}
        self.post!.stats?.commentsCount += 1
        self.post!.notifyChanged()
    }
}
