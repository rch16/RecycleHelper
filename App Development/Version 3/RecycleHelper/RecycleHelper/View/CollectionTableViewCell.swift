//
//  CollectionTableViewCell.swift
//  RecycleHelper
//
//  Created by Becca Hallam on 04/06/2020.
//  Copyright © 2020 Becca Hallam. All rights reserved.
//

import UIKit

class CollectionTableViewCell: UITableViewCell {
    
    @IBOutlet weak var collectionTitle: UILabel!
    @IBOutlet weak var collectionDate: UILabel!
    
    // Attach UI
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
