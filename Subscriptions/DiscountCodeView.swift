import SwiftUI

struct DiscountView: View {
    @AppStorage("viewStartTime") var viewStartTime: Double = 0
    @State private var showComponent = false
    @State private var remainingTime: Double = 300 // 5 minutes in seconds
    @State private var timer: Timer?
    let viewController = ViewController()
    var body: some View {
        VStack {
            if showComponent {
                VStack {
                    Text("Special Discount!")
                        .font(.title)
                        .fontWeight(.bold)
                    Text("Get 80% off on QUITTR Premium!")
                        .font(.footnote)
                    Button("Claim Now") {
                        viewController.fiftyOff()
                    }
                    .padding()
                    .background(Color.white)
                    .foregroundColor(.black)
                    .cornerRadius(10)
                }
                .padding()
                .padding(.vertical)
                .background(.white)
                .cornerRadius(20)
                .transition(.scale)
            } else {
//                Text("Waiting for component to appear in:")
//                    .font(.headline)
//                    .padding()
//
//                Text("\(Int(remainingTime)) seconds left")
//                    .font(.system(size: 48, weight: .bold, design: .monospaced))
//                    .padding()
            }
        }
        .onAppear {
            let currentTime = Date().timeIntervalSince1970
            if viewStartTime == 0 {
                viewStartTime = currentTime
            }
            let timeDifference = currentTime - viewStartTime
            
            if timeDifference >= 300 {
                showComponent = true
            } else {
                remainingTime = 300 - timeDifference
                timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
                    remainingTime -= 1
                    if remainingTime <= 0 {
                        showComponent = true
                        timer?.invalidate()
                    }
                }
            }
        }
        .onDisappear {
            timer?.invalidate()
        }
    }
}

