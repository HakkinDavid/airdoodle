import SwiftUI

struct PermissionsView: View {
    
    @StateObject private var permissionsViewModel = PermissionsViewModel()
    @Environment(\.sizeCategory) var sizeCategory
    // Usamos UserDefaults para guardar si los permisos han sido concedidos previamente
    @AppStorage("permissionsGranted") private var permissionsGranted: Bool = false
    
    var body: some View {
        if permissionsGranted {
            OptionsView()
        } else {
            NavigationStack {
                ZStack {
                    let bgRandom = Int.random(in: 1...4)
                    let colors = [Color.red.opacity(0.5), Color.orange.opacity(0.5), Color.yellow.opacity(0.5), Color.green.opacity(0.5), Color.blue.opacity(0.5)]
                    
                    Rectangle()
                        .fill(Color.white)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    
                    LinearGradient(
                        gradient: Gradient(colors: (bgRandom < 3) ? colors : colors.reversed()),
                        startPoint: (bgRandom % 2 == 0) ? .topLeading : .topTrailing,
                        endPoint: (bgRandom % 2 == 0) ? .bottomTrailing : .bottomLeading
                    )
                    .ignoresSafeArea()
                    
                    VStack(spacing: 30) {
                        Spacer(minLength: 70)
                        Text("AirDoodle")
                            .font(.system(size: getSize()*2.7, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.top, 50)
                            .shadow(color: .black.opacity(0.8), radius: 7, y: 3)
                        
                        Text("Por favor, acepta los permisos de tu cámara y galería para continuar.")
                            .font(.system(size: getSize()*0.9))
                            .multilineTextAlignment(.center)
                            .foregroundColor(.black.opacity(0.75))
                            .padding(.horizontal, 20)
                        
                        VStack(spacing: getSize()) {
                            // Permiso de Cámara
                            if !permissionsViewModel.cameraGranted {
                                Text("Permiso para la cámara necesario.")
                                    .foregroundColor(.red)
                                    .font(.system(size: getSize()))
                                Button("Solicitar acceso a la cámara") {
                                    permissionsViewModel.requestCameraAccess()
                                }
                                .font(.system(size: getSize()))
                                .buttonStyle(.borderedProminent)
                                .tint(.blue)
                            } else {
                                Text("Gracias, cámara habilitada.")
                                    .foregroundColor(.green)
                                    .font(.system(size: getSize()))
                            }
                            
                            // Permiso para la galería
                            if !permissionsViewModel.photoLibraryGranted {
                                Text("Permiso para la galería necesario.")
                                    .foregroundColor(.red)
                                    .font(.system(size: getSize()))
                                    .padding(.top, getSize())
                                Button("Solicitar acceso a la galería") {
                                    permissionsViewModel.requestPhotoLibraryAccess()
                                }
                                .font(.system(size: getSize()))
                                .buttonStyle(.borderedProminent)
                                .tint(.blue)
                            } else {
                                Text("Gracias, galería habilitada.")
                                    .foregroundColor(.green)
                                    .font(.system(size: getSize()))
                            }
                        }
                        .padding(.horizontal, getSize())
                        
                        Spacer()
                        
                        NavigationLink("Continuar", value: "OptionsView")
                            .disabled(!permissionsViewModel.areAllPermissionsGranted)
                            .font(.system(size: getSize()*1.25))
                            .foregroundColor(.white)
                            .padding()
                            .background(permissionsViewModel.areAllPermissionsGranted ? Color.orange : Color.gray)
                            .cornerRadius(10)
                            .padding(.bottom, 50)
                            .opacity(permissionsViewModel.areAllPermissionsGranted ? 1 : 0.5)
                    }
                    .navigationDestination(for: String.self) { value in
                        if value == "OptionsView" {
                            OptionsView()
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
    func getSize() -> CGFloat {
        switch sizeCategory {
        case .extraSmall, .small:
            return 14
        case .medium:
            return 20
        case .large:
            return 24
        case .extraLarge, .extraExtraLarge, .extraExtraExtraLarge:
            return 36
        default:
            return 20
        }
      }
}

#Preview {
    PermissionsView()
}
