import SwiftUI

enum POGTheme {
    static let midnight = Color(red: 0.025, green: 0.055, blue: 0.105)
    static let deepBlue = Color(red: 0.045, green: 0.095, blue: 0.17)
    static let cream = Color(red: 0.96, green: 0.93, blue: 0.84)
    static let softCream = Color(red: 0.77, green: 0.76, blue: 0.70)
    static let gold = Color(red: 0.78, green: 0.63, blue: 0.31)
    static let warmGold = Color(red: 0.91, green: 0.78, blue: 0.48)
    static let supportBlue = Color(red: 0.21, green: 0.50, blue: 0.72)
    static let urgent = Color(red: 0.75, green: 0.27, blue: 0.25)
}

struct PeopleOfGodMark: View {
    var size: CGFloat = 52

    var body: some View {
        ZStack {
            Circle()
                .stroke(POGTheme.gold.opacity(0.72), lineWidth: max(1.5, size * 0.035))

            Circle()
                .trim(from: 0.04, to: 0.29)
                .stroke(POGTheme.warmGold, style: StrokeStyle(lineWidth: max(2, size * 0.075), lineCap: .round))
                .rotationEffect(.degrees(-18))

            Circle()
                .trim(from: 0.38, to: 0.63)
                .stroke(POGTheme.warmGold, style: StrokeStyle(lineWidth: max(2, size * 0.075), lineCap: .round))
                .rotationEffect(.degrees(-18))

            Circle()
                .trim(from: 0.71, to: 0.96)
                .stroke(POGTheme.warmGold, style: StrokeStyle(lineWidth: max(2, size * 0.075), lineCap: .round))
                .rotationEffect(.degrees(-18))

            Capsule()
                .fill(POGTheme.cream)
                .frame(width: size * 0.08, height: size * 0.43)

            Capsule()
                .fill(POGTheme.cream)
                .frame(width: size * 0.28, height: size * 0.08)
                .offset(y: -size * 0.055)
        }
        .frame(width: size, height: size)
        .accessibilityLabel("People of God")
    }
}

struct POGBackground: View {
    var body: some View {
        LinearGradient(
            colors: [POGTheme.midnight, POGTheme.deepBlue, POGTheme.midnight],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .overlay(alignment: .topTrailing) {
            Circle()
                .fill(POGTheme.gold.opacity(0.08))
                .frame(width: 280, height: 280)
                .blur(radius: 8)
                .offset(x: 120, y: -120)
        }
        .ignoresSafeArea()
    }
}

struct POGCardModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(18)
            .background(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(POGTheme.deepBlue.opacity(0.78))
                    .overlay(
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .stroke(POGTheme.cream.opacity(0.09), lineWidth: 1)
                    )
            )
    }
}

extension View {
    func pogCard() -> some View {
        modifier(POGCardModifier())
    }
}

struct POGPrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundStyle(POGTheme.midnight)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 15)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(configuration.isPressed ? POGTheme.gold : POGTheme.warmGold)
            )
            .offset(y: configuration.isPressed ? 1 : 0)
    }
}

struct POGSecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundStyle(POGTheme.cream)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(POGTheme.cream.opacity(configuration.isPressed ? 0.13 : 0.07))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(POGTheme.cream.opacity(0.18), lineWidth: 1)
                    )
            )
    }
}

struct POGChoiceRow: View {
    let title: String
    let detail: String?
    let symbol: String
    let isSelected: Bool
    let action: () -> Void

    init(
        title: String,
        detail: String? = nil,
        symbol: String,
        isSelected: Bool,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.detail = detail
        self.symbol = symbol
        self.isSelected = isSelected
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                Image(systemName: symbol)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(isSelected ? POGTheme.midnight : POGTheme.warmGold)
                    .frame(width: 36, height: 36)
                    .background(
                        Circle().fill(isSelected ? POGTheme.warmGold : POGTheme.gold.opacity(0.12))
                    )

                VStack(alignment: .leading, spacing: 3) {
                    Text(title)
                        .font(.body.weight(.semibold))
                    if let detail {
                        Text(detail)
                            .font(.caption)
                            .foregroundStyle(POGTheme.softCream)
                            .multilineTextAlignment(.leading)
                    }
                }

                Spacer(minLength: 8)

                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(isSelected ? POGTheme.warmGold : POGTheme.softCream.opacity(0.55))
            }
            .foregroundStyle(POGTheme.cream)
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(isSelected ? POGTheme.gold.opacity(0.12) : POGTheme.cream.opacity(0.045))
                    .overlay(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .stroke(isSelected ? POGTheme.gold.opacity(0.55) : POGTheme.cream.opacity(0.08), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(.plain)
    }
}
