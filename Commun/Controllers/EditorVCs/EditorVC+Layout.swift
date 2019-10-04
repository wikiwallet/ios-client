//
//  EditorVC+Layout.swift
//  Commun
//
//  Created by Chung Tran on 10/4/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation

extension EditorVC {
    func setUpToolbar() {
        view.addSubview(toolbar)
        toolbar.backgroundColor = .white
        toolbar.clipsToBounds = true
        toolbar.cornerRadius = 16
        toolbar.addShadow(offset: CGSize.init(width: 0, height: 1), color: .black, radius: 10, opacity: 0.2)
        
        toolbar.autoPinEdge(toSuperviewSafeArea: .leading)
        toolbar.autoPinEdge(toSuperviewSafeArea: .trailing)
        let keyboardViewV = KeyboardLayoutConstraint(item: view!, attribute: .bottom, relatedBy: .equal, toItem: toolbar, attribute: .bottom, multiplier: 1.0, constant: 0.0)
        keyboardViewV.observeKeyboardHeight()
        self.view.addConstraint(keyboardViewV)
        
        // buttons
        setUpToolbarButtons()
        
        // sendpost button
        toolbar.addSubview(postButton)
        postButton.autoPinEdge(.leading, to: .trailing, of: buttonsCollectionView, withOffset: 10)
        postButton.autoPinEdge(toSuperviewEdge: .trailing, withInset: 16)
        postButton.autoAlignAxis(toSuperviewAxis: .horizontal)
    }
    
    func setUpToolbarButtons() {
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = .zero
        layout.scrollDirection = .horizontal
        buttonsCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        buttonsCollectionView.showsHorizontalScrollIndicator = false
        buttonsCollectionView.backgroundColor = .clear
        buttonsCollectionView.configureForAutoLayout()
        toolbar.addSubview(buttonsCollectionView)
        // layout
        buttonsCollectionView.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 10, left: 16, bottom: 10, right: 0), excludingEdge: .right)
        buttonsCollectionView.register(EditorToolbarItemCell.self, forCellWithReuseIdentifier: "EditorToolbarItemCell")
    }
    
    func addScrollView() {
        let scrollView = UIScrollView(forAutoLayout: ())
        view.addSubview(scrollView)
        scrollView.autoPinEdgesToSuperviewSafeArea(with: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0), excludingEdge: .bottom)
        scrollView.autoPinEdge(.bottom, to: .top, of: toolbar)
        
        // add childview of scrollview
        contentView = UIView(forAutoLayout: ())
        scrollView.addSubview(contentView)
        contentView.autoPinEdgesToSuperviewEdges()
        contentView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
    }
}
