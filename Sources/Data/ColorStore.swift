//
//  ColorStore.swift
//  AppLogger
//
//  Created by Pedro Almeida on 08.04.25.
//

import protocol SwiftUI.ObservableObject
import struct Models.DynamicColor

@MainActor
package final class ColorStore<Element>: ObservableObject where Element: Hashable {
    private lazy var allColors = [DynamicColor]()
    
    private var assignedColors: [Element: DynamicColor] = [:]
    
    package init() {}
    
    package func color(for element: Element) -> DynamicColor {
        if let color = assignedColors[element] {
            return color
        }
        
        if allColors.isEmpty {
            allColors = DynamicColor.makeColors().shuffled()
        }
        
        let newColor = allColors.removeFirst()
        assignedColors[element] = newColor
        return newColor
    }
}
