import SwiftUI

@main
struct StageAgentApp: App {
    @StateObject private var stageListViewModel = StageListViewModel(container: AppContainer.makeDefault())

    var body: some Scene {
        WindowGroup {
            NavigationStack {
                StageListView(viewModel: stageListViewModel)
            }
        }
    }
}
