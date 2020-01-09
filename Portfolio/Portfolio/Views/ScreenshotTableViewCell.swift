//
//  ScreenshotTableViewCell.swift
//  Portfolio
//
//  Created by Isaac Lyons on 1/9/20.
//  Copyright © 2020 Isaac Lyons. All rights reserved.
//

import UIKit

class ScreenshotTableViewCell: UITableViewCell {
    
    @IBOutlet weak var screenshotImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
