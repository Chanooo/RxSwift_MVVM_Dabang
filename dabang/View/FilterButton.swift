//
//  FilterButton.swift
//  dabang
//
//  Created by 18101004 on 2021/09/30.
//

import Foundation
import UIKit
import SnapKit

@IBDesignable
class FilterButton: UIButton {
    
    private var _on: Bool = true
    var on: Bool {
        get {
            return self._on
        }
        set {
            _on = newValue
            setUI(on: newValue)
        }
    }
    
    func setWidth() {
        if let width = titleLabel?.text?.size(withAttributes: [NSAttributedString.Key.font : titleLabel!.font!]).width {
            snp.makeConstraints{
                $0.width.equalTo(width+18)
            }
        }
    }
    
    private func setUI(on: Bool) {
        layer.masksToBounds = true
        backgroundColor = on ? UIColor.init(argb: 0xFF4383FF) : .white
        layer.borderColor = UIColor.init(argb: 0xFFDDDDDD).cgColor
        layer.borderWidth = 1
        layer.cornerRadius = 4
        titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        setTitleColor(on ? .white : UIColor.init(argb: 0xFF444444), for: .normal)
    }
    
}
