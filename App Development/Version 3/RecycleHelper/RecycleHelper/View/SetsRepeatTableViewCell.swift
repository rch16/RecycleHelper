//
//  SetsRepeatTableViewCell.swift
//  RecycleHelper
//
//  Created by Becca Hallam on 05/06/2020.
//  Copyright © 2020 Becca Hallam. All rights reserved.
//

import UIKit

protocol SwitchDelegate: class {
    func didChangeValue(value: Bool)
}

class SetsRepeatTableViewCell: UITableViewCell {

    // Attach UI
    @IBOutlet weak var repeatSwitch: UISwitch!
    @IBAction func repeatStatusDidChange(_ sender: UISwitch) {
        valueDidChange(sender)
    }
    
    weak var delegate: SwitchDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        initView()
    }
    
    public func configure(value: Bool?) {
        repeatSwitch.setOn(value!, animated: false)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func initView() {
        repeatSwitch.addTarget(self, action: #selector(valueDidChange), for: .valueChanged)
    }
    
    @objc func valueDidChange(_ sender: UISwitch) {
        delegate?.didChangeValue(value: sender.isOn)
    }

}
