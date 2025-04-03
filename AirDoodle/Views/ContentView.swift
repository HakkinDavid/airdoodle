import SwiftUI

struct ContentView: View {
    
    @StateObject private var permissionsViewModel = PermissionsViewModel()
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 30) {
                Text("AirDoodle")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding()
                    .onAppear{
                        if(!permissionsViewModel.cameraGranted) {
                            permissionsViewModel.requestCameraAccess() }
                        if(!permissionsViewModel.photoLibraryGranted) {
                            permissionsViewModel.requestPhotoLibraryAccess() }
                    }
                Text("Da click para aceptar los permisos de tu camara, galeria y ubicacion porfa")
                    .multilineTextAlignment(.center)
                
                VStack(spacing: 20) {
                    // Camara
                    Text("SEX!")
                }
                Spacer()
                NavigationLink("Next", value: "DoodleUIView")
                    .disabled(!permissionsViewModel.areAllPermissionsGranted)
                    .tint(.orange)
            }
            .navigationDestination(for: String.self) { value in
                if value == "DoodleUIView" {
                    DoodleUIView()
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
