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
import QtQuick.Controls 2.0
import QtGraphicalEffects 1.0

Rectangle {
    id: newItem
    clip:true
    border.width: plasmoid.configuration.shadows ? 0 : 1
    border.color: theme.textColor    
    property string newName
    property string newDescription
    property string newTitle
    property string newContent
    property string newSummary
    property string newUpdated
    property string newSource
    property string newAuthor
    property string newLink
    property string newMedia
    property string newMediaType
    property string newImage
    property string newResolvedUrl
    property string newFavorite

    signal requestDialog

    Component.onCompleted: {
        //         if (newMedia != undefined && (/^image/).test(newMediaType)) {
        //             icon.source = newMedia
        //             icon.width = newItem.height
        //             icon.height = newItem.height
        //             console.log("ITEM IMAGE:" + newMedia + " with size:" + newItem.height)
        //         }
        if (newImage != undefined) {
            icon.source = newImage
        }
    }
    Item {
        id:swipeWrapper
        z: 1
        clip: true
        anchors {
            fill: parent
            margins: units.gridUnit
        }
        SwipeView {
            id: paralNew
            anchors {
                fill: parent
            }
            spacing: units.gridUnit
            Pane {
                background: Rectangle {
                    anchors.fill: parent
                    color: newItem.color
                }
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        newItem.requestDialog()
                    }
                }
                ColumnLayout {
                    id: mainLayout
                    anchors {
                        top: parent.top
                        left: parent.left
                        right: parent.right
                        bottom: parent.bottom
                    }

                    PlasmaExtras.Title {
                        id: rssItemTitle
                        Layout.fillWidth: true
                        horizontalAlignment: Text.AlignJustify
                        wrapMode: Text.Wrap
                        text: newItem.newTitle
                        fontSizeMode: Text.Fit
                        color: theme.textColor
                    }

                    PlasmaComponents.Label {
                        id: rssItemSource
                        Layout.fillWidth: true
                        text: newResolvedUrl
                        font.pointSize: theme.defaultFont.pointSize / 2
                        wrapMode: Text.Wrap
                        color: theme.textColor
                    }

                    PlasmaComponents.Label {
                        id: rssItemMeta
                        font.pointSize: theme.defaultFont.pointSize / 2
                        color: theme.textColor
                        wrapMode: Text.Wrap
                        Layout.fillWidth: true
                        text: {
                            var time = new Date(0)
                            time.setUTCSeconds(newUpdated)
                            return i18n("on") + " " + time
                        }
                    }
                    Image {
                        id: icon
                        Layout.fillWidth: true
                        fillMode: Image.PreserveAspectCrop
                    }
                }
            }
            Pane {
                background: Rectangle {
                    anchors.fill: parent
                    color: newItem.color
                }
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        newItem.requestDialog()
                    }
                }
                PlasmaExtras.Paragraph {
                    id: rssItemDesc
                    text: newItem.newSummary
                    textFormat: Text.StyledText
                    Layout.fillWidth: true
                    wrapMode: Text.WordWrap
                    color: theme.textColor
                    anchors.centerIn: parent
                }
            }
        }
        PageIndicator {
            id: indicator
            count: paralNew.count
            currentIndex: paralNew.currentIndex
            anchors.bottom: paralNew.bottom
            anchors.horizontalCenter: parent.horizontalCenter
        }        
    }



    layer.enabled: plasmoid.configuration.shadows
    layer.effect: DropShadow {
        horizontalOffset: 0
        verticalOffset: 0
        radius: units.gridUnit / 1.6
        samples: 32
        color: Qt.rgba(0, 0, 0, 0.5)
    }
}
