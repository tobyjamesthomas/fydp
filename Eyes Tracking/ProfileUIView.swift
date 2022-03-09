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
        let profileBannerImageURL = json["profile_banner_url"].string ?? ""

        self.nameLabel.text = name
        self.screenNameLabel.text = "@" + self.screenname
        self.descriptionLabel.text = descriptionText
        self.followingLabel.text = String(followingCount) + " Following"
        self.followerLabel.text = String(followerCount) + " Followers"

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
}
