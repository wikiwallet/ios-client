//
//  SettingsVC+SectionHeader.swift
//  Commun
//
//  Created by Chung Tran on 18/07/2019.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation

extension SettingsVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case 0, 1, 2:
            return 56
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = .white

        let label = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 56))
        label.font = .boldSystemFont(ofSize: 22)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(label)
        
        label.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16).isActive = true
        

        switch section {
        case 0:
            label.text = "General".localized()
            break

        case 1:
            label.text = "Notifications".localized()
            let switcher = UISwitch(frame: CGRect.zero)
            switcher.translatesAutoresizingMaskIntoConstraints = false
            switcher.onTintColor = .appMainColor
            switcher.isOn = viewModel.notificationOn.value
            
            viewModel.optionsPushShow
                .filter {$0 != nil}
                .filter {
                    !$0!.upvote &&
                    !$0!.downvote &&
                    !$0!.transfer &&
                    !$0!.reply &&
                    !$0!.mention &&
                    !$0!.reward &&
                    !$0!.curatorReward &&
                    !$0!.subscribe &&
                    !$0!.repost
                }
                .subscribe(onNext: {_ in
                    switcher.rx.isOn.onNext(false)
                    switcher.sendActions(for: .valueChanged)
                })
                .disposed(by: bag)
            
            switcher.rx.isOn
                .skip(1)
                .subscribe(onNext: {isOn in
                    self.viewModel.togglePushNotify(on: isOn)
                        .subscribe( onCompleted: {
                            self.viewModel.getOptionsPushShow()
                        }, onError: {[weak self] (error) in
                            switcher.isOn = !switcher.isOn
                            self?.showError(error)
                        })
                        .disposed(by: self.bag)
                })
                .disposed(by: bag)
            
            view.addSubview(switcher)
            
            switcher.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
            switcher.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16).isActive = true
            break

        case 2:
            label.text = "Passwords".localized()
            break

        default:
            label.text = ""
        }

        return view
    }
}
