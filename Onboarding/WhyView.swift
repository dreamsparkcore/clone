import SwiftUI

struct WhyView: View {
    @State private var currentPage = 0
    let onComplete: () -> Void
    let pages: [(imageName: String, title: String, subtitle: String)] = [
        ("brain", "Porn is a drug", "Using porn releases a chemical in the brain called **dopamine**. This chemical makes you **feel good**- it's why you feel pleasure when you **watch porn**."),
        ("hb", "Porn destroys relationships", "Porn **reduces** your hunger for a **real relationship** and replaces it with the hunger for more porn."),
        ("symbol", "Porn shatters sex drive", "More than 50% of porn addicts have reported a **loss of interest** in **real sex**, and an overall **decrease in their sex drive**."),
        ("sad", "Feeling unhappy?", "An **elevated dopamine level** means you need more dopamine to feel good. This is why so many heavy porn users report feeling **depresed**, **unmotivated**, and **anti-social**."),
        ("zplant", "Path to Recovery", "Recovery is possible. By **abstaining from porn**, your brain can **reset its dopamine sensitivity**, leading to healthier relationships and **improved well-being**."),
    ]
    
    var body: some View {
        ZStack {
            Color(hex: currentPage == 4 ? "#023e8a" : "#D90429").ignoresSafeArea(.all)
            VStack {
                Image("WhiteLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 26, alignment: .center)
                    .padding(.top, 10)
                Spacer()
                
                TabView(selection: $currentPage) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        vInfoView(color: .white, info: pages[index])
                            .tag(index)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .frame(height: 400)
                
                Spacer()
                PageIndicator(color: Color(hex: "#89CFF0"), currentPage: $currentPage, pageCount: pages.count)
                    .padding(.top, 20)
                
                Button(action: {
                    if currentPage == pages.count - 1 {
                        onComplete()
                    } else {
                        withAnimation {
                            currentPage += 1
                        }
                    }
                }) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 40)
                            .frame(width: 150, height: 50)
                            .foregroundColor(.white)
                        HStack {
                            Text(LocalizedStringKey("Next"))
                            Image(systemName: "chevron.right")
                            
                        }
                        .font(.headline)
                        .foregroundColor(.black)
                        .fontWeight(.bold)
                    }
                    .padding()
                }
                .padding(.top, 20)
                
        
            }
        }
    }
}

struct vInfoView: View {
    let color: Color
    let info: (imageName: String, title: String, subtitle: String)
    
    var body: some View {
        VStack {
//            LottieView(name: info.imageName)
//                .frame(width: 300)
            
            Text(LocalizedStringKey(info.title))
                .font(.custom("DMSans-Black", size: 25))
                .padding(.bottom, 7.5)
                .foregroundColor(color)
                .multilineTextAlignment(.center)
            
            Text(LocalizedStringKey(info.subtitle))
                .font(.custom("DMSans-Medium", size: 16))
                .multilineTextAlignment(.center)
                .foregroundColor(color)
                .frame(width: 335)
        }
        .padding()
    }
}

struct PageIndicator: View {
    let color: Color
    @Binding var currentPage: Int
    let pageCount: Int
    
    var body: some View {
        HStack(spacing: 6.5) {
            ForEach(0..<pageCount, id: \.self) { page in
                Circle()
                    .fill(page == currentPage ? Color.white : Color(.systemGray2))
                    .frame(width: 8, height: 8)
            }
        }
    }
}
