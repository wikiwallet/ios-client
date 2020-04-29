//
//  CommentsListFetcher.swift
//  Commun
//
//  Created by Chung Tran on 10/23/19.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import Foundation
import CyberSwift
import RxSwift

public var maxNestedLevel = 6
//    var maxNestedLevel = 6
class CommentsListFetcher: ListFetcher<ResponseAPIContentGetComment> {
    // MARK: - Properties
    let shouldGroupComments: Bool

    // MARK: - type
    struct GroupedComment {
       var comment: ResponseAPIContentGetComment
       var replies = [GroupedComment]()
    }
    
    // MARK: - Enums
    struct Filter: FilterType {
        var sortBy: CommentSortMode = .timeDesc
        var type: GetCommentsType
        var userId: String?
        var username: String?
        var permlink: String?
        var communityId: String?
        var communityAlias: String?
        var parentComment: ResponseAPIContentId?
        var resolveNestedComments: Bool = false
        
        func newFilter(
            withSortBy sortBy: CommentSortMode? = nil,
            type: GetCommentsType? = nil,
            userId: String? = nil,
            username: String? = nil,
            permlink: String? = nil,
            communityId: String? = nil,
            communityAlias: String? = nil,
            parentComment: ResponseAPIContentId? = nil,
            resolveNestedComments: Bool? = nil
        ) -> Filter {
            var newFilter = self
            
            if let sortBy = sortBy {
                newFilter.sortBy = sortBy
            }
            
            if let type = type {
                newFilter.type = type
            }
            
            if let userId = userId {
                newFilter.userId = userId
            }
            
            if let username = username {
                newFilter.username = username
            }
            
            if let permlink = permlink {
                newFilter.permlink = permlink
            }
            if let communityId = communityId {
                newFilter.communityId = communityId
            }
            if let communityAlias = communityAlias {
                newFilter.communityAlias = communityAlias
            }
            if let parentComment = parentComment {
                newFilter.parentComment = parentComment
            }
            if let resolveNestedComments = resolveNestedComments {
                newFilter.resolveNestedComments = resolveNestedComments
            }
            return newFilter
        }
    }
    
    var filter: Filter
    
    init(filter: Filter, shouldGroupComments: Bool) {
        self.filter = filter
        self.shouldGroupComments = shouldGroupComments
    }
        
    override var request: Single<[ResponseAPIContentGetComment]> {
        var result: Single<ResponseAPIContentGetComments>
                
        //        #warning("mocking")
        //        return ResponseAPIContentGetComments.singleWithMockData()
        //            .map {$0.items!}
                
                switch filter.type {
                case .post:
                    // get post's comment
                    result = RestAPIManager.instance.loadPostComments(
                        sortBy: filter.sortBy,
                        offset: offset,
                        limit: 30,
                        userId: filter.userId,
                        username: filter.username,
                        permlink: filter.permlink ?? "",
                        communityId: filter.communityId,
                        communityAlias: filter.communityAlias
                    )
                
                case .user:
                    result = RestAPIManager.instance.loadUserComments(
                        sortBy: filter.sortBy,
                        offset: offset,
                        limit: 30,
                        userId: filter.userId)
                    maxNestedLevel = 0

                case .replies:
                    result = RestAPIManager.instance.loadPostComments(
                        sortBy: filter.sortBy,
                        offset: offset,
                        limit: 30,
                        permlink: filter.permlink ?? "",
                        communityId: filter.communityId,
                        parentCommentUserId: filter.parentComment?.userId,
                        parentCommentPermlink: filter.parentComment?.permlink
                    )
                }
                
                return result
                    .map {$0.items ?? []}
    }
    
    override func join(newItems items: [ResponseAPIContentGetComment]) -> [ResponseAPIContentGetComment] {
        var newList = super.join(newItems: items)
        // sort
        if shouldGroupComments {
            newList = groupComments(newList)
        }
        return newList
    }
    
    // MARK: - for grouping comments
    private func groupComments(_ comments: [ResponseAPIContentGetComment]) -> [ResponseAPIContentGetComment] {
        guard comments.count > 0 else {return []}

        // result array
        let result = comments.filter {$0.parents.comment == nil}
            .reduce([GroupedComment]()) { (result, comment) -> [GroupedComment] in
            return result + [GroupedComment(comment: comment, replies: getChildForComment(comment, in: comments))]
        }

        return flat(result)
    }
    
    func flat(_ array: [GroupedComment]) -> [ResponseAPIContentGetComment] {
        var myArray = [ResponseAPIContentGetComment]()
        for element in array {
            myArray.append(element.comment)
            let result = flat(element.replies)
            for i in result {
                myArray.append(i)
            }
        }
        return myArray
    }

    func getChildForComment(_ comment: ResponseAPIContentGetComment, in source: [ResponseAPIContentGetComment]) -> [GroupedComment] {
        var result = [GroupedComment]()

        // filter child
        guard maxNestedLevel > 0 else {
            return result
        }
        
        let childComments = source
            .filter {$0.parents.comment?.permlink == comment.contentId.permlink && $0.parents.comment?.userId == comment.contentId.userId}

        if childComments.count > 0 {
            // append child
            result = childComments.reduce([GroupedComment](), { (result, comment) -> [GroupedComment] in
                return result + [GroupedComment(comment: comment, replies: getChildForComment(comment, in: source))]
            })
        }

        return result
    }
}
