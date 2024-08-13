import Markdown
import SwiftUI

// MARK: - Inline Code Block
extension Renderer {
    mutating func visitInlineCode(_ inlineCode: InlineCode) -> Result {
        var attributedString = AttributedString(stringLiteral: inlineCode.code)
        attributedString.font = configuration.fontGroup.body.monospaced()
        attributedString.foregroundColor = configuration.inlineCodeTintColor
        attributedString.backgroundColor = configuration.inlineCodeTintColor.opacity(0.1)
        return Result(SwiftUI.Text(attributedString))
    }
    
    func visitInlineHTML(_ inlineHTML: InlineHTML) -> Result {
        Result(SwiftUI.Text(inlineHTML.rawHTML))
    }
}

// MARK: - Code Block

extension Renderer {
    mutating func visitCodeBlock(_ codeBlock: CodeBlock) -> Result {
        var code = codeBlock.code
        if let lastCode = code.last {
            if lastCode.isNewline {
                code = String(code.dropLast())
            }
        }
        return Result {
            #if os(watchOS) || os(tvOS)
            SwiftUI.Text(code)
            #else
            HighlightedCodeBlock(
                language: codeBlock.language,
                code: code,
                theme: configuration.codeBlockTheme
            )
            .padding(.vertical, configuration.componentSpacing)
            #endif
        }
    }
    
    func visitHTMLBlock(_ html: HTMLBlock) -> Result {
        // Forced conversion of text to view
        Result {
            SwiftUI.Text(html.rawHTML)
        }
    }
}
