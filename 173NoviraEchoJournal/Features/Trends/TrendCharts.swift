//
//  TrendCharts.swift
//  173NoviraEchoJournal
//

import SwiftUI

struct TrendLineChart: View {
    let values: [Double]
    let stroke: Color

    var body: some View {
        Canvas { context, size in
            guard !values.isEmpty else { return }
            let minValue = values.min() ?? 0
            let maxValue = values.max() ?? 1
            let span = max(maxValue - minValue, 0.0001)
            if values.count == 1, let value = values.first {
                let normalized = (value - minValue) / span
                let y = size.height - CGFloat(normalized) * size.height
                let rect = CGRect(x: size.width / 2 - 5, y: y - 5, width: 10, height: 10)
                context.fill(Path(ellipseIn: rect), with: .color(stroke))
                return
            }
            var path = Path()
            for (index, value) in values.enumerated() {
                let progress = CGFloat(index) / CGFloat(max(values.count - 1, 1))
                let x = progress * size.width
                let normalized = (value - minValue) / span
                let y = size.height - CGFloat(normalized) * size.height
                let point = CGPoint(x: x, y: y)
                if index == 0 {
                    path.move(to: point)
                } else {
                    path.addLine(to: point)
                }
            }
            context.stroke(path, with: .color(stroke), style: StrokeStyle(lineWidth: 3, lineJoin: .round))
        }
        .frame(height: 160)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.appSurface.opacity(0.45))
        )
    }
}

struct TrendBarChart: View {
    let values: [Double]
    let fill: Color

    var body: some View {
        Canvas { context, size in
            guard !values.isEmpty else { return }
            let maxValue = max(values.max() ?? 1, 0.0001)
            let barWidth = size.width / CGFloat(values.count) * 0.65
            for (index, value) in values.enumerated() {
                let x = (CGFloat(index) + 0.5) / CGFloat(values.count) * size.width
                let height = CGFloat(value / maxValue) * size.height
                let rect = CGRect(x: x - barWidth / 2, y: size.height - height, width: barWidth, height: height)
                let path = Path(roundedRect: rect, cornerRadius: 6)
                context.fill(path, with: .color(fill.opacity(0.85)))
            }
        }
        .frame(height: 160)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.appSurface.opacity(0.45))
        )
    }
}
