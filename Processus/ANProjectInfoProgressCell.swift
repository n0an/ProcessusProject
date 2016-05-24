//
//  ANProjectInfoProgressCell.swift
//  Processus
//
//  Created by Anton Novoselov on 14/05/16.
//  Copyright © 2016 Anton Novoselov. All rights reserved.
//

import UIKit

class ANProjectInfoProgressCell: UITableViewCell {

    @IBOutlet weak var keyLabel: UILabel!
    @IBOutlet weak var valueProgressSlider: UISlider!
    
    @IBOutlet weak var valuePercentLabel: UILabel!

    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
