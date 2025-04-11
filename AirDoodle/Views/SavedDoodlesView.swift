import SwiftUI
import CoreData

struct SavedDoodlesView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Doodle.date, ascending: false)],
        animation: .default)
    private var doodles: FetchedResults<Doodle>

    @State private var renamingDoodle: Doodle? = nil
    @State private var newName: String = ""

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
                            NavigationLink(destination: DoodleUIView(loadingDoodleName: doodle.name)) {
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
                                Image(systemName: "pencil")
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                    .onDelete(perform: deleteDoodles)
                }
                .listStyle(InsetGroupedListStyle())
                .frame(maxWidth: 500)
                .cornerRadius(12)
                .padding(.horizontal, 20)
                .padding(.bottom, 30)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .alert("Renombrar Doodle", isPresented: Binding<Bool>(
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

    private func deleteDoodles(at offsets: IndexSet) {
        for index in offsets {
            let doodle = doodles[index]
            if let name = doodle.name {
                let fileURL = FileManager.default
                    .urls(for: .documentDirectory, in: .userDomainMask)[0]
                    .appendingPathComponent("\(name).scn")
                try? FileManager.default.removeItem(at: fileURL)
            }
            viewContext.delete(doodle)
        }

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
                try fileManager.removeItem(at: newURL) // sobreescribe si ya existe
            }
            try fileManager.moveItem(at: oldURL, to: newURL)
            doodle.name = newName
            try viewContext.save()
        } catch {
            print("Error al renombrar doodle: \(error.localizedDescription)")
        }
    }
}
