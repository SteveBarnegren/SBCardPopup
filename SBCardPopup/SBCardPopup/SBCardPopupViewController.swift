//
//  SBCardPopupViewController.swift
//  SBCardPopup
//
//  Created by Steve Barnegren on 22/06/2017.
//  Copyright © 2017 Steve Barnegren. All rights reserved.
//

import UIKit

public class SBCardPopupViewController: UIViewController {
    
    // MARK: - Public Interface
    
    public init(contentViewController viewController: UIViewController) {
        contentViewController = viewController
        contentView = viewController.view
        super.init(nibName: nil, bundle: nil)
    }
    
    public init(contentView view: UIView) {
        contentViewController = nil
        contentView = view
        super.init(nibName: nil, bundle: nil)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Properties
    
    private let contentViewController: UIViewController?
    private let contentView: UIView
    
    private let containerView = UIView(frame: .zero)
    
    private var hasAnimatedIn = false
    
    private var containerOffscreenConstraint: NSLayoutConstraint!
    
    // MARK: - UIViewController
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.clear
        
        // Container view
        containerView.layer.cornerRadius = 5
        containerView.layer.masksToBounds = true
        view.addSubview(containerView)
        
        // Content
        if let contentViewController = contentViewController {
            addChildViewController(contentViewController)
        }
        containerView.addSubview(contentView)
        
        // Apply Constraints
        applyContainerViewConstraints()
        applyContentViewConstraints()
        containerOffscreenConstraint.isActive = true
        
        // Tap Away Recognizer
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapAway))
        view.addGestureRecognizer(tapRecognizer)
        
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if !hasAnimatedIn {
            animateIn()
            hasAnimatedIn = true
        }
    }
    
    // MARK: - Constraints
    
    private func applyContentViewConstraints() {
        
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        let margin = CGFloat(0)
        
        [NSLayoutAttribute.left, .right, .top, .bottom].forEach{
            
            var constant = margin
            if $0 == .right || $0 == .bottom {
                constant = -constant
            }
            
            let constraint = NSLayoutConstraint(item: contentView,
                                                attribute: $0,
                                                relatedBy: .equal,
                                                toItem: containerView,
                                                attribute: $0,
                                                multiplier: 1.0,
                                                constant: constant)
            containerView.addConstraint(constraint)
        }
    }
    
    private func applyContainerViewConstraints() {
        
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        let sideMargin = CGFloat(20)
        let verticalMargins = CGFloat(20)
        
        let left = NSLayoutConstraint(item: containerView,
                                      attribute: .left,
                                      relatedBy: .equal,
                                      toItem: view,
                                      attribute: .left,
                                      multiplier: 1.0,
                                      constant: sideMargin)
        
        let right = NSLayoutConstraint(item: containerView,
                                       attribute: .right,
                                       relatedBy: .equal,
                                       toItem: view,
                                       attribute: .right,
                                       multiplier: 1.0,
                                       constant: -sideMargin)
        
        let centreY = NSLayoutConstraint(item: containerView,
                                         attribute: .centerY,
                                         relatedBy: .equal,
                                         toItem: view,
                                         attribute: .centerY,
                                         multiplier: 1.0,
                                         constant: 0)
        centreY.priority = UILayoutPriorityDefaultLow
        
        let limitHeight = NSLayoutConstraint(item: containerView,
                                             attribute: .height,
                                             relatedBy: .lessThanOrEqual,
                                             toItem: view,
                                             attribute: .height,
                                             multiplier: 1.0,
                                             constant: -verticalMargins*2)
        limitHeight.priority = UILayoutPriorityDefaultHigh
        
        containerOffscreenConstraint = NSLayoutConstraint(item: containerView,
                                           attribute: .top,
                                           relatedBy: .equal,
                                           toItem: view,
                                           attribute: .bottom,
                                           multiplier: 1.0,
                                           constant: 0)
        containerOffscreenConstraint.priority = UILayoutPriorityRequired
        
        view.addConstraints([left, right, centreY, limitHeight, containerOffscreenConstraint])
    }
    
    private func pinContainerOffscreen(_ pinOffscreen: Bool) {
        containerOffscreenConstraint.isActive = pinOffscreen
    }

    
    // MARK: - Animation
    
    private func animateIn() {
        
        let duration = 0.6
        
        // Animate background color
        UIView.animate(withDuration: duration,
                       delay: 0.0,
                       options: [.curveEaseInOut],
                       animations: {
                        self.view.backgroundColor = UIColor(white: 0, alpha: 0.6)
        }, completion: nil)
        
        // Animate container on screen
        containerOffscreenConstraint.isActive = false
        view.setNeedsLayout()
        
        UIView.animate(withDuration: duration,
                       delay: 0.0,
                       usingSpringWithDamping: 0.8,
                       initialSpringVelocity: 0,
                       options: [],
                       animations: {
            self.view.layoutIfNeeded()
        }, completion: {
            _ in
        })
    }
    
    private func animateOut() {
        
        view.isUserInteractionEnabled = false
        
        let duration = 0.6

        // Animate background color
        UIView.animate(withDuration: duration,
                       delay: 0.0,
                       options: [.curveEaseInOut],
                       animations: {
                        self.view.backgroundColor = UIColor.clear
        }, completion: nil)
        
        // Animate container off screen
        containerOffscreenConstraint.isActive = true
        view.setNeedsLayout()
        
        UIView.animate(withDuration: duration,
                       delay: 0.0,
                       usingSpringWithDamping: 0.8,
                       initialSpringVelocity: 0,
                       options: [],
                       animations: {
            self.view.layoutIfNeeded()
        }, completion: {
            _ in
            self.removeFromParentViewController()
            self.view.removeFromSuperview()
        })
    }
    
    // MARK: - Gestures
    
    @objc private func tapAway() {
        animateOut()
    }
    
}
