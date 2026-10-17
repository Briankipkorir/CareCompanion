
import SwiftUI
import UniformTypeIdentifiers
import QuickLook

struct CareStoredRecord: Identifiable, Codable {

    var id: UUID
    var name: String
    var category: String
    var fileName: String
    var createdAt: Date
}

struct MyRecordsView: View {

    @State private var records: [CareStoredRecord] = []
    @State private var selectedCategory = "Health"
    @State private var showImporter = false
    @State private var previewURL: URL?
    @State private var errorMessage: String?
    @State private var recordToDelete: CareStoredRecord?

    private let categories = [
        "Health",
        "Education",
        "Family",
        "Other"
    ]

    var body: some View {

        VStack(spacing: 16) {

            VStack(alignment: .leading, spacing: 10) {

                Image(systemName: "folder.badge.person.crop")
                    .font(.system(size: 38))
                    .foregroundStyle(.teal)

                Text("My Records")
                    .font(.title.bold())

                Text(
                    "Organize important documents on this device."
                )
                .foregroundStyle(.secondary)

                Text(
                    "Demo storage only. Do not import real medical records, identification documents, or children's private information yet."
                )
                .font(.caption)
                .foregroundStyle(.orange)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Picker("Document Category", selection: $selectedCategory) {

                ForEach(categories, id: \.self) { category in
                    Text(category)
                        .tag(category)
                }
            }
            .pickerStyle(.menu)

            Button {
                showImporter = true
            } label: {
                Label(
                    "Add Document",
                    systemImage: "plus.circle.fill"
                )
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(.teal)

            if let errorMessage {
                Text(errorMessage)
                    .font(.footnote)
                    .foregroundStyle(.red)
            }

            if records.isEmpty {

                Spacer()

                ContentUnavailableView(
                    "No Documents Yet",
                    systemImage: "folder",
                    description: Text(
                        "Import a sample PDF or image to test your records organizer."
                    )
                )

                Spacer()

            } else {

                List {

                    ForEach(records) { record in

                        Button {
                            previewURL = fileURL(for: record)
                        } label: {

                            HStack(spacing: 12) {

                                Image(systemName: "doc.fill")
                                    .font(.title2)
                                    .foregroundStyle(.teal)

                                VStack(
                                    alignment: .leading,
                                    spacing: 4
                                ) {

                                    Text(record.name)
                                        .font(.headline)
                                        .foregroundStyle(.primary)

                                    Text(record.category)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)

                                    Text(
                                        record.createdAt,
                                        style: .date
                                    )
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                                }

                                Spacer()

                                Image(systemName: "eye")
                                    .foregroundStyle(.teal)
                            }
                        }
                        .swipeActions {

                            Button(role: .destructive) {
                                recordToDelete = record
                            } label: {
                                Label(
                                    "Delete",
                                    systemImage: "trash"
                                )
                            }
                        }
                    }
                }
                .listStyle(.plain)
            }

            Text(
                "Files are stored locally on this device. They are not synced between accounts or devices."
            )
            .font(.caption2)
            .foregroundStyle(.secondary)
            .multilineTextAlignment(.center)
        }
        .padding(.top, 12)
        .padding(.horizontal)
        .navigationTitle("My Records")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            loadRecords()
        }
        .fileImporter(
            isPresented: $showImporter,
            allowedContentTypes: [
                .pdf,
                .image
            ],
            allowsMultipleSelection: false
        ) { result in

            switch result {

            case .success(let urls):

                if let url = urls.first {
                    importDocument(from: url)
                }

            case .failure(let error):

                errorMessage = error.localizedDescription
            }
        }
        .quickLookPreview($previewURL)
        .alert(
            "Delete Document?",
            isPresented: Binding(
                get: { recordToDelete != nil },
                set: { if !$0 { recordToDelete = nil } }
            )
        ) {
            Button("Cancel", role: .cancel) {
                recordToDelete = nil
            }

            Button("Delete", role: .destructive) {
                if let record = recordToDelete {
                    deleteRecord(record)
                }
                recordToDelete = nil
            }
        } message: {
            Text(
                "This permanently deletes the local copy of this document."
            )
        }
    }

    // MARK: - Storage Location

    private var recordsDirectory: URL {

        FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask
        )[0]
        .appendingPathComponent(
            "CareRecords",
            isDirectory: true
        )
    }

    private var indexURL: URL {

        recordsDirectory.appendingPathComponent(
            "records.json"
        )
    }

    private func prepareDirectory() throws {

        try FileManager.default.createDirectory(
            at: recordsDirectory,
            withIntermediateDirectories: true
        )
    }

    private func fileURL(
        for record: CareStoredRecord
    ) -> URL {

        recordsDirectory.appendingPathComponent(
            record.fileName
        )
    }

    // MARK: - Import Document

    private func importDocument(from source: URL) {

        errorMessage = nil

        let accessGranted =
            source.startAccessingSecurityScopedResource()

        defer {

            if accessGranted {
                source.stopAccessingSecurityScopedResource()
            }
        }

        do {

            try prepareDirectory()

            let fileExtension = source.pathExtension
                .lowercased()

            let newName =
                UUID().uuidString + "." + fileExtension

            let destination = recordsDirectory
                .appendingPathComponent(newName)

            try FileManager.default.copyItem(
                at: source,
                to: destination
            )

            try FileManager.default.setAttributes(
                [
                    .protectionKey:
                        FileProtectionType.complete
                ],
                ofItemAtPath: destination.path
            )

            let record = CareStoredRecord(
                id: UUID(),
                name: source.lastPathComponent,
                category: selectedCategory,
                fileName: newName,
                createdAt: Date()
            )

            records.insert(record, at: 0)

            try saveRecords()

        } catch {

            errorMessage =
                "Unable to import document: \(error.localizedDescription)"
        }
    }

    // MARK: - Save Document Index

    private func saveRecords() throws {

        try prepareDirectory()

        let data = try JSONEncoder().encode(records)

        try data.write(
            to: indexURL,
            options: [.atomic, .completeFileProtection]
        )
    }

    // MARK: - Load Documents

    private func loadRecords() {

        do {

            try prepareDirectory()

            guard FileManager.default.fileExists(
                atPath: indexURL.path
            ) else {
                records = []
                return
            }

            let data = try Data(contentsOf: indexURL)

            records = try JSONDecoder().decode(
                [CareStoredRecord].self,
                from: data
            )

            records.sort {
                $0.createdAt > $1.createdAt
            }

        } catch {

            errorMessage =
                "Unable to load saved documents."
        }
    }

    // MARK: - Delete Document

    private func deleteRecord(
        _ record: CareStoredRecord
    ) {

        do {

            let url = fileURL(for: record)

            if FileManager.default.fileExists(
                atPath: url.path
            ) {
                try FileManager.default.removeItem(
                    at: url
                )
            }

            records.removeAll {
                $0.id == record.id
            }

            try saveRecords()

        } catch {

            errorMessage =
                "Unable to delete document."
        }
    }
}

#Preview {
    NavigationStack {
        MyRecordsView()
    }
}
