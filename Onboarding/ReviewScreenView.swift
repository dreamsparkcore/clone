import SwiftUI
import StoreKit

struct ReviewScreenView: View {
    @Environment(\.presentationMode) var presentationMode
    let onComplete: () -> Void
    var body: some View {
                    VStack {
                        Spacer()
                            .frame(height: 1)
                        ScrollView {
                            VStack(spacing: 20) {
                                    Text(LocalizedStringKey("Give us a rating"))
                                        .font(.largeTitle)
                                        .fontWeight(.bold)
                                        .multilineTextAlignment(.center)
                                        .foregroundColor(.black)
                                        .padding(.top, -25)
                                Image("magictest")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 200)
                                    .padding(.bottom, 10)
                                
                            
                                VStack(spacing: 10) {
                                    Text(LocalizedStringKey("This app was designed for people like you."))
                                        .multilineTextAlignment(.center)
                                        .font(.headline)
                                        .padding(.bottom, 5)
                                    HStack {
                                        HStack(spacing: 2) {
                                            Image("alex")
                                                .resizable()
                                                .scaledToFill()
                                                .frame(width: 25, height: 25)
                                                .clipShape(Circle())
                                            Image("blake")
                                                .resizable()
                                                .scaledToFill()
                                                .frame(width: 25, height: 25)
                                                .clipShape(Circle())
                                            Image("zach")
                                                .resizable()
                                                .scaledToFill()
                                                .frame(width: 25, height: 25)
                                                .clipShape(Circle())
                                        }
                                        Text(LocalizedStringKey("+ 1,000,000 people"))
                                            .foregroundColor(.gray)
                                    }
                                }
                                .padding()
                                
                                VStack(spacing: 15) {
                                    ReviewView(image: "alex", name: "Alex Slater", username: "@slater", rating: 5, review: "Cal AI has been a total game-changer. The AI food recognition makes logging effortless and the progress charts keep me motivated. I’ve already lost 22 pounds and feel healthier than ever.")
                                                                        
                                    ReviewView(image: "blake", name: "Blake Anderson", username: "@bwa", rating: 5, review: "I used to struggle with tracking calories, but Cal AI made it simple. Just snapping a photo of my meals helped me stay consistent. Down 15 pounds in 6 weeks — highly recommend!")
                                                                        
                                    ReviewView(image: "zach", name: "Zach Yadegari", username: "@zach", rating: 5, review: "Cal AI’s personalized insights helped me understand my eating habits. It’s like having a nutrition coach in my pocket. I’ve lost 30 pounds and finally feel in control of my diet.")

                                }
                                
                                Spacer()
                            }
                            .padding()
                            .onAppear {
                                if let windowScene = UIApplication.shared.windows.first?.windowScene {
                                    SKStoreReviewController.requestReview(in: windowScene)
                                }
                            }
                        }
                        .navigationBarBackButtonHidden()
                        .scrollIndicators(.hidden)
                        
                        Button {
                            onComplete()
                        } label: {
                            ZStack {
                                RoundedRectangle(cornerRadius: 25, style: .continuous)
                                    .frame(width: 350, height: 50)
                                    .foregroundColor(.black)
                                
                                Text(LocalizedStringKey("Next"))
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                            }
                        }
                        .padding(.bottom, 7.5)
                    }
                    .foregroundColor(.black)
                    .background(Color.white)
        .navigationBarBackButtonHidden()
        .navigationBarItems(leading: Button(action: {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            presentationMode.wrappedValue.dismiss()
   
        }) {
            Image(systemName: "chevron.left")
                .fontWeight(.semibold)
                .foregroundColor(.white)
        })
    }
}

struct ReviewView: View {
    let image: String
    let name: String
    let username: String
    let rating: Int
    let review: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack(alignment: .top) {
                Image(image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 45)
                    .clipShape(Circle())
                VStack(alignment: .leading) {
                    Text(name)
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                    
                    Text(username)
                        .foregroundColor(.black.opacity(0.8))
                        .fontWeight(.medium)
                }
                Spacer()
                ForEach(0..<5) { _ in
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                        .font(.caption)
                }
            }
            .padding(.bottom, 10)
            
            Text("\"") + Text(LocalizedStringKey(review)) + Text("\"")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.black)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(25)
        .overlay(
                                                  RoundedRectangle(cornerRadius: 25)
                                                      .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                              )
    }
}
