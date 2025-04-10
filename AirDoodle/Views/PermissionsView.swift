import SwiftUI

struct PermissionsView: View {
    
    @StateObject private var permissionsViewModel = PermissionsViewModel()
    
    // Usamos UserDefaults para guardar si los permisos han sido concedidos previamente
    @AppStorage("permissionsGranted") private var permissionsGranted: Bool = false
    
    var body: some View {
        if permissionsGranted {
            DoodleUIView()
        } else {
            NavigationStack {
                ZStack {
                    LinearGradient(
                        gradient: Gradient(colors: [.red.opacity(0.3), .orange.opacity(0.3), .yellow.opacity(0.3), .green.opacity(0.3), .blue.opacity(0.3)]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .ignoresSafeArea()
                    
                    
                    VStack(spacing: 30) {
                        Spacer(minLength: 70)
                        Text("AirDoodle")
                            .font(.system(size: 60, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.top, 50)
                            .shadow(color: .black.opacity(0.8), radius: 7, y: 3)
                        
                        Text("Por favor, acepta los permisos de tu cámara, galería y ubicación para continuar.")
                            .font(.title3)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.black.opacity(0.75))
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
                                    .padding(.top, 15)
                                Button("Solicitar acceso a la galería") {
                                    permissionsViewModel.requestPhotoLibraryAccess()
                                }
                                .buttonStyle(.borderedProminent)
                                .tint(.blue)
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
                }
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
    PermissionsView()
}
