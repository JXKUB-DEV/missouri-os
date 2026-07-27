import QtQuick
import org.kde.kirigami 2 as Kirigami

Rectangle {
    id: root
    color: "#08090d"

    // Wird von Plasma während des Starts aktualisiert
    property int stage

    Column {
        anchors.centerIn: parent
        spacing: Kirigami.Units.gridUnit * 1.5

        Image {
            anchors.horizontalCenter: parent.horizontalCenter
            width: Kirigami.Units.gridUnit * 10
            height: width
            source: "file:///usr/share/pixmaps/missouri-os-logo.png"
            fillMode: Image.PreserveAspectFit
            smooth: true
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "MISSOURI OS"
            color: "white"
            font.pixelSize: Kirigami.Units.gridUnit * 2
            font.bold: true
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "by JXKUB"
            color: "#b8b8c0"
            font.pixelSize: Kirigami.Units.gridUnit
        }

        Rectangle {
            anchors.horizontalCenter: parent.horizontalCenter
            width: Kirigami.Units.gridUnit * 8
            height: 3
            radius: 2
            color: "#353641"

            Rectangle {
                height: parent.height
                radius: parent.radius
                color: "white"
                width: parent.width * Math.min(root.stage / 5, 1)

                Behavior on width {
                    NumberAnimation {
                        duration: 250
                    }
                }
            }
        }
    }
}
