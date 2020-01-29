//
//  CurrenciesViewModel.swift
//  Commun
//
//  Created by Chung Tran on 1/28/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation
import RxCocoa

class CurrenciesViewModel: ListViewModel<ResponseAPIGetCurrency> {
    // MARK: - Properties
    let searchResult = BehaviorRelay<[ResponseAPIGetCurrency]?>(value: nil)
    
    // MARK: - Initializers
    init() {
        let fetcher = CurrenciesListFetcher()
        super.init(fetcher: fetcher)
        
        defer {
            fetchNext()
        }
    }
}
