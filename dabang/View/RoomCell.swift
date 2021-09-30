//
//  RoomCell.swift
//  dabang
//
//  Created by CNOO on 2021/09/30.
//

import Foundation
import UIKit

class RoomCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var roomTypeLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!
    @IBOutlet weak var tagStackView: UIStackView!
    @IBOutlet weak var starView: UIImageView!
    @IBOutlet weak var thumnail: UIImageView!  // 126 * 84
    
    func setUI(data: RoomModel) {
        selectedBackgroundView = UIView()
        thumnail.layer.masksToBounds = true
        thumnail.layer.cornerRadius = 4
        thumnail.tintColor = UIColor.secondaryLabel
        
        thumnail.setImage(from: data.imgUrl)
        titleLabel.text = "\(SellingType(rawValue: data.sellingType) ?? .월세) \(data.priceTitle)"
        roomTypeLabel.text = "\(RoomType(rawValue: data.roomType) ?? .원룸)"
        descLabel.text = data.desc
        
        starView.image = UIImage(named: data.isCheck ? "star_on" : "star_off")
        
        tagStackView.arrangedSubviews.forEach{$0.removeFromSuperview()} // Clear
        data.hashTags.enumerated().forEach{ idx, tag in
            if idx > 3 { return }
            let text = idx == 3 ? "..." : tag
            let tagLabel = UILabel().then {
                $0.text = text
                $0.font = UIFont.systemFont(ofSize: 11, weight: .regular)
                $0.textColor = UIColor(argb: 0xFF888888)
                $0.backgroundColor = UIColor(argb: 0xFFF4F4F4)
                $0.layer.masksToBounds = true
                $0.layer.cornerRadius = 2
                $0.textAlignment = .center
            }
            tagStackView.addArrangedSubview(tagLabel)
            let width = text.size(withAttributes: [NSAttributedString.Key.font : tagLabel.font!]).width
            tagLabel.snp.makeConstraints{
                $0.width.equalTo(width+4)
            }
        }
        
    }
}
