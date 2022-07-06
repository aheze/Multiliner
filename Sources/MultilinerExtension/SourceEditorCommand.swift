//
//  SourceEditorCommand.swift
//  Multiliner
//
//  Created by A. Zheng (github.com/aheze) on 6/27/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import Foundation
import XcodeKit

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

enum SelectionKind {
    case parameters
    case array
}

class SourceEditorCommand: NSObject, XCSourceEditorCommand {
    /// The `Format Selected Code` command.
    func perform(with invocation: XCSourceEditorCommandInvocation, completionHandler: @escaping (Error?) -> Void) {
        /// Get the selection first.
        guard
            let selection = invocation.buffer.selections.firstObject,
            let range = selection as? XCSourceTextRange
        else {
            completionHandler(FormatError.noSelection)
            return
        }

        /// It's possible that the user selected the last "extra" line too.
        if range.start.line > invocation.buffer.lines.count - 1 { range.start.line -= 1 }
        if range.end.line > invocation.buffer.lines.count - 1 { range.end.line -= 1 }

        /// Store the current lines of the entire file.
        let oldLines = getLines(from: invocation.buffer)

        /// The width of a single tab, usually `    `.
        let tab: String

        /// The selection's starting tab.
        /// Example:
        //     **input**  `    init()`
        //     **output** `    `
        let startTab: Substring

        let startColumn: Int

        if invocation.buffer.usesTabsForIndentation {
            tab = "\u{0009}" /// Tab character.

            startTab = oldLines[range.start.line]
                .prefix { $0 == "\u{0009}" }

            startColumn = startTab.count

        } else {
            startTab = oldLines[range.start.line]
                .prefix { $0 == " " }

            tab = String(repeating: " ", count: invocation.buffer.indentationWidth)

            startColumn = startTab.count / invocation.buffer.indentationWidth
        }

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
        /// Only use the opening brace for comparison.
        var selectionKind: SelectionKind
        switch (openingParenthesisIndex, openingArrayIndex) {
        case let (.some(openingParenthesisIndex), .some(openingArrayIndex)):
            if openingParenthesisIndex < openingArrayIndex {
                selectionKind = .parameters
            } else {
                selectionKind = .array
            }
        case (.some, .none):
            selectionKind = .parameters
        case (.none, .some):
            selectionKind = .array
        default:
            completionHandler(FormatError.noSelection)
            return
        }

        /// Determine if the selection was an array or a set of parameters.
        let openingBracesIndex: String.Index? = selectionKind == .parameters
            ? openingParenthesisIndex
            : openingArrayIndex

        let closingBracesIndex: String.Index? = selectionKind == .parameters
            ? closingParenthesisIndex
            : closingArrayIndex

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
                let line = element.trimmingCharacters(in: .whitespacesAndNewlines)
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
        let newLines = [openingString] + contentsFormatted + closingString.split(separator: "\n")

        /// The range in the existing lines that were modified.
        let oldRange = NSRange(location: range.start.line, length: range.end.line - range.start.line + 1)

        /// Update the source code.
        invocation.buffer.lines.replaceObjects(in: oldRange, withObjectsFrom: newLines)

        /// Update the selection to encompass the new text.
        invocation.buffer.selections.removeAllObjects()
        invocation.buffer.selections.add(
            XCSourceTextRange(
                start: XCSourceTextPosition(line: range.start.line, column: startColumn),
                end: XCSourceTextPosition(line: range.start.line + newLines.count - 1, column: closingString.count - 1)
            )
        )

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
