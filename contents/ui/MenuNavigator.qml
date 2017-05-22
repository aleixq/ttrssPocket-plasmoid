/**
*
*    Copyright (C) 2012 Aleix Quintana
*
*    This program is free software; you can redistribute it and/or modify
*    it under the terms of the GNU General Public License as published by
*    the Free Software Foundation; either version 3 of the License, or
*    (at your option) any later version.
*
*    This program is distributed in the hope that it will be useful,
*    but WITHOUT ANY WARRANTY; without even the implied warranty of
*    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
*    GNU General Public License for more details.
*
*    You should have received a copy of the GNU General Public License
*    along with this program; if not, see <http://www.gnu.org/licenses/>.
*
*/
import QtQuick 2.0
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.core 2.0 as PlasmaCore

Item {
    property alias title: titleText.text
    property int currentCID: 0
    id: header
    signal back
    signal titleClicked
    PlasmaComponents.ToolButton {
        id: backButton
        anchors.top: parent.top
        anchors.left: parent.left
        height: parent.height
        width: parent.width * 0.25
        text: ""
        iconSource: "draw-arrow-back"
        onClicked: {
            header.visible = false
            header.back()
        }
    }
    Text {
        id: titleText
        anchors.left: backButton.right
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        font.pointSize: 20
        fontSizeMode: Text.Fit
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        minimumPointSize: 8
        color: PlasmaCore.ColorScope.textColor
        MouseArea {
            anchors.fill: parent
            onClicked: header.titleClicked()
        }
    }
    function setTitle(name) {
        header.title = name
        header.visible = true
    }
}
