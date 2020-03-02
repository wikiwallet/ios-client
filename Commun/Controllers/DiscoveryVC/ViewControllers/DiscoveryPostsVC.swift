//
//  DiscoveryPostsVC.swift
//  Commun
//
//  Created by Chung Tran on 2/18/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation
import RxSwift

class DiscoveryPostsVC: PostsViewController {
    init(prefetch: Bool = true) {
        super.init(filter: PostsListFetcher.Filter(feedTypeMode: .subscriptionsPopular, feedType: .time, sortType: .day, userId: Config.currentUser?.id), prefetch: prefetch)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setUp() {
        super.setUp()
        view.backgroundColor = .f3f5fa
    }
    
    override func setUpTableView() {
        super.setUpTableView()
        tableView.backgroundColor = .f3f5fa
        tableView.contentInset = UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
    }
    
    override func bindItems() {
        Observable.merge(
            viewModel.items.asObservable(),
            (viewModel as! PostsViewModel).searchVM.items.map{$0.compactMap{$0.postValue}}
        )
            .map {$0.count > 0 ? [ListSection(model: "", items: $0)] : []}
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
    }
    
    override func handleListEmpty() {
        let title = "no result".localized().uppercaseFirst
        let description = "try to look for something else".localized().uppercaseFirst
        tableView.addEmptyPlaceholderFooterView(emoji: "😿", title: title, description: description)
    }
    
    // MARK: - Search manager
    func searchBarIsSearchingWithQuery(_ query: String) {
        viewModel.rowHeights = [:]
        (viewModel as! PostsViewModel).searchVM.query = query
        (viewModel as! PostsViewModel).searchVM.reload(clearResult: false)
    }
    
    func searchBarDidCancelSearching() {
        viewModel.rowHeights = [:]
        viewModel.items.accept(viewModel.items.value)
        viewModel.state.accept(.loading(false))
    }
}
