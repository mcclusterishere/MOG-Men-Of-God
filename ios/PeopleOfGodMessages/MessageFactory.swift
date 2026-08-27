import Messages
import UIKit

enum MessageFactory {
    static func makeMessage(payload: MessagePayload, session: MSSession) -> MSMessage {
        let layout = MSMessageTemplateLayout()
        layout.image = MessageCardRenderer.image(for: payload)
        layout.caption = payload.cardTitle
        layout.subcaption = payload.cardSubtitle
        layout.trailingCaption = "\(payload.showingUpCount) showing up"

        let message = MSMessage(session: session)
        message.layout = layout
        message.url = payload.encodedURL()
        message.summaryText = payload.summaryText
        return message
    }
}

private enum MessageCardRenderer {
    static func image(for payload: MessagePayload) -> UIImage {
        let size = CGSize(width: 600, height: 360)
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        format.opaque = true

        return UIGraphicsImageRenderer(size: size, format: format).image { context in
            let cg = context.cgContext
            UIColor(red: 0.02, green: 0.05, blue: 0.10, alpha: 1).setFill()
            cg.fill(CGRect(origin: .zero, size: size))

            let glow = UIBezierPath(ovalIn: CGRect(x: 390, y: -130, width: 340, height: 340))
            UIColor(red: 0.78, green: 0.63, blue: 0.31, alpha: 0.11).setFill()
            glow.fill()

            drawMark(in: cg, center: CGPoint(x: 68, y: 66), radius: 31)

            draw(
                "PEOPLE OF GOD",
                in: CGRect(x: 116, y: 39, width: 420, height: 26),
                font: .systemFont(ofSize: 19, weight: .bold),
                color: UIColor(red: 0.91, green: 0.78, blue: 0.48, alpha: 1),
                tracking: 2.2
            )
            draw(
                payload.activity.title.uppercased(),
                in: CGRect(x: 116, y: 69, width: 420, height: 22),
                font: .systemFont(ofSize: 14, weight: .semibold),
                color: UIColor(red: 0.77, green: 0.76, blue: 0.70, alpha: 1),
                tracking: 1.2
            )

            draw(
                payload.cardTitle,
                in: CGRect(x: 42, y: 130, width: 516, height: 62),
                font: .systemFont(ofSize: 36, weight: .bold),
                color: UIColor(red: 0.96, green: 0.93, blue: 0.84, alpha: 1)
            )
            draw(
                String(payload.cardSubtitle.prefix(150)),
                in: CGRect(x: 42, y: 205, width: 516, height: 70),
                font: .systemFont(ofSize: 21, weight: .regular),
                color: UIColor(red: 0.77, green: 0.76, blue: 0.70, alpha: 1)
            )

            let pill = UIBezierPath(roundedRect: CGRect(x: 42, y: 294, width: 240, height: 40), cornerRadius: 20)
            UIColor(red: 0.78, green: 0.63, blue: 0.31, alpha: 0.16).setFill()
            pill.fill()
            draw(
                "\(payload.showingUpCount) SHOWING UP",
                in: CGRect(x: 63, y: 303, width: 206, height: 25),
                font: .systemFont(ofSize: 15, weight: .bold),
                color: UIColor(red: 0.91, green: 0.78, blue: 0.48, alpha: 1),
                tracking: 0.8
            )
        }
    }

    private static func drawMark(in context: CGContext, center: CGPoint, radius: CGFloat) {
        context.saveGState()
        context.setStrokeColor(UIColor(red: 0.78, green: 0.63, blue: 0.31, alpha: 0.9).cgColor)
        context.setLineWidth(3)
        context.strokeEllipse(in: CGRect(x: center.x - radius, y: center.y - radius, width: radius * 2, height: radius * 2))

        context.setFillColor(UIColor(red: 0.96, green: 0.93, blue: 0.84, alpha: 1).cgColor)
        context.fill(CGRect(x: center.x - 2.5, y: center.y - 17, width: 5, height: 34))
        context.fill(CGRect(x: center.x - 11, y: center.y - 5, width: 22, height: 5))
        context.restoreGState()
    }

    private static func draw(
        _ text: String,
        in rect: CGRect,
        font: UIFont,
        color: UIColor,
        tracking: CGFloat = 0
    ) {
        let style = NSMutableParagraphStyle()
        style.lineBreakMode = .byTruncatingTail
        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: color,
            .kern: tracking,
            .paragraphStyle: style
        ]
        NSString(string: text).draw(in: rect, withAttributes: attributes)
    }
}
