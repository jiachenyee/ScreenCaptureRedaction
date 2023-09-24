import SwiftUI

struct RedactWhenScreenRecordedModifier: ViewModifier {
    func body(content: Content) -> some View {
        ScreenCaptureRedactionView {
            content
        }
    }
}

public extension View {
    func redactWhenScreenRecorded() -> some View {
        self.modifier(RedactWhenScreenRecordedModifier())
    }
}

public struct ScreenCaptureRedactionView<Content: View, ReplacementView: View>: View {
    
    var content: Content
    var replacementView: ReplacementView
    
    public init(@ViewBuilder content: @escaping (() -> Content), 
         @ViewBuilder replacingWith replacementView: @escaping (() -> ReplacementView)) {
        self.content = content()
        self.replacementView = replacementView()
    }
    
    public init(@ViewBuilder content: @escaping (() -> Content)) where ReplacementView == EmptyView {
        self.content = content()
        self.replacementView = EmptyView()
    }

    public var body: some View {
        if #available(iOS 17.0, *) {
            ScreenCaptureRedactionViewNew(content: content, replacingWith: replacementView)
        } else {
            ScreenCaptureRedactionViewOld(content: content, replacingWith: replacementView)
        }
    }
}

@available(iOS 17.0, *)
struct ScreenCaptureRedactionViewNew<Content: View, ReplacementView: View>: View {
    
    @Environment(\.isSceneCaptured) var isSceneCaptured
    @Environment(\.scenePhase) var scenePhase
    
    var content: Content
    var replacementView: ReplacementView
    
    init(content: Content, replacingWith replacementView: ReplacementView) {
        self.content = content
        self.replacementView = replacementView
    }
    
    var body: some View {
        if isSceneCaptured || scenePhase != .active {
            if replacementView is EmptyView {
                content
                    .redacted(reason: .placeholder)
            } else {
                replacementView
            }
        } else {
            content
        }
    }
}

@available(iOS, obsoleted: 17.0, message: "Use ScreenCaptureRedactionViewNew instead.")
struct ScreenCaptureRedactionViewOld<Content: View, ReplacementView: View>: View {
    
    @State private var isSceneCaptured = UIScreen.main.isCaptured
    @Environment(\.scenePhase) var scenePhase
    
    var content: Content
    var replacementView: ReplacementView
    
    init(content: Content, replacingWith replacementView: ReplacementView) {
        self.content = content
        self.replacementView = replacementView
    }
    
    var body: some View {
        Group {
            if isSceneCaptured || scenePhase != .active {
                if replacementView is EmptyView {
                    content
                        .redacted(reason: .placeholder)
                } else {
                    replacementView
                }
            } else {
                content
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIScreen.capturedDidChangeNotification)) { _ in
            isSceneCaptured = UIScreen.main.isCaptured
        }
    }
}
