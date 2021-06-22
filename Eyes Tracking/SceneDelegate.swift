
import UIKit
import SwifteriOS

@available(iOS 13.0, *)
class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard let context = URLContexts.first else { return }
        
        let callbackUrl = URL(string: "eyestracking://")!
        Swifter.handleOpenURL(context.url, callbackURL: callbackUrl)
    }
}
