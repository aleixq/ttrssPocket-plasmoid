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
import org.kde.plasma.extras 2.0 as PlasmaExtras
import org.kde.plasma.core 2.0 as PlasmaCore
import QtQuick.Layouts 1.1

Item {
    property string titleText:""
    anchors.top: parent.top
    anchors.bottom: parent.bottom
    property var iconSource
    PlasmaCore.IconItem {
        id: iconTitle
        width:units.iconSizes.large
        height: units.iconSizes.large
        source: iconSource
        anchors.top:parent.top
        anchors.horizontalCenter:toolbarTitle.horizontalCenter
    }
    PlasmaExtras.Heading {
        text: titleText
        color: theme.textColor
        id: toolbarTitle
        level:4
        anchors.top: iconTitle.bottom
    }
}
