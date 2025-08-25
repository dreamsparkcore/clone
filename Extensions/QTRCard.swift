import SwiftUI

struct QTRCard: View {
    @AppStorage("name") private var name: String = ""
    @State private var offset: CGFloat = 1000
    @State private var rotation: Double = 89.9
      @State private var opacity: Double = 0
    var body: some View {
        ZStack {
                  // Background with gradient image
            ZStack {
                Image("Circle")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 300, height: 400)
                    .cornerRadius(16)
                Image("recgradient2")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 300, height: 400)
                    .cornerRadius(16)
            }
                  
                  VStack(alignment: .leading, spacing: 0) {
                      // Top part of the card
                      VStack(alignment: .leading, spacing: 16) {
                          HStack {
                              Text("Cal AI Card")
                                  .font(.headline)
                                  .fontWeight(.bold)
                                  .foregroundColor(Color.white)
                              Spacer()
                              Image(systemName: "book")
                                  .renderingMode(.template)
                                  .resizable()
                                  .scaledToFit()
                                  .foregroundColor(Color.white)
                                  .frame(width: 24, height: 24)
                          }
                          .padding(.horizontal)
                          
                          Spacer()
                          
                          VStack(alignment: .leading, spacing: 4) {
                              Text(LocalizedStringKey("Lbs Lost"))
                                  .foregroundColor(.white.opacity(0.8))
                                  .font(.custom("DMSans-Medium", size: 12))
                              
                              Text("0")
                                  .foregroundColor(.white)
                                  .font(.custom("DMSans-Medium", size: 26))
                          }
                      }
                      .padding(24)
                      
                      Spacer()
                      
                      // Bottom part of the card
                      HStack {
                          if !name.isEmpty {
                              VStack(alignment: .leading) {
                                  Text(LocalizedStringKey("Name"))
                                      .foregroundColor(.white.opacity(0.8))
                                      .font(.custom("DMSans-Medium", size: 12))
                                  Text("Alex")
                                      .foregroundColor(.white)
                                      .font(.custom("DMSans-Medium", size: 16))
                              }
                          }
                          
                              Spacer()
                          
                          VStack(alignment: .trailing) {
                              Text(LocalizedStringKey("Joined in"))
                                  .foregroundColor(.white.opacity(0.8))
                                  .font(.custom("DMSans-Medium", size: 12))
                              Text("2025")
                                  .foregroundColor(.white)
                                  .font(.custom("DMSans-Medium", size: 16))
                          }
                      }
                      .padding(24)
                      .background(LinearGradient(gradient: Gradient(colors: [Color(hex: "3E3C3D"), Color(hex: "2C2C2C")]), startPoint: .leading, endPoint: .trailing))
                  }
              }
              .frame(width: 280, height: 400)
              .cornerRadius(25)
              .offset(y: offset)
                    .rotation3DEffect(
                        .degrees(rotation),
                        axis: (x: 1.0, y: 0.0, z: 0.0)
                    )
                    .opacity(opacity)
                    .onAppear {
                        withAnimation(.easeOut(duration: 0.8)) {
                            offset = 0
                            rotation = 0 // Rotate to 0 degrees during the animation
                            opacity = 1
                        }
                    }
    }
}
