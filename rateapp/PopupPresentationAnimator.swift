//
//  PopupPresentationAnimator.swift
//  rateapp
//
//  Created by Oleksandr Fedko on 15.03.2023.
//

import UIKit

final class PopupPresentationAnimator: NSObject, UIViewControllerAnimatedTransitioning, CAAnimationDelegate {
    private let isPresentation: Bool
    private var transitionContext: UIViewControllerContextTransitioning?
    
    init(isPresentation: Bool) {
        self.isPresentation = isPresentation
        super.init()
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.3
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        self.transitionContext = transitionContext
        let controller = transitionContext.viewController(forKey: isPresentation ? .to : .from)!
        var frame = transitionContext.finalFrame(for: controller)
        frame.origin = CGPoint(x: (transitionContext.containerView.bounds.width - frame.width) / 2.0, y: (transitionContext.containerView.bounds.height - frame.height) / 2.0)
        controller.view.frame = frame
        if isPresentation {
            transitionContext.containerView.addSubview(controller.view)
        }
        
        let animation = CAKeyframeAnimation(keyPath: "transform")
        animation.keyTimes = [0.0, 1.0]
        animation.fillMode = .forwards
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        animation.duration = transitionDuration(using: transitionContext)
        if isPresentation {
            animation.values = [CATransform3DMakeScale(1.5, 1.5, 1.0), CATransform3DMakeScale(1.0, 1.0, 1.0)]
        }
        else {
            animation.values = [CATransform3DMakeScale(1.0, 1.0, 1.0), CATransform3DMakeScale(0.5, 0.5, 1.0)]
        }
        
        let fade = CABasicAnimation(keyPath: "opacity")
        fade.duration = transitionDuration(using: transitionContext)
        fade.fromValue = isPresentation ? 0.0 : 1.0
        fade.toValue = isPresentation ? 1.0 : 0.0
        
        controller.view.layer.opacity = isPresentation ? 1.0 : 0.0
        
        let group = CAAnimationGroup()
        group.delegate = self
        group.animations = [fade, animation]
        group.setValue("groupAnimation", forKey: "animationName")
        controller.view.layer.add(group, forKey: "groupAnimation")
    }
    
    // MARK: - CAAnimationDelegate
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if flag {
            if let context = transitionContext, let name = anim.value(forKey: "animationName") as? String, name == "groupAnimation" {
                context.completeTransition(true)
            }
        }
    }
}
