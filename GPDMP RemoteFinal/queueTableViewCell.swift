//
//  queueTableViewCell.swift
//  GPMDP RemoteFinal
//
//  Created by Nathan Whitaker on 3/21/17.
//  Copyright © 2017 Nathan Whitaker. All rights reserved.
//

import Foundation
import UIKit

class queueTableViewCell: UITableViewCell {
    
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
