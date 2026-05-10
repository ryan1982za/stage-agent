import SwiftUI

struct StageListView: View {
    @ObservedObject var viewModel: StageListViewModel
    @State private var isShowingExportPreview = false
    @State private var hasDismissedOnboarding = false
    @FocusState private var isTitleFocused: Bool

    var body: some View {
        VStack(spacing: 0) {
            header

            if let message = viewModel.errorMessage {
                messageBanner(message, tone: .error)
                    .padding(.horizontal)
                    .padding(.top, 10)
            }

            if let message = viewModel.lastExportPathMessage {
                messageBanner(message, tone: .success)
                    .padding(.horizontal)
                    .padding(.top, 10)
            }

            if !hasDismissedOnboarding && !viewModel.hasExportedOnce {
                onboardingCard
                    .padding(.horizontal)
                    .padding(.top, 10)
            }

            if viewModel.stages.isEmpty {
                VStack(spacing: 16) {
                    ContentUnavailableView(
                        "No Stages Yet",
                        systemImage: "square.and.pencil",
                        description: Text("Create your first stage to begin placing elements, adding notes, and exporting layouts.")
                    )

                    Text("Tip: start with a short, clear title like 'Range A Morning Setup'.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List {
                    Section {
                        ForEach(viewModel.stages) { stage in
                            stageRow(stage)
                                .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                                .listRowSeparator(.hidden)
                                .listRowBackground(Color.clear)
                        }
                    } header: {
                        HStack {
                            Text("Your Stages")
                            Spacer(minLength: 0)
                            Text("\(viewModel.stages.count)")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(.secondary)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(.quaternary.opacity(0.75), in: Capsule())
                        }
                        .textCase(nil)
                    }
                }
                .listStyle(.plain)
            }
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Stages")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    viewModel.refresh()
                } label: {
                    Image(systemName: "arrow.clockwise")
                }
                .accessibilityLabel("Refresh stages")
            }
        }
        .onAppear {
            viewModel.refresh()
        }
        .onSubmit {
            createStageFromDraft()
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
        .confirmationDialog(
            "Delete Stage?",
            isPresented: $viewModel.isShowingDeleteConfirmation,
            presenting: viewModel.pendingDeleteStage
        ) { stage in
            Button("Delete \(stage.title)", role: .destructive) {
                viewModel.confirmDeletePendingStage()
            }
            Button("Cancel", role: .cancel) {
                viewModel.pendingDeleteStage = nil
            }
        } message: { stage in
            Text("This removes \(stage.title) from your stage list.")
        }
        .overlay {
            busyOverlay
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Stage Agent")
                .font(.largeTitle.weight(.bold))
            Text("Create stages, review details, and export deliverables in one place.")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            HStack(spacing: 10) {
                TextField("New stage title", text: $viewModel.draftTitle)
                    .textFieldStyle(.roundedBorder)
                    .focused($isTitleFocused)
                    .submitLabel(.done)
                    .accessibilityLabel("New stage title")

                Button("Create") {
                    createStageFromDraft()
                }
                .buttonStyle(.borderedProminent)
                .disabled(viewModel.draftTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            LinearGradient(
                colors: [.blue.opacity(0.16), .mint.opacity(0.08)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
    }

    private func stageRow(_ stage: Stage) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            NavigationLink {
                StageDetailView(viewModel: viewModel.makeDetailViewModel(stageId: stage.id))
            } label: {
                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 8) {
                        Text(stage.title)
                            .font(.headline)
                            .lineLimit(1)
                        Spacer(minLength: 0)
                        Image(systemName: "chevron.right")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.tertiary)
                    }

                    Text(stage.disciplineLabel.isEmpty ? "No discipline selected" : stage.disciplineLabel)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .buttonStyle(.plain)

            HStack(spacing: 8) {
                Menu("Actions") {
                    Button("Add Element") {
                        viewModel.addSampleElement(stageId: stage.id)
                    }

                    Button("Rename") {
                        viewModel.renameStage(id: stage.id, newTitle: "\(stage.title) (Updated)")
                    }

                    Divider()

                    Button("Preview JSON") {
                        viewModel.exportStage(id: stage.id, format: .json)
                        isShowingExportPreview = true
                    }

                    Button("Preview CSV") {
                        viewModel.exportStage(id: stage.id, format: .csv)
                        isShowingExportPreview = true
                    }

                    Button("Write Files") {
                        viewModel.exportStageToFiles(id: stage.id)
                    }

                    Divider()

                    Button("Delete Stage", role: .destructive) {
                        viewModel.requestDelete(for: stage)
                    }
                }
                .menuStyle(.button)

                Spacer(minLength: 0)
            }
            .font(.footnote)
        }
        .padding(12)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
        .swipeActions {
            Button(role: .destructive) {
                viewModel.requestDelete(for: stage)
            } label: {
                Text("Delete")
            }
        }
    }

    private func createStageFromDraft() {
        viewModel.createStage()
        isTitleFocused = false
    }

    private var onboardingCard: some View {
        let hasCreatedStage = !viewModel.stages.isEmpty
        let hasAddedElement = viewModel.stages.contains { !$0.elements.isEmpty }

        return VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Quick Start")
                    .font(.headline)
                Spacer(minLength: 0)
                Button("Dismiss") {
                    hasDismissedOnboarding = true
                }
                .font(.footnote)
            }

            checklistRow("Create your first stage", isDone: hasCreatedStage)
            checklistRow("Add at least one element", isDone: hasAddedElement)
            checklistRow("Export once (JSON, CSV, or files)", isDone: viewModel.hasExportedOnce)
        }
        .padding(12)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    private func checklistRow(_ title: String, isDone: Bool) -> some View {
        HStack(spacing: 8) {
            Image(systemName: isDone ? "checkmark.circle.fill" : "circle")
                .foregroundStyle(isDone ? .green : .secondary)
            Text(title)
                .font(.footnote)
            Spacer(minLength: 0)
        }
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
                .lineLimit(2)
            Spacer(minLength: 0)
        }
        .padding(10)
        .foregroundStyle(tone == .error ? .red : .green)
        .background((tone == .error ? Color.red : Color.green).opacity(0.12), in: RoundedRectangle(cornerRadius: 10, style: .continuous))
    }
}

extension StageListView {
    @ViewBuilder
    var busyOverlay: some View {
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
