//
//  BalancesViewModel.swift
//  Commun
//
//  Created by Chung Tran on 12/18/19.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import Foundation
import CyberSwift
import RxCocoa

class BalancesViewModel: ListViewModel<ResponseAPIWalletGetBalance> {
    let searchResult = BehaviorRelay<[ResponseAPIWalletGetBalance]?>(value: nil)
    
    convenience init(userId: String? = nil, balances: [ResponseAPIWalletGetBalance]? = nil) {
        let fetcher = BalancesListFetcher(userId: userId)
        self.init(fetcher: fetcher)
        defer {
            if let balances = balances {
                items.accept(balances)
            } else {
                fetchNext()
            }
            
        }
    }
}
