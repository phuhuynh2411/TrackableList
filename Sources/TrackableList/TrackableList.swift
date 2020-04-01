import SwiftUI

public struct TrackableList<Content>: View where Content: View {
    let content: Content
    public typealias Action = ()-> Void
    let action: Action?
    let showDividers: Bool
    
    public init(onLast: Action?, showDividers: Bool = true, content: ()-> Content) {
        self.content = content()
        self.action = onLast
        self.showDividers = showDividers
        
        UITableView.appearance().separatorColor = .clear
    }
    
    public var body: some View {
        List {
            self.content
                .listRowBackground(self.divider)
            Color.blue.frame(height: 0).onAppear {
                DispatchQueue.main.async {
                    self.action?()
                }
            }
        }
        .environment(\.defaultMinListRowHeight, 0)
    }
    
    public var divider: some View {
        Group {
            if self.showDividers {
                VStack{
                    Spacer()
                    Divider()
                        .padding(.leading)
                }
            }
        }
    }
}
