//
//  BackUpKeysVC.swift
//  Commun
//
//  Created by Chung Tran on 11/27/19.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import Foundation

class GenerateMasterPasswordVC: BaseViewController, SignUpRouter {
    override var prefersNavigationBarStype: BaseViewController.NavigationBarStyle {.hidden}
    
    // MARK: - Properties
    var masterPassword: String?
    
    // MARK: - Subviews
    lazy var copyButton = UIButton.circle(size: 24, backgroundColor: .appGrayColor, tintColor: .appWhiteColor, imageName: "copy", imageEdgeInsets: UIEdgeInsets(inset: 6))
    lazy var backUpICloudButton = CommunButton.default(height: 50 * Config.heightRatio, label: "save to iCloud".localized().uppercaseFirst)

    lazy var iSavedItButton: UIButton = {
        let button = UIButton(label: "i saved it".localized().uppercaseFirst, textColor: .appMainColor, contentInsets: UIEdgeInsets(top: 10, left: 100, bottom: 10, right: 100))
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 15)
        return button
    }()
    
    // MARK: - Methods
    override func setUp() {
        super.setUp()
        AnalyticsManger.shared.openMasterPasswordGenerated()
        view.backgroundColor = .appWhiteColor
        
        let imageView = UIImageView(imageNamed: "masterkey-save")
        
        view.addSubview(imageView)
        imageView.autoPinEdge(toSuperviewSafeArea: .top)
        imageView.autoAlignAxis(toSuperviewAxis: .vertical)
        imageView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 1/2, constant: -32)
            .isActive = true
        imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor)
            .isActive = true
        
        let titleLabel = UILabel.with(text: "you are the owner".localized().uppercaseFirst, textSize: 33 * Config.heightRatio, weight: .bold)
        view.addSubview(titleLabel)
        titleLabel.autoPinEdge(.top, to: .bottom, of: imageView, withOffset: 13)
        titleLabel.autoAlignAxis(toSuperviewAxis: .vertical)
        
        let descriptionLabel = UILabel.with(text: "of your identity".localized(), textSize: 33 * Config.heightRatio)
        view.addSubview(descriptionLabel)
        descriptionLabel.autoPinEdge(.top, to: .bottom, of: titleLabel)
        descriptionLabel.autoAlignAxis(toSuperviewAxis: .vertical)
        
        let infoLabel = UILabel.with(numberOfLines: 0, textAlignment: .center)
        infoLabel.attributedText = NSMutableAttributedString()
            .text("commun doesn't have access to your password".localized().uppercaseFirst + ". ", size: 17 * Config.heightRatio, weight: .medium, color: .appGrayColor)
            .text("save it securely".localized().uppercaseFirst + "!", size: 17 * Config.heightRatio, weight: .medium)
        view.addSubview(infoLabel)
        infoLabel.autoPinEdge(.top, to: .bottom, of: descriptionLabel, withOffset: 6)
        infoLabel.autoPinEdge(toSuperviewEdge: .leading, withInset: 16)
        infoLabel.autoPinEdge(toSuperviewEdge: .trailing, withInset: 16)
        
        let masterPasswordContainer = UIView(cornerRadius: 10)
        masterPasswordContainer.borderWidth = 1
        masterPasswordContainer.borderColor = .appLightGrayColor
        view.addSubview(masterPasswordContainer)
        masterPasswordContainer.autoPinEdge(.top, to: .bottom, of: infoLabel, withOffset: 16)
        masterPasswordContainer.autoPinEdge(toSuperviewEdge: .leading, withInset: 16)
        masterPasswordContainer.autoPinEdge(toSuperviewEdge: .trailing, withInset: 16)
        
        let masterPasswordLabel = UILabel.with(text: "master password".localized().uppercaseFirst, textSize: 12 * Config.heightRatio, weight: .semibold, textColor: .appGrayColor)
        masterPasswordContainer.addSubview(masterPasswordLabel)
        masterPasswordLabel.autoPinTopAndLeadingToSuperView(inset: 10, xInset: 16)
        
        let masterPasswordContentLabel = UILabel.with(textSize: 17 * Config.heightRatio, weight: .bold)
        masterPasswordContainer.addSubview(masterPasswordContentLabel)
        masterPasswordContentLabel.autoPinEdge(.top, to: .bottom, of: masterPasswordLabel, withOffset: 8)
        masterPasswordContentLabel.autoPinBottomAndLeadingToSuperView(inset: 10, xInset: 16)
        
        masterPasswordContainer.addSubview(copyButton)
        copyButton.autoPinEdge(toSuperviewEdge: .trailing, withInset: 16)
        copyButton.autoPinEdge(.leading, to: .trailing, of: masterPasswordContentLabel, withOffset: 16)
        copyButton.autoAlignAxis(toSuperviewAxis: .horizontal)
        copyButton.addTarget(self, action: #selector(copyButtonDidTouch), for: .touchUpInside)
        
        view.addSubview(iSavedItButton)
        iSavedItButton.autoPinEdgesToSuperviewSafeArea(with: UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16), excludingEdge: .top)
        iSavedItButton.addTarget(self, action: #selector(iSavedItButtonDidTouch), for: .touchUpInside)
        
        view.addSubview(backUpICloudButton)
        backUpICloudButton.autoPinEdge(.bottom, to: .top, of: iSavedItButton, withOffset: -10)
        backUpICloudButton.autoPinEdge(toSuperviewEdge: .leading, withInset: 16)
        backUpICloudButton.autoPinEdge(toSuperviewEdge: .trailing, withInset: 16)
        backUpICloudButton.addTarget(self, action: #selector(backupIcloudDidTouch), for: .touchUpInside)
        
        // generate master password
        masterPassword = String.randomString(length: 51)
        masterPasswordContentLabel.text = masterPassword
    }
    
    @objc func copyButtonDidTouch() {
        guard let key = masterPassword else {return}
        UIPasteboard.general.string = key
        showDone("copied to clipboard".localized().uppercaseFirst)
        AnalyticsManger.shared.passwordCopy()
    }
    
    @objc func iSavedItButtonDidTouch() {
        showAttention(subtitle: "master password attention note".localized().uppercaseFirst,
                      descriptionText: "unfortunately, blockchain doesn’t allow us".localized().uppercaseFirst,
                      backButtonLabel: "save to iCloud".localized().uppercaseFirst,
                      ignoreButtonLabel: "continue".localized().uppercaseFirst, ignoreAction: {
                            AnalyticsManger.shared.clickISaveItMasterPassword()
                            self.handlePassword()
                        }, backAction: {
                            AnalyticsManger.shared.clickBackupMasterPassword()
                            self.backupIcloudDidTouch()
        })
    }

    var backupAlert: UIAlertController?
    @objc func backupIcloudDidTouch() {
        guard let password = masterPassword, let userName = Config.currentUser?.name
        else {return}

        SecAddSharedWebCredential(URL.appDomain as CFString, userName as CFString, password as CFString) { [weak self] (error) in
            DispatchQueue.main.async {
                if error != nil {
                    self?.backupAlert = self?.showAlert(title: "oops, we couldn’t save your password".localized().uppercaseFirst, message: "You need to enable Keychain, then".localized().uppercaseFirst, buttonTitles: ["retry".localized().uppercaseFirst, "cancel".localized().uppercaseFirst], highlightedButtonIndex: 0) { (index) in
                        if index == 0 {
                            self?.backupIcloudDidTouch()
                        }
                        self?.backupAlert?.dismiss(animated: true, completion: nil)
                    }
                } else {
                    self?.handlePassword(saveToIcloud: true)
                }
            }
        }
    }
    
    func handlePassword(saveToIcloud: Bool = false) {
        self.showIndetermineHudWithMessage("saving to blockchain")
        RestAPIManager.instance.toBlockChain(password: masterPassword)
            .subscribe(onCompleted: {
                if saveToIcloud {
                    self.save()
                }
                AuthManager.shared.reload()
            }) { (error) in
                self.hideHud()
                self.handleSignUpError(error: error)
            }
            .disposed(by: self.disposeBag)
    }
    
    func save() {
        RestAPIManager.instance.backUpICloud()
    }
}
