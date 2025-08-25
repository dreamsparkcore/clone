//
//  OnboardingView.swift
//  Cal AI
//
//  Created by Alex Slater on 19/8/25.
//

import SwiftUI
import SuperwallKit

struct OnboardingView: View {
    // MARK: - State
    @State private var step: Int = 0
    @State private var answers: [Int: Answer] = [:]
    @State private var showingCalculating = false
    @State private var clickedPaywall = false
    @State private var showSkipAlert = false

    // Persisted user info
    @AppStorage("name") private var userName: String = ""
    @AppStorage("age") private var userAge: Int = 0
    @State private var ageText: String = "" // for numeric TextField, mirrored -> userAge

    let onComplete: () -> Void

    // MARK: - Questions
    private let questions: [Question] = [
        .init(id: 0,
              title: "Welcome to Cal AI 👋",
              subtitle: "I’ll tailor this to you. Sound good?",
              kind: .singleChoice(options: ["Let’s do it", "I can't wait, let's go!"])),

        .init(id: 1,
              title: "Where are you starting from?",
              subtitle: "Be honest—this helps me give you realistic wins.",
              kind: .singleChoice(options: ["Total beginner", "On & off tracker", "Pretty consistent", "Dialed in"])),

        .init(id: 2,
              title: "What’s the primary goal?",
              subtitle: "Pick the one you care about most right now.",
              kind: .singleChoice(options: ["Lose fat", "Build muscle", "Maintain + feel better", "Improve energy/health"])),

        .init(id: 3,
              title: "What’s your target pace?",
              subtitle: "Faster is harder. Steady is sustainable.",
              kind: .slider(range: 1...3, step: 1,
                            labels: [1: "Slow & steady", 2: "Balanced", 3: "Aggressive"])),

        .init(id: 4,
              title: "How do you want to track?",
              subtitle: "No judgment—your system, your rules.",
              kind: .singleChoice(options: ["Photo + estimate (quick)", "Weigh ingredients (precise)", "A mix of both"])),

        .init(id: 5,
              title: "Typical weekday activity?",
              subtitle: "Just a vibe check so we can set calories right.",
              kind: .singleChoice(options: ["Mostly seated", "Some movement", "Active job", "Athlete-level"])),

        .init(id: 6,
              title: "How many workouts / week?",
              subtitle: "Walking counts if it’s intentional.",
              kind: .slider(range: 0...7, step: 1,
                            labels: [:])),

        .init(id: 7,
              title: "What trips you up most?",
              subtitle: "We’ll build around your real life.",
              kind: .singleChoice(options: ["Late-night snacking", "Weekends/socials", "Under-eating then binging", "No time to cook"])),

        .init(id: 8,
              title: "If we nail this, what changes first?",
              subtitle: "Paint the win so we can aim at it.",
              kind: .singleChoice(options: ["Look leaner", "Feel more confident", "More energy + focus", "Perform better in training"])),

        // Final two slides: Name + Age
        .init(id: 9,
              title: "What’s your name?",
              subtitle: "So I can personalize your plan.",
              kind: .text(placeholder: "Enter your name")),

        .init(id: 10,
              title: "How old are you?",
              subtitle: "Age helps me estimate daily targets more accurately.",
              kind: .text(placeholder: "Enter your age"))
    ]

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                ZStack {
                    HStack {
                        Spacer()

                        Button {
                            showSkipAlert.toggle()
                        } label: {
                            Text("Skip Quiz")
                                .fontWeight(.medium)
                                .foregroundColor(.gray)
                                .font(.footnote)
                                .padding(.trailing)
                        }
                    }
                    Image("calai")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 120)
                        .padding(.vertical, 10)
                }
                // Progress
                ProgressBar(progress: Double(step) / Double(max(questions.count - 1, 1)))
                    .padding(.horizontal, 20)
                    .padding(.top, 24)

                // Card
                VStack(spacing: 16) {
                    Text(questions[step].title)
                        .font(.system(size: 28, weight: .bold))
                        .multilineTextAlignment(.leading)
                        .lineLimit(nil)              // allow unlimited lines
                        .fixedSize(horizontal: false, vertical: true) // expand vertically
                        .frame(maxWidth: .infinity, alignment: .leading)

                    if let subtitle = questions[step].subtitle {
                        Text(subtitle)
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    // Custom bindings for Name/Age so they persist and don't leak
                    if questions[step].id == 9 {
                        // Name
                        TextField("Enter your name", text: Binding(
                            get: { userName },
                            set: { newVal in
                                userName = newVal
                                answers[step] = .text(newVal) // keep step-complete logic intact
                            }
                        ))
                        .textFieldStyle(.roundedBorder)
                        .padding(.vertical, 6)
                        .onAppear {
                            // initialize on first show if empty
                            if userName.isEmpty { answers[step] = .text("") }
                        }
                    } else if questions[step].id == 10 {
                        // Age
                        TextField("Enter your age", text: Binding(
                            get: { ageText.isEmpty ? (userAge == 0 ? "" : String(userAge)) : ageText },
                            set: { newVal in
                                ageText = newVal
                                let intVal = Int(newVal.filter(\.isNumber)) ?? 0
                                userAge = intVal
                                answers[step] = .text(newVal)
                            }
                        ))
                        .keyboardType(.numberPad)
                        .textFieldStyle(.roundedBorder)
                        .padding(.vertical, 6)
                        .onAppear {
                            // prime value
                            ageText = userAge == 0 ? "" : String(userAge)
                            answers[step] = .text(ageText)
                        }
                    } else {
                        // All other questions use the generic renderer
                        QuestionView(
                            question: questions[step],
                            answer: answers[step],
                            onChange: { answers[step] = $0 }
                        )
                        .id(questions[step].id) // ensure SwiftUI doesn't recycle state across steps
                        .padding(.top, 8)
                    }
                }
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color(.systemBackground))
                        .shadow(color: .black.opacity(0.06), radius: 20, x: 0, y: 10)
                )
                .padding(.horizontal, 20)
                .padding(.top, 20)

                Spacer()

                // Navigation
                HStack(spacing: 12) {
                    Button {
                        withAnimation(.easeInOut) {
                            step = max(step - 1, 0)
                        }
                    } label: {
                        HStack {
                            Image(systemName: "chevron.left")
                            Text("Back")
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(SecondaryButtonStyle())
                    .disabled(step == 0)

                    Button {
                        advance()
                    } label: {
                        HStack {
                            Text(step == questions.count - 1 ? "Finish" : "Continue")
                            Image(systemName: "chevron.right")
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(PrimaryButtonStyle())
                    .disabled(!isStepComplete(step))
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)

            }

        }
        .animation(.easeInOut, value: step)
        .alert(isPresented: $showSkipAlert) {
            Alert(
                title: Text(LocalizedStringKey("Are you sure?")),
                message: Text(LocalizedStringKey("We use this to make your custom porn-quitting plan more accurate.")),
                primaryButton: .destructive(Text(LocalizedStringKey("Skip"))) {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        step = 9
                    }
                },
                secondaryButton: .cancel()
            )
        }
    }
}

// MARK: - Advance Logic
private extension OnboardingView {
    func isStepComplete(_ index: Int) -> Bool {
        // Name/Age steps rely on mirrored answers set above
        guard let a = answers[index] else { return false }
        switch a {
        case .choice(let str): return !str.isEmpty
        case .slider(_): return true
        case .text(let str): return !str.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }
    }

    func advance() {
        if step < questions.count - 1 {
            withAnimation(.easeInOut) { step += 1 }
        } else {
            // Finished all questions → complete
            withAnimation(.spring) {
                onComplete()
            }
        }
    }
}

// MARK: - Models
struct Question: Identifiable, Equatable {
    enum Kind: Equatable {
        case singleChoice(options: [String])
        case slider(range: ClosedRange<Int>, step: Int, labels: [Int: String])
        case text(placeholder: String)
    }

    let id: Int
    let title: String
    let subtitle: String?
    let kind: Kind
}

enum Answer: Equatable {
    case choice(String)
    case slider(Int)
    case text(String)
}

// MARK: - Question View
struct QuestionView: View {
    let question: Question
    let answer: Answer?
    let onChange: (Answer) -> Void

    // Removed textValue; we now bind directly to `answer` so values don't leak between questions
    @State private var sliderInitialized = false

    var body: some View {
        switch question.kind {
        case .singleChoice(let options):
            VStack(spacing: 10) {
                ForEach(options, id: \.self) { option in
                    let isSelected = (answer == .choice(option))
                    Button {
                        onChange(.choice(option))
                    } label: {
                        HStack {
                            Text(option)
                                .fontWeight(.medium)
                            Spacer()
                            Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                                .imageScale(.large)
                                .symbolRenderingMode(.hierarchical)
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(isSelected ? Color.accentColor.opacity(0.12) : Color.secondary.opacity(0.08))
                        )
                    }
                    .buttonStyle(.plain)
                }
            }

        case .slider(let range, let step, let labels):
            // Integer-only, stable binding sourced from `answer`
            let currentInt: Int = {
                if case .slider(let v) = answer { return v }
                return range.lowerBound
            }()

            let valueBinding = Binding<Double>(
                get: { Double(currentInt) },
                set: { newVal in
                    let snapped = Int(newVal.rounded())
                    onChange(.slider(snapped))
                }
            )

            VStack(spacing: 14) {
                HStack {
                    Text(labels[range.lowerBound] ?? "\(range.lowerBound)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text(labels[currentInt] ?? "\(currentInt)")
                        .font(.subheadline).bold()
                    Spacer()
                    Text(labels[range.upperBound] ?? "\(range.upperBound)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Slider(value: valueBinding,
                       in: Double(range.lowerBound)...Double(range.upperBound),
                       step: Double(step))

                if !labels.isEmpty, let label = labels[currentInt] {
                    Text(label).foregroundStyle(.secondary)
                }
            }
            .onAppear {
                // If no answer yet, auto-select the lowest bound
                if answer == nil {
                    onChange(.slider(range.lowerBound))
                }
            }

        case .text(let placeholder):
            // Small, single-line TextField that binds directly to `answer`
            let textValue = (ifCaseText(answer) ?? "")
            TextField(placeholder,
                      text: Binding(
                        get: { textValue },
                        set: { onChange(.text($0)) }
                      )
            )
            .textFieldStyle(.roundedBorder)
            .padding(.vertical, 6)
        }
    }

    private func ifCaseText(_ answer: Answer?) -> String? {
        if case .text(let s) = answer { return s }
        return nil
    }
}

// MARK: - Calculating Overlay
struct CalculatingOverlay: View {
    let onDone: () -> Void
    @State private var progress: Double = 0
    @State private var timerActive = true

    var body: some View {
        ZStack {
            Color.black.opacity(0.4).ignoresSafeArea()
            VStack(spacing: 16) {
                ProgressView(value: progress, total: 1.0)
                    .progressViewStyle(.linear)
                    .tint(.accentColor)
                Text("Calculating your plan…")
                    .font(.headline)
                Text("Locking in calories, macros, and an approach that matches your lifestyle.")
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            .padding(24)
            .background(RoundedRectangle(cornerRadius: 20).fill(Color(.systemBackground)))
            .padding(24)
        }
        .onAppear {
            // Faux progress that feels smooth, then call onDone()
            withAnimation(.easeInOut(duration: 0.9)) { progress = 0.62 }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.95) {
                withAnimation(.easeInOut(duration: 0.7)) { progress = 1.0 }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.65) {
                onDone()
            }
        }
    }
}

// MARK: - Styles
struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .fontWeight(.semibold)
            .padding(.vertical, 14)
            .padding(.horizontal, 16)
            .background(RoundedRectangle(cornerRadius: 14).fill(configuration.isPressed ? Color.accentColor.opacity(0.7) : Color.accentColor))
            .foregroundStyle(.white)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .fontWeight(.semibold)
            .padding(.vertical, 14)
            .padding(.horizontal, 16)
            .background(RoundedRectangle(cornerRadius: 14).strokeBorder(Color.secondary.opacity(configuration.isPressed ? 0.5 : 0.25)))
            .foregroundStyle(.primary)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }
}

// MARK: - Progress Bar
struct ProgressBar: View {
    let progress: Double // 0...1
    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule().fill(Color.secondary.opacity(0.15))
                Capsule()
                    .fill(Color.accentColor)
                    .frame(width: max(8, geo.size.width * progress))
            }
        }
        .frame(height: 8)
        .accessibilityLabel("Progress")
        .accessibilityValue("\(Int(progress * 100)) percent")
    }
}
