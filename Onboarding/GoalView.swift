import SwiftUI

struct Goal: Identifiable, Hashable, Equatable {
    let id = UUID()
    let icon: String
    let title: String
    let color: Color

    static func == (lhs: Goal, rhs: Goal) -> Bool {
        return lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

struct GoalSelectView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var goals = [
        Goal(icon: "chart.bar.fill", title: "Reach weight goals faster", color: .blue),
        Goal(icon: "smiley.fill", title: "Boost mood and confidence", color: .yellow),
        Goal(icon: "bolt.fill", title: "More daily energy", color: .orange),
        Goal(icon: "heart.fill", title: "Better overall health", color: .red),
        Goal(icon: "brain.head.profile", title: "Stay consistent with habits", color: .cyan),
        Goal(icon: "eye.fill", title: "Clearer focus & productivity", color: .purple),
        Goal(icon: "sparkles", title: "Simpler, stress-free tracking", color: .pink),
    ]
    @State private var selectedGoals: Set<Goal> = []
    let onComplete: () -> Void
    var body: some View {
                VStack(alignment: .leading) {
                    ScrollView {
                        Text(LocalizedStringKey("Select your health goals to build your custom plan."))
                            .font(.custom("DMSans-Medium", size: 15))
                            .foregroundColor(.gray)
                            .padding(.bottom, 15)
                        
                        
                        
                        
                        ForEach(goals) { goal in
                            VStack(spacing: 20) {
                                GoalRow(goal: goal, isSelected: selectedGoals.contains(goal)) {
                                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                    if selectedGoals.contains(goal) {
                                        selectedGoals.remove(goal)
                                        AnalyticsManager.shared.trackEvent(eventName: "select_goal", properties: ["goal": goal.title])
                                    } else {
                                        selectedGoals.insert(goal)
                                        AnalyticsManager.shared.trackEvent(eventName: "select_goal", properties: ["goal": goal.title])
                                        AnalyticsManager.shared.updateUserAttributes(attributes: ["goals": selectedGoals.map({ $0.title }).joined(separator: ",")])
                                    }
                                }
                                .padding(.horizontal, 10)
                                .padding(.bottom, 5)
                            }
                        }
                        
                        Spacer()
                        
                    }
                    .scrollIndicators(.hidden)
                    Button(action: {
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        onComplete()
                    }) {
                        Text("Track these goals")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(.black)
                            .foregroundColor(.white)
                            .cornerRadius(25)
                            .fontWeight(.semibold)
                    }
                }
                .padding()
                .navigationTitle(LocalizedStringKey("Choose your goals"))
                .navigationBarItems(leading: Button(action: {
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.primary)
                        .fontWeight(.semibold)
                })
    }
}

struct GoalRow: View {
    let goal: Goal
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button {
            withAnimation {
                action()
            }
        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: 35, style: .continuous)
                    .fill(goal.color.opacity(isSelected ? 0.5 : (UITraitCollection.current.userInterfaceStyle == .dark ? 0.3 : 0.1)))
                    .frame(height: 65)
                    .shadow(color: Color.black.opacity(0.3), radius: 1)
                HStack {
                    Image(systemName: goal.icon)
                        .foregroundColor(.white)
                        .frame(width: 30, height: 30)
                        .background(goal.color)
                        .cornerRadius(15)
                        .padding(.trailing, 5)
                    
                    Text(LocalizedStringKey(goal.title))
                        .foregroundColor(.primary)
                        .font(.headline)
                        .fontWeight(.medium)
                        .multilineTextAlignment(.leading)
                    
                    Spacer()
                    
                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 22)
                            .symbolRenderingMode(.palette)
                            .foregroundStyle(.black.opacity(0.7), .white)
                    } else {
                        Image(systemName: "circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 22)
                            .foregroundColor(Color(.systemGray6))
                    }
                }
                .padding()
            }
        }
    }
}
