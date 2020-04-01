//
//  PostEditorVC.swift
//  Commun
//
//  Created by Chung Tran on 10/4/19.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import PureLayout

class PostEditorVC: EditorVC {
    // MARK: - Constants
    let communityDraftKey = "PostEditorVC.communityDraftKey"
    
    // MARK: - Properties
    var chooseCommunityAfterLoading: Bool
    var parseDraftAfterLoading: Bool
    var explanationViewShowed = false
    
    // MARK: - Computed properties
    var contentLettersLimit: UInt {30000}
    
    /// Condition that define when to start updating send button state
    var contentCombined: Observable<Void> {
        viewModel.community.map {_ in ()}
    }
    
    /// Define whenever content is valid to enable send button
    var hintType: CMHint.HintType?
    var isContentValid: Bool {
        let communityChosen = viewModel.community.value != nil
        if !communityChosen {hintType = .chooseCommunity}
        return communityChosen
    }
    
    var viewModel: PostEditorViewModel {
        fatalError("Must override")
    }
    
    var postTitle: String? { nil }
    
    // MARK: - Subviews
    // community
    lazy var communityView = UIView(forAutoLayout: ())
    lazy var youWillPostInLabel = UILabel.descriptionLabel("you will post in".localized().uppercaseFirst)
    lazy var communityAvatarImage = MyAvatarImageView(size: 40)
    lazy var communityNameLabel = UILabel.with(text: "choose a community".localized().uppercaseFirst, textSize: 15, weight: .semibold, numberOfLines: 0)
    lazy var contentTextViewCountLabel = UILabel.descriptionLabel("0/30000")
    
    var contentTextView: ContentTextView {
        fatalError("Must override")
    }
    
    // MARK: - Initializers
    init(post: ResponseAPIContentGetPost? = nil, community: ResponseAPIContentGetCommunity? = nil, chooseCommunityAfterLoading: Bool = true, parseDraftAfterLoading: Bool = true) {
        self.chooseCommunityAfterLoading = chooseCommunityAfterLoading
        self.parseDraftAfterLoading = parseDraftAfterLoading
        super.init(nibName: nil, bundle: nil)
        viewModel.postForEdit = post
        viewModel.community.accept(community)
        modalPresentationStyle = .fullScreen
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // if editing post
        if let post = viewModel.postForEdit {
            communityView.removeGestureRecognizers()
            showIndetermineHudWithMessage("loading".localized().uppercaseFirst)
            setUp(with: post)
                .subscribe(onCompleted: {
                    self.hideHud()
                }) { (error) in
                    self.hideHud()
                    self.showError(error)
                }
                .disposed(by: disposeBag)
        } else {
            // parse draft
            if hasDraft && parseDraftAfterLoading {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    // your code here
                    self.retrieveDraft()
                }
            } else {
                if viewModel.community.value == nil && chooseCommunityAfterLoading {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        self.chooseCommunityDidTouch()
                    }
                }
            }
        }
    }
    
    override func setUp() {
        super.setUp()
        
        actionButton.isDisabled = true
        actionButton.backgroundColor = .appMainColor
        actionButton.setTitle("send post".localized().uppercaseFirst, for: .normal)
        
        // common contentTextView
        contentTextView.placeholder = "write text placeholder".localized().uppercaseFirst + "..."
        headerLabel.text = String(format: "$@ %@", (viewModel.postForEdit != nil ? "edit" : "create").localized().uppercaseFirst, "post".localized())
        contentTextView.textContainerInset = UIEdgeInsets(top: 0, left: 16, bottom: 100, right: 16)
        
        contentTextView.addLinkDidTouch = { [weak self] in
            self?.addLink()
        }

        // add default tool
//        appendTool(EditorToolbarItem.ageLimit)
        appendTool(EditorToolbarItem.addPhoto)
    }
    
    override func bind() {
        super.bind()
        bindKeyboardHeight()
        
        bindSendPostButton()
        
        bindContentTextView()
        
        bindCommunity()
    }
    
    override func didSelectTool(_ item: EditorToolbarItem) {
        super.didSelectTool(item)
        
        guard item.isEnabled else {return}
        
        if item == .setBold {
            contentTextView.toggleBold()
        }
        
        if item == .setItalic {
            contentTextView.toggleItalic()
        }
        
        if item == .clearFormatting {
            contentTextView.clearFormatting()
        }
        
        if item == .addPhoto {
            addImage()
        }
        
        if item == .addLink {
            addLink()
        }
        
        if item == .ageLimit {
            addAgeLimit()
        }
    }
    
    // MARK: - action for overriding
    func setUp(with post: ResponseAPIContentGetPost) -> Completable {
        guard let document = post.document,
            let community = post.community
        else {return .empty()}
        viewModel.community.accept(community)
        return contentTextView.parseContentBlock(document)
    }
    
    func getContentBlock() -> Single<ResponseAPIContentBlock> {
        contentTextView.getContentBlock()
    }
}
