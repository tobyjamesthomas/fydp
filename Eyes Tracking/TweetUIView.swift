//
//  TweetUIView.swift
//  Eyes Tracking
//
//  Created by Toby James Thomas on 2021-07-21.
//  Copyright © 2021 virakri. All rights reserved.
//

import Foundation
import UIKit
import Swifter

class TweetUIView: UIView {

    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var screenNameLabel: UILabel!
    @IBOutlet weak var tweetLabel: UILabel!

    public var tid: String = ""

    required init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
    }

    func update(_ json: JSON) {
        self.tid = json["id_str"].string!

        let name = json["user"]["name"].string!
        let screenName = json["user"]["screen_name"].string!
        let tweetText = json["full_text"].string!
        let profileImageURL = json["user"]["profile_image_url_https"].string!

        print(json)

        self.nameLabel.text = name
        self.screenNameLabel.text = "@" + screenName
        self.tweetLabel.text = tweetText

        setProfileImage(from: profileImageURL)
    }

    func setProfileImage(from url: String) {
        guard let imageURL = URL(string: url) else { return }

        DispatchQueue.global().async {
            guard let imageData = try? Data(contentsOf: imageURL) else { return }

            let image = UIImage(data: imageData)
            DispatchQueue.main.async {
                self.profileImage.image = image
            }
        }
    }
}
