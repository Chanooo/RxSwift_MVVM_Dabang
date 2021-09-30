//
//  UIImage+.swift
//  dabang
//
//  Created by CNOO on 2021/09/30.
//

import Foundation
import UIKit

extension UIImage {
    func resizedImage(targetSize: CGSize) -> UIImage? {
        let renderer = UIGraphicsImageRenderer(size: targetSize)
        return renderer.image { _ in
            self.draw(in: CGRect(origin: .zero, size: targetSize))
        }
    }
}
