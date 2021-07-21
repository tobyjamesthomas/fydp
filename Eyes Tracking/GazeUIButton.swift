//
//  GazeUIButton.swift
//  Eyes Tracking
//

import Foundation
import UIKit

class GazeUIButton: UIButton {
    private var displayLink: CADisplayLink?
    private var startTime = 0.0
    private var duration = 2.0

    required init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
    }

    func isActive() -> Bool {
        return displayLink != nil
    }

    func startLink() {
        guard displayLink == nil else { return }

        startTime = CACurrentMediaTime()

        let displayLink = CADisplayLink(target: self, selector: #selector(linkDidFire))
        displayLink.preferredFramesPerSecond = 20
        displayLink.add(to: .main, forMode: .common)

        self.displayLink = displayLink
    }

    @objc func linkDidFire(_ link: CADisplayLink) {
        let progress = min((CACurrentMediaTime() - startTime) / duration, 1.0)

        if progress == 1.0 {
            stopLink()
            sendActions(for: .primaryActionTriggered)
            return
        }

        backgroundColor = backgroundColor?.withAlphaComponent(CGFloat(progress))
    }

    func stopLink() {
        backgroundColor = backgroundColor?.withAlphaComponent(0.0)
        displayLink?.invalidate()
        displayLink = nil
    }
}
