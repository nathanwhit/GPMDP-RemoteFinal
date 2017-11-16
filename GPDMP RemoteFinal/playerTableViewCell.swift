//
//  playerTableViewCell.swift
//  GPMDP RemoteFinal
//
//  Created by Nathan Whitaker on 3/14/17.
//  Copyright © 2017 Nathan Whitaker. All rights reserved.
//

import UIKit

class playerTableViewCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var subtitleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
