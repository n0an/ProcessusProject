//
//  ANProjectInfoStateCell.swift
//  Processus
//
//  Created by Anton Novoselov on 14/05/16.
//  Copyright © 2016 Anton Novoselov. All rights reserved.
//

import UIKit

class ANProjectInfoStateCell: UITableViewCell {

    @IBOutlet weak var keyLabel: UILabel!
    @IBOutlet weak var valueStateSegmentedControl: UISegmentedControl!
    @IBOutlet weak var projectStateView: UIView!

    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
