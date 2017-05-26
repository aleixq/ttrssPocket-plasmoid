/*
* Copyright (C) 2012 Aleix Quintana <kinta@communia.org>
*
*  This program is free software; you can redistribute it and/or modify
*  it under the terms of the GNU General Public License as published by
*  the Free Software Foundation; either version 2 of the License, or
*  (at your option) any later version.
*
*  This program is distributed in the hope that it will be useful,
*  but WITHOUT ANY WARRANTY; without even the implied warranty of
*  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
*  GNU General Public License for more details.
*
*  You should have received a copy of the GNU General Public License
*  along with this program; if not, write to the Free Software
*  Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  2.010-1301, USA.
*/
import QtQuick 2.1
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.core 2.0 as PlasmaCore
import QtQuick.Layouts 1.1
import org.kde.plasma.extras 2.0 as PlasmaExtras
import org.kde.plasma.plasmoid 2.0
import QtQuick.Controls 1.4

// debug run with : QT_MESSAGE_PATTERN="[%{type}] %{appname} (%{file}:%{line}) - %{message}" plasmoidviewer -a org.communia.ttrssPocket  -s 2500x1080 -c org.kde.panel [ --qmljsdebugger=port:3966 ]
Item {
    Layout.preferredWidth: plasmoid.screenGeometry.width
    Layout.preferredHeight: plasmoid.screenGeometry.height
    id: fullRepresentation
    SwipeArea {
        anchors.fill: parent
        PropertyAnimation {
            id: slide_anim
            target: grip
            easing.type: Easing.OutExpo
            properties: "y"
        }

        PropertyAnimation {
            id: showDialog
            target: grip
            property: "opacity"
            to: 1
            duration: 500
            easing.type: Easing.InQuad
        }
        onSwipeDown: {
            console.log("swDown " + track)
            slide_anim.to = parent.height * 1
            slide_anim.start()
        }
        onSwipeUp: {
            console.log("swUp ")
            slide_anim.to = 0
            slide_anim.start()
        } 
    }

    Item {
        // Drawer
        //NonSense when using without swipe so reduct to zero waiting for a better future...
        id: grip
        width: parent.width
        anchors.bottom: parent.bottom
        height: 0
        anchors.horizontalCenter: parent.horizontalCenter
        Rectangle {
            height: 0
            color: "#000"
            width: parent.width
            anchors.bottom: parent.bottom
        }
    }

    PlasmaComponents.ToolBar {
        id: mainStackToolBar
        anchors.bottom: parent.bottom
        height: units.gridUnit * 8
        width:  (parent.width/6) - units.gridUnit
        visible: mainStack.currentPage != webLoader
        //THESE TOOLS ARE NOT USED AS EACH PAGE HAS A TOOLBAR
        tools: PlasmaComponents.ToolBarLayout {
            PlasmaComponents.ToolButton {
                visible: false
            }
            PlasmaComponents.ToolButton {
                iconSource: "draw-arrow-back"
                height: units.gridUnit * 2.5
                text: "Back"
            }
            PlasmaComponents.ToolButton {
                iconSource: "view-refresh"
                height: units.gridUnit * 2.5
                text: "Fresher"
            }
            PlasmaComponents.ToolButton {
                visible: false
                height: units.gridUnit * 2.5
            }
        }
    }

    PlasmaComponents.PageStack {
        id: mainStack
        initialPage: ttrssPage //rssPage  //INITIAL PAGE SET
        width: parent.width
        height: parent.height - grip.height - mainStackToolBar.height
        anchors.top:parent.top
        anchors.bottom: grip.top
        toolBar: mainStackToolBar //comment to share the same toolbuttons instead of define for every page
    Action {
        shortcut: "Escape"
        onTriggered: plasmoid.expanded = false
    }

    }

    //ArticleOxidePage {     //  UBUNTU OPTION- cannot be inside scrollview
    ArticlePage {
        id: webLoader
        onBack: {
            mainStack.pop()
        }
        onToPocket: {
            pocketManager.add(link)
        }
    }
    /* To debug article page
    Articledebug{id:articledebug
    }*/
    /* POCKETMANAGER*/
    PlasmaComponents.Page {
        id: pocketConfig
        anchors.centerIn: parent
        anchors.fill: parent
        PocketManager {
            id: pocketManager
            onClaimPage: mainStack.push(pocketConfig)
            onAuthenticated: mainStack.pop()
            onNewData: pocket.appendData(someData)
        }
    }
    PlasmaComponents.Page {
        id: pocketPage
        tools: PlasmaComponents.ToolBarLayout {
            ToolBarTitle {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter            
                anchors.bottom:barToTtrs
                Layout.fillWidth: true
                titleText: "Pocket"
                iconSource: "download-later"
            }
            PlasmaComponents.ToolButton {
                id: barToTtrs
                iconSource: "draw-arrow-back"
                height: units.gridUnit * 2.5
                width: 20
                anchors.bottom: parent.bottom
                text: "back to ttrss"
                onClicked: mainStack.pop()
            }
        }

        Pocket {
            id: pocket
            anchors.fill: parent
            pocketManager: pocketManager
            onNeedConfig: pocketManager.needConfig
            onRequestPage: {
                webLoader.title = webTitle
                webLoader.originalLink = webLink
                webLoader.setUrl()
                console.log("Requesting from fullRepresentation.qml:" + webTitle
                            + " from source:" + webLink)
                mainStack.push(webLoader)
            }
        }
    }
    /* TTRSS */
    PlasmaComponents.Page {
        id: ttrssPage
        tools: PlasmaComponents.ToolBarLayout {
            ToolBarTitle {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                titleText: "TTRSS"
                iconSource: "feed-subscribe"
                 Layout.fillWidth: true
            }

            PlasmaComponents.ToolButton {
                id: barToPocket
                iconSource: "download-later"
                height: units.gridUnit * 2.5
                text: "Pocket"
                anchors.bottom: parent.bottom
                onClicked: mainStack.push(pocketPage) //appletsContainer)
            }
        }

        TtRss {
            id: ttrss
            anchors.fill: parent
            onRequestPage: {
                webLoader.title = webTitle
                webLoader.bodyContent = webContent
                webLoader.authoring = "by <b>" + webAuthor + "</b>  on <b>"
                        + webSource + "</b>, dated <b>" + webUpdated + "</b>"
                webLoader.originalLink = webLink
                webLoader.source = webSource
                console.log("Requesting from fullRepresentation.qml:" + webTitle
                            + " from source:" + webLink)
                webLoader.updateContent()
                mainStack.push(webLoader)
            }
            onToPocket: {
                if (plasmoid.configuration.pocketAccessToken === ""){
                    mainStack.push(pocketPage)
                }
                else {pocketManager.add(link)
                }
            }
        }
    }
    Component.onCompleted: resizeToFitScreen()
    function resizeToFitScreen() {
        //TODO REAL RESIZING, not working
        // fit the containment to within the boundaries of the visible panels
        // (so no panels should be covering any information)
        // rect 0 is available screen region, rect 1 is for panels not 100% wide
        return
        var screen = Plasmoid.screen
        print("RESIZING!")
        print(plasmoid.screen())
        print(plasmoid.screenGeometry())
        print(plasmoid.availableScreenRect)
        print(Plasmoid.availableScreenRect)

        var sourceRegion = plasmoid.availableScreenRegion()[1]
        if (sourceRegion === undefined) {
            sourceRegion = plasmoid.availableScreenRegion()[0]
        }

        main.y = sourceRegion.y
        main.x = sourceRegion.x
        main.height = sourceRegion.height
        main.width = sourceRegion.width
    }
    function stopWebLoader() {
        //Workaround to disable webloader crash!
        mainStack.pop(null)
    }
}
