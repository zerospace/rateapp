//
//  RatePopup.swift
//  rateapp
//
//  Created by Oleksandr Fedko on 15.03.2023.
//

import UIKit
import Combine

enum RateResult: Int {
    case none, bad, poor, fine, good, amazing
    
    var emoji: String {
        switch self {
        case .none: return "👻"
        case .bad: return "💩"
        case .poor: return "🤮"
        case .fine: return "😐"
        case .good: return "😍"
        case .amazing: return "🥰"
        }
    }
    
    var description: String {
        switch self {
        case .none: return ""
        case .bad: return ""
        case .poor: return ""
        case .fine: return ""
        case .good: return ""
        case .amazing: return ""
        }
    }
}

class RatePopup: UIViewController {
    var completion: ((RateResult) -> Void)?
    
    @IBOutlet private weak var closeButton: TransparentTitleButton!
    @IBOutlet private weak var rateControl: StarControl!
    
    private var gradientLayer = CAGradientLayer()
    private var cancellable: Cancellable?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.layer.cornerRadius = 16.0
        view.layer.masksToBounds = true
        
        gradientLayer.colors = [UIColor(red: 0.49, green: 0.0, blue: 1.0, alpha: 1.0).cgColor, UIColor(red: 0.88, green: 0.0, blue: 1.0, alpha: 1.0).cgColor]
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 1.0)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.0)
        view.layer.insertSublayer(gradientLayer, at: 0)
        
        rateControl.backgroundColor = .clear
        cancellable = rateControl.$rateValue.dropFirst().sink(receiveValue: { [weak self] value in
            DispatchQueue.main.asyncAfter(deadline: .now() + (value >= 4 ? 0.5 : 0.0)) {
                self?.completion?(RateResult(rawValue: value) ?? .none)
                self?.dismiss(animated: true)
            }
        })
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        closeButton.startAnimation(with: 5.0) {
            self.completion?(.none)
            self.dismiss(animated: true)
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        gradientLayer.frame = view.bounds
    }

    // MARK: - Actions
    @IBAction private func closeAction(_ sender: UIButton) {
        dismiss(animated: true)
    }
}
