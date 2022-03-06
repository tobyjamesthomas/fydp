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
    @IBOutlet weak var tweetImage: UIImageView!
    @IBOutlet weak var tweetImageHeight: NSLayoutConstraint!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var screenNameLabel: UILabel!
    @IBOutlet weak var tweetLabel: UILabel!
    @IBOutlet weak var retweetCountLabel: UILabel!
    @IBOutlet weak var favouriteCountLabel: UILabel!

    public var tid: String = ""
    public var screenname: String = ""
    public var retweetCount = 0
    public var favouriteCount = 0

    required init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
    }

    func update(_ json: JSON) {
        print(json)

        self.tid = json["id_str"].string!
        self.screenname = json["user"]["screen_name"].string!
        self.retweetCount = json["retweet_count"].integer!
        self.favouriteCount = json["favorite_count"].integer!

        let name = json["user"]["name"].string!
        let tweetText = json["full_text"].string!
        let profileImageURL = getBigProfileImageUrl(from: json["user"]["profile_image_url_https"].string!)

        self.nameLabel.text = name
        self.screenNameLabel.text = "@" + self.screenname
        self.tweetLabel.text = tweetText
        self.retweetCountLabel.text = String(self.retweetCount)
        self.favouriteCountLabel.text = String(self.favouriteCount)

        setProfileImage(from: profileImageURL)
        parseTweetImageFromJson(from: json)
    }

    func updateRetweet(delta: Int) {
        retweetCount += delta
        self.retweetCountLabel.text = String(self.retweetCount)
    }

    func updateLike(delta: Int) {
        favouriteCount += delta
        self.favouriteCountLabel.text = String(self.favouriteCount)
    }

    func setProfileImage(from url: String) {
        // Assign an image to the profile picture from a valid image url.
        guard let imageURL = URL(string: url) else { return }

        DispatchQueue.global().async {
            guard let imageData = try? Data(contentsOf: imageURL) else { return }

            let image = UIImage(data: imageData)
            DispatchQueue.main.async {
                self.profileImage.image = image
            }
        }
    }

    func setTweetImageView(from url: String) {
        // Assign an image to the TweetUI from a valid image url.
        guard let imageURL = URL(string: url) else { return }

        DispatchQueue.global().async {
            guard let imageData = try? Data(contentsOf: imageURL) else { return }

            let image = UIImage(data: imageData)
            DispatchQueue.main.async {
                self.tweetImage.image = image
            }
        }
    }

    func parseTweetImageFromJson(from json: JSON) {
        // Acquire teh tweet image if it exists from the Tweet JSON details
        self.tweetImage.image = nil
        tweetImageHeight.constant = 0
        let media = json["entities"]["media"]
        switch media {
        case .invalid:
            break
        default:
            let picture = media[0]
            switch picture {
            case .invalid:
                break
            default:
                tweetImageHeight.constant = 175
                setTweetImageView(from: (picture["media_url_https"].string!))
            }
        }
    }

    func getBigProfileImageUrl(from url: String) -> String {
        // https://media.giphy.com/media/dl8b48ULQRjBkRcmZZ/giphy.gif
        // Upsize the profile picture image for better display
        return url.replacingOccurrences(of: "normal.jpg", with: "400x400.jpg")
    }

}
