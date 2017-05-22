/**
* Copyright 2013 Aleix Quintana
*
* This program is free software; you can redistribute it and/or
* modify it under the terms of the GNU General Public License as
* published by the Free Software Foundation; either version 2 of
* the License or (at your option) version 3 or any later version
* accepted by the membership of KDE e.V. (or its successor approved
* by the membership of KDE e.V.), which shall act as a proxy
* defined in Section 14 of version 3 of the license.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
* GNU General Public License for more details.
*
* You should have received a copy of the GNU General Public License
* along with this program. If not, see <http://www.gnu.org/licenses/>.
*/
import QtQuick 2.1
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.extras 2.0
import QtQuick.Layouts 1.1

PlasmaComponents.Button {
    id: view
    //anchors.fill: parent
    anchors.horizontalCenter: parent.horizontalCenter
    anchors.verticalCenter: parent.verticalCenter
    Layout.fillWidth: true
    iconSource: "feed-subscribe"

    //TODO: Use this to detect if we should be iconized or full size
    function isConstrained() {
        return (plasmoid.formFactor == Vertical
                || plasmoid.formFactor == Horizontal)
    }
    Component.onCompleted: {
        console.log("Lite Grip Loaded")
    }
    SwipeArea {
        anchors.fill: parent
        property QtObject dashWindow: null
        onSwipeDown: {
            main.togglePopup()
        }
        onSwipeUp: {
            main.togglePopup()
        }
    }
    PlasmaCore.ToolTipArea {
        id: tooltip
        anchors.fill: parent
        mainText : i18n("Tiny Tiny RSS client")
        subText : i18n("Show the ttrss and pocket feeds")
        icon : plasmoid.configuration.icon
    }
}
