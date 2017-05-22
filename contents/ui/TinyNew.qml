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
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.extras 2.0 as PlasmaExtras
import QtQuick.Layouts 1.1
import QtQuick.Controls 1.4
import QtGraphicalEffects 1.0
import "../code/ttrss.js" as TTRSS

Rectangle {
    id: newItem

    property bool newUnread

    signal requestDialog
    //string title, string bodyContent,variant newData)
    signal requestOp(string op, int hlID, int field)
    signal toPocket
    signal read
    border.width: plasmoid.configuration.shadows ? 0 : 1
    border.color: theme.textColor
    clip: true
    Component.onCompleted: {

        if (attachments.count > 0) {
            if ((/^image/).test(attachments.get(0).content_type)) {
                icon.source = attachments.get(0).content_url
                icon.width = 60
                icon.height = parent.height / 3
                console.log("ITEM IMAGE:" + attachments.get(
                                0).content_url + " with size: " + attachments.get(
                                0).height)
            }
        } else {
            var img = TTRSS.firstImg(content)
            if (img) {
                icon.source = img
                icon.width = 60
                icon.height = parent.height / 3
                console.log("ITEM IMAGE:" + attachments.get(
                                0).content_url + " with size: " + attachments.get(
                                0).height)
            }
        }
    }
    MouseArea {
            anchors.fill: parent
            onClicked: {
                newItem.newUnread = false
                newItem.read()
                console.log("Requesting from New.qml:" + newItem.title)
                newItem.requestDialog()
            }
    }
    RowLayout{
        id: links
        anchors{
            left: parent.left
            right: parent.right
            top: parent.top
            leftMargin: units.gridUnit
            rightMargin: units.gridUnit / 3
            topMargin: units.gridUnit / 3
        }
        PlasmaComponents.Label {
            id: rssItemSource
            horizontalAlignment: Text.AlignLeft
            text: feed_title
            wrapMode: Text.WordWrap
            font.pointSize: 8
            Layout.fillWidth:true
            elide: Text.ElideRight
            color: newItem.newUnread ? theme.textColor : "grey"
        }

        PlasmaCore.IconItem {
            id: pocket
            Layout.minimumWidth: units.iconSizes.medium
            Layout.maximumWidth: units.iconSizes.medium
            Layout.minimumHeight: units.iconSizes.medium
            Layout.maximumHeight: units.iconSizes.medium
            source: "download-later"
            opacity: newItem.newUnread ? 1 : 0.2

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked:  newItem.toPocket()
            }
        }
        PlasmaCore.IconItem {
            id: star
            Layout.minimumWidth: units.iconSizes.medium
            Layout.maximumWidth: units.iconSizes.medium
            Layout.minimumHeight: units.iconSizes.medium
            Layout.maximumHeight: units.iconSizes.medium
            source: marked ? "rating" : "draw-star"
            property string field: "star"
            opacity: newItem.newUnread ? 1 : 0.2

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked:  {
                    if (setStarCondenser.running == false) {
                        setStarCondenser.start()
                    }
                }
            }
        }
        /* When toolButton uses gridUnit this will be the way:
        PlasmaComponents.ToolButton {
            id: pocket
            iconSource: "download-later"
            width: units.gridUnit * 12
            height: units.gridUnit * 12

            onClicked: newItem.toPocket()
        }
        */
    }    
    ColumnLayout {
        id: mainLayout
        anchors {
            top: links.bottom
            left: parent.left
            right: parent.right
            bottom:parent.bottom
            margins: units.gridUnit
        }

        PlasmaExtras.Title {
            id: rssItemTitle
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignJustify
            wrapMode: Text.Wrap
            text: title 
            fontSizeMode: Text.Fit
            color: newItem.newUnread ? theme.textColor : "grey"
        }

        PlasmaComponents.Label {
            property var locale: Qt.locale()
            id: rssItemMeta
            Layout.fillWidth: true
            wrapMode: Text.Wrap
            color: newItem.newUnread ? theme.textColor : "grey"
            text: {
                var time = new Date(0)
                time.setUTCSeconds(updated)
                return i18n("By") + " <b>" + author + "</b> " +i18n("on") + " " + time
            }
            font: theme.smallestFont
        }

        RowLayout {
            anchors{
                left: parent.left
                right: parent.right
            }
            Image{
                id: icon
                Layout.fillWidth: true
                fillMode: Image.PreserveAspectCrop
            }
        }
        Text {
        
            id: rssItemDesc
            text: excerpt
            //             elide : Text.EllideRight
            textFormat: Text.StyledText
            wrapMode: Text.WordWrap
            color: newItem.newUnread ? theme.textColor : "grey"
            font.pointSize: 10
        }
    }

    Timer {
        //Prevents obsessive and reiterative clicks as some touch interfaces has poor stability with this
        id: setStarCondenser
        interval: 200
        running: false
        repeat: false
        onTriggered: {
            requestOp("updateArticle", id, TTRSS.Headline.Starred)
            star.iconSource = star.iconSource == "rating" ? "draw-star" : "rating"
        }
    }
    Timer {
        //Prevents obsessive and reiterative clicks as some touch interfaces has poor stability with this
        id: readItLater
        interval: 200
        running: false
        repeat: false
        onTriggered: {
            toPocket()
        }
    }
    layer.enabled: plasmoid.configuration.shadows
    layer.effect: DropShadow {
        horizontalOffset: 0
        verticalOffset: 0
        radius: units.gridUnit/1.6
        samples: 12
        color: Qt.rgba(0, 0, 0, 0.5)
    }    
}
