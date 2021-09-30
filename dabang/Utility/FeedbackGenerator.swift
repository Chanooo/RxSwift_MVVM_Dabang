//
//  FeedbackGenerator.swift
//  dabang
//
//  Created by 18101004 on 2021/09/30.
//

import Foundation
import UIKit
import Then

class FeedbackGenerator: NSObject {
    func impact(style: UIImpactFeedbackGenerator.FeedbackStyle = .light){
        _ = UIImpactFeedbackGenerator(style: style).then {
            $0.prepare()
            $0.impactOccurred()
        }
    }
    
    func selection() {
        _ = UISelectionFeedbackGenerator().then {
            $0.selectionChanged()
        }
    }
    
    func notification(type: UINotificationFeedbackGenerator.FeedbackType) {
        _ = UINotificationFeedbackGenerator().then {
            $0.prepare()
            $0.notificationOccurred(type)
        }
    }
}
