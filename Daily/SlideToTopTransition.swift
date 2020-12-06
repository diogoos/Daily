//
//  SlideToTopTransition.swift
//  Daily
//
//  Created by Diogo Silva on 11/15/20.
//

import UIKit

class SlideToTopTransition: NSObject, UIViewControllerAnimatedTransitioning, UIViewControllerTransitioningDelegate {
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return SlideToTopTransition()
    }

    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return SlideToTopTransition()
    }

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 1
    }

    enum AnimationDirection {
        case slideIn
        case slideOut
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        var direction: AnimationDirection
        var animatedView: UIView

        // Set the animated view and the sliding direction
        if let fromView = transitionContext.view(forKey: UITransitionContextViewKey.from) {
            direction = .slideOut
            animatedView = fromView
        } else if let toView = transitionContext.view(forKey: UITransitionContextViewKey.to) {
            direction = .slideIn
            animatedView = toView
        } else {
            return
        }

        // Set up the transform for sliding
        let container = transitionContext.containerView
        let offScreenDrawerFrame = CGRect(origin: CGPoint(x: 0, y: container.frame.height * -1), size: container.frame.size)
        let animation = direction == .slideIn ? CGAffineTransform(translationX: 0, y: container.frame.height) :
                                                CGAffineTransform(translationX: 0, y: container.frame.height * -1)

        // Set the frame and add the subviews
        if direction == .slideIn { animatedView.frame = offScreenDrawerFrame }
        container.addSubview(animatedView)

        // Perform the animation
        UIView.animate(withDuration: transitionDuration(using: transitionContext),
                       delay: 0.0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0.3, options: [],
                       animations: {
            animatedView.transform = animation
        }, completion: { finished in
            transitionContext.completeTransition(true)
        })
    }
}
