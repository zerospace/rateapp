//
//  PopupPresentationController.swift
//  rateapp
//
//  Created by Oleksandr Fedko on 15.03.2023.
//

import UIKit

final class PopupPresentationController: UIPresentationController {
    private let dimView: UIVisualEffectView
    
    override var frameOfPresentedViewInContainerView: CGRect {
        guard let container = containerView else { return .zero }
        let size = CGSize(width: 345, height: 450) //size(forChildContentContainer: presentedViewController, withParentContainerSize: container.bounds.size)
        return CGRect(origin: CGPoint(x: (container.bounds.width - size.width) / 2.0, y: (container.bounds.height - size.height) / 2.0), size: size)
    }
    
    override init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController?) {
        self.dimView = UIVisualEffectView()
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
    }
    
    override func containerViewWillLayoutSubviews() {
        presentedView?.frame = frameOfPresentedViewInContainerView
    }
    
    override func size(forChildContentContainer container: UIContentContainer, withParentContainerSize parentSize: CGSize) -> CGSize {
        return presentedViewController.preferredContentSize
    }
    
    override func presentationTransitionWillBegin() {
        dimView.frame = containerView?.frame ?? .zero
        containerView?.insertSubview(dimView, at: 0)
        if let coordinator = presentedViewController.transitionCoordinator {
            coordinator.animate { _ in
                self.dimView.effect = UIBlurEffect(style: .dark)
            }
        }
    }
    
    override func dismissalTransitionWillBegin() {
        if let coordinator = presentedViewController.transitionCoordinator {
            coordinator.animate { _ in
                self.dimView.effect = nil
            } completion: { _ in
                self.dimView.removeFromSuperview()
            }
        }
    }
}
