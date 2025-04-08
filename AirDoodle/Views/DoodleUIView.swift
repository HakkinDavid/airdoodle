import SwiftUI

struct DoodleUIView: View {
    @State private var selectedTool: DrawingTool = .pencil
    @State private var lineWidth: CGFloat = 2.0
    @State private var selectedColor: Color = .blue
    
    private var selectedUIColor: UIColor {
        UIColor(selectedColor)
    }
    
    var body: some View {
        ZStack {
            ARDoodleView(selectedTool: $selectedTool, lineWidth: $lineWidth, selectedColor: .constant(selectedUIColor))
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                HStack {
                    Picker("Herramienta", selection: $selectedTool) {
                        Text("Lápiz").tag(DrawingTool.pencil)
                        Text("Borrador").tag(DrawingTool.eraser)
                        Text("Línea").tag(DrawingTool.line)
                        Text("Círculo").tag(DrawingTool.circle)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding()
                }
                
                Slider(value: $lineWidth, in: 1...10, step: 0.5) {
                    Text("Grosor")
                }
                .padding()
                
                ColorPicker("Color", selection: $selectedColor)
                    .padding()
                
                Button(action: {
                    NotificationCenter.default.post(name: NSNotification.Name("ClearCanvas"), object: nil)
                }) {
                    Text("Borrar Dibujo")
                        .padding()
                        .background(Color.red)
                        .foregroundColor(.white)
                        .clipShape(Capsule())
                }
                .padding()
                
                Button(action: {
                    // Lógica futura para tomar foto
                    screenshotObject(_:)
                }) {
                    Text("Tomar Foto")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .clipShape(Capsule())
                }
                .padding()
            }
            .background(Color.white.opacity(0.0))
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .ignoresSafeArea(.all)
        }
    }
}
