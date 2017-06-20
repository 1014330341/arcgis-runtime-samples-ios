//
// Copyright 2017 Esri.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//   http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import UIKit
import ArcGIS

enum GridColorPickerToggle: String {
    case On = "On"
    case Off = "Off"
}

enum GridAnimationDirection: String {
    case Forward = "Forward"
    case Backward = "Backward"
}

class DisplayGridSettingsViewController: UIViewController, HorizontalPickerDelegate, HorizontalColorPickerDelegate {
    
    var mapView: AGSMapView!
    var gridTypes = ["LatLong", "MGRS", "UTM", "USNG"]
    var labelPositions = ["Geographic", "Bottom Left", "Bottom Right", "Top Left", "Top Right", "Center", "All Sides"]
    var labelUnits = ["Kilometers Meters", "Meters"]
    var labelFormats = ["Decimal Degrees", "Degrees Minutes Seconds"]
    
    @IBOutlet var settingsView: UIView!
    @IBOutlet var gridTypePicker: HorizontalPicker!
    @IBOutlet var gridColorPicker: HorizontalColorPicker!
    @IBOutlet var gridVisibilitySwitch: UISwitch!
    @IBOutlet var labelVisibilitySwitch: UISwitch!
    @IBOutlet var labelColorPicker: HorizontalColorPicker!
    @IBOutlet var labelFormatPicker: HorizontalPicker!
    @IBOutlet var labelUnitPicker: HorizontalPicker!
    @IBOutlet var labelPositionPicker: HorizontalPicker!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Corner radius for parent view
        self.settingsView.layer.cornerRadius = 10
        
        // Set picker options
        self.gridTypePicker.options = gridTypes
        self.labelPositionPicker.options = self.labelPositions
        self.labelUnitPicker.options = self.labelUnits
        self.labelFormatPicker.options = self.labelFormats
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        //
        // Setup UI Controls
        self.setupUI()
        
        // Set picker delegates
        self.gridTypePicker.delegate = self
        self.labelPositionPicker.delegate = self
        self.labelUnitPicker.delegate = self
        self.labelFormatPicker.delegate = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func setupUI() {
        //
        // Set current grid type
        if self.mapView.grid != nil {
            self.gridTypePicker.selectedIndex = self.gridTypes.index(of: self.currentGridType())!
        }
        
        // Setup other controls
        self.setupOtherUIControls()
    }
    
    private func setupOtherUIControls() {
        //
        // Set values for controls
        if self.mapView.grid != nil {
            self.gridVisibilitySwitch.isOn = (self.mapView.grid?.isVisible)!
            self.labelVisibilitySwitch.isOn = (self.mapView.grid?.labelVisibility)!
            self.labelPositionPicker.selectedIndex = (self.mapView.grid?.labelPosition.rawValue)!
            
            if self.mapView.grid is AGSLatitudeLongitudeGrid {
                self.labelFormatPicker.isEnabled = true
                self.labelFormatPicker.selectedIndex = (self.mapView?.grid as! AGSLatitudeLongitudeGrid).labelFormat.rawValue
                self.labelUnitPicker.isEnabled = false
            }
            else if self.mapView.grid is AGSMGRSGrid {
                self.labelUnitPicker.isEnabled = true
                self.labelUnitPicker.selectedIndex = (self.mapView?.grid as! AGSMGRSGrid).labelUnit.rawValue
                self.labelFormatPicker.isEnabled = false
            }
            else if self.mapView.grid is AGSUTMGrid {
                self.labelUnitPicker.isEnabled = false
                self.labelFormatPicker.isEnabled = false
            }
            else if self.mapView.grid is AGSUSNGGrid {
                self.labelUnitPicker.isEnabled = true
                self.labelUnitPicker.selectedIndex = (self.mapView?.grid as! AGSUSNGGrid).labelUnit.rawValue
                self.labelFormatPicker.isEnabled = false
            }
            
            //self.changeGridColor()
            //self.changeLabelColor()
        }
    }
    
    //MARK: - Actions
    
    @IBAction private func closeAction() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction private func gridVisibilityAction() {
        self.mapView?.grid?.isVisible = self.gridVisibilitySwitch.isOn
    }
    
    @IBAction private func labelVisibilityAction() {
        self.mapView?.grid?.labelVisibility = self.labelVisibilitySwitch.isOn
    }
    
    // MARK: - Helper Functions

    private func currentGridType() -> String {
        if self.mapView.grid is AGSLatitudeLongitudeGrid {
            return "LatLong"
        }
        else if self.mapView.grid is AGSMGRSGrid {
            return "MGRS"
        }
        else if self.mapView.grid is AGSUTMGrid {
            return "UTM"
        }
        else if self.mapView.grid is AGSUSNGGrid {
            return "USNG"
        }
        else {
            return "LatLong"
        }
    }
    
    private func changeGrid() {
        //
        //
        var grid = AGSGrid()
        
        let gridType = self.gridTypePicker.options[self.gridTypePicker.selectedIndex]
        if (gridType == "LatLong") {
            grid = AGSLatitudeLongitudeGrid()
        }
        else if (gridType == "MGRS") {
            grid = AGSMGRSGrid()
        }
        else if (gridType == "UTM") {
            grid = AGSUTMGrid()
        }
        else if (gridType == "USNG") {
            grid = AGSUSNGGrid()
        }
        
        // Set selected grid
        self.mapView?.grid = grid
        
        // Setup other controls
        self.setupOtherUIControls()
    }
    
    // Change the grid color
    private func changeGridColor() {
        if (self.mapView?.grid != nil) {
            let gridLevels = self.mapView?.grid?.levelCount
            for gridLevel in 0..<gridLevels! {
                let lineSymbol = AGSSimpleLineSymbol(style: .solid, color: self.gridColorPicker.selectedColor!, width: CGFloat(gridLevel+2))
                self.mapView?.grid?.setLineSymbol(lineSymbol, forLevel: gridLevel)
            }
        }
    }
    
    // Change the grid label color
    private func changeLabelColor() {
        if (self.mapView?.grid != nil) {
            let gridLevels = self.mapView?.grid?.levelCount
            for gridLevel in 0..<gridLevels! {
                let textSymbol = AGSTextSymbol()
                textSymbol.color = self.labelColorPicker.selectedColor!
                textSymbol.size = 14
                textSymbol.horizontalAlignment = .left
                textSymbol.verticalAlignment = .bottom
                textSymbol.haloColor = UIColor.white
                textSymbol.haloWidth = CGFloat(gridLevel+1)
                self.mapView?.grid?.setTextSymbol(textSymbol, forLevel: gridLevel)
            }
        }
    }
    
    // Change the grid label position
    private func changeLabelPosition() {
        self.mapView.grid?.labelPosition = AGSGridLabelPosition(rawValue: self.labelPositionPicker.selectedIndex)!
    }
    
    // Change the grid label format
    private func changeLabelFormat() {
        if self.mapView.grid is AGSLatitudeLongitudeGrid {
            (self.mapView?.grid as! AGSLatitudeLongitudeGrid).labelFormat = AGSLatitudeLongitudeGridLabelFormat(rawValue: self.labelFormatPicker.selectedIndex)!
        }
    }
    
    // Change the grid label unit
    private func changeLabelUnit() {
        if self.mapView.grid is AGSMGRSGrid {
            (self.mapView?.grid as! AGSMGRSGrid).labelUnit = AGSMGRSGridLabelUnit(rawValue: self.labelUnitPicker.selectedIndex)!
        }
        else if self.mapView.grid is AGSUSNGGrid {
            (self.mapView?.grid as! AGSUSNGGrid).labelUnit = AGSUSNGGridLabelUnit(rawValue: self.labelUnitPicker.selectedIndex)!
        }
    }
    
    // MARK: Horizontal Picker Delegate
    
    internal func horizontalPicker(_ horizontalPicker: HorizontalPicker, didUpdateSelectedIndex index: Int) {
        if horizontalPicker == self.gridTypePicker {
            self.changeGrid()
        }
        else if horizontalPicker == self.labelPositionPicker {
            self.changeLabelPosition()
        }
        else if horizontalPicker == self.labelFormatPicker {
            self.changeLabelFormat()
        }
        else if horizontalPicker == self.labelUnitPicker {
            self.changeLabelUnit()
        }
    }
    
//    func horizontalColorPicker(_ horizontalColorPicker: HorizontalColorPicker, didUpdateSelectedIndex index: Int) {
//        <#code#>
//    }
}