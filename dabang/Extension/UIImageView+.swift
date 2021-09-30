//
//  UIImageView+.swift
//  dabang
//
//  Created by CNOO on 2021/09/30.
//

import Foundation
import UIKit

extension UIImageView {
    
    func setImage(from url: URL, contentMode mode: ContentMode = .scaleAspectFit) {
        contentMode = mode
        
        if url.absoluteString == "http://simpleicon.com/wp-content/uploads/apple.png" {
            DispatchQueue.main.async() { [weak self] in
                self?.image = UIImage(systemName: "applelogo")
            }
            return
        }
        
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)?.resizedImage(targetSize: CGSize(width: 126, height: 84))
                else { return }
            
            DispatchQueue.main.async() { [weak self] in
                self?.image = image
            }
        }.resume()
        
    }
    
    func setImage(from link: String, contentMode mode: ContentMode = .scaleAspectFit) {
        guard let url = URL(string: link) else { return }
        setImage(from: url, contentMode: mode)
    }
}
