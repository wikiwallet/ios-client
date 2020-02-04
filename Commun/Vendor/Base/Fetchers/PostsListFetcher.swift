//
//  PostsListFetcher.swift
//  Commun
//
//  Created by Chung Tran on 10/23/19.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import Foundation
import CyberSwift
import RxSwift

class PostsListFetcher: ListFetcher<ResponseAPIContentGetPost> {
    // MARK: - Enums
    struct Filter: FilterType {
        var feedTypeMode: FeedTypeMode
        var feedType: FeedSortMode
        var sortType: FeedTimeFrameMode?
        var searchKey: String?
        var userId: String?
        var communityId: String?
        var communityAlias: String?
        
        func newFilter(
            withFeedTypeMode feedTypeMode: FeedTypeMode? = nil,
            feedType: FeedSortMode? = nil,
            sortType: FeedTimeFrameMode? = nil,
            searchKey: String? = nil,
            userId: String? = nil,
            communityId: String? = nil,
            communityAlias: String? = nil
        ) -> Filter {
            var newFilter = self
            if let feedTypeMode = feedTypeMode,
                feedTypeMode != newFilter.feedTypeMode {
                newFilter.feedTypeMode = feedTypeMode
            }
            
            if let feedType = feedType,
                feedType != newFilter.feedType {
                newFilter.feedType = feedType
            }
            
            if let sortType = sortType,
                sortType != newFilter.sortType {
                newFilter.sortType = sortType
            }
            
            newFilter.searchKey = searchKey
            
            if let userId = userId,
                userId != newFilter.userId {
                newFilter.userId = userId
            }
            
            if let communityId = communityId,
                communityId != newFilter.communityId {
                newFilter.communityId = communityId
            }
            
            if let alias = communityAlias,
                communityAlias != newFilter.communityAlias
            {
                newFilter.communityAlias = alias
            }
            
            return newFilter
        }
    }
    
    var filter: Filter 
    
    required init(filter: Filter) {
        self.filter = filter
        super.init()
    }
        
    override var request: Single<[ResponseAPIContentGetPost]> {
//        return ResponseAPIContentGetPosts.singleWithMockData()
//            .delay(0.8, scheduler: MainScheduler.instance)
        return RestAPIManager.instance.getPosts(userId: filter.userId, communityId: filter.communityId, communityAlias: filter.communityAlias, allowNsfw: false, type: filter.feedTypeMode, sortBy: filter.feedType, sortType: filter.sortType, limit: limit, offset: offset
        )
            .map {$0.items ?? []}
    }
    
    override func filter(items: [ResponseAPIContentGetPost]) -> [ResponseAPIContentGetPost] {
        items.filter { (item) -> Bool in
            !self.items.value.contains {$0.identity == item.identity} && item.document != nil
        }
    }
}
