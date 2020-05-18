//
//  ItemInfoTableViewCell.swift
//  RecycleHelper
//
//  Created by Becca Hallam on 18/05/2020.
//  Copyright © 2020 Becca Hallam. All rights reserved.
//

import UIKit

class ItemInfoTableViewCell: UITableViewCell {

    @IBOutlet weak var instr: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        //let margins = UIEdgeInsets(top: 0, left: 0, bottom: 10, right: 0)
        //bounds = bounds.inset(by: margins)
    }

}
