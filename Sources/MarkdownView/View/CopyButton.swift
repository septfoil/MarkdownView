import SwiftUI

#if os(macOS) || os(iOS)
struct CopyButton: View {
    var content: String
    @State private var copied = false
    #if os(macOS)
    @ScaledMetric private var size = 12
    #else
    @ScaledMetric private var size = 18
    #endif
    @State private var isHovering = false
    
    var body: some View {
        Button(action: copy) {
            Group {
                if copied {
                    Image("markdown-copied")
                        .transition(.opacity.combined(with: .scale))
                } else {
                    Image("markdown-copy")
                        .transition(.opacity.combined(with: .scale))
                }
            }
            .font(.system(size: size))
            .frame(width: size, height: size)
            .padding(8)
            .contentShape(Rectangle())
        }
        .foregroundStyle(.primary)
        .contentShape(Rectangle())
        .brightness(isHovering ? 0.3 : 0)
        .buttonStyle(.borderless) // Only use `.borderless` can behave correctly when text selection is enabled.
        .onHover { isHovering = $0 }
    }
    
    private func copy() {
        #if os(macOS)
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(content, forType: .string)
        #else
        UIPasteboard.general.string = content
        #endif
        Task {
            withAnimation(.spring()) {
                copied = true
            }
            try await Task.sleep(nanoseconds: 2_000_000_000)
            withAnimation(.spring()) {
                copied = false
            }
        }
    }
}
#endif
