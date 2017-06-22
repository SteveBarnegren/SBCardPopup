//
//  PopupContentWithDismissViewController.swift
//  SBCardPopupExample
//
//  Created by Steve Barnegren on 22/06/2017.
//  Copyright © 2017 Steve Barnegren. All rights reserved.
//

import UIKit
import SBCardPopup

class PopupContentWithDismissViewController: UIViewController, SBPopupCardContent {
    
    weak var popupViewController: SBCardPopupViewController?
    
    var allowsTapToDismissPopupCard: Bool {
        return true
    }
    
    static func create() -> UIViewController {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "PopupContentWithDismissViewController") as! PopupContentWithDismissViewController
        return viewController
    }

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    @IBAction func closeButtonPressed(sender: UIButton){
        popupViewController?.close()
    }

}

