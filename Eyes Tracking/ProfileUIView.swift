//
//  ProfileUIView.swift
//  Eyes Tracking
//
//  Created by Toby James Thomas on 2021-07-21.
//  Copyright © 2021 virakri. All rights reserved.
//

import Foundation
import UIKit
import Swifter

class ProfileUIView: UIView {

    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var profileBannerImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var screenNameLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var followingLabel: UILabel!
    @IBOutlet weak var followerLabel: UILabel!

    public var screenname: String = ""

    required init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
    }

    func update(_ json: JSON) {
        print(json)

        self.screenname = json["screen_name"].string!

        let name = json["name"].string!
        let descriptionText = json["description"].string!
        let followingCount = json["friends_count"].integer!
        let followerCount = json["followers_count"].integer!
        let profileImageURL = json["profile_image_url_https"].string!
        
        // Parse profile banner image or use a default from Imgur
        let profileBannerImageURL = json["profile_banner_url"].string ?? "https://i.imgur.com/pDh2Ox7.png"

        self.nameLabel.text = name
        self.screenNameLabel.text = "@" + self.screenname
        self.descriptionLabel.text = descriptionText
        self.followingLabel.text = self.formatCount(count: followingCount) + " Following"
        self.followerLabel.text = self.formatCount(count: followerCount) + " Followers"

        setImage(from: profileImageURL, for: self.profileImage)
        setImage(from: profileBannerImageURL, for: self.profileBannerImage)
    }

    func setImage(from url: String, for view: UIImageView) {
        guard let imageURL = URL(string: url) else { return }

        DispatchQueue.global().async {
            guard let imageData = try? Data(contentsOf: imageURL) else { return }

            let image = UIImage(data: imageData)
            DispatchQueue.main.async {
                view.image = image
            }
        }
    }

    func formatCount(count: Int) -> String {
        if count < 1000 { return String(count) }

        var count = Double(count)
        var thousands = 0

        while count / 1000 >= 1 {
            count /= 1000
            thousands += 1
        }

        let formattedCount = String(floor(count * 10) / 10.0)
        switch thousands {
        case 3: return formattedCount + "B"  // Billion
        case 2: return formattedCount + "M"  // Million
        default: return formattedCount + "K" // Thousand
        }
    }
}
