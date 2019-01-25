//
//  UIView+Gradient.swift
//  Bate Ponto
//
//  Created by Lucas Franco Bernardes on 23/01/19.
//  Copyright © 2019 Lucas Franco Bernardes. All rights reserved.
//

import UIKit

extension UIView
{
    func applyGradient(colors: [CGColor])
    {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = colors
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0)
        gradientLayer.frame = self.bounds
        gradientLayer.cornerRadius = 10
        self.layer.insertSublayer(gradientLayer, at: 0)
        
    }
    
}
