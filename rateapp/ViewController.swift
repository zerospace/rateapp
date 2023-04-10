//
//  ViewController.swift
//  rateapp
//
//  Created by Oleksandr Fedko on 14.03.2023.
//

import UIKit

class ViewController: UIViewController, UIViewControllerTransitioningDelegate {
    @IBOutlet private weak var emojiLabel: UILabel!
    @IBOutlet private weak var desciptionLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    // MARK: - Actions
    @IBAction private func rateAction(_ sender: UIButton) {
        if let popup = UIStoryboard(name: "Main", bundle: .main).instantiateViewController(withIdentifier: "RatePopup") as? RatePopup {
            popup.modalPresentationStyle = .custom
            popup.transitioningDelegate = self
            popup.completion = { [weak self] value in
                self?.emojiLabel.text = value.emoji
            }
            present(popup, animated: true)
        }
    }
    
    // MARK: - UIViewControllerTransitioningDelegate
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return PopupPresentationController(presentedViewController: presented, presenting: presenting)
    }
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return PopupPresentationAnimator(isPresentation: true)
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return PopupPresentationAnimator(isPresentation: false)
    }
}

