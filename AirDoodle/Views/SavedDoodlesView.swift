import SwiftUI

struct SavedDoodlesView: View {
    @State private var doodlePaths: [URL] = []
    @State private var selectedDoodleName: String? = nil

    var body: some View {
        NavigationView {
            List(doodlePaths, id: \.self) { url in
                NavigationLink(destination: DoodleUIView(loadingDoodleName: url.lastPathComponent.replacing(".scn", with: ""))) {
                    VStack(alignment: .leading) {
                        Text(url.lastPathComponent)
                            .font(.headline)
                        Text(fileModificationDate(for: url), style: .date)
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
            }
            .navigationTitle("Doodles Guardados")
            .onAppear(perform: loadSavedDoodles)
            .background()
        }
    }

    private func loadSavedDoodles() {
        let fileManager = FileManager.default
        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!

        do {
            let contents = try fileManager.contentsOfDirectory(at: documentsURL, includingPropertiesForKeys: nil)
            doodlePaths = contents.filter { $0.pathExtension == "scn" }
        } catch {
            print("Error al cargar doodles: \(error.localizedDescription)")
        }
    }

    private func fileModificationDate(for url: URL) -> Date {
        let attributes = try? FileManager.default.attributesOfItem(atPath: url.path)
        return attributes?[.modificationDate] as? Date ?? Date()
    }
}
