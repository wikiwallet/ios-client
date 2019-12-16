//
//  PostEditorVC+Draft.swift
//  Commun
//
//  Created by Chung Tran on 10/15/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation

extension PostEditorVC {
    // MARK: - draft
    func retrieveDraft() {
        showAlert(
            title: "retrieve draft".localized().uppercaseFirst,
            message: "you have a draft version on your device".localized().uppercaseFirst + ". " + "continue editing it".localized().uppercaseFirst + "?",
            buttonTitles: ["OK".localized(), "cancel".localized().uppercaseFirst],
            highlightedButtonIndex: 0) { (index) in
                if index == 0 {
                    self.getDraft()
                }
                else if index == 1 {
                    self.removeDraft()
                }
        }
    }
    
    @objc var hasDraft: Bool {
        return contentTextView.hasDraft || UserDefaults.standard.dictionaryRepresentation().keys.contains(communityDraftKey)
    }
    
    @objc func getDraft() {
        // retrieve community
        if let savedCommunity = UserDefaults.standard.object(forKey: communityDraftKey) as? Data,
            let loadedCommunity = try? JSONDecoder().decode(ResponseAPIContentGetCommunity.self, from: savedCommunity)
        {
            viewModel.community.accept(loadedCommunity)
        }
        
        // retrieve content
        contentTextView.getDraft {
            // remove draft
            self.removeDraft()
        }
    }
    
    @objc func saveDraft(completion: (()->Void)? = nil) {
        // save community
        if let community = viewModel.community.value,
            let encoded = try? JSONEncoder().encode(community)
        {
            UserDefaults.standard.set(encoded, forKey: communityDraftKey)
        }
        
        // save content
        contentTextView.saveDraft(completion: completion)
    }
    
    @objc func removeDraft() {
        contentTextView.removeDraft()
        UserDefaults.standard.removeObject(forKey: communityDraftKey)
    }
}