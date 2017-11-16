//
//  searchTableViewCell.swift
//  GPMDP RemoteFinal
//
//  Created by Nathan Whitaker on 3/17/17.
//  Copyright © 2017 Nathan Whitaker. All rights reserved.
//

import UIKit

class searchTableViewCell: UITableViewCell {

    @IBOutlet weak var resultText: UILabel!
    
    @IBOutlet weak var resultSubtitle: UILabel!
    
    @IBOutlet weak var resultPicture: UIImageView!
   
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
