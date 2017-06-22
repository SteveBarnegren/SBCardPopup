//
//  ViewController.swift
//  SBCardPopupExample
//
//  Created by Steve Barnegren on 22/06/2017.
//  Copyright © 2017 Steve Barnegren. All rights reserved.
//

import UIKit
import SBCardPopup

class ViewController: UIViewController {
    
    var popup: SBCardPopupViewController?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        //perform(#selector(showPopup), with: nil, afterDelay: 3)
        
    }
    
    @IBAction func popupButtonPressed(sender: UIButton){
        showPopup()
    }
    
    func showPopup() {
        //let popupContent = BasicPopupContentViewController.create()
        //let popupContent = PopupContentWithDismissViewController.create()
        //let popupContent = DisableDismissPopupContentViewController.create()
        let popupContent = ChangeSizePopupContentViewController.create()
        
        let cardPopup = SBCardPopupViewController(contentViewController: popupContent)
        
        addChildViewController(cardPopup)
        view.addSubview(cardPopup.view)
        popup = cardPopup
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if let popup = popup {
            popup.view.frame = view.bounds
        }
    }


}

