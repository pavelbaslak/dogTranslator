//
//  SettingController.swift
//  dogTranslator
//
//  Created by Stas Dashkevich on 15.12.22.
//

import Foundation
import UIKit
import SnapKit

class SettingController: UIViewController {
    
    lazy var header = Label(style: .navigationHeader, NSLocalizedString("titleSetting", comment: ""))
    lazy var doneButton = Button(style: .doneButton, NSLocalizedString("buttonDone", comment: ""))
    lazy var background = ImageView(style: .mainBackgroundImage)
    lazy var subImage = ImageView(style: .settingSub)
    lazy var subView = View(style: .clearView)
    lazy var subLabel = Label(style: .semibold22, NSLocalizedString("settingUnlock", comment: ""))
    lazy var crownImage = ImageView(style: .settingSub)
    
    lazy var settingLabel = Label(style: .medium22, NSLocalizedString("settingUnlock", comment: ""))
    lazy var settingImage = ImageView(style: .settingCrown)
    
    lazy var openSub = UITapGestureRecognizer(target: self, action: #selector(openSubscription))
    var sub = UserDefaults.standard.value(forKey: "getter2") as? String ?? "1"
    var rateUs = UserDefaults.standard.value(forKey: "rateUs") as? String ?? "0"
    
    var sections = 6
    
    lazy var tableView: UITableView = {
        let tb = UITableView()
        tb.translatesAutoresizingMaskIntoConstraints = false
        tb.delegate = self
        tb.dataSource = self
        
        return tb
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(reloadSetting), name: Notification.Name("reloadSetting"), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setUpUI()

    }
}

extension SettingController: UIViewControllerTransitioningDelegate {
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return PresentTransition()
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return DismissTransition()
    }
    
    @objc func reloadSetting() {
        
    }
}
