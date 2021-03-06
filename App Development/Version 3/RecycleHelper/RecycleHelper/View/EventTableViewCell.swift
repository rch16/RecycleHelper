//
//  EventTableViewCell.swift
//  RecycleHelper
//
//  Created by Becca Hallam on 04/06/2020.
//  Copyright © 2020 Becca Hallam. All rights reserved.
//

import UIKit

class EventTableViewCell: UITableViewCell {

    // Attach UI
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    // Cell height
    class func cellHeight() -> CGFloat {
        return 44.0
    }
    
    // Update text
    func updateText(text: String, date: Date) {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        dateFormatter.locale = Locale(identifier: "en_GB")
        
        dateFormatter.setLocalizedDateFormatFromTemplate("hh:mm MMMMd")

        label.text = text
        valueLabel.text = dateFormatter.string(from: date)

    }
    
    func updateCollection(text: String, day: Int) {
        label.text = text
        valueLabel.text = K.weekdaysFromDateComponent[day]
    }
    
    func updateFrequency(text: String, frequency: String){
        label.text = text
        valueLabel.text = frequency
    }
    
    func updateGoal(text: String, goal: Int){
        label.text = text
        valueLabel.text = String(goal)
    }

}
