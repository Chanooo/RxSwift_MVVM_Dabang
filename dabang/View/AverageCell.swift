//
//  AverageCell.swift
//  dabang
//
//  Created by CNOO on 2021/09/30.
//

import Foundation
import UIKit

class AverageCell: UITableViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var yearPriceLabel: UILabel!
    @IBOutlet weak var monthPriceLabel: UILabel!
    
    func setUI(data: AverageModel) {
        selectedBackgroundView = UIView()
        
        nameLabel.text = data.name
        yearPriceLabel.text = data.yearPrice
        monthPriceLabel.text = data.monthPrice
    }
    
}
