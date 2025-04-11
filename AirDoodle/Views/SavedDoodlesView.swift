import SwiftUI
import CoreData
import UniformTypeIdentifiers

struct SavedDoodlesView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Doodle.date, ascending: false)],
        animation: .default)
    private var doodles: FetchedResults<Doodle>

    @State private var renamingDoodle: Doodle? = nil
    @State private var newName: String = ""
    @State private var selectedDoodleName: String? = nil
    @State private var showExporter: Bool = false
    @State private var showImporter: Bool = false
    @State private var exportURL: URL? = nil

    var body: some View {
        ZStack {
            let bgRandom = Int.random(in: 1...4)
            let colors = [Color.red.opacity(0.5), Color.orange.opacity(0.5), Color.yellow.opacity(0.5), Color.green.opacity(0.5), Color.blue.opacity(0.5)]

            Rectangle()
                .fill(Color.white)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .ignoresSafeArea()

            LinearGradient(
                gradient: Gradient(colors: (bgRandom < 3) ? colors : colors.reversed()),
                startPoint: (bgRandom % 2 == 0) ? .topLeading : .topTrailing,
                endPoint: (bgRandom % 2 == 0) ? .bottomTrailing : .bottomLeading
            )
            .ignoresSafeArea()

            VStack(spacing: 20) {
                Text("Tus AirDoodles")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .shadow(radius: 4)
                    .padding(.top, 40)

                List {
                    ForEach(doodles) { doodle in
                        HStack {
                            NavigationLink(
                                destination: DoodleUIView(loadingDoodleName: doodle.name ?? ""),
                                tag: doodle.name ?? "",
                                selection: $selectedDoodleName
                            ) {
                                VStack(alignment: .leading) {
                                    Text(doodle.name ?? "(sin nombre)")
                                        .font(.headline)
                                    if let date = doodle.date {
                                        Text(date, style: .date)
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                    }
                                }
                            }

                            Spacer()

                            Button(action: {
                                renamingDoodle = doodle
                                newName = doodle.name ?? ""
                            }) {
                                Image(systemName: "pencil").foregroundColor(.blue)
                            }
                            .buttonStyle(.plain)

                            Button(action: {
                                deleteDoodle(doodle)
                            }) {
                                Image(systemName: "trash").foregroundColor(.red)
                            }
                            .buttonStyle(.plain)

                            Button(action: {
                                if let name = doodle.name {
                                    exportURL = FileManager.default
                                        .urls(for: .documentDirectory, in: .userDomainMask)[0]
                                        .appendingPathComponent("\(name).scn")
                                    showExporter = true
                                }
                            }) {
                                Image(systemName: "square.and.arrow.up").foregroundColor(.orange)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .listStyle(InsetGroupedListStyle())
                .frame(maxWidth: 500)
                .cornerRadius(12)
                .padding(.horizontal, 20)
                .padding(.bottom, 30)

                Button("Importar AirDoodle") {
                    showImporter = true
                }
                .padding()
                .background(Color.white.opacity(0.3))
                .cornerRadius(10)
                .padding(.bottom, 20)
            }
        }
        .navigationDestination(for: String.self) { name in
            DoodleUIView(loadingDoodleName: name)
        }
        .fileExporter(isPresented: $showExporter, document: exportURL.map { URLDocument(url: $0) }, contentType: .sceneKitScene, defaultFilename: exportURL?.lastPathComponent ?? "AirDoodle") { result in
            switch result {
            case .success: print("AirDoodle exportado")
            case .failure(let error): print("Error al exportar: \(error.localizedDescription)")
            }
        }
        .fileImporter(isPresented: $showImporter, allowedContentTypes: [.sceneKitScene]) { result in
            do {
                let selectedFile = try result.get()
                let name = selectedFile.deletingPathExtension().lastPathComponent
                let destination = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("\(name).scn")
                if FileManager.default.fileExists(atPath: destination.path) {
                    try FileManager.default.removeItem(at: destination)
                }
                try FileManager.default.copyItem(at: selectedFile, to: destination)
                let doodle = Doodle(context: viewContext)
                doodle.id = UUID()
                doodle.name = name
                doodle.date = Date()
                try viewContext.save()
            } catch {
                print("Error al importar AirDoodle: \(error.localizedDescription)")
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .alert("Renombrar AirDoodle", isPresented: Binding<Bool>(
            get: { renamingDoodle != nil },
            set: { if !$0 { renamingDoodle = nil } }
        ), actions: {
            TextField("Nuevo nombre", text: $newName)
            Button("Guardar") {
                if let doodle = renamingDoodle, !newName.isEmpty {
                    renameDoodle(doodle, to: newName)
                }
            }
            Button("Cancelar", role: .cancel) {}
        }, message: {
            Text("Ingresa un nuevo nombre para tu AirDoodle")
        })
    }

    private func deleteDoodle(_ doodle: Doodle) {
        if let name = doodle.name {
            let fileURL = FileManager.default
                .urls(for: .documentDirectory, in: .userDomainMask)[0]
                .appendingPathComponent("\(name).scn")
            try? FileManager.default.removeItem(at: fileURL)
        }
        viewContext.delete(doodle)

        do {
            try viewContext.save()
        } catch {
            print("Error al borrar doodle: \(error.localizedDescription)")
        }
    }

    private func renameDoodle(_ doodle: Doodle, to newName: String) {
        guard let oldName = doodle.name, !newName.isEmpty else { return }
        let fileManager = FileManager.default
        let dir = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let oldURL = dir.appendingPathComponent("\(oldName).scn")
        let newURL = dir.appendingPathComponent("\(newName).scn")

        do {
            if fileManager.fileExists(atPath: newURL.path) {
                try fileManager.removeItem(at: newURL)
            }
            try fileManager.moveItem(at: oldURL, to: newURL)
            doodle.name = newName
            try viewContext.save()
        } catch {
            print("Error al renombrar doodle: \(error.localizedDescription)")
        }
    }
}

struct URLDocument: FileDocument {
    static var readableContentTypes: [UTType] { [.sceneKitScene] }
    var url: URL

    init(url: URL) {
        self.url = url
    }

    init(configuration: ReadConfiguration) throws {
        fatalError("init(configuration:) has not been implemented")
    }

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        return try FileWrapper(url: url, options: .immediate)
    }
}
