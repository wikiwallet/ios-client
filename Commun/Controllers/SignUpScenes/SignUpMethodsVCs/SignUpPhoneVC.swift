//
//  SignUpPhoneVC.swift
//  Commun
//
//  Created by Chung Tran on 3/23/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation
import PhoneNumberKit

class SignUpPhoneVC: BaseSignUpVC {
    // MARK: - Subviews
    lazy var selectCountryView: UIView = {
        let view = UIView(width: 290, height: 56, backgroundColor: .f3f5fa, cornerRadius: 12)
        view.addSubview(selectCountryPlaceholderLabel)
        selectCountryPlaceholderLabel.autoPinEdge(toSuperviewEdge: .leading, withInset: 16)
        selectCountryPlaceholderLabel.autoAlignAxis(toSuperviewAxis: .horizontal)
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(selectCountryDidTouch)))
        return view
    }()
    
    lazy var selectCountryPlaceholderLabel = UILabel.with(text: "select country placeholder".localized().uppercaseFirst, textSize: 17, textColor: UIColor(hexString: "#9B9FA2")!)
    
    lazy var flagImageView = UIImageView(width: 56, height: 56)
    lazy var countryNameLabel = UILabel.with(textSize: 17)
    
    lazy var phoneTextField: PhoneNumberTextField = {
        let tf = PhoneNumberTextField(width: 290, height: 56, backgroundColor: .f3f5fa, cornerRadius: 12)
        let paddingView = UIView(width: 16 * Config.widthRatio, height: 20)
        tf.leftView = paddingView
        tf.leftViewMode = .always
        tf.placeholder = "phone number placeholder".localized().uppercaseFirst
        return tf
    }()
    
    // MARK: - Methods
    override func setUp() {
        super.setUp()
        AnalyticsManger.shared.registrationOpenScreen(2)
        
        // override font size
        titleLabel.font = .systemFont(ofSize: 34, weight: .bold)
    }
    
    override func setUpScrollView() {
        super.setUpScrollView()
        // select country view
        scrollView.contentView.addSubview(selectCountryView)
        selectCountryView.autoPinEdge(toSuperviewEdge: .top, withInset: UIScreen.main.isSmall ? 16 : 47)
        selectCountryView.autoAlignAxis(toSuperviewAxis: .vertical)
        
        // phone text field
        scrollView.contentView.addSubview(phoneTextField)
        phoneTextField.autoPinEdge(.top, to: .bottom, of: selectCountryView, withOffset: 16)
        phoneTextField.autoAlignAxis(toSuperviewAxis: .vertical)
        
        // term of use
        scrollView.contentView.addSubview(termOfUseLabel)
        termOfUseLabel.autoPinEdge(toSuperviewEdge: .leading, withInset: 16)
        termOfUseLabel.autoPinEdge(toSuperviewEdge: .trailing, withInset: 16)
        termOfUseLabel.autoPinEdge(.top, to: .bottom, of: phoneTextField, withOffset: 30)
        
        // next button
        scrollView.contentView.addSubview(nextButton)
        nextButton.autoPinEdge(.top, to: .bottom, of: termOfUseLabel, withOffset: 16)
        nextButton.autoAlignAxis(toSuperviewAxis: .vertical)
        
        // sign in label
        scrollView.contentView.addSubview(signInLabel)
        signInLabel.autoPinEdge(toSuperviewEdge: .leading, withInset: 16)
        signInLabel.autoPinEdge(toSuperviewEdge: .trailing, withInset: 16)
        signInLabel.autoPinEdge(.top, to: .bottom, of: nextButton, withOffset: 31)
        
        // pin bottom
        signInLabel.autoPinEdge(toSuperviewEdge: .bottom, withInset: 31)
    }
    
    // MARK: - Actions
    @objc func selectCountryDidTouch() {
        
    }
}
