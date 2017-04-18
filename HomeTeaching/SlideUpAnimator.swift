//
//  SlideUpAnimator.swift
//  HomeTeaching
//
//  Created by Devin Moss on 4/17/17.
//  Copyright © 2017 Devin Moss. All rights reserved.
//

import Foundation
import UIKit

class SlideUpAnimator: NSObject, UIViewControllerAnimatedTransitioning {
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
        
        toViewController!.view.frame = transitionContext.finalFrame(for: toViewController!)
        toViewController?.view.transform = CGAffineTransform(translationX: 0, y: (toViewController?.view.frame.size.height)!);
        transitionContext.containerView.addSubview(fromViewController!.view)
        transitionContext.containerView.addSubview(toViewController!.view)
        
        UIView.animate(withDuration: self.transitionDuration(using: transitionContext), animations: { () -> Void in
            toViewController?.view.transform = CGAffineTransform(translationX: 0, y: 0);
        }, completion: { (finished) -> Void in
            transitionContext.completeTransition(true)
        })
    }
}
