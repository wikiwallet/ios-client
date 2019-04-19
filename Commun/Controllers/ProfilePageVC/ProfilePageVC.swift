//
//  ProfilePageVC.swift
//  Commun
//
//  Created by Chung Tran on 17/04/2019.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import UIKit
import RxSwift
import CyberSwift
import SDWebImage
import UIImageView_Letters

class ProfilePageVC: UIViewController {
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var userAvatarImage: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var joinedDateLabel: UILabel!
    @IBOutlet weak var followersCountLabel: UILabel!
    @IBOutlet weak var followingsCountLabel: UILabel!
    @IBOutlet weak var communitiesCountLabel: UILabel!
    @IBOutlet weak var segmentio: Segmentio!
    
    let bag = DisposeBag()
    let viewModel = ProfilePageViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // setup view
        setUpViews()
        
        // bind view model
        bindViewModel()
        
        // load profile
        viewModel.loadProfile()
    }
    
    func setUpViews() {
        // Indicator settings
        activityIndicator.hidesWhenStopped = true
        
        // Configure tableView
        tableView.register(UINib(nibName: "PostCardCell", bundle: nil), forCellReuseIdentifier: "PostCardCell")
        tableView.rowHeight = UITableView.automaticDimension
        tableView.tableFooterView = UIView()
        
        // RefreshControl
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        tableView.refreshControl = refreshControl
        
        // Segmentio
        let segmentedItems = ProfilePageSegmentioItem.AllCases()
        let items: [SegmentioItem] = segmentedItems.map {SegmentioItem(title: $0.rawValue, image: nil)}
        
        segmentio.setup(
            content: items,
            style: SegmentioStyle.onlyLabel,
            options: SegmentioOptions.default)
        
        segmentio.valueDidChange = {_, index in
            self.viewModel.segmentedItem.accept(segmentedItems[index])
        }
    }
    
    @objc func refresh() {
        viewModel.reload()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

}
