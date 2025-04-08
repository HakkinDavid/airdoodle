import SwiftUI

struct ContentView: View {
    
    @StateObject private var permissionsViewModel = PermissionsViewModel()
    
    // Usamos UserDefaults para guardar si los permisos han sido concedidos previamente
    @AppStorage("permissionsGranted") private var permissionsGranted: Bool = false
    
    var body: some View {
        if permissionsGranted {
            DoodleUIView()
        } else {
            NavigationStack {
                VStack(spacing: 30) {
                    Text("AirDoodle")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.red)
                        .padding(.top, 50)
                        .padding(.bottom, 10)
                    
                    Text("Por favor, acepta los permisos de tu cámara, galería y ubicación para continuar.")
                        .font(.title3)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.gray)
                        .padding(.horizontal, 20)
                    
                    VStack(spacing: 20) {
                        // Permiso de Cámara
                        if !permissionsViewModel.cameraGranted {
                            Text("Permiso para la cámara necesario.")
                                .foregroundColor(.red)
                                .font(.body)
                            Button("Solicitar acceso a la cámara") {
                                permissionsViewModel.requestCameraAccess()
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(.blue)
                            .padding(.top, 10)
                        } else {
                            Text("Gracias, cámara habilitada.")
                                .foregroundColor(.green)
                                .font(.body)
                        }
                        
                        // Permiso para la galería
                        if !permissionsViewModel.photoLibraryGranted {
                            Text("Permiso para la galería necesario.")
                                .foregroundColor(.red)
                                .font(.body)
                            Button("Solicitar acceso a la galería") {
                                permissionsViewModel.requestPhotoLibraryAccess()
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(.blue)
                            .padding(.top, 10)
                        } else {
                            Text("Gracias, galería habilitada.")
                                .foregroundColor(.green)
                                .font(.body)
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    Spacer()
                    
                    NavigationLink("Continuar", value: "DoodleUIView")
                        .disabled(!permissionsViewModel.areAllPermissionsGranted)
                        .font(.title2)
                        .foregroundColor(.white)
                        .padding()
                        .background(permissionsViewModel.areAllPermissionsGranted ? Color.orange : Color.gray)
                        .cornerRadius(10)
                        .padding(.bottom, 50)
                        .opacity(permissionsViewModel.areAllPermissionsGranted ? 1 : 0.5)
                }
                .navigationDestination(for: String.self) { value in
                    if value == "DoodleUIView" {
                        DoodleUIView()
                    }
                }
                .background(Color(UIColor.systemBackground))  // Fondo claro para la vista
                .edgesIgnoringSafeArea(.all)  // Para que el fondo cubra toda la pantalla
            }
            .onChange(of: permissionsViewModel.areAllPermissionsGranted) { newValue in
                // Si todos los permisos son concedidos, guardamos en UserDefaults
                if newValue {
                    permissionsGranted = true
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
