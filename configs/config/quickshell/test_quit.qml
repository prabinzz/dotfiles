import QtQuick
import QtQml
import Quickshell

QtObject {
    Component.onCompleted: {
        console.log("Checking IPC instance...")
        if (Quickshell.ipc && Quickshell.ipc.currentInstance) {
             console.log("PID: " + Quickshell.ipc.currentInstance.pid)
        } else {
             console.log("IPC or currentInstance is null")
        }
    }
}
