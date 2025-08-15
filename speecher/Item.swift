//
//  Item.swift
//  speecher
//
//  Created by Lazaro Borges on 15/08/25.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
