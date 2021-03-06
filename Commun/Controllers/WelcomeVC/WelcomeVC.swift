//
//  WelcomeVC.swift
//  Commun
//
//  Created by Chung Tran on 3/25/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation

class WelcomeVC: BaseViewController {
    override var prefersNavigationBarStype: BaseViewController.NavigationBarStyle {.hidden}
    let numberOfPages = 3
    
    // MARK: - Properties
    lazy var pageVC = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
    var currentPage = 0
    
    // MARK: - Subviews
    lazy var topSignInButton = UIButton(label: "sign in".localized().uppercaseFirst, labelFont: .systemFont(ofSize: 15, weight: .medium), textColor: .appBlackColor)
    lazy var pageControl = CMPageControll(numberOfPages: numberOfPages)
    lazy var containerView = UIView(forAutoLayout: ())
    lazy var buttonStackView = UIStackView(axis: .vertical, spacing: 10, alignment: .fill, distribution: .fillEqually)
    
    lazy var nextButton = CommunButton.default(height: 50, label: "next".localized().uppercaseFirst, isHuggingContent: false)
    lazy var startButton = CommunButton.default(height: 50, label: "start".localized().uppercaseFirst, isHuggingContent: false)
//    lazy var signUpButton: UIView = {
//        let view = UIView(height: 50, backgroundColor: .appMainColor, cornerRadius: 25)
//        let hStack = UIStackView(axis: .horizontal, spacing: 10, alignment: .center, distribution: .fill)
//        hStack.addArrangedSubviews([
//            UILabel.with(text: "start and get 30 points".localized().uppercaseFirst, textSize: 15, weight: .semibold, textColor: .white),
//            UIImageView(width: 35, height: 33, imageNamed: "coin-reward")
//        ])
//        view.addSubview(hStack)
//        hStack.autoCenterInSuperview()
//
//        view.isUserInteractionEnabled = true
//        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(signUpButtonTap(_:))))
//        return view
//    }()
    
    // MARK: - Methods
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        pageVC.view.translatesAutoresizingMaskIntoConstraints = false
        pageVC.view.autoPinEdgesToSuperviewEdges()
        containerView.setNeedsLayout()
    }
    
    override func setUp() {
        super.setUp()
        // navigation bar
        let navigationBarAppearace = UINavigationBar.appearance()
        navigationBarAppearace.tintColor = .appMainColor
        navigationBarAppearace.largeTitleTextAttributes = [
            .foregroundColor: UIColor.appBlackColor,
            .font: UIFont.systemFont(ofSize: .adaptive(width: 30), weight: .bold)
        ]
        
        // top sign in button
        view.addSubview(topSignInButton)
        topSignInButton.autoPinTopAndTrailingToSuperViewSafeArea(inset: 0, xInset: 16)
        topSignInButton.addTarget(self, action: #selector(signInButtonTap(_:)), for: .touchUpInside)
        
        // page control
        view.addSubview(pageControl)
        pageControl.autoAlignAxis(.horizontal, toSameAxisOf: topSignInButton)
        pageControl.autoAlignAxis(toSuperviewAxis: .vertical)
        
        pageControl.selectedIndex = 0
        
        // button stack view
        view.addSubview(buttonStackView)
        buttonStackView.autoPinEdge(toSuperviewSafeArea: .bottom, withInset: 16)
        buttonStackView.autoPinEdge(toSuperviewEdge: .leading, withInset: 20)
        buttonStackView.autoPinEdge(toSuperviewEdge: .trailing, withInset: 20)
        buttonStackView.autoAlignAxis(toSuperviewAxis: .vertical)
        
        buttonStackView.addArrangedSubviews([
            nextButton,
            startButton
        ])
        
        startButton.addTarget(self, action: #selector(startButtonDidTap(_:)), for: .touchUpInside)
        nextButton.addTarget(self, action: #selector(nextButtonTap(_:)), for: .touchUpInside)
        
        // container view
        view.addSubview(containerView)
        containerView.autoPinEdge(.bottom, to: .top, of: buttonStackView, withOffset: .adaptive(width: -50))
        containerView.autoPinEdge(toSuperviewEdge: .top, withInset: 10)
        containerView.autoPinEdge(toSuperviewEdge: .leading)
        containerView.autoPinEdge(toSuperviewEdge: .trailing)

        view.bringSubviewToFront(pageControl)
        view.bringSubviewToFront(topSignInButton)

        // add pageVC
        pageVC.dataSource = self
        pageVC.delegate = self
        addChild(pageVC)
        containerView.addSubview(pageVC.view)
        pageVC.didMove(toParent: self)
        kickOff()
    }
    
    func showActionButtons(_ index: Int) {
        let lastScreenIndex = numberOfPages - 1
        nextButton.isHidden = index == lastScreenIndex
//        topSignInButton.isHidden = index == lastScreenIndex
        startButton.isHidden = index != lastScreenIndex
//        coinImageView.isHidden = index != lastScreenIndex
    }
    
    // MARK: - Actions
    private func kickOff() {
        let firstVC = WelcomeItemVC(index: 0)
        pageVC.setViewControllers([firstVC], direction: .forward, animated: true, completion: nil)
        showActionButtons(0)
    }
    
    @objc func signInButtonTap(_ sender: UIButton) {
        let signInVC = SignInVC()
        show(signInVC, sender: nil)
    }
    
    @objc func nextButtonTap(_ sender: Any) {
        let nextIndex = currentPage + 1
        pageVC.setViewControllers([WelcomeItemVC(index: nextIndex)], direction: .forward, animated: true, completion: nil)
        currentPage = nextIndex
        showActionButtons(nextIndex)
        pageControl.selectedIndex = nextIndex
    }
    
    @objc func startButtonDidTap(_ sender: Any) {
        UserDefaults.standard.set(true, forKey: Config.currentUserDidShowWelcomeScreen)
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            appDelegate.changeRootVC(appDelegate.splashVC)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                appDelegate.changeRootVC(NonAuthTabBarVC())
            }
        }
    }
}

extension WelcomeVC: UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let vc = viewController as? WelcomeItemVC,
            vc.index != 0
        else {return nil}
        return WelcomeItemVC(index: vc.index - 1)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let vc = viewController as? WelcomeItemVC,
            vc.index < numberOfPages - 1
        else {return nil}
        return WelcomeItemVC(index: vc.index + 1)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if let vc = pageVC.viewControllers?.first as? WelcomeItemVC {
            let index = vc.index
            showActionButtons(index)
            pageControl.selectedIndex = index
            currentPage = index
        }
    }
}
