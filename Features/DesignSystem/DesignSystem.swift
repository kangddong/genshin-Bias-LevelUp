import SwiftUI

enum DSColor {
    static let canvasTop = Color(red: 0.94, green: 0.97, blue: 1.0)
    static let canvasBottom = Color(red: 0.99, green: 0.96, blue: 0.92)

    static let panel = Color.white.opacity(0.88)
    static let panelStrong = Color.white.opacity(0.97)
    static let border = Color.black.opacity(0.08)

    static let primary = Color(red: 0.08, green: 0.45, blue: 0.84)
    static let primarySoft = Color(red: 0.79, green: 0.89, blue: 0.99)
    static let accent = Color(red: 0.94, green: 0.57, blue: 0.2)

    static let textPrimary = Color(red: 0.09, green: 0.12, blue: 0.19)
    static let textSecondary = Color(red: 0.37, green: 0.42, blue: 0.52)
}

enum DSTypography {
    static let title = Font.system(size: 28, weight: .bold, design: .rounded)
    static let section = Font.system(size: 19, weight: .semibold, design: .rounded)
    static let headline = Font.system(size: 16, weight: .semibold, design: .rounded)
    static let body = Font.system(size: 14, weight: .regular, design: .rounded)
    static let caption = Font.system(size: 12, weight: .medium, design: .rounded)
}

struct DSBackgroundLayer: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [DSColor.canvasTop, DSColor.canvasBottom],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            Circle()
                .fill(DSColor.primarySoft.opacity(0.45))
                .frame(width: 240, height: 240)
                .blur(radius: 24)
                .offset(x: -140, y: -240)

            Circle()
                .fill(DSColor.accent.opacity(0.16))
                .frame(width: 200, height: 200)
                .blur(radius: 28)
                .offset(x: 150, y: 260)
        }
    }
}

struct DSCard<Content: View>: View {
    private let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .padding(14)
            .background(DSColor.panel)
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(DSColor.border, lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 4)
    }
}

struct DSPrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(DSTypography.body.weight(.semibold))
            .foregroundStyle(Color.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(configuration.isPressed ? DSColor.primary.opacity(0.8) : DSColor.primary)
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
    }
}

struct DSSecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(DSTypography.body.weight(.semibold))
            .foregroundStyle(DSColor.primary)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(DSColor.primarySoft.opacity(configuration.isPressed ? 0.5 : 0.72))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .stroke(DSColor.primary.opacity(0.25), lineWidth: 1)
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
    }
}

struct DSSectionHeader: View {
    let title: String
    let trailing: String?

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(title)
                .font(DSTypography.section)
                .foregroundStyle(DSColor.textPrimary)
            Spacer()
            if let trailing {
                Text(trailing)
                    .font(DSTypography.caption)
                    .foregroundStyle(DSColor.textSecondary)
            }
        }
    }
}

extension View {
    func dsNavigationBar() -> some View {
        self
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarBackground(DSColor.panelStrong, for: .navigationBar)
    }
}
