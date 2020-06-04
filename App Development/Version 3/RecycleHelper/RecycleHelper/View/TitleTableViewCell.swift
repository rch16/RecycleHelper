//
//  TitleTableViewCell.swift
//  RecycleHelper
//
//  Created by Becca Hallam on 04/06/2020.
//  Copyright © 2020 Becca Hallam. All rights reserved.
//

import UIKit

class TitleTableViewCell: UITableViewCell {//}, UITextFieldDelegate {
    
    // Attach UI
    @IBOutlet weak var collectionTitle: UITextField!
    
    var indexPath: IndexPath!
    weak var delegate: UITextFieldDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        //collectionTitle.delegate = self
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    public func configure(text: String?, placeholder: String) {
        collectionTitle.text = text
        collectionTitle.placeholder = placeholder
        collectionTitle.accessibilityValue = text
        collectionTitle.accessibilityLabel = placeholder
    }
}
