//
//  PaywallView.swift
//  Cal AI
//
//  Created by Alex Slater on 19/8/25.
//

import SwiftUI
import SuperwallKit

struct PaywallView: View {
    @State private var maintainText: String = "You should maintain:"
    @State private var maintainAmount: String = "694 lbs"   // replace with your data
    
    @State private var targets: [NutrientTarget] = [
        NutrientTarget(title: "Calories", value: 2240, goal: 2600, unit: "", icon: "flame.fill",
                       ringStyle: .init(), accent: .primary),
        NutrientTarget(title: "Carbs", value: 260, goal: 320, unit: "g", icon: "leaf.fill",
                       ringStyle: .init(), accent: Color.orange),
        NutrientTarget(title: "Protein", value: 180, goal: 210, unit: "g", icon: "dumbbell.fill",
                       ringStyle: .init(), accent: Color.red),
        NutrientTarget(title: "Fats", value: 70, goal: 80, unit: "g", icon: "drop.fill",
                       ringStyle: .init(), accent: Color.blue)
    ]
    let viewController = ViewController()
    @AppStorage("name") private var userName: String = ""
    @AppStorage("age") private var userAge: Int = 0
    let onComplete: () -> Void
    var body: some View {
        VStack {
            ScrollView {
                     VStack(spacing: 20) {
                         Image(systemName: "checkmark.circle.fill")
                             .resizable()
                             .scaledToFit()
                             .frame(width: 40)
                             .foregroundColor(.green)
                         Text("\(userName), your custom\nplan is ready.")
                             .font(.title)
                             .fontWeight(.bold)
                             .multilineTextAlignment(.center)
                         VStack(spacing: 10) {
                             Text(maintainText)
                                 .font(.title3).fontWeight(.semibold)
                                 .foregroundStyle(.secondary)
                             Text(maintainAmount)
                                 .font(.system(size: 20, weight: .semibold, design: .rounded))
                                 .padding(.horizontal, 14)
                                 .padding(.vertical, 6)
                                 .background(
                                     Capsule().fill(.secondary.opacity(0.12))
                                 )
                         }
                         .padding(.top, 8)
                         
                         DiscountView()
                         
                         // Section Title
                         VStack(alignment: .leading, spacing: 4) {
                             Text("Daily recommendation")
                                 .font(.title2).fontWeight(.bold)
                             Text("You can edit this anytime")
                                 .font(.callout).foregroundStyle(.secondary)
                         }
                         .frame(maxWidth: .infinity, alignment: .leading)
                         .padding(.horizontal)
                         .padding(.bottom, 15)
                         
                         // Bento Grid
                         BentoGrid(targets: $targets, onEdit: handleEdit)
                             .padding(.horizontal)
                     }
                     .padding(.bottom, 24)
                 }
            
                 .background(Color(.systemGroupedBackground))
                 .onAppear {
                     PersistanceManager.shared.saveFile(.onboarded, value: true)
                     scheduleNotification()
                 }
            
            Button {
                viewController.pressedButton()
            } label: {
                ZStack {
                    RoundedRectangle(cornerRadius: 35)
                        .frame(width: 350, height: 60)
                        .foregroundColor(.black)
                    
                    Text("Let's get started!")
                        .foregroundColor(.white)
                        .fontWeight(.semibold)
                }
            
             }
        }
    }
    
    private func scheduleNotification() {
          PersistanceManager.shared.saveFile(.sentDiscountNoti, value: true)
          let content = UNMutableNotificationContent()
          content.title = "\(userName), we didn't give up on you."
          content.body = "🎁⏳ Limited time offer: Get 80% off Cal AI and become the healthiest version of yourself."
          content.sound = UNNotificationSound.default
          
          let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 300, repeats: false) // 3 minutes
          
          let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
          
          UNUserNotificationCenter.current().add(request) { error in
              if let error = error {
                  print("Error scheduling notification: \(error)")
              }
          }
      }
    
    private func handleEdit(_ target: NutrientTarget) {
         // Haptic feedback
         UIImpactFeedbackGenerator(style: .light).impactOccurred()
         // TODO: Present your editor. For demo, bump goal by 5%.
         if let index = targets.firstIndex(of: target) {
             withAnimation(.spring) {
                 targets[index].goal = max(1, targets[index].goal * 1.05)
             }
         }
     }
}

struct BentoGrid: View {
    @Binding var targets: [NutrientTarget]
    var onEdit: (NutrientTarget) -> Void
    
    private let cols = [
        GridItem(.flexible(), spacing: 14),
        GridItem(.flexible(), spacing: 14)
    ]
    
    var body: some View {
        LazyVGrid(columns: cols, spacing: 25) {
            ForEach(targets) { target in
                BentoCard(target: target) { onEdit(target) }
            }
        }
    }
}


struct BentoCard: View {
    var target: NutrientTarget
    var onEdit: () -> Void
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(.background)
                .overlay(
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .strokeBorder(.separator.opacity(0.35), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.08), radius: 14, x: 0, y: 6)
            
            VStack(spacing: 16) {
                HStack(spacing: 8) {
                    Image(systemName: target.icon)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.secondary)
                        .frame(width: 28, height: 28)
                        .background(Circle().fill(.secondary.opacity(0.12)))
                    Text(target.title)
                        .font(.headline)
                    Spacer(minLength: 0)
                }
                
                RingStat(
                    progress: target.progress,
                    valueText: formatted(value: target.value, unit: target.unit),
                    ringColor: ringColor(for: target),
                    style: target.ringStyle
                )
                .accessibilityElement(children: .ignore)
                .accessibilityLabel(Text("\(target.title)"))
                .accessibilityValue(Text("\(Int(round(target.progress * 100))) percent of goal"))
                
                // Minibar: value vs goal
                HStack {
                    Text("Goal")
                        .font(.caption).foregroundStyle(.secondary)
                    Spacer()
                    Text(formatted(value: target.goal, unit: target.unit))
                        .font(.caption).foregroundStyle(.secondary)
                        .monospacedDigit()
                }
            }
            .padding(16)
            
            // Edit button
            Button(action: onEdit) {
                Image(systemName: "pencil")
                    .font(.system(size: 14, weight: .semibold))
                    .padding(8)
                    .background(.thinMaterial, in: Circle())
            }
            .buttonStyle(.plain)
            .padding(10)
        }
        .frame(height: 160)
    }
    
    private func ringColor(for t: NutrientTarget) -> AngularGradient {
        // Subtle dual-stop gradient around the ring
        AngularGradient(
            gradient: Gradient(colors: [
                t.accent.opacity(0.95),
                t.accent.opacity(0.65),
                t.accent.opacity(0.95)
            ]),
            center: .center
        )
    }
    
    private func formatted(value: Double, unit: String) -> String {
        let noUnit = unit.trimmingCharacters(in: .whitespaces).isEmpty
        let v = value == floor(value) ? String(format: "%.0f", value) : String(format: "%.1f", value)
        return noUnit ? v : "\(v)\(unit)"
    }
}

// MARK: - Ring

struct RingStat: View {
    var progress: Double               // 0…1
    var valueText: String              // center text
    var ringColor: AngularGradient
    var style: RingStyle
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(lineWidth: style.lineWidth)
                .foregroundStyle(.secondary.opacity(style.backgroundOpacity))
            
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    ringColor,
                    style: StrokeStyle(
                        lineWidth: style.lineWidth,
                        lineCap: style.roundedCaps ? .round : .butt
                    )
                )
                .rotationEffect(.degrees(-90))
                .animation(.spring(response: 0.6, dampingFraction: 0.8), value: progress)
            
            Text(valueText)
                .font(.system(.title3, design: .rounded).weight(.semibold))
                .monospacedDigit()
        }
        .frame(width: 110, height: 110)
        .accessibilityHidden(true)
    }
}

struct NutrientTarget: Identifiable, Hashable {
    let id = UUID()
    var title: String
    var value: Double      // current amount (e.g. 2450)
    var goal: Double       // daily target (e.g. 2800)
    var unit: String       // "kcal", "g"
    var icon: String       // SF Symbol
    var ringStyle: RingStyle
    var accent: Color
    
    var progress: Double { goal == 0 ? 0 : min(max(value / goal, 0), 1) }
}

struct RingStyle: Equatable, Hashable {
    var lineWidth: CGFloat = 14
    var backgroundOpacity: Double = 0.15
    var roundedCaps: Bool = true
}
