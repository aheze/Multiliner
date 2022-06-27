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
    case invalidSelection

    public var description: String {
        switch self {
        case .noSelection:
            return "No selection."
        case .invalidSelection:
            return "Selection must be bounded by `()` or `[]`."
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

        /// Store the current lines of the entire file.
        let oldLines = getLines(from: invocation.buffer)

        /// The selection's starting tab.
        /// Example:
        //     **input**  `    init()`
        //     **output** `    `
        let startTab = oldLines[range.start.line]
            .prefix { $0 == " " }

        /// The width of a single tab, usually `    `.
        let tab = String(repeating: " ", count: invocation.buffer.indentationWidth)
        
        /// The tab that prefixes each parameter/array element.
        let contentTab = startTab + tab

        /// The entire text of the file.
        let text = getText(from: range, buffer: invocation.buffer)

        /// Get the opening and closing indices if the selected text contains parameters.
        let openingParenthesisIndex = text.firstIndex(of: "(")
        let closingParenthesisIndex = text.lastIndex(of: ")")

        /// Get the opening and closing array element if the selected text is an array.
        let openingArrayIndex = text.firstIndex(of: "[")
        let closingArrayIndex = text.lastIndex(of: "]")

        /// Determine if the selection was an array or a set of parameters.
        let openingBracesIndex: String.Index? = [openingParenthesisIndex, openingArrayIndex]
            .compactMap { $0 }
            .sorted()
            .first

        let closingBracesIndex: String.Index? = [closingParenthesisIndex, closingArrayIndex]
            .compactMap { $0 }
            .sorted()
            .last

        /// Make sure there's an opening and closing index.
        guard let openingBracesIndex = openingBracesIndex, let closingBracesIndex = closingBracesIndex else {
            completionHandler(FormatError.invalidSelection)
            return
        }

        /// Skip the opening `(` or `[`.
        let openingContentIndex = text.index(after: openingBracesIndex)
        let closingContentIndex = closingBracesIndex

        /// The text inside the braces.
        let contentsString = text[openingContentIndex ..< closingContentIndex]
        let contents = contentsString
            .components(separatedBy: ",")

        /// Format the content by adding spaces and commas.
        let contentsFormatted: [String] = contents.enumerated()
            .map { index, element in
                let line = element.trimmingCharacters(in: .whitespaces)
                if index == contents.indices.last {
                    return contentTab + line
                } else {
                    return contentTab + line + ","
                }
            }

        /// The string that comes before the selection.
        let openingString = text[..<openingContentIndex]
        let closingString = startTab + text[closingContentIndex...] /// add start tab padding

        /// The new lines of the entire file.
        let newLines = [openingString] + contentsFormatted + [closingString]

        let openingLines = oldLines[..<range.start.line]
        let closingLines = oldLines[(range.end.line + 1)...]
        let lines = Array(openingLines) + Array(newLines) + Array(closingLines)

        /// Update the source code.
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
