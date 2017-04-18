//
//  SlideUpAnimator.swift
//  HomeTeaching
//
//  Created by Devin Moss on 4/17/17.
//  Copyright © 2017 Devin Moss. All rights reserved.
//

import Foundation
import UIKit

class SlideDownAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    let duration = 0.5
    
    open func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }
    
    open func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let toViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)
        let fromViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)
        
        if toViewController == nil || fromViewController == nil {
            return
        }
        
        fromViewController?.view.transform = CGAffineTransform(translationX: 0, y: 0);
        transitionContext.containerView.addSubview(toViewController!.view)
        transitionContext.containerView.addSubview(fromViewController!.view)
        
        UIView.animate(withDuration: self.transitionDuration(using: transitionContext), animations: { () -> Void in
            fromViewController?.view.transform = CGAffineTransform(translationX: 0, y: (fromViewController?.view.frame.size.height)!);
        }, completion: { (finished) -> Void in
            transitionContext.completeTransition(true)
        })
    }
}
