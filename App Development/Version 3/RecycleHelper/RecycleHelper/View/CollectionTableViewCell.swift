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
    @IBOutlet weak var repeatBtn: UIButton!
    
    // Attach UI
    override func awakeFromNib() {
        super.awakeFromNib()
        // Keep rounded corners
        self.contentView.layer.cornerRadius = 15
        self.layer.cornerRadius = 15
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Keep rounded corners
//        self.contentView.layer.cornerRadius = 15
//        self.layer.cornerRadius = 15
    }

}
