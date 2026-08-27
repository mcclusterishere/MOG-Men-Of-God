import SwiftUI

struct SafetySupportView: View {
    var compact = false

    var body: some View {
        VStack(alignment: .leading, spacing: compact ? 12 : 18) {
            Label("Your safety comes first", systemImage: "lifepreserver.fill")
                .font(compact ? .headline : .title2.bold())
                .foregroundStyle(POGTheme.cream)

            Text("People of God is peer support, not an emergency or medical service. You do not have to handle this alone.")
                .font(compact ? .caption : .body)
                .foregroundStyle(POGTheme.softCream)

            Link(destination: URL(string: "sms:988")!) {
                Label("Text 988", systemImage: "message.fill")
            }
            .buttonStyle(POGPrimaryButtonStyle())

            Link(destination: URL(string: "tel:988")!) {
                Label("Call 988", systemImage: "phone.fill")
            }
            .buttonStyle(POGSecondaryButtonStyle())

            Link(destination: URL(string: "sms:")!) {
                Label("Text someone you trust", systemImage: "person.crop.circle.badge.checkmark")
            }
            .buttonStyle(POGSecondaryButtonStyle())

            Text("If you or someone else is in immediate danger, call 911 or go to the nearest emergency department.")
                .font(.caption)
                .foregroundStyle(POGTheme.cream)

            Link(destination: URL(string: "tel:911")!) {
                Label("Call 911", systemImage: "phone.badge.waveform.fill")
            }
            .font(.callout.weight(.semibold))
            .foregroundStyle(Color.white)
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity)
            .background(POGTheme.urgent, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
        .padding(compact ? 14 : 18)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(POGTheme.urgent.opacity(0.13))
                .overlay(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .stroke(POGTheme.urgent.opacity(0.5), lineWidth: 1)
                )
        )
        .accessibilityElement(children: .contain)
    }
}
