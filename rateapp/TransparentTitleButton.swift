//
//  TransparentTitleButton.swift
//  rateapp
//
//  Created by Oleksandr Fedko on 17.03.2023.
//

import UIKit

class TransparentTitleButton: UIButton, CAAnimationDelegate {
    private var fillCollor: UIColor?
    
    private let backgroundLayer = CALayer()
    private let maskLayer = CALayer()
    private let dimLayer = CALayer()
    
    private var animationCompletion: (() -> Void)?
    
    override var isHighlighted: Bool {
        didSet {
            dimLayer.opacity = isHighlighted ? 1.0 : 0.0
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setup()
    }
    
    private func setup() {
        fillCollor = backgroundColor
        backgroundColor = .clear
        setTitleColor(.clear, for: .normal)
        
        dimLayer.backgroundColor = UIColor(white: 0.0, alpha: 0.1).cgColor
        dimLayer.opacity = 0.0
        layer.addSublayer(dimLayer)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        dimLayer.frame = bounds
        dimLayer.cornerRadius = layer.cornerRadius
    }
    
    override func draw(_ rect: CGRect) {
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)

        var context = UIGraphicsGetCurrentContext()
        context?.addPath(UIBezierPath(roundedRect: rect, cornerRadius: layer.cornerRadius).cgPath)
        context?.setFillColor(UIColor.black.cgColor)
        context?.drawPath(using: .fill)
        context?.setBlendMode(.destinationOut)

        if let label = titleLabel, let font = label.font {
            context?.saveGState()
            context?.concatenate(CGAffineTransformMake(1.0, 0.0, 0.0, -1.0, 0.0, rect.height))
            label.text?.draw(at: label.frame.origin, withAttributes: [.font : font])
            context?.restoreGState()
        }
        
        let image = context?.makeImage()
        UIGraphicsEndImageContext()
        if let mask = image {
            context = UIGraphicsGetCurrentContext()
            context?.clip(to: rect, mask: mask)
            fillCollor?.set()
            context?.fill([rect])
        }
    }
    
    func startAnimation(with duration: CGFloat, _ completion: @escaping () -> Void) {
        let rendererFormat = UIGraphicsImageRendererFormat()
        rendererFormat.scale = 0
        rendererFormat.preferredRange = .standard
        let renderer = UIGraphicsImageRenderer(bounds: frame, format: rendererFormat)
        backgroundLayer.frame = bounds
        isHidden = true
        let image = renderer.image {
            let path = UIBezierPath(roundedRect: renderer.format.bounds, cornerRadius: layer.cornerRadius)
            $0.cgContext.addPath(path.cgPath)
            $0.cgContext.clip()
            
            guard let view = self.superview else { return }
            view.drawHierarchy(in: view.bounds, afterScreenUpdates: true)
            UIColor(white: 1.0, alpha: 0.3).setFill()
            $0.fill(renderer.format.bounds, blendMode: .normal)
            if let label = self.titleLabel, let font = label.font, let color = fillCollor {
                label.text?.draw(at: self.convert(label.frame.origin, to: superview), withAttributes: [.font : font, .foregroundColor : color])
            }
        }
        isHidden = false
        backgroundLayer.contents = image.cgImage

        layer.insertSublayer(backgroundLayer, at: 0)

        maskLayer.anchorPoint = CGPoint(x: 0.0, y: 0.5)
        maskLayer.backgroundColor = UIColor.black.cgColor
        maskLayer.frame = CGRect(origin: .zero, size: CGSize(width: 0.0, height: bounds.height))
        backgroundLayer.mask = maskLayer
        
        var newBounds = maskLayer.bounds
        newBounds.size.width = bounds.width
        let animation = CABasicAnimation(keyPath: "bounds")
        animation.delegate = self
        animationCompletion = completion
        animation.timingFunction = CAMediaTimingFunction(name: .linear)
        animation.fromValue = maskLayer.bounds
        animation.toValue = newBounds
        animation.duration = duration
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        maskLayer.bounds = newBounds
        CATransaction.commit()
        maskLayer.add(animation, forKey: "boundsAnimation")
    }
    
    // MARK: - CAAnimationDelegate
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if flag {
            animationCompletion?()
        }
    }
}
