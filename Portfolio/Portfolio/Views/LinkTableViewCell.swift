//
//  LinkTableViewCell.swift
//  Portfolio
//
//  Created by Isaac Lyons on 1/7/20.
//  Copyright © 2020 Isaac Lyons. All rights reserved.
//

import UIKit

class LinkTableViewCell: UITableViewCell {

    @IBOutlet weak var appStoreButton: UIButton!
    @IBOutlet weak var ageRating: UIButton!
    @IBOutlet weak var ratingsButton: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
