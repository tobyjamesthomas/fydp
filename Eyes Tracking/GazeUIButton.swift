//
//  GazeUIButton.swift
//  Eyes Tracking
//
//  Created by Toby James Thomas on 2021-06-21.
//  Copyright © 2021 virakri. All rights reserved.
//

import Foundation
import UIKit

class GazeUIButton : UIButton {
    private var displayLink: CADisplayLink?
    private var startTime = 0.0
    private var duration = 2.0
    
    public var isActive = false
    
    required init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
    }
    
    func startLink() {
        guard displayLink == nil else { return }
        
        startTime = CACurrentMediaTime()
        
        let displayLink = CADisplayLink(target: self, selector: #selector(linkDidFire))
        displayLink.preferredFramesPerSecond = 20
        displayLink.add(to: .main, forMode: .common)
        
        self.displayLink = displayLink
        
        isActive = true
    }
    
    @objc func linkDidFire(_ link: CADisplayLink) {
        let progress = min((CACurrentMediaTime() - startTime) / duration, 1.0)
        
        if progress == 1.0 {
            stopLink()
            print(currentTitle!, "done!")
        }
        
        backgroundColor = backgroundColor?.withAlphaComponent(CGFloat(progress))
    }
    
    func stopLink() {
        print(currentTitle!, "stopped!")
        backgroundColor = backgroundColor?.withAlphaComponent(0.0)
        displayLink?.invalidate()
        displayLink = nil
        isActive = false
    }
}
