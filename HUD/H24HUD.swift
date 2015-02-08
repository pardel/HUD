//
//  H24HUD.swift
//  Health
//
//  Created by Paul on 04/11/2014.
//  Copyright (c) 2014 Hello24. All rights reserved.
//

import Foundation
import UIKit

let kColorSuccess = UIColor(red:  40.0 / 255.0, green: 220.0 / 255.0, blue: 120.0 / 255.0, alpha: 1.0)
let kColorFailure = UIColor(red: 255.0 / 255.0, green:  80.0 / 255.0, blue:   0.0 / 255.0, alpha: 1.0)

private func devPrintln<T>(to_print: T, _ file: String = __FILE__, _ line: Int = __LINE__, _ function: String = __FUNCTION__) {
#if DEBUG
    dispatch_async(dispatch_get_main_queue()) {
        print("💭 [\(file.lastPathComponent):\(line)] ● \(function) : \(to_print)\n")
    }
#endif
}

enum H24HUDType {
    case Loading
    case Success
    case Failure
}

let sharedH24HUD = H24HUD()

@objc public class H24HUD {
    
    private let window = H24HUDWindow()
    var type: H24HUDType = .Loading
    
    public class func showLoading(message: String) {
        sharedH24HUD.type = .Loading
        show(message)
    }
    public class func showSuccess(message: String) {
        sharedH24HUD.type = .Success
        show(message)
    }
    public class func showFailure(message: String) {
        sharedH24HUD.type = .Failure
        show(message)
    }
    private class func show(message: String) {
        sharedH24HUD.window.type = sharedH24HUD.type
        dispatch_async(dispatch_get_main_queue()) {
            sharedH24HUD.window.show(message)
        }
        
    }
    public class func hide() {
        sharedH24HUD.window.hide()
    }
}


class H24HUDWindow : UIWindow {
    
    var type = H24HUDType.Loading
    let viewController = H24HUDViewController()

    override init() {
        super.init(frame: UIApplication.sharedApplication().delegate!.window!!.bounds)
        windowLevel = UIWindowLevelNormal + 1
        viewController.view.frame = self.bounds
        rootViewController = viewController
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    func show(message: String) {
        viewController.type = self.type
        makeKeyAndVisible()
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.viewController.show(message)
        })
    }
    
    func hide() {
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.viewController.hide()
        }) { (done) -> Void in
        }
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW,  Int64(NSEC_PER_SEC) / 2), dispatch_get_main_queue()) {
            self.resignKeyWindow()
            self.hidden = true
        }
    }
    
}



class H24HUDViewController : UIViewController {
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    var type = H24HUDType.Loading
    let backgroundShadeView = UIView()
    let backgroundIndicatorView = UIView()
    let loadingIndicator = UIImageView()
    let successIndicator = UIImageView()
    let failureIndicator = UIImageView()
    let statusLabel = UILabel()
    
    override func willRotateToInterfaceOrientation(toInterfaceOrientation: UIInterfaceOrientation, duration: NSTimeInterval) {
        UIView.animateWithDuration(0.1, animations: { () -> Void in
            self.view.alpha = 0
        })
        
    }
    override func didRotateFromInterfaceOrientation(fromInterfaceOrientation: UIInterfaceOrientation) {
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            self.positionElements()
            self.view.alpha = 1
        })
    }
    
    override init() {
        super.init()
        // Background view - shading
        backgroundShadeView.backgroundColor = UIColor.blackColor()
        backgroundShadeView.alpha = 0
        backgroundShadeView.frame = self.view.bounds
        view.addSubview(backgroundShadeView)
        
        backgroundIndicatorView.backgroundColor = UIColor.blackColor()
        backgroundIndicatorView.alpha = 0
        backgroundIndicatorView.frame = CGRectMake(0, 0, 100, 100)
        backgroundIndicatorView.center = view.center
        var viewLayer = backgroundIndicatorView.layer
        viewLayer.shadowColor = UIColor.whiteColor().CGColor
        viewLayer.shadowOffset = CGSize(width: 0, height: 0)
        viewLayer.shadowOpacity = 0.1
        viewLayer.shadowRadius = 8
        viewLayer.cornerRadius = 8
        viewLayer.masksToBounds = true
        view.addSubview(backgroundIndicatorView)
        
        if let loadingImage = UIImage(named: "HUDLoading", inBundle: NSBundle(forClass: self.dynamicType), compatibleWithTraitCollection: nil) {
            loadingIndicator.image = loadingImage
        }
        loadingIndicator.alpha = 0
        view.addSubview(loadingIndicator)
        
        if let successImage = UIImage(named: "HUDSuccess", inBundle: NSBundle(forClass: self.dynamicType), compatibleWithTraitCollection: nil) {
            let templateImage = successImage.imageWithRenderingMode(.AlwaysTemplate)
            successIndicator.tintColor = kColorSuccess
            successIndicator.image = templateImage
        }
        successIndicator.alpha = 0
        view.addSubview(successIndicator)
        
        if let failureImage = UIImage(named: "HUDFailure", inBundle: NSBundle(forClass: self.dynamicType), compatibleWithTraitCollection: nil) {
            let templateImage = failureImage.imageWithRenderingMode(.AlwaysTemplate)
            failureIndicator.tintColor = kColorFailure
            failureIndicator.image = templateImage
            
        }
        failureIndicator.alpha = 0
        view.addSubview(failureIndicator)
        
        statusLabel.text = "Loading..."
        statusLabel.textColor = UIColor.whiteColor()
        statusLabel.textAlignment = .Center
        statusLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleFootnote)
        statusLabel.numberOfLines = 0
        statusLabel.alpha = 0
        view.addSubview(statusLabel)
        
        self.showState()
    }
    
    func show(message: String) {
        self.statusLabel.text = message
        switch self.type {
        case .Loading:
            self.showLoading()
        case .Success:
            self.showSuccess()
        case .Failure:
            self.showFailure()
        default:
            self.showLoading()
        }
    }
    
    func showLoading() {
        devPrintln("HUD Loading...")
        self.showState()
        self.loadingIndicator.alpha = 1.0
        self.statusLabel.alpha = 1.0
        self.statusLabel.textColor = UIColor.whiteColor()
    }
    
    func showSuccess() {
        devPrintln("HUD Success...")
        self.showState()
        self.successIndicator.alpha = 1.0
        self.statusLabel.alpha = 1.0
        self.statusLabel.textColor = kColorSuccess
    }
    
    func showFailure() {
        devPrintln("HUD Failure...")
        self.showState()
        self.failureIndicator.alpha = 1.0
        self.statusLabel.alpha = 1.0
        self.statusLabel.textColor = kColorFailure
    }
    
    func showState() {
        hideAll()
        positionElements()
    }
    
    func hide() {
        devPrintln("HUD hide...")
        self.hideAll()
    }
    
    
    private func positionElements() {
        backgroundShadeView.frame = self.view.bounds
        
        backgroundIndicatorView.frame = CGRectMake(0, 0, 150, 100)
        backgroundIndicatorView.center = self.view.center
        backgroundShadeView.alpha = 0.3
        backgroundIndicatorView.alpha = 0.8
        
        if let image = loadingIndicator.image {
            loadingIndicator.frame = CGRectMake(
                (view.bounds.size.width - image.size.width) / 2.0,
                backgroundIndicatorView.frame.origin.y + 20,
                image.size.width, image.size.height)
            let rotation = CABasicAnimation(keyPath: "transform.rotation")
            rotation.fromValue = 0
            rotation.toValue = 2 * M_PI
            rotation.duration = 1.2
            rotation.repeatCount = Float(Int.max)
            loadingIndicator.layer.addAnimation(rotation, forKey: "spin")
        }
        
        if let image = successIndicator.image {
            successIndicator.frame = CGRectMake(
                (view.bounds.size.width - image.size.width) / 2.0,
                backgroundIndicatorView.frame.origin.y + 20,
                image.size.width, image.size.height)
        }
        
        if let image = failureIndicator.image {
            failureIndicator.frame = CGRectMake(
                (view.bounds.size.width - image.size.width) / 2.0,
                backgroundIndicatorView.frame.origin.y + 20,
                image.size.width, image.size.height)
        }
        
        statusLabel.frame = CGRectMake(backgroundIndicatorView.frame.origin.x + 10,
            backgroundIndicatorView.frame.origin.y + backgroundIndicatorView.frame.size.height - 45,
            backgroundIndicatorView.frame.size.width - 20, 35)
        let newSize = statusLabel.sizeThatFits(CGSizeMake(statusLabel.frame.size.width, 1000))
        if newSize.height > 35 {
            statusLabel.frame = CGRectMake(backgroundIndicatorView.frame.origin.x + 10,
                backgroundIndicatorView.frame.origin.y + backgroundIndicatorView.frame.size.height - 45,
                backgroundIndicatorView.frame.size.width - 20, newSize.height)
            backgroundIndicatorView.frame.size = CGSizeMake(backgroundIndicatorView.frame.size.width,
                100 + newSize.height - 35)
        }

    }
    
    private func hideAll() {
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            self.backgroundShadeView.alpha = 0
            self.backgroundIndicatorView.alpha = 0
            self.loadingIndicator.alpha = 0
            self.successIndicator.alpha = 0
            self.failureIndicator.alpha = 0
            self.statusLabel.alpha = 0
        })
    }
    
    
    let mainRootViewController = UIApplication.sharedApplication().delegate!.window!!.rootViewController
    internal override func shouldAutorotate() -> Bool {                                  return mainRootViewController!.shouldAutorotate() }
    internal override func supportedInterfaceOrientations() -> Int {                     return mainRootViewController!.supportedInterfaceOrientations() }
    internal override func preferredStatusBarStyle() -> UIStatusBarStyle {               return mainRootViewController!.preferredStatusBarStyle() }
    internal override func prefersStatusBarHidden() -> Bool {                            return mainRootViewController!.prefersStatusBarHidden() }
    internal override func preferredStatusBarUpdateAnimation() -> UIStatusBarAnimation { return mainRootViewController!.preferredStatusBarUpdateAnimation() }
    
}