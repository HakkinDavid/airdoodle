//
//  SavedDoodlesView.swift
//  AirDoodle
//
//  Created by CETYS Universidad  on 09/04/25.
//

import SwiftUI

struct SavedDoodlesView: View {
    @State private var doodles: [Doodle] = []
    @State private var coordinator = ARDoodleView.Coordinator()
    let manager = FileManager.default
    let url = FileManager.default
        .urls(for: .documentDirectory, in: .userDomainMask)[0]
        //.appendingPathComponent("\\")
    
    var body: some View {
        NavigationStack {
            ZStack {
                let bgRandom = Int.random(in: 1...4)
                let colors = [Color.red.opacity(0.3), Color.orange.opacity(0.3), Color.yellow.opacity(0.3), Color.green.opacity(0.3), Color.blue.opacity(0.3)]
                LinearGradient(
                    gradient: Gradient(colors: (bgRandom < 3) ? colors : colors.reversed()),
                    startPoint: (bgRandom % 2 == 0) ? .topLeading : .topTrailing,
                    endPoint: (bgRandom % 2 == 0) ? .bottomTrailing : .bottomLeading
                )
                .ignoresSafeArea()
                
                VStack(spacing: 5) {
                    Text("\(url)")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.8), radius: 7, y: 3)
                        .padding(.bottom, 40)
                }
                
                    /*
                        List{
                            
                                ForEach(doodles) { doodle in
                                    NavigationLink(destination: ARDoodleView(doodle: Doodle)) {
                                        Text(doodle.name!)
                        }*/
            }
        }
        .navigationBarBackButtonHidden(false)
    }
}

#Preview {
    SavedDoodlesView()
}
