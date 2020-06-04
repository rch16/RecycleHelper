//
//  DatePickerTableViewCell.swift
//  RecycleHelper
//
//  Created by Becca Hallam on 04/06/2020.
//  Copyright © 2020 Becca Hallam. All rights reserved.
//

import UIKit

protocol DatePickerDelegate: class {
    func didChangeDate(date: Date, indexPath: IndexPath)
}

class DatePickerTableViewCell: UITableViewCell {

    // Attach UI
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBAction func dateChanged(_ sender: UIDatePicker) {
        dateDidChange(sender)
    }
    
    var indexPath: IndexPath!
    weak var delegate: DatePickerDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        initView()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    // Cell height
    class func cellHeight() -> CGFloat {
        return 162.0
    }

    func initView() {
        datePicker.addTarget(self, action: #selector(dateDidChange), for: .valueChanged)
    }

    func updateCell(date: Date, indexPath: IndexPath) {
        datePicker.setDate(date, animated: true)
        self.indexPath = indexPath
    }
    
    @objc func dateDidChange(_ sender: UIDatePicker) {
        let indexPathForDisplayDate = IndexPath(row: indexPath.row - 1, section: indexPath.section)
        delegate?.didChangeDate(date: sender.date, indexPath: indexPathForDisplayDate)
    }
}
