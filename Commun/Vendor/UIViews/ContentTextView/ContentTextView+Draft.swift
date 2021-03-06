//
//  ContentTextView+Draft.swift
//  Commun
//
//  Created by Chung Tran on 10/7/19.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import Foundation

extension ContentTextView {
    var hasDraft: Bool {
        return UserDefaults.standard.dictionaryRepresentation().keys.contains(draftKey)
    }
    
    func saveDraft() {
        var draft = [Data]()
        var aText = NSAttributedString()
        if Thread.isMainThread {
            aText = self.attributedText!
        } else {
            DispatchQueue.main.sync {
                aText = self.attributedText!
            }
        }
        aText.enumerateAttributes(in: NSRange(location: 0, length: aText.length), options: []) { (attributes, range, _) in
            if self.canContainAttachments {
                if let attachment = attributes[.attachment] as? TextAttachment {
                    if let data = try? JSONEncoder().encode(attachment) {
                        draft.append(data)
                    }
                    return
                }
            }
            if let data = try? aText.data(from: range, documentAttributes: [.documentType: NSAttributedString.DocumentType.rtfd]) {
                draft.append(data)
            }
        }
        if let data = try? JSONEncoder().encode(draft) {
            UserDefaults.standard.set(data, forKey: self.draftKey)
        }
    }
    
    func removeDraft() {
        UserDefaults.standard.removeObject(forKey: self.draftKey)
    }
    
    func getDraft(completion: (() -> Void)? = nil) {
        let defaultFont = defaultTypingAttributes[.font] as! UIFont
        
        // show hud
        self.parentViewController?
            .showIndetermineHudWithMessage("retrieving draft".localized().uppercaseFirst)
        
        // retrieve draft on another thread
        DispatchQueue(label: "pasting").async {
            guard let data = UserDefaults.standard.data(forKey: self.draftKey),
                let draft = try? JSONDecoder().decode([Data].self, from: data) else {
                    DispatchQueue.main.async {
                        self.parentViewController?.hideHud()
                    }
                    return
            }
            
            let mutableAS = NSMutableAttributedString()
            for data in draft {
                if self.canContainAttachments {
                    var skip = false
                    DispatchQueue.main.sync {
                        if let attachment = try? JSONDecoder().decode(TextAttachment.self, from: data) {
                            attachment.delegate = self.parentViewController as? AttachmentViewDelegate
                            let attachmentAS = NSMutableAttributedString(attachment: attachment)
                            attachmentAS.addAttributes(self.defaultTypingAttributes, range: NSRange(location: 0, length: 1))
                            mutableAS.append(attachmentAS)
                            skip = true
                        }
                    }
                    
                    if skip {continue}
                }
                
                if let aStr = try? NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.rtfd], documentAttributes: nil) {
                    mutableAS.append(aStr)
                }
            }
            
            DispatchQueue.main.async {
                // Has to modify font back to systemFont because of illegal font in data
                mutableAS.overrideFont(
                    replacementFont: defaultFont,
                    keepSymbolicTraits: true)
                
                // set attributedText
                self.attributedText = mutableAS
                
                // hide hud
                self.parentViewController?
                    .hideHud()
                
                completion?()
            }
        }
    }
}
