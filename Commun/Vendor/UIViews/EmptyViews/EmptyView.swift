//
//  EmptyView.swift
//  Commun
//
//  Created by Chung Tran on 8/12/19.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import UIKit

class EmptyView: UIView {
    @IBOutlet var backgroundView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var emptyImageView: UIImageView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    func commonInit() {
        Bundle.main.loadNibNamed("EmptyView", owner: self, options: nil)
        addSubview(backgroundView)
        backgroundView.frame = self.bounds
        backgroundView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
    }
    
    func setUpEmptyComment() {
        titleLabel.text = "no comments".localized().uppercaseFirst
        descriptionLabel.text = String(format: "%@ %@", "you have not made any".localized().uppercaseFirst, "comment".localized())
        emptyImageView.image = UIImage(named: "ProfilePageItemsEmptyComment")
    }
    
    func setUpEmptyPost() {
        titleLabel.text = "no posts".localized().uppercaseFirst
        descriptionLabel.text = String(format: "%@ %@", "you have not made any".localized().uppercaseFirst, "post".localized())
        emptyImageView.image = UIImage(named: "ProfilePageItemsEmptyPost")
    }
}
