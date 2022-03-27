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
    @IBOutlet weak var joinDate: UILabel!
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
        if #available(iOS 13.0, *) {
            self.followingLabel.attributedText = self.attributedText(withString: self.formatCount(count: followingCount), userType: " Following")
            self.followerLabel.attributedText = self.attributedText(withString: self.formatCount(count: followerCount), userType: " Followers")
        }
        self.joinDate.text = self.getJoinDate(from: json["created_at"].string!)

        setImage(from: self.getBigProfileImageUrl(from: profileImageURL), for: self.profileImage)
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

    @available(iOS 13.0, *)
    func attributedText(withString userCount: String, userType: String) -> NSAttributedString {
        // Set the UI label to use an AttributedString so that the number text can be bolded.
        let boldText = userCount
        let attrs = [NSAttributedString.Key.font : UIFont(name: "HelveticaNeue-Bold", size: 15)!, NSAttributedString.Key.foregroundColor: UIColor.black]
        let attributedString = NSMutableAttributedString(string:boldText, attributes:attrs)

        let normalText = userType
        let attrsNormal = [NSAttributedString.Key.font : UIFont(name: "HelveticaNeue-Thin", size: 15)!, NSAttributedString.Key.foregroundColor: UIColor.black]
        let normalString = NSMutableAttributedString(string:normalText, attributes: attrsNormal)

        attributedString.append(normalString)
        return attributedString
    }

    func getBigProfileImageUrl(from url: String) -> String {
        // https://media.giphy.com/media/dl8b48ULQRjBkRcmZZ/giphy.gif
        // Upsize the profile picture image for better display
        return url.replacingOccurrences(of: "normal.jpg", with: "400x400.jpg")
    }
    
    func getJoinDate(from url: String) -> String {
        // Parse the join date from the json object
        var dateItems = url.components(separatedBy: " ")
        return "Joined " + dateItems[1] + " " + dateItems[5]
    }
}
