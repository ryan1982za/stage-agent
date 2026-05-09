import SwiftUI

struct StageListView: View {
    @ObservedObject var viewModel: StageListViewModel
    @State private var isShowingExportPreview = false

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                TextField("Stage title", text: $viewModel.draftTitle)
                    .textFieldStyle(.roundedBorder)

                Button("Add") {
                    viewModel.createStage()
                }
                .buttonStyle(.borderedProminent)
            }
            .padding(.horizontal)
            .padding(.top, 12)

            if let message = viewModel.errorMessage {
                Text(message)
                    .font(.footnote)
                    .foregroundStyle(.red)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
            }

            if let message = viewModel.lastExportPathMessage {
                Text(message)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
            }

            List {
                ForEach(viewModel.stages) { stage in
                    VStack(alignment: .leading, spacing: 8) {
                        NavigationLink {
                            StageDetailView(viewModel: viewModel.makeDetailViewModel(stageId: stage.id))
                        } label: {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(stage.title)
                                    .font(.headline)
                                Text(stage.disciplineLabel.isEmpty ? "No discipline" : stage.disciplineLabel)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .buttonStyle(.plain)

                        HStack(spacing: 12) {
                            Button("Add Element") {
                                viewModel.addSampleElement(stageId: stage.id)
                            }
                            .buttonStyle(.bordered)

                            Button("Export JSON") {
                                viewModel.exportStage(id: stage.id, format: .json)
                                isShowingExportPreview = true
                            }
                            .buttonStyle(.bordered)

                            Button("Export CSV") {
                                viewModel.exportStage(id: stage.id, format: .csv)
                                isShowingExportPreview = true
                            }
                            .buttonStyle(.bordered)

                            Button("Export Files") {
                                viewModel.exportStageToFiles(id: stage.id)
                            }
                            .buttonStyle(.bordered)

                            Button("Rename") {
                                viewModel.renameStage(id: stage.id, newTitle: "\(stage.title) (Updated)")
                            }
                            .buttonStyle(.bordered)
                        }
                        .font(.caption)
                    }
                    .swipeActions {
                        Button(role: .destructive) {
                            viewModel.deleteStage(id: stage.id)
                        } label: {
                            Text("Delete")
                        }
                    }
                }
            }
            .listStyle(.plain)
        }
        .navigationTitle("Stages")
        .onAppear {
            viewModel.refresh()
        }
        .sheet(isPresented: $isShowingExportPreview) {
            NavigationStack {
                ScrollView {
                    Text(viewModel.exportPreviewText ?? "No export data")
                        .font(.system(.footnote, design: .monospaced))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                }
                .navigationTitle("Export Preview")
            }
        }
    }
}
