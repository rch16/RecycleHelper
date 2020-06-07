//
//  ButtonTableViewCell.swift
//  RecycleHelper
//
//  Created by Becca Hallam on 07/06/2020.
//  Copyright © 2020 Becca Hallam. All rights reserved.
//

import UIKit

protocol CellActionDelegate: class {
    func callSegueFromCell(_ sender: Any?)
}

class ButtonTableViewCell: UITableViewCell {

    @IBOutlet weak var actionBtn: UIButton!
    @IBAction func actionBtnPressed(_ sender: UIButton) {
        if (self.delegate != nil) { // Just to be safe
            self.delegate?.callSegueFromCell(actionBtn.title(for: .normal))
        }
    }
    
    weak var delegate: CellActionDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
