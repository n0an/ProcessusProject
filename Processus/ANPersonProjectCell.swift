//
//  ANPersonProjectCell.swift
//  Processus
//
//  Created by Anton Novoselov on 14/05/16.
//  Copyright © 2016 Anton Novoselov. All rights reserved.
//

import UIKit

class ANPersonProjectCell: UITableViewCell {

    @IBOutlet weak var customerNameLabel: UILabel!
    @IBOutlet weak var projectNameLabel: UILabel!
    @IBOutlet weak var completedRatioLabel: UILabel!
    @IBOutlet weak var projectDueDateLabel: UILabel!
    
    @IBOutlet weak var participantsCountLabel: UILabel!

    
    @IBOutlet weak var projectStateView: UIView!
    
    
    @IBOutlet weak var checkMarkImageView: UIImageView!


    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
