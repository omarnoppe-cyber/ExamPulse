import SwiftUI

struct SummaryView: View {
    let summaryText: String
    @State private var viewModel: SummaryViewModel

    init(summaryText: String) {
        self.summaryText = summaryText
        _viewModel = State(initialValue: SummaryViewModel(summaryText: summaryText))
    }

    var body: some View {
        ScrollView {
            Text(LocalizedStringKey(viewModel.summaryText))
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .textSelection(.enabled)
        }
        .navigationTitle("Summary")
        .navigationBarTitleDisplayMode(.inline)
    }
}
