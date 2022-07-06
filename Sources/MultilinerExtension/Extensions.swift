//
//  Extensions.swift
//  Multiliner
//
//  Created by A. Zheng (github.com/aheze) on 7/5/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import Foundation
import XcodeKit

extension XCSourceEditorCommand {
    /// Get the lines of an entire files as an array of `String`s.
    func getLines(from buffer: XCSourceTextBuffer) -> [String] {
        guard let lines = buffer.lines as? [String] else { return [] }
        return lines
    }

    /// Get a single string from a range.
    func getText(from range: XCSourceTextRange, buffer: XCSourceTextBuffer) -> String {
        let allLines = getLines(from: buffer)
        let lines = allLines[range.start.line ... range.end.line]
        let text = lines.map { String($0) }.joined()
        return text
    }
}
