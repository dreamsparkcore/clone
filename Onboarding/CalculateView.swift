import SwiftUI
import CoreHaptics

struct InitialCalcView: View {
    @State private var progress: Double = 0
    @State private var engine: CHHapticEngine?
    @State private var showGraph = false
    let onComplete: () -> Void
    let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()

    var body: some View {
        ZStack {
            Color.white
                .ignoresSafeArea()
                .scaledToFill()
                .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
            
            if !showGraph {
                VStack {
                    ZStack {
                        Circle()
                            .stroke(Color(.systemGray6).opacity(0.65), lineWidth: 15)

                        Circle()
                            .trim(from: 0, to: progress)
                            .stroke(style: StrokeStyle(lineWidth: 18, lineCap: .round, lineJoin: .round))
                            .foregroundStyle(LinearGradient(Color(hex: "23C8C8"), Color(hex: "#32C730")))
                            .rotationEffect(.degrees(-90))
                            .animation(.linear, value: progress)

                        Text("\(Int(progress * 100))%")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                            .contentTransition(.numericText())
                    }
                    .frame(width: 200, height: 200)
                    .padding(.bottom, 30)

                    Text("Calculating")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)

                    Text(subtitleForProgress(progress))
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(Color.gray)
                        .padding(.top, 5)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                DependencyGraph(onComplete: onComplete)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .onAppear(perform: prepareHaptics)
        .onReceive(timer) { _ in
            guard !showGraph else { return }
            if progress < 1.0 {
                progress += 0.01
                vibrate()
            } else {
                explode()
            }
        }
    }


    func prepareHaptics() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        do {
            engine = try CHHapticEngine()
            try engine?.start()
        } catch {
            print("Haptics error: \(error.localizedDescription)")
        }
    }

    func vibrate() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: Float(progress))
        let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: Float(progress))
        let event = CHHapticEvent(eventType: .hapticTransient, parameters: [intensity, sharpness], relativeTime: 0)
        do {
            let pattern = try CHHapticPattern(events: [event], parameters: [])
            let player = try engine?.makePlayer(with: pattern)
            try player?.start(atTime: 0)
        } catch {
            print("Pattern error: \(error.localizedDescription)")
        }
    }

    func explode() {
        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
        withAnimation(.easeInOut(duration: 0.5)) {
            showGraph = true
        }
    }

    func subtitleForProgress(_ progress: Double) -> String {
        switch progress {
        case 0.0..<0.2:
            return "Understanding responses"
        case 0.2..<0.6:
            return "Learning relapse triggers"
        case 0.6..<1:
            return "Building custom plan"
        default:
            return "Finalizing"
        }
    }
}

struct DependencyGraph: View {
    let userScore: Double = 0.7
    let averageScore: Double = 0.4
    let onComplete: () -> Void
    @State private var showRectangles = false

    var dependentScorePercentage: Int {
        let rangeMin = 33.0
        let rangeMax = 78.0
        let clamped = min(max(userScore, 0), 1)
        return Int(rangeMin + (rangeMax - rangeMin) * clamped)
    }

    var averageScorePercentage: Int {
        let rangeMin = 0.0
        let rangeMax = 100.0
        return Int(rangeMin + (rangeMax - rangeMin) * averageScore)
    }

    var body: some View {
            VStack {
                    VStack(spacing: 10) {
                        HStack(spacing: 5) {
                            Text("Analysis Complete")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                        }
                        .padding(.bottom, 40)
  
                        Image("chart")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 250)
                            .padding(.bottom, 10)
      
                        Text("*You'll be 76% more likely to achieve your goals with Cal AI*")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        
                        
                    }
                    .padding()

                Text("* This result is an indication only, not a medical diagnosis.")
                    .font(.caption2)
                    .foregroundColor(.primary.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                    .padding(.top, 40)

                Button(action: {
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    onComplete()
                }) {
                    Text("Continue")
                        .foregroundColor(.white)
                        .frame(width: 300)
                        .padding()
                        .background(Color(hex: "0073FF"))
                        .cornerRadius(25)
                        .fontWeight(.semibold)
                }
                .padding(.bottom)
            }
    }
}
