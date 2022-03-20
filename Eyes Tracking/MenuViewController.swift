//
//  MenuViewController.swift
//  Eyes Tracking
//
//  Created by Eddie Ren on 2021-08-02.
//  Copyright © 2021 virakri. All rights reserved.
//

import UIKit
import SceneKit
import ARKit
import WebKit
import SafariServices
import Swifter
import AuthenticationServices

// swiftlint:disable type_body_length file_length
class MenuViewController: UIViewController, ARSCNViewDelegate, ARSessionDelegate {

    @IBOutlet weak var webView: WKWebView!
    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet weak var eyePositionIndicatorView: UIView!
    @IBOutlet weak var eyePositionIndicatorCenterView: UIView!
    @IBOutlet weak var blurBarView: UIVisualEffectView!
    @IBOutlet weak var lookAtPositionXLabel: UILabel!
    @IBOutlet weak var lookAtPositionYLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var gazeLabel: UILabel!
    @IBOutlet weak var gazeButtonsView: UIView!
    @IBOutlet weak var leftButton: GazeUIButton!
    @IBOutlet weak var rightButton: GazeUIButton!
    @IBOutlet weak var upButton: GazeUIButton!
    @IBOutlet weak var downButton: GazeUIButton!
    @IBOutlet weak var userLabel: UILabel!
    @IBOutlet weak var homeTimelineLabel: UILabel!
    @IBOutlet weak var personalProfileLabel: UILabel!

    var faceNode: SCNNode = SCNNode()

    var eyeLNode: SCNNode = {
        let geometry = SCNCone(topRadius: 0.005, bottomRadius: 0, height: 0.2)
        geometry.radialSegmentCount = 3
        geometry.firstMaterial?.diffuse.contents = UIColor.blue
        let node = SCNNode()
        node.geometry = geometry
        node.eulerAngles.x = -.pi / 2
        node.position.z = 0.1
        let parentNode = SCNNode()
        parentNode.addChildNode(node)
        return parentNode
    }()

    var eyeRNode: SCNNode = {
        let geometry = SCNCone(topRadius: 0.005, bottomRadius: 0, height: 0.2)
        geometry.radialSegmentCount = 3
        geometry.firstMaterial?.diffuse.contents = UIColor.blue
        let node = SCNNode()
        node.geometry = geometry
        node.eulerAngles.x = -.pi / 2
        node.position.z = 0.1
        let parentNode = SCNNode()
        parentNode.addChildNode(node)
        return parentNode
    }()

    var lookAtTargetEyeLNode: SCNNode = SCNNode()
    var lookAtTargetEyeRNode: SCNNode = SCNNode()

    // actual physical size of iPhoneX screen
    let phoneScreenSize = CGSize(width: 0.0623908297, height: 0.135096943231532)

    // actual point size of iPhoneX screen
    let phoneScreenPointSize = CGSize(width: 375, height: 812)

    var virtualPhoneNode: SCNNode = SCNNode()

    var virtualScreenNode: SCNNode = {

        let screenGeometry = SCNPlane(width: 1, height: 1)
        screenGeometry.firstMaterial?.isDoubleSided = true
        screenGeometry.firstMaterial?.diffuse.contents = UIColor.green

        return SCNNode(geometry: screenGeometry)
    }()

    var eyeLookAtPositionXs: [CGFloat] = []

    var eyeLookAtPositionYs: [CGFloat] = []

    var swifter = Swifter(consumerKey: "", consumerSecret: "")

    var screenname = ""
    var authenticatedScreenName = ""

    var gazeButtons: [GazeUIButton] = []

    var isBlinking: Bool = false
    var lastBlinkDate: Date = Date()

    var menuLabels: [UILabel] = []
    var currentLabelIndex = 0
    var moveHome = false

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Setup Design Elements
        eyePositionIndicatorView.layer.cornerRadius = eyePositionIndicatorView.bounds.width / 2
        sceneView.layer.cornerRadius = 28
        eyePositionIndicatorCenterView.layer.cornerRadius = 4

        blurBarView.layer.cornerRadius = 36
        blurBarView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        webView.layer.cornerRadius = 16
        webView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]

        // Set the view's delegate
        sceneView.delegate = self
        sceneView.session.delegate = self
        sceneView.automaticallyUpdatesLighting = true

        // Setup Scenegraph
        sceneView.scene.rootNode.addChildNode(faceNode)
        sceneView.scene.rootNode.addChildNode(virtualPhoneNode)
        virtualPhoneNode.addChildNode(virtualScreenNode)
        faceNode.addChildNode(eyeLNode)
        faceNode.addChildNode(eyeRNode)
        eyeLNode.addChildNode(lookAtTargetEyeLNode)
        eyeRNode.addChildNode(lookAtTargetEyeRNode)

        // Set LookAtTargetEye at 2 meters away from the center of eyeballs to create segment vector
        lookAtTargetEyeLNode.position.z = 1
        lookAtTargetEyeRNode.position.z = 1

        // Format TweetView to display single tweet
        self.setupTwitter()
        
        menuLabels.append(userLabel)
        menuLabels.append(homeTimelineLabel)
        menuLabels.append(personalProfileLabel)
    }

    func setupTwitter() {
        view.bringSubviewToFront(eyePositionIndicatorView)

        // Add actions to buttons
        if #available(iOS 13.0, *) {
            leftButton.addTarget(self, action: #selector(backAction), for: .primaryActionTriggered)
            rightButton.addTarget(self, action: #selector(selectAction), for: .primaryActionTriggered)
            upButton.addTarget(self, action: #selector(upMenuOptionAction), for: .primaryActionTriggered)
            downButton.addTarget(self, action: #selector(downMenuOptionAction), for: .primaryActionTriggered)
        } else {
            // Fallback on earlier versions
        }

        // Group buttons
        gazeButtons.append(upButton)
        gazeButtons.append(leftButton)
        gazeButtons.append(rightButton)
        gazeButtons.append(downButton)

        for gazeButton in gazeButtons {
            gazeButton.backgroundColor = gazeButton.backgroundColor?.withAlphaComponent(0.0)
        }

        userLabel.text = "Visit @" + self.screenname
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // Create a session configuration
        guard ARFaceTrackingConfiguration.isSupported else { return }
        let configuration = ARFaceTrackingConfiguration()
        configuration.isLightEstimationEnabled = true

        // Run the view's session
        sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        // Pause the view's session
        sceneView.session.pause()
    }

    // Pass swifter to next view
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "userprofile" {
            if let userProfileViewController = segue.destination as? UserProfileViewController {
                userProfileViewController.swifter = self.swifter
                userProfileViewController.authenticatedScreenName = self.authenticatedScreenName
                if !moveHome {
                    userProfileViewController.screenname = self.screenname
                } else {
                    userProfileViewController.screenname = self.authenticatedScreenName
                }
            }
        }
    }

    // MARK: - ARSCNViewDelegate

    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {

        faceNode.transform = node.transform
        guard let faceAnchor = anchor as? ARFaceAnchor else { return }

        update(withFaceAnchor: faceAnchor)
    }

    override func pressesEnded(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        guard let key = presses.first?.key else { return }
        // Keypresses for debugging
        
        if #available(iOS 13.0, *) {
            if self.isViewLoaded && (self.view.window != nil) {
                switch key.keyCode {
                case .keyboardD:
                    print("Detect double blink")
                    showUserProfileViewController()
                case .keyboardUpArrow:
                    upMenuOptionAction()
                case .keyboardDownArrow:
                    downMenuOptionAction()
                case .keyboardLeftArrow:
                    backAction()
                case .keyboardRightArrow:
                    selectAction()
                default:
                    super.pressesEnded(presses, with: event)
                }
            }
        }
    }

    // MARK: - update(ARFaceAnchor)
    func update(withFaceAnchor anchor: ARFaceAnchor) {

        eyeRNode.simdTransform = anchor.rightEyeTransform
        eyeLNode.simdTransform = anchor.leftEyeTransform

        handleBlink(withFaceAnchor: anchor)

        var eyeLLookAt = CGPoint()
        var eyeRLookAt = CGPoint()

        let heightCompensation: CGFloat = 312

        DispatchQueue.main.async {

            // Perform Hit test using the ray segments that are drawn by the center of the eyeballs to somewhere two
            // meters away at direction of where users look at to the virtual plane that place at the same orientation
            // of the phone screen
            let phoneScreenEyeRHitTestResults = self.virtualPhoneNode.hitTestWithSegment(
                from: self.lookAtTargetEyeRNode.worldPosition, to: self.eyeRNode.worldPosition, options: nil)

            let phoneScreenEyeLHitTestResults = self.virtualPhoneNode.hitTestWithSegment(
                from: self.lookAtTargetEyeLNode.worldPosition, to: self.eyeLNode.worldPosition, options: nil)

            for result in phoneScreenEyeRHitTestResults {

                eyeRLookAt.x = CGFloat(result.localCoordinates.x) / (self.phoneScreenSize.width / 2)
                    * self.phoneScreenPointSize.width

                eyeRLookAt.y = CGFloat(result.localCoordinates.y) / (self.phoneScreenSize.height / 2)
                    * self.phoneScreenPointSize.height + heightCompensation
            }

            for result in phoneScreenEyeLHitTestResults {

                eyeLLookAt.x = CGFloat(result.localCoordinates.x) / (self.phoneScreenSize.width / 2)
                    * self.phoneScreenPointSize.width

                eyeLLookAt.y = CGFloat(result.localCoordinates.y) / (self.phoneScreenSize.height / 2)
                    * self.phoneScreenPointSize.height + heightCompensation
            }

            // Add the latest position and keep up to 8 recent position to smooth with.
            let smoothThresholdNumber: Int = 10
            self.eyeLookAtPositionXs.append((eyeRLookAt.x + eyeLLookAt.x) / 2)
            self.eyeLookAtPositionYs.append(-(eyeRLookAt.y + eyeLLookAt.y) / 2)
            self.eyeLookAtPositionXs = Array(self.eyeLookAtPositionXs.suffix(smoothThresholdNumber))
            self.eyeLookAtPositionYs = Array(self.eyeLookAtPositionYs.suffix(smoothThresholdNumber))

            let smoothEyeLookAtPositionX = self.eyeLookAtPositionXs.average!
            let smoothEyeLookAtPositionY = self.eyeLookAtPositionYs.average!

            let gazePositionX = Int(round(smoothEyeLookAtPositionX + self.phoneScreenPointSize.width / 2))
            let gazePositionY = Int(round(smoothEyeLookAtPositionY + self.phoneScreenPointSize.height / 2))

            // update indicator position
            self.eyePositionIndicatorView.transform = CGAffineTransform(translationX: smoothEyeLookAtPositionX,
                                                                        y: smoothEyeLookAtPositionY)

            // update eye look at labels values
            self.lookAtPositionXLabel.text = "\(gazePositionX)"
            self.lookAtPositionYLabel.text = "\(gazePositionY)"

            // Calculate distance of the eyes to the camera
            let distanceL = self.eyeLNode.worldPosition - SCNVector3Zero
            let distanceR = self.eyeRNode.worldPosition - SCNVector3Zero

            // Average distance from two eyes
            let distance = (distanceL.length() + distanceR.length()) / 2

            // Update distance label value
            self.distanceLabel.text = "\(Int(round(distance * 100))) cm"

            // Detect gaze
            self.detectGaze(CGPoint(x: gazePositionX, y: gazePositionY - 44)) // -44 for gazeButtonsView y offset
        }

    }

    func detectGaze(_ point: CGPoint) {
        let view: UIView? = self.gazeButtonsView.hitTest(point, with: nil)

        guard view is GazeUIButton else {
            if self.gazeLabel.text != "" {
                self.gazeLabel.text = ""
            }

            for button in gazeButtons {
                if button.isActive() { button.stopLink() }
            }

            return
        }

        let button: GazeUIButton = (view as? GazeUIButton)!

        for otherButton in gazeButtons {
            if otherButton != button && otherButton.isActive() {
                otherButton.stopLink()
            }
        }

        button.startLink()

        self.gazeLabel.text = button.currentTitle
    }

    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        virtualPhoneNode.transform = (sceneView.pointOfView?.transform)!
    }

    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        faceNode.transform = node.transform
        guard let faceAnchor = anchor as? ARFaceAnchor else { return }
        update(withFaceAnchor: faceAnchor)
    }


    @objc func backAction() {
        // Pop the current view controller to go back to previous controller
        unwindToHome()

    }

    @objc func unwindToHome() {
        // Pop the current view controller to go back to previous controller
        self.performSegue(withIdentifier: "unwindHomeTimeline", sender: self)

    }

    @objc func selectAction() {
        switch currentLabelIndex {
        case 0:
            moveHome = false
            self.showUserProfileViewController()
        case 1:
            unwindToHome()
        case 2:
            moveHome = true
            self.showUserProfileViewController()
        default:
            unwindToHome()
        }
        
        self.showUserProfileViewController()
    }

    @available(iOS 13.0, *)
    @objc func downMenuOptionAction() {
        // Reset fond size to default
        menuLabels[currentLabelIndex].font = menuLabels[currentLabelIndex].font.withSize(16.0)

        // Animate font size transition
        currentLabelIndex = min(menuLabels.count-1, currentLabelIndex+1)
        UIView.transition(with: menuLabels[currentLabelIndex], duration: 0.25,
                          options: .transitionFlipFromTop, animations: { [self] in
            menuLabels[self.currentLabelIndex].font = UIFont(name: "HelveticaNeue", size: 22.0)!
        })
    }

    @available(iOS 13.0, *)
    @objc func upMenuOptionAction() {
        // Reset fond size to default
        menuLabels[currentLabelIndex].font = menuLabels[currentLabelIndex].font.withSize(16.0)

        // Animate font size transition
        currentLabelIndex =  max(0, currentLabelIndex-1)
        UIView.transition(with: menuLabels[currentLabelIndex], duration: 0.25,
                          options: .transitionFlipFromBottom, animations: { [self] in
            menuLabels[self.currentLabelIndex].font = UIFont(name: "HelveticaNeue", size: 22.0)!
        })

    }

    private func handleBlink(withFaceAnchor anchor: ARFaceAnchor) {
        let blendShapes = anchor.blendShapes
        if let eyeBlinkLeft = blendShapes[.eyeBlinkLeft] as? Float,
           let eyeBlinkRight = blendShapes[.eyeBlinkRight] as? Float {
            if eyeBlinkRight > 0.9 || eyeBlinkLeft > 0.9 {
                isBlinking = true
            }
            if eyeBlinkLeft < 0.2 && eyeBlinkRight < 0.2 {
                if isBlinking == true {
                    let elapsed = Date().timeIntervalSince(lastBlinkDate)
                    if elapsed < 1 {
                        print("Double blink detected!")
                        DispatchQueue.main.async {
                            self.showUserProfileViewController()
                        }

                    } else {
                        print("Single blink detected")
                    }
                    lastBlinkDate = Date()
                }
                isBlinking = false

            }
        }
    }

    private func showUserProfileViewController() {
        self.performSegue(withIdentifier: "userprofile", sender: self)
    }
}
