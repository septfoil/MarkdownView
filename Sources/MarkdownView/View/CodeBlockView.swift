import SwiftUI

#if canImport(Highlightr)
import Highlightr
#endif

#if canImport(Highlightr)
struct HighlightedCodeBlock: View {
    var language: String?
    var code: String
    var theme: CodeHighlighterTheme
    
    @Environment(\.fontGroup) private var font
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.codeTheme) private var codeTheme
    @State private var attributedCode: AttributedString?
    @State private var showCopyButton = false
    
    private var id: String {
        "\(colorScheme) mode" + (codeTheme.theme) + code
    }

    var body: some View {
        Group {
            if let attributedCode {
                SwiftUI.Text(attributedCode)
            } else {
                SwiftUI.Text(code)
            }
        }
        .allowsHitTesting(false)
        .task(id: id, highlight)
        .font(font.codeBlock)
        .padding(.horizontal, 12)
        .padding(.vertical, 9)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.quaternary.opacity(0.5), in: RoundedRectangle(cornerRadius: 8))
//        .gesture(
//            TapGesture()
//                .onEnded { _ in showCopyButton.toggle() }
//        )
        .overlay(alignment: .topTrailing) {
            if showCopyButton {
                CopyButton(content: code)
                    .padding(8)
                    .transition(.opacity.animation(.easeInOut))
            }
        }
//        .overlay(alignment: .bottomTrailing) {
//            codeLanguage
//        }
        .onHover { showCopyButton = $0 }
    }
    
    @ViewBuilder
    private var codeLanguage: some View {
        if let language {
            SwiftUI.Text(language.uppercased())
                .font(.callout)
                .padding(8)
                .foregroundStyle(.secondary)
        }
    }
    
    @Sendable private func highlight() async {
        guard let highlighter = Highlightr.shared else { return }
        let language = highlighter.supportedLanguages().first(where: { $0.lowercased() == self.language?.lowercased() })
        if let highlightedCode = highlighter.highlight(code, as: language) {
            withAnimation {
                attributedCode = AttributedString(highlightedCode)
                attributedCode?.font = font.codeBlock
            }
        }
    }
}
#endif

// MARK: - Shared Instance

#if canImport(Highlightr)
extension Highlightr {
    static var shared: Highlightr? = Highlightr()
}
#endif

struct CodeHighlighterUpdator: ViewModifier {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.codeTheme) private var theme
    
    func body(content: Content) -> some View {
        content
            #if canImport(Highlightr)
            .onChange(of: theme) { newTheme in
                Highlightr.shared?.theme = newTheme
            }
            #endif
    }
}

extension View {
    func updateCodeBlocksWhenColorSchemeChanges() -> some View {
        modifier(CodeHighlighterUpdator())
    }
}
