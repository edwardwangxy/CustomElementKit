//
//  CustomPickerView.swift
//  CalmNoise
//
//  Created by JIAZI XUAN on 2/9/21.
//

import SwiftUI

public struct CustomPickerView: UIViewRepresentable {
    var data: [[String]]
    @Binding var selections: Int
    var textColor: UIColor = UIColor.black
    var textFont: UIFont = UIFont.systemFont(ofSize: 20)
    var rowHeight: CGFloat = 40
    var selectorHeight: CGFloat = 40
    var cornerRadius: CGFloat = 20
    
    public init(data: [[String]], selections: Binding<Int>, font: UIFont = UIFont.systemFont(ofSize: 20), textColor: UIColor = UIColor.black, rowHeight: CGFloat = 40, selectorHeight: CGFloat = 40, cornerRadius: CGFloat = 20) {
        self.data = data
        self._selections = selections
        self.textFont = font
        self.textColor = textColor
        self.rowHeight = rowHeight
        self.selectorHeight = selectorHeight
        self.cornerRadius = cornerRadius
    }
    //makeCoordinator()
    public func makeCoordinator() -> CustomPickerView.Coordinator {
        Coordinator(self)
    }

    //makeUIView(context:)
    public func makeUIView(context: UIViewRepresentableContext<CustomPickerView>) -> UIPickerView {
        let picker = UIPickerView(frame: .zero)
        picker.dataSource = context.coordinator
        picker.delegate = context.coordinator
        return picker
    }

    //updateUIView(_:context:)
    public func updateUIView(_ view: UIPickerView, context: UIViewRepresentableContext<CustomPickerView>) {
//        for i in 0...(self.selections.count - 1) {
//            view.selectRow(self.selections[i], inComponent: i, animated: false)
//        }
    }

    public class Coordinator: NSObject, UIPickerViewDataSource, UIPickerViewDelegate {
        var parent: CustomPickerView

        //init(_:)
        init(_ pickerView: CustomPickerView) {
            self.parent = pickerView
        }

        public func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
            return self.parent.rowHeight
        }
        
        public func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
            
            if pickerView.subviews.count >= 2 {
                let pickerFrame = pickerView.subviews[1].bounds
                let newFrame = CGRect(x: 0, y: (self.parent.rowHeight - self.parent.selectorHeight) / 4, width: pickerFrame.width, height: self.parent.selectorHeight)
                let mask = CAShapeLayer()
                // Set its frame to the view bounds
                mask.frame = newFrame
                // Build its path with a smoothed shape
                mask.path = UIBezierPath(roundedRect: newFrame, cornerRadius: self.parent.cornerRadius).cgPath
                // Apply the mask to the view
                pickerView.subviews[1].layer.mask = mask
            }
            
            var pickerLabel: UILabel? = (view as? UILabel)
            if pickerLabel == nil {
                pickerLabel = UILabel()
                pickerLabel?.font = self.parent.textFont
                pickerLabel?.textAlignment = .center
            }
            pickerLabel?.text = self.parent.data[component][row]
            pickerLabel?.textColor = self.parent.textColor

            return pickerLabel!
        }

        //numberOfComponents(in:)
        public func numberOfComponents(in pickerView: UIPickerView) -> Int {
            return self.parent.data.count
        }

        //pickerView(_:numberOfRowsInComponent:)
        public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
            return self.parent.data[component].count
        }

        //pickerView(_:titleForRow:forComponent:)
        public func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
            return self.parent.data[component][row]
        }

        //pickerView(_:didSelectRow:inComponent:)
        public func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
            self.parent.selections = row
        }
    }
}


