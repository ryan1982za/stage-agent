import SwiftUI

struct StageDetailView: View {
    @ObservedObject var viewModel: StageDetailViewModel
    @State private var showExportPreview = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                if let stage = viewModel.stage {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Stage Metadata")
                            .font(.headline)

                        TextField("Stage title", text: $viewModel.titleDraft)
                            .textFieldStyle(.roundedBorder)

                        HStack {
                            Button("Save Title") {
                                viewModel.saveTitle()
                            }
                            .buttonStyle(.borderedProminent)

                            Button("Add Element") {
                                viewModel.addSampleElement()
                            }
                            .buttonStyle(.bordered)
                        }

                        Text("Elements: \(stage.elements.count)")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }

                    Divider()

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Checklist")
                            .font(.headline)

                        HStack {
                            TextField("Add checklist item", text: $viewModel.checklistDraft)
                                .textFieldStyle(.roundedBorder)
                            Button("Add") {
                                viewModel.addChecklistItem()
                            }
                            .buttonStyle(.bordered)
                        }

                        ForEach(viewModel.checklist) { item in
                            Button {
                                viewModel.toggleChecklist(item)
                            } label: {
                                HStack {
                                    Image(systemName: item.isDone ? "checkmark.circle.fill" : "circle")
                                    Text(item.text.isEmpty ? "(untitled item)" : item.text)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            .buttonStyle(.plain)
                        }
                    }

                    Divider()

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Run Notes")
                            .font(.headline)

                        HStack {
                            TextField("Add run note", text: $viewModel.runNoteDraft)
                                .textFieldStyle(.roundedBorder)
                            Button("Add") {
                                viewModel.addRunNote()
                            }
                            .buttonStyle(.bordered)
                        }

                        ForEach(viewModel.runNotes) { note in
                            Text(note.text)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(8)
                                .background(.thinMaterial)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                    }

                    Divider()

                    HStack {
                        Button("Export JSON") {
                            viewModel.export(format: .json)
                            showExportPreview = true
                        }
                        .buttonStyle(.bordered)

                        Button("Export CSV") {
                            viewModel.export(format: .csv)
                            showExportPreview = true
                        }
                        .buttonStyle(.bordered)

                        Button("Export PDF/PNG/JPG") {
                            viewModel.exportVisualFiles()
                        }
                        .buttonStyle(.bordered)
                    }
                } else {
                    Text("Stage not found")
                        .foregroundStyle(.secondary)
                }

                if let message = viewModel.lastExportPathMessage {
                    Text(message)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }

                if let message = viewModel.errorMessage {
                    Text(message)
                        .font(.footnote)
                        .foregroundStyle(.red)
                }
            }
            .padding()
        }
        .navigationTitle("Stage Detail")
        .sheet(isPresented: $showExportPreview) {
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
        .sheet(isPresented: $viewModel.isShowingShareSheet, onDismiss: {
            viewModel.dismissShareSheet()
        }) {
            ActivityShareSheet(activityItems: viewModel.shareFileURLs)
        }
    }
}
