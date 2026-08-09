import AppKit

/// Slider embedded in the status menu for manual width tuning.
final class WidthSliderView: NSView {
    private let slider = NSSlider()
    private let valueLabel = NSTextField(labelWithString: "")
    var onChange: ((CGFloat) -> Void)?

    init(width: CGFloat, enabled: Bool) {
        super.init(frame: NSRect(x: 0, y: 0, width: 260, height: 40))

        let caption = NSTextField(labelWithString: "Width")
        caption.font = .menuFont(ofSize: NSFont.smallSystemFontSize)
        caption.textColor = .secondaryLabelColor
        caption.frame = NSRect(x: 20, y: 20, width: 60, height: 14)

        valueLabel.font = .monospacedDigitSystemFont(ofSize: NSFont.smallSystemFontSize, weight: .regular)
        valueLabel.textColor = .secondaryLabelColor
        valueLabel.alignment = .right
        valueLabel.frame = NSRect(x: 170, y: 20, width: 70, height: 14)

        slider.minValue = Double(Preferences.widthRange.lowerBound)
        slider.maxValue = Double(Preferences.widthRange.upperBound)
        slider.doubleValue = Double(width)
        slider.isContinuous = true
        slider.target = self
        slider.action = #selector(sliderChanged)
        slider.isEnabled = enabled
        slider.frame = NSRect(x: 20, y: 2, width: 220, height: 18)

        caption.alphaValue = enabled ? 1 : 0.4
        valueLabel.alphaValue = enabled ? 1 : 0.4

        addSubview(caption)
        addSubview(valueLabel)
        addSubview(slider)
        updateLabel()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) is not used") }

    @objc private func sliderChanged() {
        updateLabel()
        onChange?(CGFloat(slider.doubleValue))
    }

    private func updateLabel() {
        valueLabel.stringValue = "\(Int(slider.doubleValue.rounded())) pt"
    }
}
