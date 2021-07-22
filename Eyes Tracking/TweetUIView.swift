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

    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var tweetLabel: UILabel!

    public var id: String = ""

    required init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
    }

    func update(_ json: JSON) {
        self.id = json["id_str"].string!

        let username = json["user"]["screen_name"].string!
        let tweetText = json["full_text"].string!

        print(id, username, tweetText)

        self.usernameLabel.text = username
        self.tweetLabel.text = tweetText
    }
}
