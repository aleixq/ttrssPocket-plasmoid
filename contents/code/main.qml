/*
 *   Author: kinta <kinta@communia.org>
 *   Date: ds. de nov. 1 2014, 18:01:51
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU Library General Public License as
 *   published by the Free Software Foundation; either version 2 or
 *   (at your option) any later version.
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU General Public License for more details
 *
 *   You should have received a copy of the GNU Library General Public
 *   License along with this program; if not, write to the
 *   Free Software Foundation, Inc.,
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

import QtQuick 2.1
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.core 2.0 as PlasmaCore
import QtQuick.Layouts 1.1
import org.kde.plasma.extras 2.0 as PlasmaExtras
import org.kde.plasma.plasmoid 2.0
import QtQuick.Controls 1.4

import "../ui/"

Item {
    id: main
    Plasmoid.switchWidth: units.gridUnit * 14
    Plasmoid.switchHeight: units.gridUnit * 10
    PlasmaCore.Svg {
        id: lineSvg
        imagePath: "widgets/line"

        property int horLineHeight
        property int vertLineWidth
    }

    function isConstrained() {
        return (Plasmoid.formFactor == PlasmaCore.Types.Vertical || Plasmoid.formFactor == PlasmaCore.Types.Horizontal);
    }
    property int currentIndex: 0
    Plasmoid.fullRepresentation: FullRepresentation {} 
    Plasmoid.compactRepresentation: LiteGrip { }
    //Plasmoid.preferredRepresentation: Plasmoid.FullRepresentation // Useful when debugging with plasmawindowed
    Plasmoid.preferredRepresentation: isConstrained() ? Plasmoid.compactRepresentation : Plasmoid.fullRepresentation //If Smart size preferred
    onCurrentIndexChanged: {
        slide_anim.to = - root.width * currentIndex
        slide_anim.start()
    }
    Component.onCompleted: {}
    function togglePopup() {
        console.debug("Toggling!")
        console.debug("Post Resize!")

        if (!plasmoid.expanded) {
            plasmoid.expanded = true
        } else {
            if (main.expandedTask == null) {
                Plasmoid.fullRepresentationItem.stopWebLoader()
                plasmoid.expanded = false
            }
        }
    }

    Action {
        shortcut: "Escape"
        onTriggered: plasmoid.expanded = false
    }
    
    PlasmaCore.ToolTipArea {
        id: tooltip
        anchors.fill: parent
        mainText : i18n("Tiny Tiny RSS client")
        subText : i18n("Show the ttrss and pocket feeds")
        icon : plasmoid.configuration.icon

        MouseArea {
            id: mouseArea
            anchors.fill: parent
            onClicked: activate()
        }
    }
}
