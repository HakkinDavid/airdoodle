import SwiftUI

struct OptionsView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [.red.opacity(0.3), .orange.opacity(0.3), .yellow.opacity(0.3), .green.opacity(0.3), .blue.opacity(0.3)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                
                VStack(spacing: 30) {
                    Text("AirDoodle")
                        .font(.system(size: 60, weight: .bold))
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.8), radius: 7, y: 3)
                        .padding(.bottom, 30)
                    
                    VStack(spacing: 20) {
                        NavigationLink("🎨 Nuevo Dibujo", value: "DoodleUIView")
                            .font(.title)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: 350)
                            .background(Color.gray.opacity(0.45))
                            .cornerRadius(10)
                        
                        NavigationLink("🌠 Dibujos guardados", value: "GagaView")
                            .font(.title)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: 350)
                            .background(Color.gray.opacity(0.45))
                            .cornerRadius(10)
                    }
                }
                .padding(.bottom, 30)
                .navigationDestination(for: String.self) { value in
                    if value == "DoodleUIView" {
                        DoodleUIView()
                    } else if value == "GagaView" {
                        OptionsView()
                    }
                }
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    OptionsView()
}
