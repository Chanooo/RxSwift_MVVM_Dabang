//
//  FilterButton.swift
//  dabang
//
//  Created by 18101004 on 2021/09/30.
//

import Foundation
import UIKit

@IBDesignable
class FilterButton: UIButton {
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
    }
    
    private var _on: Bool = true
    var on: Bool {
        get {
            return self._on
        }
        set {
            _on = newValue
            layer.masksToBounds = true
            backgroundColor = newValue ? .blue : .white
            layer.cornerRadius = 8
            titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .bold)
            setTitleColor(.black, for: .normal)
        }
    }
    
}
