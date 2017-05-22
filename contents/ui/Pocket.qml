
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
import QtQuick.Controls 1.4
import QtGraphicalEffects 1.0
import QtQuick.XmlListModel 2.0
import QtQuick.Layouts 1.1

/**
 * Long component to view pocket articles depending on pocketmanager backend.
 * The normal workflow of obtaining data is as follows:
 * - Once component is completed it need oauth credentials configuration 
 * to be filled. To achieve this user needs to push "launch configuration" button 
 * (pocketConnect). It will call the pocketmanager.launchconfig: Initializing the process of oauth autentication (started by auth_refresh:): ObtainRequestCode will send the consumerKey, and requestCode will be obtained and stored as requestToken, onRequestTokenChanged will push the fullRepresentation webLoader WebPage in mainstack. This page will load the pocket website asking user to enter credentials and allow the access to his account of application ttrssPocket. These oauth credentials (plasmoid.configuration.pocketAccessToken) will be stored in plasmoid configuration.
 * - Once configuration is done and onAccesTokenChanged is triggered, it will claim for first list of articles: it will call pocketManager.loadBookmarks with pocketManager.lastUpdate parameter that will be setted to 0.
 * - The operation of refresh will be done whenever pocketManager.AccesToken is changed, so pocketManager.accesToken is defined and so on is changed in every initial process through pocket component event : onCompleted
 * - Refresh again will be done by the gridview itemsList pulldown (onDragEnded) will call pocketManager.loadBookmarks with lastUpdate parameter (then it will get the articles since that lastUpdate), It will send a request and a JSON will be returned, if it has a "list" object then info will be parsed to newData(data) and gotBookmarks will append the since timestamp to pocketmanager.lastUpdate for next data retrieval.
 *
 */
Item {
    id: pocket
    property Item pocketManager

    signal needConfig
    signal requestPage(string webTitle, string webLink)

    clip: true

    function appendData(data) {
        if (data) {
            pocketModel.append(data)
        }
        pocketModel.loadingData = false
    }

    Component.onCompleted: {
        try {
            pocketModel.loadingData = true
            pocketManager.username = plasmoid.configuration.pocketUsername
            pocketManager.accessToken = plasmoid.configuration.pocketAccessToken
            //consumerKey is hardcoded in plasmoid configuration already
        } catch (e) {
            console.log("exception: getSettingsValue" + e)
        }    
    }
    PlasmaExtras.Heading{
        id: pocketConnectText
        text: i18n("Configuration empty, please fill in settings")
        anchors.horizontalCenter: parent.horizontalCenter
        visible: plasmoid.configuration.pocketAccessToken === ""
        level: 4
    }
    PlasmaComponents.Button{
        id: pocketConnect
        text: i18n("Connect Pocket account")
        anchors.centerIn: parent
        visible: plasmoid.configuration.pocketAccessToken === ""
        onClicked: {
            pocketManager.launchConfig()
      }
    }    
    Item{
        id: feedUi
        clip:true
        anchors.fill:parent
        visible: plasmoid.configuration.pocketAccessToken != ""
        Rectangle{
            id: navigatorWrapper
            z:11
            height: pocket.height
            width:(parent.width / 6) * 1
            color: theme.viewBackgroundColor
            Rectangle{
                id: navigator
                color: theme.viewBackgroundColor
                height: parent.height - mainStackToolBar.height 
                width:parent.width
                MenuNavigator {
                    id: categoriesNavigator
                    visible: false
                    height: units.gridUnit * 3
                    width: categoriesIndex.width
                    onBack: {
                        console.debug("back to feeds categories")
                        feedsIndexList.viewFeedIndex = false
                    }
                }
                PlasmaExtras.Heading {
                    id: categoriesTitle
                    height: units.gridUnit * 2.5
                    text: "Categories"
                    anchors.top: categoriesNavigator.top
                }
                ScrollView {
                    //or SplitView?
                    id: categoriesIndex
                    width: (parent.width / 6) * 1
                    anchors {
                        left: parent.left
                        top: categoriesNavigator.bottom
                        bottom: parent.bottom
                    }
                    ListView {
                        orientation: Qt.Horizontal
                        ListView {
                            /*Categories Index list*/
                            id: categoriesIndexList
                            anchors.fill: parent
                            model: opmlModelCategories
                            visible: !categoriesNavigator.visible
                            delegate: Item {
                                height: categoryItemTitle.height + units.gridUnit * 2
                                width: parent.width
                                PlasmaExtras.Heading {
                                    id: categoryItemTitle
                                    horizontalAlignment: Text.AlignJustify
                                    width: parent.width
                                    text: title
                                    font.pointSize: 12
                                }
                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: {
                                        categoriesIndexList.currentIndex = index
                                        opmlModelFeeds.query = "/opml/body/outline[@text='"
                                                + title + "']/outline"
                                        opmlModelFeeds.source = plasmoid.configuration.ttrssOPML
                                        categoriesNavigator.setTitle(title)
                                        feedsIndexList.viewFeedIndex = true
                                    }
                                }
                            }
                        }

                        ListView {
                            /*Concrete Category Feeds List*/
                            property bool viewFeedIndex: false
                            id: feedsIndexList
                            anchors.fill: parent
                            model: opmlModelFeeds
                            visible: this.model.status == XmlListModel.Ready
                                    && feedsIndexList.viewFeedIndex
                            delegate: Item {
                                height: feedItemTitle.height + units.gridUnit * 2
                                width: parent.width
                                PlasmaExtras.Heading {
                                    id: feedItemTitle
                                    width: parent.width
                                    horizontalAlignment: Text.AlignJustify
                                    text: title
                                    font.pointSize: 12
                                }
                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: {
                                        feedsIndexList.currentIndex = index
                                        console.log("loading xml url:" + xmlUrl)
                                        feedModel.query = "/rss/channel/item"
                                        feedModel.namespaceDeclarations = "declare namespace content = 'http://purl.org/rss/1.0/modules/content/'; declare namespace media = 'http://search.yahoo.com/mrss/'; declare namespace dc='http://purl.org/dc/elements/1.1/';"
                                        feedModel.source = xmlUrl //loadFeed()
                                        feedTitle.text = title
                                    }
                                }
                            }
                        }
                    }
                }
            }
            layer.enabled: true
            layer.effect: DropShadow {
                horizontalOffset: 0
                verticalOffset: 0
                radius: units.gridUnit/1.6
                samples: 32
                color: Qt.rgba(0, 0, 0, 0.5)
            }
        }
        Rectangle{
            id:feedAreaHeader
            width: parent.width
            height: feedTitle.height
            color:theme.viewBackgroundColor
            z:10
            PlasmaExtras.Heading {
                id: feedTitle
                height: units.gridUnit * 2.5
                    anchors.horizontalCenter: loadingBox.horizontalCenter
                    width: parent.width
                    horizontalAlignment: Text.AlignHCenter
                    level: 3
            }
            Item {
                id: filterBar
                anchors.right: parent.right
                anchors.bottom:parent.bottom
                anchors.top: parent.top
                width: feedArea.width
                z: 999
                PlasmaCore.IconItem {
                    source: "view-filter"
                    anchors.right: searcher.left
                    anchors.verticalCenter: feedAreaHeader.verticalCenter
                    height: searcher.height
                }
                PlasmaComponents.TextField {
                    id: searcher
                    anchors.right: sorter.left
                    height:parent.height
                    anchors.verticalCenter: feedAreaHeader.verticalCenter
                }
                PlasmaComponents.ToolButton {
                    id: sorter
                    anchors.right: refresher.left
                    anchors.verticalCenter: feedAreaHeader.verticalCenter
                    height:parent.height
                    iconSource: "view-sort-ascending"
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            if (feedCategoryFilter.sortOrder == "AscendingOrder") {
                                feedCategoryFilter.sortOrder == "DescendingOrder"
                            } else {
                                feedCategoryFilter.sortOrder = "AscendingOrder"
                            }
                        }
                    }
                }
                PlasmaComponents.ToolButton {
                    id: refresher
                    anchors.right: parent.right
                    Layout.minimumWidth: parent.width
                    Layout.minimumHeight: units.gridUnit * 2
                    iconSource: "view-refresh"
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            pocketModel.loadingData = true
                            pocket.pocketManager.loadBookmarks(
                                        pocket.pocketManager.lastUpdate)
                        }
                    }
                }
            }
            layer.enabled: true
            layer.effect: DropShadow {
                horizontalOffset: 0
                verticalOffset: 0
                radius: units.gridUnit/1.6
                samples:32
                color: Qt.rgba(0, 0, 0, 0.5)
            }
        }


        ScrollView {
            id: feedArea
            anchors.left: navigatorWrapper.right
            anchors.top: parent.top
            anchors.topMargin: feedAreaHeader.height
            anchors.right: parent.right
            anchors.leftMargin: itemsList.spacing
            anchors.bottom:parent.bottom
            PlasmaExtras.Heading {
              id: scrollInfoText
              anchors {
                horizontalCenter: parent.horizontalCenter
                top:parent.top
              }
              text: i18n("Scroll down to refresh")
              level: 4
              visible: false
            }
            GridView {
                id: itemsList
                property alias pocketMng: pocket.pocketManager
                property string lastUpdate                
                property int spacing: units.gridUnit * 2
                height: pocket.contentHeight - filterBar.height
                anchors.top: categoriesTitle.bottom
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: parent.bottom
                visible: plasmoid.configuration.pocketAccessToken != ""
                cellWidth: (parent.width / 3)
                cellHeight: (parent.width / 3)

                model: PlasmaCore.SortFilterModel {
                    id: postTitleFilter
                    filterRole: "title"
                    sortRole: "addedTime"
                    sortOrder: "DescendingOrder"
                    filterRegExp: searcher.text //toolbarFrame.searchQuery
                    sourceModel: PlasmaCore.SortFilterModel {
                        id: feedCategoryFilter
                        filterRole: "addedTime"
                        sourceModel: ListModel {
                            id: pocketModel
                            property bool loadingData: false
                            //Data comes from Data published from pocketManager and passed via newData example:
                            /*ListElement{
                              url : "http://url"
                              title : "Press Refresh to get poket articles"
                              tags : ""
                              addedTime : "now"
                              excerpt : ""
                            }*/
                        }
                    }
                }
                onDragEnded: {
                    if (refreshHeader.refresh) { 
                        console.debug("pulling news")
                            pocketModel.loadingData = true
                            pocket.pocketManager.loadBookmarks(
                                        pocket.pocketManager.lastUpdate)
                            console.log("reload that SOURCE")
                    }
                    if (itemsList.atYEnd) {
                        console.debug("pushing olds")
                        //TODO PAGER FOR POCKET
                        //return feedsIndexList.moreOldData()
                    }
                }
                delegate: PocketNew {
                    width: itemsList.cellWidth - itemsList.spacing
                    height: itemsList.cellHeight - itemsList.spacing
                    visible: plasmoid.configuration.pocketAccessToken != ""
                    color: theme.viewBackgroundColor
                    newTitle: title
                    newContent: tags
                    newSummary: excerpt
                    newUpdated: addedTime
                    newSource: "Pocket"
                    newAuthor: ""
                    newLink: url
                    newMedia: ""
                    newMediaType: ""
                    newImage: image
                    newFavorite: favorite
                    newResolvedUrl: resolvedUrl
                    onRequestDialog: {
                        pocket.requestPage(title, url) //PAgE
                    }
                }
                Rectangle {
                    id: loadingBox
                    width: parent.width
                    height: parent.height
                    anchors.left: categoriesIndex.right
                    visible: pocketModel.loadingData == true
                    opacity: 0.5
                    z: 1000
                    PlasmaComponents.Label {
                        id: statusLabel
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.verticalCenter: parent.verticalCenter
                        text: {
                            pocketModel.loadingData ? "Loading items" : "Loaded %1 items".arg(
                                                          pocketModel.count)
                        }
                        font.pointSize: 24
                        font.weight: Font.Bold
                    }
                }
                RefreshHeader{
                    id:refreshHeader
                    y: -itemsList.contentY - height
                }
                Component.onCompleted: {

                }

                function refresh() {
                    pocketModel.refresh()
                }
            }
        }
    }

    ArticlePage {
        id: articleDialog
    }

    XmlListModel {
        id: feedModel
        /*      Native feeds*/
        namespaceDeclarations: "declare namespace content = 'http://purl.org/rss/1.0/modules/content/'; declare namespace media = 'http://search.yahoo.com/mrss/'; declare namespace dc='http://purl.org/dc/elements/1.1/';"
        XmlRole {
            name: "title"
            query: "title/string()"
        }
        XmlRole {
            name: "link"
            query: "link/string()"
        }
        XmlRole {
            name: "updated"
            query: "pubDate/string()"
        }
        XmlRole {
            name: "author"
            query: "dc:creator/string()"
        }
        XmlRole {
            name: "summary"
            query: "description/string()"
        }
        XmlRole {
            name: "content"
            query: "content:encoded/string()"
        }
        XmlRole {
            name: "media"
            query: "media:content[1]/@url/string()"
        }
        XmlRole {
            name: "mediaType"
            query: "media:content[1]/@type/string()"
        }
        XmlRole {
            name: "source"
            query: "link/string()"
        }
        onStatusChanged: {
            if (status == XmlListModel.Ready) {
                console.log("[READY] '" + source + "' | " + count + " items")
            }
            if (status == XmlListModel.Error) {
                console.log("[ERROR] '" + source + "' | Error: '" + errorString(
                                ) + "'")
            }
            if (status == XmlListModel.Loading) {
                console.log("[LOADING] '" + source + "'")
            }
        }
    }
    XmlListModel {
        id: opmlModelFeeds
        query: "/opml/body/outline"
        XmlRole {
            name: "title"
            query: "@text/string()"
        }
        XmlRole {
            name: "xmlUrl"
            query: "@xmlUrl/string()"
        }
        XmlRole {
            name: "htmlUrl"
            query: "@htmlUrl/string()"
        }
        onStatusChanged: {
            if (status == XmlListModel.Ready) {
                console.log("[READY] '" + source + "' | " + count + " items")
            }
            if (status == XmlListModel.Error) {
                console.log("[ERROR] '" + source + "' | Error: '" + errorString(
                                ) + "'")
            }
            if (status == XmlListModel.Loading) {
                console.log("[LOADING] '" + source + "'")
            }
        }
    }
    XmlListModel {
        id: opmlModelCategories
        source: plasmoid.configuration.ttrssOPML
        query: "/opml/body/outline"
        XmlRole {
            name: "title"
            query: "@text/string()"
        }
        onStatusChanged: {
            if (status == XmlListModel.Ready) {
                console.log("[READY] '" + source + "' | " + count + " items")
            }
            if (status == XmlListModel.Error) {
                console.log("[ERROR] '" + source + "' | Error: '" + errorString(
                                ) + "'")
            }
            if (status == XmlListModel.Loading) {
                console.log("[LOADING] '" + source + "'")
            }
        }
    }
    function reload() {
        categoriesIndexList.model.reload()
    }
}
