//
//  SourceEditorCommand.swift
//  Multiliner
//
//  Created by A. Zheng (github.com/aheze) on 6/27/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import Foundation
import XcodeKit

public enum FormatError: Error, CustomStringConvertible, LocalizedError, CustomNSError {
    case noSelection

    public var description: String {
        switch self {
        case .noSelection:
            return "No selection."
        }
    }

    public var localizedDescription: String {
        return "Error: \(description)."
    }

    public var errorUserInfo: [String: Any] {
        return [NSLocalizedDescriptionKey: localizedDescription]
    }
}


class SourceEditorCommand: NSObject, XCSourceEditorCommand {
    
    /// The `Format Selection` command.
    func perform(with invocation: XCSourceEditorCommandInvocation, completionHandler: @escaping (Error?) -> Void) {

        /// Get the selection first.
        guard
            let selection = invocation.buffer.selections.firstObject,
            let range = selection as? XCSourceTextRange
        else {
            completionHandler(FormatError.noSelection)
            return
        }

        let oldLines = getLines(from: invocation.buffer)

        let startTab = oldLines[range.start.line]
            .prefix { $0 == " " }

        let tab = String(repeating: " ", count: invocation.buffer.indentationWidth)
        let parameterTab = startTab + tab

        let text = getText(from: range, buffer: invocation.buffer)

        let openingParenthesisIndex = text.firstIndex(of: "(")
        let closingParenthesisIndex = text.lastIndex(of: ")")

        let openingArrayIndex = text.firstIndex(of: "[")
        let closingArrayIndex = text.lastIndex(of: "]")

        let openingBracesIndex: String.Index? = [openingParenthesisIndex, openingArrayIndex]
            .compactMap { $0 }
            .sorted()
            .first

        let closingBracesIndex: String.Index? = [closingParenthesisIndex, closingArrayIndex]
            .compactMap { $0 }
            .sorted()
            .last

        guard let openingBracesIndex = openingBracesIndex, let closingBracesIndex = closingBracesIndex else { return }

        let openingParametersIndex = text.index(after: openingBracesIndex)
        let closingParametersIndex = closingBracesIndex

        let parametersString = text[openingParametersIndex ..< closingParametersIndex]
        let parameters = parametersString
            .components(separatedBy: ",")

        let parametersFormatted: [String] = parameters.enumerated()
            .map { index, element in
                let line = element.trimmingCharacters(in: .whitespaces)
                if index == parameters.indices.last {
                    return parameterTab + line
                } else {
                    return parameterTab + line + ","
                }
            }

        let openingString = text[..<openingParametersIndex]
        let closingString = startTab + text[closingBracesIndex...] /// add start tab padding

        let newLines = [openingString] + parametersFormatted + [closingString]

        let openingLines = oldLines[..<range.start.line]
        let closingLines = oldLines[(range.end.line + 1)...]
        let lines = Array(openingLines) + Array(newLines) + Array(closingLines)

        invocation.buffer.lines.removeAllObjects()
        invocation.buffer.lines.addObjects(from: lines)

        /// Success!
        completionHandler(nil)
    }

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
