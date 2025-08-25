import SwiftUI
import CoreHaptics

struct FinalCalculateView: View {
    @State private var currentText = ""
    @State private var currentIndex = 0
    @State private var messageIndex = 0
    @State private var engine: CHHapticEngine?
    var calc: Bool
    let onComplete: () -> Void
    let messages: [String] = [
        String(localized: "Hey, Alex"),
        String(localized: "Welcome to Cal AI, your path to healthy eating."),
        String(localized: "Based on your answers, we've built a plan just for you."),
        String(localized: "It's designed to help you lose 25lbs in 90 days"),
        String(localized: "Now, it's time to invest in yourself.")
    ]
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {

                VStack(spacing: 0) {
                    Text(currentText)
                        .font(.title)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.black)
                        .animation(.none)
                        .padding(30)
                        .frame(height: 250)
                    
                    if messageIndex >= 2 {
                        QTRCard()
                    }
                    Spacer()
                    
                  ProgressView()
                        .tint(.white)
                        .frame(width: 120, height: 120)
                }
                .frame(width: geometry.size.width, height: geometry.size.height)
            }
            .background(.white)
        }
        .navigationBarBackButtonHidden()
        .onAppear {
            startAnimation()
            prepareHaptics()
        }
    }
    
    func startAnimation() {
        Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { timer in
            if currentIndex < messages[messageIndex].count {
                withAnimation {
                    let nextCharacter = String(messages[messageIndex][messages[messageIndex].index(messages[messageIndex].startIndex, offsetBy: currentIndex)])
                    currentText += nextCharacter
                    currentIndex += 1
                    triggerHapticFeedback()
                }
            } else {
                timer.invalidate()
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    currentText = ""
                    currentIndex = 0
                    messageIndex += 1
                    if messageIndex < messages.count {
                        startAnimation()
                    } else {
                        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                        PersistanceManager.shared.saveFile(.onboarded, value: true)
                        onComplete()
                    }
                }
            }
        }
    }
    
    func prepareHaptics() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        do {
            self.engine = try CHHapticEngine()
            try engine?.start()
        } catch {
            print("There was an error creating the engine: \(error.localizedDescription)")
        }
    }
    
    func triggerHapticFeedback() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        
        var events = [CHHapticEvent]()
        
        let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 1.0)
        let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 1.0)
        let event = CHHapticEvent(eventType: .hapticTransient, parameters: [intensity, sharpness], relativeTime: 0)
        events.append(event)
        
        do {
            let pattern = try CHHapticPattern(events: events, parameters: [])
            let player = try engine?.makePlayer(with: pattern)
            try player?.start(atTime: 0)
        } catch {
            print("Failed to play pattern: \(error.localizedDescription).")
        }
    }
}
