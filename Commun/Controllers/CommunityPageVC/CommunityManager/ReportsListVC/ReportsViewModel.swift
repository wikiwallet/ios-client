//
//  ReportsViewModel.swift
//  Commun
//
//  Created by Chung Tran on 8/13/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation

class ReportsViewModel: ListViewModel<ResponseAPIContentGetReport> {
    var reportsCount: UInt64 {(fetcher as! ReportsListFetcher).reportsCount}
    var issuers = [String: String]()
    
    init() {
        let fetcher = ReportsListFetcher()
        super.init(fetcher: fetcher, prefetch: false)
    }
    
    override func shouldUpdateHeightForItem(_ item: ResponseAPIContentGetReport?, withUpdatedItem updatedItem: ResponseAPIContentGetReport?) -> Bool {
        if item?.post?.reports?.items != updatedItem?.post?.reports?.items {
            return true
        }
        
        return false
    }
}
