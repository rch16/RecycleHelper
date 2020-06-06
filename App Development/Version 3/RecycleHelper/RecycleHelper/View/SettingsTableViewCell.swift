//
//  SettingsTableViewCell.swift
//  RecycleHelper
//
//  Created by Becca Hallam on 06/06/2020.
//  Copyright © 2020 Becca Hallam. All rights reserved.
//

import UIKit

class SettingsTableViewCell: UITableViewCell {

    // Attach UI
    @IBOutlet weak var nameTextField: UITextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
