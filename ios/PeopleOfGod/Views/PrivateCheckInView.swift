import SwiftUI

struct PrivateCheckInView: View {
    @EnvironmentObject private var store: SharedStore
    @State private var selectedState: CheckInState?
    @State private var selectedSupport: Set<SupportKind> = []
    @State private var didSave = false

    var body: some View {
        ZStack {
            POGBackground()

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("PRIVATE CHECK-IN")
                            .font(.caption.weight(.bold))
                            .tracking(1.6)
                            .foregroundStyle(POGTheme.warmGold)
                        Text("How are you, really?")
                            .font(.largeTitle.bold())
                            .foregroundStyle(POGTheme.cream)
                        Text("Choose what is true right now. Your answer is not uploaded or added to a profile.")
                            .foregroundStyle(POGTheme.softCream)
                    }

                    VStack(spacing: 10) {
                        ForEach(CheckInState.allCases) { state in
                            POGChoiceRow(
                                title: state.title,
                                symbol: state.symbol,
                                isSelected: selectedState == state
                            ) {
                                selectedState = state
                            }
                        }
                    }

                    if selectedState?.requiresSafetyOffer == true {
                        SafetySupportView()
                    }

                    if selectedState != nil {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("WHAT WOULD HELP?")
                                .font(.caption.weight(.bold))
                                .tracking(1.4)
                                .foregroundStyle(POGTheme.warmGold)
                            Text("Choose any that fit. These choices stay private here.")
                                .font(.subheadline)
                                .foregroundStyle(POGTheme.softCream)

                            ForEach(SupportKind.allCases) { support in
                                POGChoiceRow(
                                    title: support.title,
                                    symbol: support.symbol,
                                    isSelected: selectedSupport.contains(support)
                                ) {
                                    if selectedSupport.contains(support) {
                                        selectedSupport.remove(support)
                                    } else {
                                        selectedSupport.insert(support)
                                    }
                                }
                            }
                        }

                        Button(didSave ? "Check-in saved" : "Save private check-in") {
                            guard let selectedState else { return }
                            store.recordPrivateCheckIn(
                                PrivateCheckIn(
                                    state: selectedState,
                                    support: selectedSupport,
                                    shareChoice: .privateOnly,
                                    createdAt: Date()
                                )
                            )
                            withAnimation { didSave = true }
                        }
                        .buttonStyle(POGPrimaryButtonStyle())
                        .disabled(didSave)

                        if didSave {
                            Label("Only participation was counted. Your answers were not saved.", systemImage: "lock.shield.fill")
                                .font(.caption)
                                .foregroundStyle(POGTheme.softCream)
                                .transition(.opacity.combined(with: .move(edge: .bottom)))
                        }
                    }
                }
                .padding(18)
                .padding(.bottom, 30)
            }
        }
        .navigationTitle("Circle Check")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(POGTheme.midnight, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
    }
}
