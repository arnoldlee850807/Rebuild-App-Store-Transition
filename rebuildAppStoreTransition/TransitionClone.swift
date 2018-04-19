//
//  TransitionClone.swift
//  rebuildAppStoreTransition
//
//  Created by Arnold Lee on 4/17/18.
//  Copyright © 2018 Arnold Lee. All rights reserved.
//

import UIKit

class TransitionClone: NSObject {
    
    var startingFrame = CGRect.zero
    var destinationFrame = CGRect.zero
    var shadow = UIView()
    let duration = 1.5
    
    enum TransitionMode: Int {
        case present
        case dismiss
        case pop
    }
    
    var transitionMode: TransitionMode = .present
    
}

extension TransitionClone: UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        let containerView = transitionContext.containerView
        
        if transitionMode == .present{
            
            if let presentingView = transitionContext.view(forKey: UITransitionContextViewKey.to){
        
                let initialFrame = startingFrame // cell frame
                
                let finalFrame = destinationFrame //presented image frame
                
                let scaleX = initialFrame.width / finalFrame.width
                
                let scaleY = initialFrame.height / finalFrame.height
                
                shadow.backgroundColor = UIColor.lightGray
                
                shadow.frame = containerView.frame
                
                shadow.alpha = 0
                
                containerView.addSubview(shadow)
                
                presentingView.frame = destinationFrame
                
                presentingView.transform = CGAffineTransform(scaleX: scaleX, y: scaleY)
                
                presentingView.center = CGPoint(x: initialFrame.midX, y: initialFrame.midY)
                
                presentingView.clipsToBounds = true
                
                presentingView.layer.cornerRadius = 30
                
                containerView.addSubview(presentingView)
                
                containerView.bringSubview(toFront: presentingView)
                
                UIView.animate(withDuration: duration, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseIn, animations: {
                    
                    self.shadow.alpha = 0.95
                    
                    presentingView.transform = CGAffineTransform.identity
                    presentingView.layer.cornerRadius = 0
                    presentingView.frame.origin = CGPoint(x: 0, y: 0)
                    
                    presentingView.frame.size = containerView.frame.size
                    
                }) { (success) in
                    transitionContext.completeTransition(success)
                }
            }
        }
        else{
            let transitionModeKey = (transitionMode == .pop) ? UITransitionContextViewKey.to : UITransitionContextViewKey.from

            if let returningView = transitionContext.view(forKey: transitionModeKey){

                let initialFrame = destinationFrame
                
                let finalFrame = startingFrame
                
                print("\(finalFrame.width, initialFrame.width)")
                print("\(finalFrame.height, initialFrame.height)")
                
                let scaleX = finalFrame.width / initialFrame.width
                
                let scaleY = finalFrame.height / initialFrame.height
                
                shadow.backgroundColor = UIColor.lightGray
                
                shadow.frame = containerView.frame
                
                shadow.alpha = 0.95
                
                containerView.addSubview(shadow)
                
                returningView.clipsToBounds = true
                
                containerView.addSubview(returningView)
                containerView.bringSubview(toFront: returningView)
                
                containerView.sendSubview(toBack: containerView)
                
                UIView.animate(withDuration: duration, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseIn, animations: {
                    
                    self.shadow.alpha = 0
                    
                    returningView.transform = CGAffineTransform(scaleX: scaleX, y: scaleY)
                    returningView.layer.cornerRadius = 15
                    returningView.frame = finalFrame
                    
                    
                    if self.transitionMode == .pop {
                        containerView.insertSubview(returningView, belowSubview: returningView)
                    }
                    
                }) { (success) in
                    
                    returningView.removeFromSuperview()
    
                    transitionContext.completeTransition(success)
                    
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "tabBarShow"), object: nil)
                    
                    
                }
            }
        }
    }
}
