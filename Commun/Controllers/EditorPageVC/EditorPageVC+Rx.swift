//
//  EditorPageVC+Rx.swift
//  Commun
//
//  Created by Maxim Prigozhenkov on 08/04/2019.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

extension EditorPageVC {
    
    func bindUI() {
        guard let viewModel = viewModel else {return}
        // scrollView
        scrollView.rx.willDragDown
            .filter {$0}
            .subscribe(onNext: {_ in
                self.view.endEditing(true)
            })
            .disposed(by: disposeBag)
        
        // isAdult
        adultButton.rx.tap
            .map {_ in !viewModel.isAdult.value}
            .bind(to: viewModel.isAdult)
            .disposed(by: disposeBag)
        
        viewModel.isAdult
            .map {$0 ? "18ButtonSelected": "18Button"}
            .map {UIImage(named: $0)}
            .bind(to: self.adultButton.rx.image(for: .normal))
            .disposed(by: disposeBag)
        
        // Retrieve link
        contentTextView.rx.text.orEmpty
            .filter {$0 != ""}
            .debounce(0.3, scheduler: MainScheduler.instance)
            .subscribe(onNext: {[weak self] text in
                self?.previewView.setUp(mediaType: .linkFromText(text: text))
            })
            .disposed(by: disposeBag)
        
        // verification
        
        #warning("Verify community")
        #warning("fix contentText later")
        Observable.combineLatest(
                titleTextView.rx.text.orEmpty,
                contentTextView.rx.text.orEmpty,
                previewView.media
            )
            .map {
                // Text field  is not empty
                (!$0.0.isEmpty) && (!$0.1.isEmpty) &&
                // Title or content has changed
                ($0.0 != viewModel.postForEdit?.content.title ||
                $0.1 != viewModel.postForEdit?.content.body.preview ||
                    $0.2 == self.previewView.initialMedia)
            }
            .bind(to: sendPostButton.rx.isEnabled)
            .disposed(by: disposeBag)
    }
    
}
