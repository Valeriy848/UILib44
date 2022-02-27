//
//  Vibrate.swift
//  UILib44
//
//  Created by Valeriy on 20.02.2022.
//

import UIKit

public final class Vibrate {

    private init() {}

    public static func vibrate(style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }
}
