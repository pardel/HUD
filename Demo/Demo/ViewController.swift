//
//  ViewController.swift
//  Demo
//
//  Created by Paul on 07/02/2015.
//  Copyright (c) 2015 Hello24. All rights reserved.
//

import UIKit
import HUD

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func showLoading(sender: AnyObject) {
        H24HUD.showLoading("Loading...")
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW,  Int64(NSEC_PER_SEC) * 3), dispatch_get_main_queue()) {
            H24HUD.hide()
        }
    }

    @IBAction func showSuccess(sender: AnyObject) {
        H24HUD.showSuccess("Projects loaded successfully.")
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW,  Int64(NSEC_PER_SEC) * 3), dispatch_get_main_queue()) {
            H24HUD.hide()
        }
    }
    
    @IBAction func showError(sender: AnyObject) {
        H24HUD.showFailure("Something went wrong. Please try again!")
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW,  Int64(NSEC_PER_SEC) * 3), dispatch_get_main_queue()) {
            H24HUD.hide()
        }
    }
    
    
}

