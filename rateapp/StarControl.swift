//
//  StarControl.swift
//  rateapp
//
//  Created by Oleksandr Fedko on 03.04.2023.
//

import UIKit

enum StarControlAlignment {
    case left, center, right
}

class StarControl: UIView {
    var alignment = StarControlAlignment.center {
        didSet { setNeedsDisplay() }
    }
    
    var itemSize = CGSize(width: 50.0, height: 50.0) {
        didSet { setNeedsDisplay() }
    }
    
    var itemOffset: CGFloat = 5.0 {
        didSet { setNeedsDisplay() }
    }
    
    var image = UIImage(named: "star") {
        didSet {
            setNeedsDisplay() }
    }
    
    var fillImage = UIImage(named: "star_fill") {
        didSet { setNeedsDisplay() }
    }
    
    @Published private(set) var rateValue: Int = 0 {
        didSet { setNeedsDisplay() }
    }
    private var rects = [CGRect]()
    
    override func draw(_ rect: CGRect) {
        rects.removeAll()
        var x: CGFloat
        switch alignment {
        case .left:
            x = itemOffset
        case .center:
            x = rect.midX - (itemSize.width * 2 + itemOffset * 3 + itemSize.width / 2.0)
        case .right:
            x = rect.maxX - (itemSize.width * 5 + itemOffset * 6)
        }
        
        for i in 1...5 {
            guard let itemImage = i <= rateValue ? fillImage : image else { continue }
            let itemRect = CGRect(origin: CGPoint(x: x, y: (rect.size.height - itemSize.height) / 2.0), size: itemSize)
            rects.append(itemRect)
            let ratio = fmax(itemImage.size.width / itemRect.width, itemImage.size.height / itemRect.height)
            let width = itemImage.size.width / ratio
            let height = itemImage.size.height / ratio
            itemImage.draw(in: CGRect(x: x + (itemRect.width - width) / 2.0, y: itemRect.minY + (itemRect.height - height) / 2.0, width: width, height: height))
            x += itemOffset + itemSize.width
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let position = touch.location(in: self)
            if let index = rects.firstIndex(where: { $0.contains(position) }) {
                rateValue = index + 1
                if rateValue >= 4 {
                    let rect = rects[index]
                    let confetti = CAEmitterLayer()
                    confetti.opacity = 0
                    confetti.frame = bounds
                    confetti.emitterPosition = CGPoint(x: rect.midX, y: rect.midY)
                    confetti.emitterSize = CGSize(width: rect.height, height: rect.height)
                    confetti.emitterCells = [emiterCell(with: image, name: "star"), emiterCell(with: fillImage, name: "fill_star")]
                    layer.insertSublayer(confetti, at: 0)
                    
                    let groupAnimation = CAAnimationGroup()
                    groupAnimation.duration = 1.0
                    groupAnimation.timingFunction = CAMediaTimingFunction(name: .linear)
                    var animations = [CAAnimation]()
                    confetti.emitterCells?.forEach {
                        if let name = $0.name {
                            let anim = CABasicAnimation(keyPath: "emitterCells.\(name).velocity")
                            anim.fromValue = 0
                            anim.toValue = 300
                            anim.duration = 0.25
                            animations.append(anim)
                        }
                    }
                    
                    let alphaAnimation = CAKeyframeAnimation(keyPath: "opacity")
                    alphaAnimation.values = [0.0, 1.0, 0.0]
                    alphaAnimation.keyTimes = [0.0, 0.25, 1.0]
                    animations.append(alphaAnimation)
                    
                    groupAnimation.animations = animations
                    CATransaction.begin()
                    CATransaction.setCompletionBlock {
                        confetti.removeFromSuperlayer()
                    }
                    confetti.add(groupAnimation, forKey: nil)
                    CATransaction.commit()
                }
            }
        }
    }
    
    // MARK: - Private
    private func emiterCell(with image: UIImage?, name: String?) -> CAEmitterCell {
        let cell = CAEmitterCell()
        cell.name = name
        cell.contents = image?.cgImage
        cell.birthRate = 200
        cell.lifetime = 0.5
        cell.lifetimeRange = 0.5
        cell.emissionRange = .pi * 2.0
        cell.spinRange = .pi * 4.0
        cell.scale = 0.05
        cell.scaleRange = 0.1
        return cell
    }
}
