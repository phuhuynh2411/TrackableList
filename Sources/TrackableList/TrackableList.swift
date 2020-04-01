import SwiftUI

public struct TrackableList<Content>: View where Content: View {
    let content: Content
    @State var contentSize: CGSize = .zero
    @State var visibleSize: CGSize  = .zero
    @State var contentOffset: CGFloat = .zero
    let threshold: CGFloat = 10
    @State var isLast: Bool = false
    public typealias Action = ()-> Void
    let action: Action?
    let whenScrollOnly: Bool
    
    public init(onLast: Action?, whenScrollOnly: Bool = true, content: ()-> Content) {
        self.content = content()
        self.action = onLast
        self.whenScrollOnly = whenScrollOnly
    }
    
    public var body: some View {
        GeometryReader { proxy1 in
            List {
                ZStack {
                    GeometryReader { proxy2 in
                        Color
                            .clear
                            .preference(key: ContentSizePreferenceKey.self
                                , value: [ContentSizePreferenceData(size: proxy2.frame(in: .global).size)])
                    }
                    VStack {
                        GeometryReader { proxy3 in
                            ZStack {
                                Color
                                    .clear
                                    .preference(key: ScrollOffsetPreferenceKey.self, value: [ScrollOffsetPreferenceData(offset: self.offset(proxy1, proxy3))])
                            }
                        }
                        VStack {
                            self.content
                        }
                    }
                }
                .preference(key: VisibleContentSizePreferenceKey.self, value: [ContentSizePreferenceData(size: proxy1.frame(in: .global).size)])
                .onPreferenceChange(ContentSizePreferenceKey.self) { (preferences) in
                    self.contentSize = preferences[0].size
                }
            }
            .onPreferenceChange(VisibleContentSizePreferenceKey.self) { (preferences) in
                if preferences.first != nil {
                    self.visibleSize = preferences[0].size
                }
            }
            .onPreferenceChange(ScrollOffsetPreferenceKey.self) { (preferences) in
                if preferences.first != nil {
                    self.contentOffset = preferences[0].offset
                    self.scrollToLast()
                }
            }
        }
    }
    
    func offset(_ outProxy: GeometryProxy, _ inProxy: GeometryProxy) -> CGFloat {
        return inProxy.frame(in: .global).minY - outProxy.frame(in: .global).minY
    }
    
    func scrollToLast() {
        if self.contentSize.height - abs(self.contentOffset) <= self.visibleSize.height + self.threshold, self.isScrollOnly {
            if !isLast {
                self.isLast = true
                DispatchQueue.main.asyncAfter {
                    self.action?()
                }
            }
        } else {
            self.isLast = false
        }
    }
    
    var isScrollOnly: Bool {
        self.whenScrollOnly ? self.contentSize.height > self.visibleSize.height : true
    }
}

struct ContentSizePreferenceKey: PreferenceKey {
    typealias Value = [ContentSizePreferenceData]
    static var defaultValue: [ContentSizePreferenceData] = []
    
    static func reduce(value: inout [ContentSizePreferenceData], nextValue: () -> [ContentSizePreferenceData]) {
        value.append(contentsOf: nextValue())
    }
}

struct VisibleContentSizePreferenceKey: PreferenceKey {
    typealias Value = [ContentSizePreferenceData]
    static var defaultValue: [ContentSizePreferenceData] = []
    
    static func reduce(value: inout [ContentSizePreferenceData], nextValue: () -> [ContentSizePreferenceData]) {
        value.append(contentsOf: nextValue())
    }
}

struct ContentSizePreferenceData: Equatable {
    let size: CGSize
}

struct ScrollOffsetPreferenceKey: PreferenceKey {
    typealias Value = [ScrollOffsetPreferenceData]
    
    static var defaultValue: [ScrollOffsetPreferenceData] = []
    
    static func reduce(value: inout [ScrollOffsetPreferenceData], nextValue: () -> [ScrollOffsetPreferenceData]) {
        value.append(contentsOf: nextValue())
    }
}

struct ScrollOffsetPreferenceData: Equatable {
    let offset: CGFloat
}
