import SwiftUI
import StageDesignerDomain

struct StageDetailView: View {
    @ObservedObject var viewModel: StageDetailViewModel
    @State private var showExportPreview = false
    @FocusState private var focusedInput: InputField?

    private enum InputField {
        case title
        case checklist
        case runNote
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                if let stage = viewModel.stage {
                    metadataCard(stage)
                    checklistCard
                    runNotesCard
                    exportCard
                } else {
                    ContentUnavailableView(
                        "Stage Not Found",
                        systemImage: "exclamationmark.magnifyingglass",
                        description: Text("Return to the stage list and select a valid stage.")
                    )
                    .frame(maxWidth: .infinity, minHeight: 280)
                }

                if let message = viewModel.lastExportPathMessage {
                    messageBanner(message, tone: .success)
                }

                if let message = viewModel.errorMessage {
                    messageBanner(message, tone: .error)
                }
            }
            .padding(14)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Stage Detail")
        .navigationBarTitleDisplayMode(.inline)
        .onSubmit {
            switch focusedInput {
            case .title:
                viewModel.saveTitle()
                focusedInput = nil
            case .checklist:
                viewModel.addChecklistItem()
            case .runNote:
                viewModel.addRunNote()
            case .none:
                break
            }
        }
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
        .overlay {
            if viewModel.isBusy {
                ZStack {
                    Color.black.opacity(0.12)
                        .ignoresSafeArea()
                    ProgressView("Working...")
                        .padding(14)
                        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
            }
        }
    }

    private func metadataCard(_ stage: Stage) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: "rectangle.stack")
                    .foregroundStyle(.secondary)
                Text("Stage Metadata")
                    .font(.headline)
            }

            TextField("Stage title", text: $viewModel.titleDraft)
                .textFieldStyle(.roundedBorder)
                .focused($focusedInput, equals: .title)
                .submitLabel(.done)

            HStack {
                Button("Save Title") {
                    viewModel.saveTitle()
                    focusedInput = nil
                }
                .buttonStyle(.borderedProminent)

                Button("Add Element") {
                    viewModel.addSampleElement()
                }
                .buttonStyle(.bordered)

                Spacer(minLength: 0)

                Text("Elements: \(stage.elements.count)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 6)
                    .background(.quaternary.opacity(0.6), in: Capsule())
            }
        }
        .padding(14)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    private var checklistCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: "checklist")
                    .foregroundStyle(.secondary)
                Text("Checklist")
                    .font(.headline)
            }

            HStack {
                TextField("Add checklist item", text: $viewModel.checklistDraft)
                    .textFieldStyle(.roundedBorder)
                    .focused($focusedInput, equals: .checklist)
                    .submitLabel(.done)
                Button("Add") {
                    viewModel.addChecklistItem()
                }
                .buttonStyle(.bordered)
            }

            if viewModel.checklist.isEmpty {
                Text("No checklist items yet. Add your first task for setup or safety checks.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .padding(.top, 2)
            } else {
                ForEach(viewModel.checklist) { item in
                    Button {
                        viewModel.toggleChecklist(item)
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: item.isDone ? "checkmark.circle.fill" : "circle")
                                .foregroundStyle(item.isDone ? .green : .secondary)
                            Text(item.text.isEmpty ? "(untitled item)" : item.text)
                            Spacer(minLength: 0)
                        }
                        .padding(.vertical, 8)
                        .padding(.horizontal, 10)
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(14)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    private var runNotesCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: "text.bubble")
                    .foregroundStyle(.secondary)
                Text("Run Notes")
                    .font(.headline)
            }

            HStack {
                TextField("Add run note", text: $viewModel.runNoteDraft)
                    .textFieldStyle(.roundedBorder)
                    .focused($focusedInput, equals: .runNote)
                    .submitLabel(.done)
                Button("Add") {
                    viewModel.addRunNote()
                }
                .buttonStyle(.bordered)
            }

            if viewModel.runNotes.isEmpty {
                Text("No run notes yet. Capture key observations while walking the stage.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .padding(.top, 2)
            } else {
                ForEach(viewModel.runNotes) { note in
                    Text(note.text)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(10)
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
                }
            }
        }
        .padding(14)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    private var exportCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: "square.and.arrow.up")
                    .foregroundStyle(.secondary)
                Text("Export")
                    .font(.headline)
            }

            Text("Create previews first, then generate shareable visual files.")
                .font(.footnote)
                .foregroundStyle(.secondary)

            HStack(spacing: 8) {
                Button("JSON") {
                    viewModel.export(format: .json)
                    showExportPreview = true
                }
                .buttonStyle(.bordered)

                Button("CSV") {
                    viewModel.export(format: .csv)
                    showExportPreview = true
                }
                .buttonStyle(.bordered)

                Button("PDF/PNG/JPG") {
                    viewModel.exportVisualFiles()
                }
                .buttonStyle(.borderedProminent)
            }
            .font(.footnote)
        }
        .padding(14)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    private enum BannerTone {
        case error
        case success
    }

    private func messageBanner(_ message: String, tone: BannerTone) -> some View {
        HStack(spacing: 8) {
            Image(systemName: tone == .error ? "exclamationmark.triangle.fill" : "checkmark.circle.fill")
            Text(message)
                .font(.footnote)
                .lineLimit(3)
            Spacer(minLength: 0)
        }
        .padding(10)
        .foregroundStyle(tone == .error ? .red : .green)
        .background((tone == .error ? Color.red : Color.green).opacity(0.12), in: RoundedRectangle(cornerRadius: 10, style: .continuous))
    }
}
