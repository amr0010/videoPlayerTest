//
//  ViewController.swift
//  videoPlayerFloatingView
//
//  Created by Amr Magdy on 11/29/18.
//  Copyright © 2018 Amr Magdy. All rights reserved.
//

import UIKit

fileprivate enum playerStateSize {
    case largePlayer
    case smallPlayer
}

fileprivate enum playerStatePosition {
    case topLeftPlayer
    case topRightPlayer
    case bottomLeftPlayer
    case bottomRightPlayer
}

class ViewController: UIViewController {
    
    var lastScale:CGFloat = 1.0
    private var largeSize : CGSize = CGSize(width: 100, height: 100)
    var smallSize : CGSize = CGSize(width: 50, height: 50)
    var yPointOfRestriction : CGFloat = 90.0
    var xPointOfRestriction : CGFloat = 30.0
    
    var topHalf = CGRect()
    var bottomHalf = CGRect()
    
    
    var position = CGPoint()
    var size = CGSize()
    
    
    fileprivate var playerPosition : playerStatePosition = .topLeftPlayer {
        didSet {
            adjustPosition()
        }
    }
    fileprivate var playerSize : playerStateSize = .largePlayer {
        didSet {
            adjustSize()
        }
    }
    var myView = UIView()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        determineLocation()
        self.position = CGPoint(x: 10, y: 75)
        self.size = CGSize(width: self.view.frame.width - 20, height: (self.view.frame.height / 2) - 150)
        
        topHalf = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height / 2)
        bottomHalf = CGRect(x: self.view.frame.width , y: self.view.frame.height, width: self.view.frame.width, height: self.view.frame.height / 2)
    }
    
    @IBAction func showPlayerClicked(_ sender: Any) {
        setupView()
    }
    func setupView() {
        
        let rect = CGRect(x: 10, y: 75, width: topHalf.width - 20, height: topHalf.height - 150)
        myView = UIView(frame: rect)
        myView.backgroundColor = UIColor.red
        myView.layer.shadowRadius = 5
        myView.layer.shadowColor = UIColor.black.cgColor
        myView.layer.cornerRadius = 5
        self.view.addSubview(myView)
        let panGest = UIPanGestureRecognizer(target: self, action: #selector(ViewController.draggedView(_:)))
        let pinchGest = UIPinchGestureRecognizer(target: self, action: #selector(ViewController.pinchedView(_:)))
        myView.addGestureRecognizer(panGest)
        myView.addGestureRecognizer(pinchGest)
    }
    
    
    func  adjustPosition() {
        switch playerPosition {
        case .topLeftPlayer :
            self.position = CGPoint(x: 10, y: 75)
        case .bottomLeftPlayer :
            self.position = CGPoint(x: 10, y: (self.view.frame.maxY - self.myView.frame.height) - 75)
        case .bottomRightPlayer :
            self.position = CGPoint(x: self.view.frame.midX + 10 , y: (self.view.frame.maxY - self.myView.frame.height) - 75)
        case .topRightPlayer :
            self.position = CGPoint(x: self.view.frame.midX + 10, y: 75)
        }
        adjustPlayer()
    }
    
    func  adjustSize() {
        switch playerSize {
        case .largePlayer :
             self.size = CGSize(width: self.view.frame.width - 20, height: (self.view.frame.height / 2) - 150)
        case .smallPlayer :
             self.size = CGSize(width: self.view.frame.width - 160, height: (self.view.frame.height / 2) - 200)
        }
        adjustPlayer()
    }
    func adjustPlayer () {
        if playerSize == .largePlayer && playerPosition == .topRightPlayer
        {
            playerPosition = .topLeftPlayer
        }
        if playerSize == .largePlayer && playerPosition == .bottomRightPlayer
        {
            playerPosition = .bottomLeftPlayer
        }
        UIView.animate(withDuration: 0.6) {
             self.myView.frame = CGRect(origin: self.position, size: self.size)
        }
       
    }
    @objc func pinchedView(_ sender:UIPinchGestureRecognizer)
    {
        
        if sender.state == .began {
            lastScale = sender.scale
        }
        if sender.state == .began||sender.state == .changed {
            let currentScale :CGFloat = sender.view!.layer.value(forKeyPath: "transform.scale") as! CGFloat
            let minScale : CGFloat =  0.7
            let maxScale : CGFloat = 1.3
            
            var newScale : CGFloat = 1 - (lastScale - sender.scale)
            newScale = min(newScale, maxScale / currentScale)
            newScale = max(newScale, minScale / currentScale)
            sender.view?.transform = (sender.view?.transform)!.scaledBy(x: newScale, y: newScale)
            lastScale = sender.scale
        }
        
        if sender.state == .ended {
            if lastScale < 1 {
                self.playerSize = .smallPlayer
            }
            else {
                self.playerSize = .largePlayer
            }
            determineLocation()
        }
    }
    
    @objc func draggedView(_ sender:UIPanGestureRecognizer)
    {
        if sender.state == .began || sender.state == .changed
        {
            let point = sender.location(in: self.view)
            if let superview = self.view
            {
                
                let superBounds = CGRect(x: superview.bounds.origin.x + xPointOfRestriction, y: superview.bounds.origin.y + yPointOfRestriction, width: superview.bounds.size.width - 2*xPointOfRestriction, height: superview.bounds.size.height - yPointOfRestriction)
                
                
                if (superBounds.contains(point))
                {
                    let translation = sender.translation(in: self.view)
                    sender.view!.center = CGPoint(x: sender.view!.center.x + translation.x, y: sender.view!.center.y + translation.y)
                    sender.setTranslation(CGPoint.zero, in: self.view)
                }
            }
        }
            
        else if sender.state == .ended
        {
            
            determineLocation()
            //            if (topHalf.contains(sender.view!.center))
            //            {
            //                self.playerPosition = .topLeftPlayer
            //            }
            //            else {
            //                self.playerPosition = .bottomLeftPlayer
            //            }
            //
        }
        
    }
    
    
    func determineLocation()
    {
        let topLeft = CGRect(x: 0, y: 0, width: self.view.frame.width / 2, height: self.view.frame.height / 2)
        let topRight = CGRect(x: self.view.frame.midX, y: 0, width: self.view.frame.width / 2, height: self.view.frame.height / 2)
        let bottomLeft = CGRect(x: 0, y: self.view.frame.midY, width: self.view.frame.width / 2, height: self.view.frame.height / 2)
        let bottomRight = CGRect(x: self.view.frame.midX, y: self.view.frame.midY, width: self.view.frame.width / 2, height: self.view.frame.height / 2)
        
        if topLeft.contains(self.myView.center)
        {
            self.playerPosition = .topLeftPlayer
        }
        else if topRight.contains(self.myView.center)
        {
            self.playerPosition = .topRightPlayer
        }
        else if bottomLeft.contains(self.myView.center)
        {
            self.playerPosition = .bottomLeftPlayer
        }
        else
        {
            self.playerPosition = .bottomRightPlayer
        }
        
    }
}

