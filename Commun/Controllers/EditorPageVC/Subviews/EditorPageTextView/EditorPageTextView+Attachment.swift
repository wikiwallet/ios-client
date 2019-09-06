//
//  EditorPageTextView+Attachment.swift
//  Commun
//
//  Created by Chung Tran on 9/6/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation
import CyberSwift
import RxSwift

extension EditorPageTextView {
    // MARK: - Methods
    private func addEmbed(_ embed: ResponseAPIFrameGetEmbed) {
        guard let type = embed.type else {return}
        // url for images
        var urlString = embed.url
        
        // thumbnail for website and video
        if type == "website" || type == "video" {
            urlString = embed.thumbnail_url
        }
        
        // request
        var downloadImage: Single<UIImage>
        if urlString == nil || URL(string: urlString!) == nil {
            downloadImage = .just(UIImage(named: "image-not-available")!)
        }
        else {
            downloadImage = NetworkService.shared.downloadImage(URL(string: urlString!)!)
        }
        
        // Donwload image
        downloadImage
            .do(onSubscribe: {
                self.parentViewController?.navigationController?
                    .showIndetermineHudWithMessage("loading".localized().uppercaseFirst)
            })
            .catchErrorJustReturn(UIImage(named: "image-not-available")!)
            .subscribe(
                onSuccess: { [weak self] (image) in
                    guard let strongSelf = self else {return}
                    strongSelf.parentViewController?.navigationController?.hideHud()
                    
                    // Insert Attachment
                    var attachment = TextAttachment()
                    attachment.embed = embed
                    
                    // Add image to attachment
                    strongSelf.add(image, to: &attachment)
                    
                    // Add attachment
                    strongSelf.addAttachmentAtSelectedRange(attachment)
                },
                onError: {[weak self] error in
                    self?.parentViewController?.navigationController?.hideHud()
                    self?.parentViewController?.showError(error)
                }
            )
            .disposed(by: bag)
    }
    
    // MARK: - Link
    func addLink(_ urlString: String, placeholder: String?) {
        // if link has placeholder
        if let placeholder = placeholder {
            var attrs = typingAttributes
            attrs[.link] = urlString
            let attrStr = NSMutableAttributedString(string: placeholder, attributes: attrs)
            attrStr.insert(NSAttributedString(string: String.invisible, attributes: typingAttributes), at: 0)
            attrStr.append(NSAttributedString(string: String.invisible, attributes: typingAttributes))
            textStorage.replaceCharacters(in: selectedRange, with: attrStr)
            selectedRange.location += 1
        }
            // if link is a separated block
        else {
            // detect link type
            NetworkService.shared.getEmbed(url: urlString)
                .do(onSubscribe: {
                    self.parentViewController?
                        .showIndetermineHudWithMessage(
                            "loading".localized().uppercaseFirst)
                })
                .subscribe(onSuccess: {[weak self] embed in
                    self?.parentViewController?.hideHud()
                    self?.addEmbed(embed)
                }, onError: {error in
                    self.parentViewController?.hideHud()
                    self.parentViewController?.showError(error)
                })
                .disposed(by: bag)
            // show
        }
    }
    
    func removeLink() {
        if selectedRange.length > 0 {
            textStorage.removeAttribute(.link, range: selectedRange)
        }
            
        else if var range = textStorage.rangeOfLink(at: selectedRange.location) {
            textStorage.removeAttribute(.link, range: range)
            if range.location > 0 {
                var invisibleTextLocation = range.location - 1
                var invisibleTextRange = NSMakeRange(invisibleTextLocation, 1)
                if textStorage.attributedSubstring(from: invisibleTextRange).string == .invisible {
                    textStorage.replaceCharacters(in: invisibleTextRange, with: "")
                    range.location -= 1
                    invisibleTextLocation = range.location + range.length
                    
                    if invisibleTextLocation >= textStorage.length {return}
                    
                    invisibleTextRange = NSMakeRange(invisibleTextLocation, 1)
                    if textStorage.attributedSubstring(from: invisibleTextRange).string == .invisible {
                        textStorage.replaceCharacters(in: invisibleTextRange, with: "")
                    }
                }
            }
        }
    }
    
    // MARK: - Image
    func addImage(_ image: UIImage? = nil, urlString: String? = nil, description: String? = nil) {
        var embed = try! ResponseAPIFrameGetEmbed(
            blockAttributes: ContentBlockAttributes(
                url: urlString, description: description
            )
        )
        embed.type = "image"
        
        // if image is local image
        if let image = image {
            // Insert Attachment
            var attachment = TextAttachment()
            attachment.embed = embed
            attachment.localImage = image
            
            // Add image to attachment
            add(image, to: &attachment)
            
            // Add attachment
            addAttachmentAtSelectedRange(attachment)
        }
            
        // if image is from link
        else {
            addEmbed(embed)
        }
    }
}
