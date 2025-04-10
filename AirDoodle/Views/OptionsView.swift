import SwiftUI

struct OptionsView: View {
    var body: some View {
        NavigationStack {
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
                        
                        NavigationLink("🌠 Dibujos guardados", value: "SavedDoodlesView")
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
                    } else if value == "SavedDoodlesView" {
                        SavedDoodlesView()
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
