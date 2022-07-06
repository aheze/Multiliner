//
//  FormatError.swift
//  Multiliner
//
//  Created by A. Zheng (github.com/aheze) on 7/5/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import Foundation

enum FormatError: Error, CustomStringConvertible, LocalizedError, CustomNSError {
    case noSelection
    case invalidSelection

    var description: String {
        switch self {
        case .noSelection:
            return "No selection."
        case .invalidSelection:
            return "Selection must be bounded by `()` or `[]`."
        }
    }

    var localizedDescription: String {
        return "Error: \(description)."
    }

    var errorUserInfo: [String: Any] {
        return [NSLocalizedDescriptionKey: localizedDescription]
    }
}
