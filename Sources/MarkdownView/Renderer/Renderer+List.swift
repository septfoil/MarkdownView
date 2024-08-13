import Markdown
import SwiftUI

extension Renderer {
    // List row which contains inner items.
    mutating func visitListItem(_ listItem: ListItem) -> Result {
        Result {
            let contents = contents(of: listItem)
            VStack(alignment: .leading, spacing: configuration.componentSpacing / 2) {
                ForEach(contents.indices, id: \.self) { index in
                    contents[index].content
                }
            }
            .padding(.vertical, listItem.listDepth == 0 ? configuration.componentSpacing / 2 : 0)
        }
    }
    
    mutating func visitOrderedList(_ orderedList: OrderedList) -> Result {
        Result {
            let listItems = orderedList.children.map { $0 as! ListItem }
            let itemContent = listItems.map { visit($0).content }
            let depth = orderedList.listDepth
            let handler = interactiveEditHandler
            let rawText = text
            let configuration = configuration
            VStack(alignment: .leading, spacing: configuration.componentSpacing / 2) {
                ForEach(listItems.indices, id: \.self) { index in
                    let listItem = listItems[index]
                    HStack(alignment: .firstTextBaseline) {
                        SwiftUI.Text("\(index + 1).")
                            .padding(.leading, depth == 0 ? configuration.listIndent : 0)
                        itemContent[index]
                    }
                }
            }
            .padding(.vertical, orderedList.listDepth == 0 ? configuration.componentSpacing / 2 : 0)
        }
    }
    
    mutating func visitUnorderedList(_ unorderedList: UnorderedList) -> Result {
        Result {
            let listItems = unorderedList.children.map { $0 as! ListItem }
            let itemContent = listItems.map { visit($0).content }
            let depth = unorderedList.listDepth
            let handler = interactiveEditHandler
            let rawText = text
            let configuration = configuration
            VStack(alignment: .leading, spacing: configuration.componentSpacing / 2) {
                ForEach(itemContent.indices, id: \.self) { index in
                    let listItem = listItems[index]
                    HStack(alignment: .firstTextBaseline) {
                        SwiftUI.Text(configuration.unorderedListBullet)
                            .font(.title2)
                            .padding(.leading, depth == 0 ? configuration.listIndent : 0)
                        itemContent[index]
                    }
                }
            }
            .padding(.vertical, orderedList.listDepth == 0 ? configuration.componentSpacing / 2 : 0)
        }
    }
}

struct CheckBoxRewriter: MarkupRewriter {
    func visitListItem(_ listItem: ListItem) -> Markup? {
        var listItem = listItem
        listItem.checkbox = listItem.checkbox == .checked ? .unchecked : .checked
        return listItem
    }
}

struct CheckboxView: View {
    var listItem: ListItem
    var text: String
    var handler: (String) -> Void
    
    var body: some View {
        if let checkbox = listItem.checkbox {
            switch checkbox {
            case .checked:
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.accentColor)
                    #if !os(tvOS)
                    .onTapGesture(perform: toggleStatus)
                    #endif
            case .unchecked:
                Image(systemName: "circle")
                    .foregroundStyle(.secondary)
                    #if !os(tvOS)
                    .onTapGesture(perform: toggleStatus)
                    #endif
            }
        }
    }
    
    func toggleStatus() {
        guard let sourceRange = listItem.range else { return }
        let rewriter = CheckBoxRewriter()
        let newNode = rewriter.visitListItem(listItem) as! ListItem
        let newMarkdownText = newNode.format().trimmingCharacters(in: .newlines)
        
        var separatedText = text.split(separator: "\n", omittingEmptySubsequences: false)
        separatedText[sourceRange.lowerBound.line - 1] = Substring(stringLiteral: newMarkdownText)
        handler(separatedText.joined(separator: "\n"))
    }
}
