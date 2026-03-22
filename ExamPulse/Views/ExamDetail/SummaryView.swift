import SwiftUI

struct SummaryView: View {
    let summary: Summary
    @State private var viewModel: SummaryViewModel

    init(summary: Summary) {
        self.summary = summary
        _viewModel = State(initialValue: SummaryViewModel(summaryText: summary.content))
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
