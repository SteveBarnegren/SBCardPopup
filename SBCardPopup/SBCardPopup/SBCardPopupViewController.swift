//
//  SBCardPopupViewController.swift
//  SBCardPopup
//
//  Created by Steve Barnegren on 22/06/2017.
//  Copyright © 2017 Steve Barnegren. All rights reserved.
//

import UIKit

public protocol SBCardPopupContent: class {
    weak var popupViewController: SBCardPopupViewController? {get set}
    var allowsTapToDismissPopupCard: Bool {get}
}

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
    
    public func close() {
        animateOut()
    }
    
    public func show(onViewController viewController: UIViewController) {
        
        self.modalPresentationStyle = .overCurrentContext
        viewController.present(self, animated: false, completion: nil)
    }
    
    // MARK: - Types
    
    enum State {
        case animatingIn
        case idle
        case panning
        case physicsOut(PhysicsState)
    }
    
    struct PhysicsState {
        let acceleration = CGFloat(9999)
        var velocity = CGFloat(0)
    }
    
    // MARK: - Properties
    
    private let backgroundOpacity = CGFloat(0.6)
    
    private var displayLink: CADisplayLink!
    private var lastTimeStamp: CFTimeInterval?
    
    private let contentViewController: UIViewController?
    private let contentView: UIView
    
    private let containerView = UIView(frame: .zero)
    
    private var hasAnimatedIn = false
    
    private var containerOffscreenConstraint: NSLayoutConstraint!
    
    private var swipeOffset = CGFloat(0)
    
    private var popupProtocolResponder: SBCardPopupContent? {
        
        if let contentViewController = contentViewController {
            if let protocolResponder = contentViewController as? SBCardPopupContent {
                return protocolResponder
            }
        }
        else if let protocolResponder = contentView as? SBCardPopupContent {
            return protocolResponder
        }
        
        return nil
    }
    
    private var state = State.animatingIn {
        didSet{
            
            switch state {
            case .idle: print("STATE: Idle")
            case .animatingIn: print("STATE: Animating in")
            case .panning: print("STATE: Panning")
            case .physicsOut: print("STATE: Physics Out")
            }
        }
    }
    
    // MARK: - UIViewController
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.clear
        
        // Container view
        containerView.layer.cornerRadius = 5
        containerView.layer.masksToBounds = true
        view.addSubview(containerView)
        containerView.isUserInteractionEnabled = false
        
        // Content
        if let contentViewController = contentViewController {
            addChildViewController(contentViewController)
        }
        containerView.addSubview(contentView)
        
        // Popup Protocol Responder
        popupProtocolResponder?.popupViewController = self
        
        // Apply Constraints
        applyContainerViewConstraints()
        applyContentViewConstraints()
        containerOffscreenConstraint.isActive = true
        
        // Tap Away Recognizer
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapAway))
        view.addGestureRecognizer(tapRecognizer)
        
        // Pan Recognizer
        let panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(didPan))
        view.addGestureRecognizer(panRecognizer)
        
        // Display Link
        displayLink = CADisplayLink(target: self, selector: #selector(tick))
        displayLink.add(to: .current, forMode: .commonModes)
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if !hasAnimatedIn {
            animateIn()
            hasAnimatedIn = true
        }
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // Container View
        containerView.frame.origin.y += swipeOffset
      
        // Update background color if panning or physics out
        switch state {
        case .animatingIn: break
        case .idle: break
        case .panning: fallthrough
        case .physicsOut:
            
            let outPct = 1.0 - (swipeOffset / view.bounds.size.height/2)
            let opacity = backgroundOpacity * outPct
            view.backgroundColor = UIColor(white: 0, alpha: opacity)
        }
    }
    
    // MARK: - Constraints
    
    private func applyContentViewConstraints() {
        
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        [NSLayoutAttribute.left, .right, .top, .bottom].forEach{
            
            let constraint = NSLayoutConstraint(item: contentView,
                                                attribute: $0,
                                                relatedBy: .equal,
                                                toItem: containerView,
                                                attribute: $0,
                                                multiplier: 1.0,
                                                constant: 0)
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
                        self.view.backgroundColor = UIColor(white: 0, alpha: self.backgroundOpacity)
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
            self.containerView.isUserInteractionEnabled = true
            self.state = .idle
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
            self.dismiss(animated: false, completion: nil)
        })
    }
    
    // MARK: - Gestures
    
    @objc private func tapAway() {
        
        if let protocolResponder = popupProtocolResponder {
            if protocolResponder.allowsTapToDismissPopupCard {
                animateOut()
            }
        }
        else{
            animateOut()
        }
        
    }
    
    @objc private func didPan(recognizer: UIPanGestureRecognizer) {
        print("did pan")
        
        guard
            state == .idle || state == .panning
            else { return }
        
        let location = recognizer.location(in: view)
        print("Location: \(location)")
        
        let applyOffset = {
            self.swipeOffset = recognizer.translation(in: self.view).y
            self.view.setNeedsLayout()
        }
        
        switch recognizer.state {
        case .possible:
            break
        case .began:
            state = .panning
            applyOffset()
        case .changed:
            applyOffset()
        case .cancelled:
            break
        case .failed:
            break
        case .ended:
            animateOut(fromPan: recognizer)
        }
    
    }
    
    private func animateOut(fromPan panRecognizer: UIPanGestureRecognizer) {
        
//        let animateOutThreshold = CGFloat(50)
//        
//        let velocity = panRecognizer.velocity(in: view).y
//        let magnitude = fabs(velocity)
//        
//        if magnitude > animateOutThreshold {
//            
//        }
        
        let velocity = panRecognizer.velocity(in: view).y
        
        let physicsState = PhysicsState(velocity: velocity)
        state = .physicsOut(physicsState)
    }
    
    // MARK: - Display Link
    
    func tick() {
        
        // We need a previous time stamp to work with, bail if we don't have one
        guard let last = lastTimeStamp else{
            lastTimeStamp = displayLink.timestamp
            return
        }
        
        // Work out dt
        let dt = displayLink.timestamp - last
        
        // Save the current time
        lastTimeStamp = displayLink.timestamp

        
        // If we're using physics to animate out, update
        guard case var State.physicsOut(physicsState) = state else {
            return
        }

        print("tick")
        physicsState.velocity += CGFloat(dt) * physicsState.acceleration
        
        swipeOffset += physicsState.velocity * CGFloat(dt)
        
        view.setNeedsLayout()
        state = .physicsOut(physicsState)
        
        // Remove if the content view is off screen
        if swipeOffset > view.bounds.size.height / 2 {
            dismiss(animated: false, completion: nil)
        }
        
    }
    
}

func ==(lhs: SBCardPopupViewController.State, rhs: SBCardPopupViewController.State) -> Bool {
    
    switch (lhs, rhs) {
    case (.animatingIn, .animatingIn):
        return true
    case (.idle, .idle):
        return true
    case (.panning, .panning):
        return true
    case (.physicsOut, .physicsOut):
        return true
    default:
        return false
    }
}
