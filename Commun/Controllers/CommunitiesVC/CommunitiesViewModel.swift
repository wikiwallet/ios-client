//
//  CommunitiesViewModel.swift
//  Commun
//
//  Created by Chung Tran on 11/6/19.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import Foundation
import CyberSwift

class CommunitiesViewModel: ListViewModel<ResponseAPIContentGetCommunity> {
    lazy var searchVM: SearchViewModel = {
        let fetcher = SearchListFetcher()
        fetcher.limit = 20
        fetcher.searchType = .entitySearch
        fetcher.entitySearchEntity = .communities
        return SearchViewModel(fetcher: fetcher)
    }()
    
    init(type: GetCommunitiesType, userId: String? = nil, prefetch: Bool = true) {
        let fetcher = CommunitiesListFetcher(type: type, userId: userId)
        super.init(fetcher: fetcher, prefetch: prefetch)
        self.fetcher = fetcher
    }
}
