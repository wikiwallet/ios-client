//
//  MasterPasswordViewController.swift
//  Commun
//
//  Created by Sergey Monastyrskiy on 25.11.2019.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import UIKit

class MasterPasswordViewController: UIViewController {
    // MARK: - Properties
    var masterPasswordAttentionView: MasterPasswordAttention = MasterPasswordAttention(frame: CGRect(x: CGFloat.adaptive(width: 10.0), y: 0.0, width: CGFloat.adaptive(width: 355.0), height: CGFloat.adaptive(height: 581.0)))

    
    // MARK: - IBOutlets
    @IBOutlet weak var titleLabel1: UILabel! {
        didSet {
            self.titleLabel1.tune(withText:         "master password".localized().uppercaseFirst,
                                  hexColors:        blackWhiteColorPickers,
                                  font:             UIFont(name: "SFProDisplay-Bold", size: CGFloat.adaptive(width: 33.0)),
                                  alignment:        .center,
                                  isMultiLines:     false)
        }
    }

    @IBOutlet weak var titleLabel2: UILabel! {
        didSet {
            self.titleLabel2.tune(withText:         "has been generated".localized(),
                                  hexColors:        blackWhiteColorPickers,
                                  font:             UIFont(name: "SFProDisplay-Regular", size: CGFloat.adaptive(width: 33.0)),
                                  alignment:        .center,
                                  isMultiLines:     false)
        }
    }

    @IBOutlet weak var describeLabel: UILabel! {
        didSet {
            self.describeLabel.tune(withText:       "describe master password".localized().uppercaseFirst,
                                    hexColors:      grayishBluePickers,
                                    font:           UIFont(name: "SFProDisplay-Regular", size: CGFloat.adaptive(width: 17.0)),
                                    alignment:      .center,
                                    isMultiLines:   true)
        }
    }

    @IBOutlet weak var noteLabel: UILabel! {
        didSet {
            self.noteLabel.tune(withText:           "master password".localized().uppercaseFirst,
                                hexColors:          grayishBluePickers,
                                font:               UIFont(name: "SFProText-Regular", size: CGFloat.adaptive(width: 12.0)),
                                alignment:          .center,
                                isMultiLines:       false)
        }
    }

    @IBOutlet weak var passwordView: UIView! {
        didSet {
            self.passwordView.layer.cornerRadius = CGFloat.adaptive(width: 10.0)
            self.passwordView.layer.borderColor = UIColor(hexString: "#E2E6E8")?.cgColor
            self.passwordView.layer.borderWidth = 1.0
            self.passwordView.clipsToBounds = true
        }
    }
    
    @IBOutlet weak var masterPasswordTextField: UITextField! {
        didSet {
            
        }
    }
    
    @IBOutlet weak var backupiCloudButton: UIButton! {
        didSet {
            self.backupiCloudButton.backgroundColor = #colorLiteral(red: 0.4156862745, green: 0.5019607843, blue: 0.9607843137, alpha: 1)
            self.backupiCloudButton.setTitleColor(.white, for: .normal)
            self.backupiCloudButton.titleLabel?.font = .boldSystemFont(ofSize: 15)
            self.backupiCloudButton.layer.cornerRadius = self.backupiCloudButton.frame.height / 2
            self.backupiCloudButton.clipsToBounds = true
            self.backupiCloudButton.setTitle("backup iCloud".localized().uppercaseFirst, for: .normal)
        }
    }

    @IBOutlet weak var iSavedButton: BlankButton! {
        didSet {
            self.iSavedButton.titleLabel?.font = UIFont(name: "SFProDisplay-Bold", size: CGFloat.adaptive(width: 15.0))
        }
    }
    
    // MARK: - Class Functions
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.addSubview(self.masterPasswordAttentionView)
        self.masterPasswordAttentionView.display(false)
        
        // Attention view cancel
        self.masterPasswordAttentionView.closeButtonTapHandler = {
            self.showBlackoutView(false)
        }

        // Attention view save backup
        self.masterPasswordAttentionView.saveBackupButtonTapHandler = {
            self.showBlackoutView(false)
        }

        // Attention view continue
        self.masterPasswordAttentionView.continueButtonTapHandler = {
            self.showBlackoutView(false)
            AppDelegate.reloadSubject.onNext(true)
//            self.navigationController?.pushViewController(SetPasscodeVC(), animated: true)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)

        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }

    
    // MARK: - Custom Functions
    
    
    // MARK: - Actions
    @IBAction func copyButtonTapped(_ sender: Any) {
        guard let masterPassword = self.masterPasswordTextField.text?.trimmingCharacters(in: .whitespaces), !masterPassword.isEmpty else { return }
        
        self.view.endEditing(true)
        self.showIndetermineHudWithMessage("copy master password to clipboard".localized().uppercaseFirst)
        UIPasteboard.general.string = masterPassword
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.hideHud()
        }
    }
    
    @IBAction func backupButtonTapped(_ sender: Any) {
    
    }
    
    @IBAction func iSavedButtonTapped(_ sender: Any) {
        self.showBlackoutView(true)
        self.view.bringSubviewToFront(self.masterPasswordAttentionView)
        self.masterPasswordAttentionView.display(true)
    }
}
