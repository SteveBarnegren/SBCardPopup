//
//  DisableDismissPopupContentViewController.swift
//  SBCardPopupExample
//
//  Created by Steve Barnegren on 22/06/2017.
//  Copyright © 2017 Steve Barnegren. All rights reserved.
//

import UIKit
import SBCardPopup

class DisableDismissPopupContentViewController: UIViewController, SBPopupCardContent {
    
    static func create() -> UIViewController {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "DisableDismissPopupContentViewController") as! DisableDismissPopupContentViewController
        return viewController
    }
    
    // MARK: - Properties
    @IBOutlet fileprivate var buttons: [UIButton]!
    
    // MARK: - UIViewController

    override func viewDidLoad() {
        super.viewDidLoad()
        
        buttons.forEach{
            $0.layer.borderColor = UIColor.lightGray.cgColor
            $0.layer.borderWidth = 2
            $0.layer.cornerRadius = 5
        }
    }
    
    // MARK: - Actions
    
    @IBAction func option1ButtonPressed(sender: UIButton){
        popupViewController?.close()
    }
    
    @IBAction func option2ButtonPressed(sender: UIButton){
        popupViewController?.close()
    }
    
    // MARK: - SBPopupCardContent
    
    weak var popupViewController: SBCardPopupViewController?
    
    var allowsTapToDismissPopupCard: Bool {
        return false
    }



}
