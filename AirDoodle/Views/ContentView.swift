import SwiftUI

struct ContentView: View {
    var body: some View {
        ZStack {
            ARDoodleView().edgesIgnoringSafeArea(.all)
            
            VStack {
                Spacer()
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
            }
        }
    }
}
