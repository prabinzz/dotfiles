import QtQuick
import QtQuick.Layouts
import QtQml
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

QtObject {
    id: root

    property color c_bg: "#EB1E1E2E"
    property color c_fg: "#CDD6F4"
    property color c_primary: "#CBA6F7"
    property color c_secondary: "#585B70"
    property color c_surface: "#99313244"
    property color c_highlight: "#26CBA6F7"
    property color c_alert: "#F38BA8"
    property color c_border: "#14FFFFFF"

    property Process themeLoader: Process {
        command: ["cat", Quickshell.env("HOME") + "/.config/colors.json"]
        stdout: StdioCollector {
            onStreamFinished: {
                if (this.text.trim() !== "") {
                    try {
                        var colors = JSON.parse(this.text);
                        root.c_bg = colors.background.replace("#", "#EB");
                        root.c_fg = colors.foreground;
                        root.c_primary = colors.primary;
                        root.c_secondary = colors.secondary;
                        root.c_surface = colors.secondary + "99"; 
                        root.c_highlight = colors.primary + "26";
                        root.c_alert = colors.alert;
                    } catch(e) {
                    }
                }
            }
        }
    }

    property ListModel sinksModel: ListModel { id: sharedSinks }
    property string currentDefaultSink: ""
    property bool dataReady: false
    property int focusedIndex: -1

    property Process pactlList: Process {
        command: ["pactl", "-f", "json", "list", "sinks"]
        stdout: StdioCollector {
            onStreamFinished: root.parseJson(this.text)
        }
    }
    
    property Process defaultSinkGetter: Process {
        command: ["pactl", "get-default-sink"]
        stdout: StdioCollector {
            onStreamFinished: root.updateDefault(this.text.trim())
        }
    }

    property Process actionProc: Process {}
    
    property Process exitProc: Process {
        command: ["pkill", "-f", "quickshell.*AudioSelector.qml"]
    }

    function quitApp() {
        exitProc.running = true
    }

    function reload() {
        if (themeLoader.running) themeLoader.running = false
        themeLoader.running = true

        if (pactlList.running) pactlList.running = false
        pactlList.running = true
        
        if (defaultSinkGetter.running) defaultSinkGetter.running = false
        defaultSinkGetter.running = true
    }

    function parseJson(jsonText) {
        try {
            var data = JSON.parse(jsonText)
            var newItems = []
            for (var i = 0; i < data.length; i++) {
                var s = data[i];
                var vol = 0;
                if (s.volume) {
                    for (var key in s.volume) {
                        if (s.volume[key].value_percent) {
                            vol = parseInt(s.volume[key].value_percent.replace("%", ""));
                            break;
                        }
                    }
                }
                newItems.push({
                    "name": s.name,
                    "description": s.description || s.name,
                    "volume": vol,
                    "isMuted": s.mute,
                    "isDefault": (s.name === root.currentDefaultSink)
                })
            }

            if (newItems.length > 0) {
                sharedSinks.clear()
                for (var j = 0; j < newItems.length; j++) {
                    sharedSinks.append(newItems[j])
                    if (newItems[j].isDefault && root.focusedIndex === -1) {
                        root.focusedIndex = j
                    }
                }
                root.dataReady = true
            }
        } catch(e) {}
    }

    function updateDefault(name) {
        root.currentDefaultSink = name
        for(var i=0; i<sharedSinks.count; i++) {
            var isDef = sharedSinks.get(i).name === name
            sharedSinks.setProperty(i, "isDefault", isDef)
            if (isDef && root.focusedIndex === -1) root.focusedIndex = i
        }
    }

    function setDefault(name) {
        root.currentDefaultSink = name
        updateDefault(name)
        actionProc.command = ["pactl", "set-default-sink", name]
        actionProc.running = true
        reloadTimer.start()
    }

    property Timer reloadTimer: Timer {
        interval: 200
        onTriggered: root.reload()
    }

    function setVolume(name, vol) {
        var boundedVol = Math.max(0, Math.min(100, vol))
        actionProc.command = ["pactl", "set-sink-volume", name, boundedVol + "%"]
        actionProc.running = true
        for(var i=0; i<sharedSinks.count; i++) {
            if (sharedSinks.get(i).name === name) {
                sharedSinks.setProperty(i, "volume", boundedVol)
            }
        }
    }

    property var winGenerator: Instantiator {
        model: Quickshell.screens
        delegate: PanelWindow {
            id: panelWin
            screen: modelData
            visible: root.dataReady
            
            anchors.top: true
            anchors.right: true
            margins.top: 34
            margins.right: 12

            WlrLayershell.layer: WlrLayershell.Overlay
            WlrLayershell.namespace: "quickshell-audio"
            WlrLayershell.keyboardFocus: WlrLayershell.OnDemand

            implicitWidth: 320
            implicitHeight: layout.height + 24

            color: "transparent"

            Rectangle {
                id: mainRect
                anchors.fill: parent
                color: c_bg
                radius: 16
                border.color: c_border
                border.width: 1
                
                focus: true
                
                Shortcut { sequence: "Escape"; onActivated: root.quitApp() }
                Shortcut { sequence: "J"; onActivated: root.focusedIndex = Math.min(sharedSinks.count - 1, root.focusedIndex + 1) }
                Shortcut { sequence: "K"; onActivated: root.focusedIndex = Math.max(0, root.focusedIndex - 1) }
                Shortcut {
                    sequences: ["Return", "Enter", "Space"]
                    onActivated: {
                        if (root.focusedIndex >= 0 && root.focusedIndex < sharedSinks.count) {
                            root.setDefault(sharedSinks.get(root.focusedIndex).name)
                        }
                    }
                }

                onVisibleChanged: { if (visible) mainRect.forceActiveFocus() }

                opacity: root.dataReady ? 1.0 : 0.0
                Behavior on opacity { NumberAnimation { duration: 200 } }

                Column {
                    id: layout
                    width: parent.width
                    spacing: 4
                    padding: 12
                    
                    Item {
                        width: parent.width - 24
                        height: 30
                        anchors.horizontalCenter: parent.horizontalCenter
                        
                        Text {
                            text: "Audio Control"
                            color: c_fg
                            font.bold: true
                            font.pixelSize: 15
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.left: parent.left
                        }

                        Rectangle {
                            width: 26; height: 26
                            radius: 13
                            color: closeMouse.containsMouse ? "#1AFFFFFF" : "transparent"
                            anchors.right: parent.right
                            anchors.verticalCenter: parent.verticalCenter
                            
                            Text {
                                text: "󰅖"
                                color: closeMouse.containsMouse ? c_alert : c_secondary
                                font.family: "JetBrainsMono Nerd Font"
                                font.pixelSize: 18
                                anchors.centerIn: parent
                            }
                            
                            MouseArea {
                                id: closeMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                onClicked: root.quitApp()
                            }
                        }
                    }

                    Item { width: 1; height: 4 }

                    Rectangle {
                        width: parent.width - 24
                        height: 1
                        color: c_border
                        anchors.horizontalCenter: parent.horizontalCenter
                    }

                    Item { width: 1; height: 8 }

                    Repeater {
                        model: sharedSinks
                        delegate: Rectangle {
                            id: sinkDelegate
                            width: 296
                            height: 68
                            anchors.horizontalCenter: parent.horizontalCenter
                            
                            property bool isHighlighted: (index === root.focusedIndex || itemMouseArea.containsMouse)
                            
                            color: isDefault ? c_highlight : (isHighlighted ? c_surface : "transparent")
                            radius: 12
                            border.width: 1
                            border.color: isDefault ? c_primary : (isHighlighted ? c_border : "transparent")
                            
                            Behavior on color { ColorAnimation { duration: 150 } }

                            MouseArea {
                                id: itemMouseArea
                                anchors.fill: parent
                                hoverEnabled: true
                                onEntered: root.focusedIndex = index
                                onClicked: root.setDefault(name)
                                
                                onWheel: (wheel) => {
                                    var delta = wheel.angleDelta.y > 0 ? 4 : -4
                                    root.setVolume(name, volume + delta)
                                }
                            }
                            
                            Row {
                                anchors.fill: parent
                                anchors.margins: 10
                                spacing: 12

                                Rectangle {
                                    width: 36; height: 36
                                    radius: 18
                                    color: isDefault ? c_primary : c_secondary
                                    opacity: isDefault ? 1.0 : 0.4
                                    anchors.verticalCenter: parent.verticalCenter

                                    Text { 
                                        text: isMuted ? "󰖁" : "󰓃"
                                        color: isDefault ? c_bg : c_fg
                                        font.family: "JetBrainsMono Nerd Font"
                                        font.pixelSize: 18
                                        anchors.centerIn: parent
                                    }
                                }

                                Column {
                                    width: parent.width - 48 - 12
                                    spacing: 6
                                    anchors.verticalCenter: parent.verticalCenter
                                    
                                    Text { 
                                        text: description
                                        color: c_fg
                                        elide: Text.ElideRight
                                        width: parent.width
                                        font.bold: isDefault
                                        font.pixelSize: 13
                                    }
                                    
                                    Rectangle {
                                        width: parent.width
                                        height: 4
                                        color: c_border
                                        radius: 2
                                        
                                        Rectangle {
                                            width: parent.width * (volume / 100)
                                            height: parent.height
                                            color: isDefault ? c_primary : c_fg
                                            radius: 2
                                            
                                            Rectangle {
                                                width: 8; height: 8
                                                radius: 4
                                                color: isDefault ? c_primary : c_fg
                                                anchors.verticalCenter: parent.verticalCenter
                                                anchors.right: parent.right
                                                anchors.rightMargin: -4
                                                visible: sinkDelegate.isHighlighted
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    Component.onCompleted: reload()
}