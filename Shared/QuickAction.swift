import Foundation

enum QuickAction: String {
    case home = "home", memories = "memories", search = "search", profile = "profile"
}

final class QuickActionService: ObservableObject {
    @Published var action: QuickAction?
    
    init(initialValue: QuickAction? = nil) {
        action = initialValue
    }
}
