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
import QtGraphicalEffects 1.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.extras 2.0 as PlasmaExtras
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.1
import QtQuick.XmlListModel 2.0
import "../code/ttrss.js" as TTRSS

/**
 * Long long component that must be splitted in manager and Interface.
 * The normal Wokflow of obtaining data is as follows:
 * - Once main component is completed, and configuration is filled, 
 * call reload() method  to obtain the sid (getSid method) adding a flag
 * to getCategories immediately if logged in.
 * - Once Sid we can get api resources without exposing user and password.
 * In my opinion oauth wll be safer, but I cannot fins in ttrss api.
 * - Send a post request to Login resource, If 200 is returned, as we included 
 * a flag then automatically will send a refresh to getCategories JSONListModel
 * that will send a new post request to getCategories JSONListModel refresh method,
 * which also will send a new post request to obtain categories. At this point categories
 * will be populated. So on user can navigate.
 * - getCategories, getFeeds and getHeadLines will be done by JSONListModel sendRequest method,
 * - updateArticle(to rate and to mars as read), Login, and logut will be done here.
 * 
 */

Item {
    id: ttrss
    property int contentWidth: this.width
    property int contentHeight: this.height
    property bool authenticated: false
    property string sid: ""
    property string loginFail
    /* Serialized conf to listen for grouped configuration changes events*/
    property var ttrssConfiguration: plasmoid.configuration.ttrssUser+plasmoid.configuration.ttrssUrl+plasmoid.configuration.ttrssPw

    property int countLoading: 0

    signal requestPage(string webTitle, string webContent, string webAuthor, string webUpdated, string webSource, string webLink)
    signal toPocket(string link)

    clip: true
    Component.onCompleted: {
        if (plasmoid.configuration.ttrssUrl != ""
                && plasmoid.configuration.ttrssUser != ""
                && plasmoid.configuration.ttrssPw != "") {
            reload()
        } else {
            console.log("Some parameters not found so please fill it in configuration dialog")
            console.debug(JSON.stringify(plasmoid.configurationRequired))
            return
        }
    }
    onTtrssConfigurationChanged: {
       console.debug("ttrss configuration changed, reloading...")
       reload()
    }    

    PlasmaExtras.Heading{
        id: ttrssConnect
        text: i18n("Configuration empty, please fill in settings")
        anchors.horizontalCenter: parent.horizontalCenter
        visible: !ttrss.authenticated && ttrssConfiguration == ""
        level: 4
    }
    PlasmaComponents.Button {
        anchors.centerIn: parent
        text: i18n("Configure...")
        visible: ttrssConfiguration == "" && !ttrss.authenticated
        onClicked: plasmoid.action("configure").trigger();
    }    
    Item{
        id: feedUI
        anchors.fill:parent
        clip:true
        visible:ttrss.authenticated
        Rectangle{
            id: navigatorWrapper
            z:11
            height: ttrss.height
            width:(parent.width / 6) * 1
            color: theme.viewBackgroundColor
            Rectangle{
                id: navigator
                color: theme.viewBackgroundColor
                height: parent.height - mainStackToolBar.height
                width:parent.width 
                PlasmaExtras.Heading {
                    height: units.gridUnit * 2.5
                    visible: !categoriesNavigator.visible
                    text: "Categories"
                    anchors.top: categoriesNavigator.top
                    id: categoriesTitle
                }
                MenuNavigator {
                    id: categoriesNavigator
                    visible: false
                    height: units.gridUnit * 2.5
                    width: categoriesIndex.width
                    onBack: {
                        console.log("back to feeds categories")
                        feedsIndexList.viewFeedIndex = false
                    }
                    onTitleClicked: {
                        //Mixed Category Feeds
                        getHeadLines.doResetModel = true
                        getHeadLines.postData = JSON.stringify({
                                                                  op: "getHeadLines",
                                                                  feed_id: categoriesNavigator.currentCID,
                                                                  is_cat: true,
                                                                  sid: ttrss.sid,
                                                                  show_excerpt: true,
                                                                  show_content: true,
                                                                  include_attachments: true,
                                                                  limit: 10
                                                              })
                        getHeadLines.currentFID = categoriesNavigator.currentCID
                        feedTitle.text = this.title
                        feedsIndexList.currentIndex = -1
                        categoriesIndexList.currentIndex = -1
                    }
                }
                ScrollView {
                    id: categoriesIndex
                    width: parent.width
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
                            model: getCategories.model
                            visible: !categoriesNavigator.visible
                            highlight: PlasmaComponents.Highlight {
                            }
                            delegate: Item {
                                height: categoryItemTitle.height + units.gridUnit * 2
                                width: parent.width
                                PlasmaExtras.Heading {
                                    id: categoryItemTitle
                                    horizontalAlignment: Text.AlignJustify
                                    //anchors.verticalCenter:parent.verticalCenter
                                    anchors.left: parent.left
                                    anchors.leftMargin: units.gridUnit * 2
                                    width: parent.width - units.gridUnit * 2
                                    text: title + " (" + unread + ")"
                                    //                         font.weight:Font.Bold
                                    //color: categoriesIndexList.currentIndex == index ? "#dddddd" : "white"
                                    level: 5
                                }
                                MouseArea {
                                  anchors.fill: parent
                                    onClicked: {
                                        categoriesIndexList.currentIndex = index
                                        getFeeds.postData = JSON.stringify({
                                                                              op: "getFeeds",
                                                                              cat_id: id,
                                                                              sid: ttrss.sid
                                                                          })
                                        getHeadLines.doResetModel = true
                                        getHeadLines.postData = JSON.stringify({
                                                                                  op: "getHeadLines",
                                                                                  feed_id: id,
                                                                                  is_cat: true,
                                                                                  sid: ttrss.sid,
                                                                                  show_excerpt: true,
                                                                                  show_content: true,
                                                                                  include_attachments: true,
                                                                                  limit: 10
                                                                              })
                                        categoriesNavigator.setTitle(title)
                                        getFeeds.currentCID = id
                                        feedsIndexList.currentIndex = -1
                                        getHeadLines.currentFID = id
                                        categoriesNavigator.currentCID = id
                                        feedsIndexList.viewFeedIndex = true
                                        feedTitle.text = title
                                    }
                                }
                            }
                        }

                        ListView {
                            /*Concrete Category Feeds List*/
                            id: feedsIndexList
                            property bool viewFeedIndex: false

                            anchors.fill: parent
                            model: getFeeds.model
                            visible: getFeeds.readyState == XMLHttpRequest.DONE
                                    && getFeeds.status == 200
                                    && feedsIndexList.viewFeedIndex

                            highlight: PlasmaComponents.Highlight {
                            }
                            delegate: Item {
                                height: feedItemTitle.height + units.gridUnit * 2
                                width: parent.width
                                PlasmaExtras.Heading {
                                    id: feedItemTitle
                                    width: parent.width - units.gridUnit * 2
                                    horizontalAlignment: Text.AlignJustify
                                    anchors.left: parent.left
                                    anchors.leftMargin: units.gridUnit * 2
                                    text: title
                                    level: 5
                                }
                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: {
                                        feedsIndexList.currentIndex = index
                                        getHeadLines.doResetModel = true
                                        getHeadLines.postData = JSON.stringify({
                                                                                  op: "getHeadLines",
                                                                                  feed_id: id,
                                                                                  sid: ttrss.sid,
                                                                                  show_excerpt: true,
                                                                                  show_content: true,
                                                                                  include_attachments: true,
                                                                                  limit: 10
                                                                              })
                                        feedTitle.text = title
                                        getHeadLines.currentFID = id
                                    }
                                }
                            }
                            function moreOldData() {
                                getHeadLines.doResetModel = false
                                getHeadLines.postData = JSON.stringify({
                                                                          op: "getHeadLines",
                                                                          feed_id: getHeadLines.currentFID,
                                                                          is_cat: getHeadLines.currentFID == getFeeds.currentCID,
                                                                          sid: ttrss.sid,
                                                                          skip: getHeadLines.count,
                                                                          show_excerpt: true,
                                                                          show_content: true,
                                                                          include_attachments: true,
                                                                          limit: 10
                                                                      })
                                console.log("Want new data " + getHeadLines.currentFID
                                            + " " + getHeadLines.postData)
                            }
                            function moreNewData() {
                                getHeadLines.doResetModel = false
                                getHeadLines.postData = JSON.stringify({
                                                                          op: "getHeadLines",
                                                                          feed_id: getHeadLines.currentFID,
                                                                          is_cat: getHeadLines.currentFID == getFeeds.currentCID,
                                                                          sid: ttrss.sid,
                                                                          skip: getHeadLines.count,
                                                                          show_excerpt: true,
                                                                          show_content: true,
                                                                          include_attachments: true,
                                                                          limit: 10
                                                                      })
                                console.log("Want old data " + getHeadLines.currentFID
                                            + " " + getHeadLines.postData)
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
              anchors.top: parent.top
              anchors.bottom:parent.bottom
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
                  height:parent.height
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
                samples: 32
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
                anchors.top: categoriesTitle.bottom
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: parent.bottom
                visible: ttrss.sid != ""
                cellWidth: (parent.width / 3)
                cellHeight: (parent.width / 3)
                property int spacing: units.gridUnit * 2
                property int currentFeedId
                signal itemSelected(int id)

                model:     PlasmaCore.SortFilterModel {
                    id: postTitleFilter
                    filterRole: "title"
                    sortRole: "updated"
                    sortOrder: "DescendingOrder"
                    filterRegExp: searcher.text 
                    sourceModel: PlasmaCore.SortFilterModel {
                        id: feedCategoryFilter
                        filterRole: "updated"
                        sourceModel: getHeadLines.model
                    }
                }
                
                delegate:TinyNew {
                    id: tinyNew
                    width: itemsList.cellWidth - itemsList.spacing
                    height: itemsList.cellHeight - itemsList.spacing
                    color: marked ? "#FFFFDD" : theme.viewBackgroundColor 
                    newUnread: unread //it is replicated to ensure that mark unread is greyed in realtime
                    onRequestDialog: {
                        var fullContent = content == "" ? summary : content
                        var time = new Date(0)
                        time.setUTCSeconds(updated)
                        ttrss.requestPage(title, content,  author, time,
                                          feed_title, link) //PagE
                    }
                    onRequestOp: ttrss.updateArticle(op, hlID, field)
                    onRead: {
                        unread = false
                        ttrss.updateArticle("updateArticle", id,
                                            TTRSS.Headline.Unread)
                    }
                    onToPocket: {
                        ttrss.toPocket(link)
                    }
                }
                
                onDragEnded: {
                    if (refreshHeader.refresh) { 
                        console.debug("pulling news")
                        return feedsIndexList.moreNewData()
                    }
                    if (itemsList.atYEnd) {
                        console.debug("pushing olds")
                        return feedsIndexList.moreOldData()
                    }
                }

                RefreshHeader{
                    id:refreshHeader
                    y: -itemsList.contentY - height
                }

                Rectangle {
                    id: loadingBox
                    width: parent.width
                    height: parent.height
                    visible: getHeadLines.loading || (!ttrss.authenticated && ttrssConfiguration != "" )
                    color: "#000000"
                    opacity: 0.8
                    z: 1000
                    PlasmaComponents.Label {
                        id: statusLabel
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.verticalCenter: parent.verticalCenter
                        text: {
                            getHeadLines.loading ? "Loading items" : "Loaded" // + " (%1%)".arg(itemsList.model.progress) : "Loaded ".arg(itemsList.count);
                        }
                        color: theme.textColor
                        font.pointSize: 24
                        font.weight: Font.Bold
                    }
                }
            }
        }
    }
    //END OF FEEDUI
    ArticlePage {
        id: articleDialog
    }
    JSONListModel {
        id: getCategories
        requestType: "POST"
        query: "$.content.*"
        postData: JSON.stringify({
                                     op: "getCategories",
                                     sid: ttrss.sid
                                 })
        source: plasmoid.configuration.ttrssUrl + "/api/"
        onStatusChanged: {
            if (readyState == XMLHttpRequest.DONE && status == 200) {
                console.log("[READY] '" + source + "' | " + count + " items")
            }
            if (readyState == XMLHttpRequest.DONE && status != 200) {
                console.log("[TTRSS ERROR => " + status + "] '" + source)
            } //+ "' | Error: '" + statusText + "'")}   //errorString() + "'")}
            if (readyState == XMLHttpRequest.LOADING) {
                console.log("[LOADING] '" + source + "'")
            }
        }
    }
    JSONListModel {
        id: getFeeds
        property int currentCID
        requestType: "POST"
        query: "$.content.*"
        //         postData: JSON.stringify({"op":"getFeeds","sid":ttrss.sid})
        source: plasmoid.configuration.ttrssUrl + "/api/"
        onStatusChanged: {
            if (readyState == XMLHttpRequest.DONE && status == 200) {
                console.log("[READY] '" + source + "' | " + count + " items")
            }
            if (readyState == XMLHttpRequest.DONE && status != 200) {
                console.log("[ERROR] '" + source)
            } //+ "' | Error: '" + statusText + "'")}   //errorString() + "'")}
            if (readyState == XMLHttpRequest.LOADING) {
                console.log("[LOADING] '" + source + "'")
            }
        }
    }
    JSONListModel {
        id: getHeadLines
        property int currentFID
        requestType: "POST"
        query: "$.content.*"
        source: plasmoid.configuration.ttrssUrl + "/api/"
        onStatusChanged: {
            if (readyState == XMLHttpRequest.DONE && status == 200) {
                console.log("[READY] '" + source + "' | " + count + " items")
            }
            if (readyState == XMLHttpRequest.DONE && status != 200) {
                console.log("[ERROR] '" + source)
            } //+ "' | Error: '" + statusText + "'")}   //errorString() + "'")}
            if (readyState == XMLHttpRequest.LOADING) {
                console.log("[LOADING] '" + source + "'")
            }
        }
    }

    function reload() {
        getSid(true)
    }

    function getSid(withLoadData) {
        var params = {
            op: "login",
            user: plasmoid.configuration.ttrssUser,
            password: plasmoid.configuration.ttrssPw
        }
        var source = plasmoid.configuration.ttrssUrl + "/api/"
        sendRequest(source, params, "POST", "login", withLoadData)
        return
    }

    function updateArticle(op, hlID, field) {
        switch (op) {
        case 'updateArticle':
            var params = {
                op: "updateArticle",
                sid: ttrss.sid,
                field: field,
                //If is star toggle, if is read set false unread only
                mode: field == TTRSS.Headline.Starred ? TTRSS.Toggle : false,
                article_ids: hlID
            }
            var source = plasmoid.configuration.ttrssUrl + "/api/"
            sendRequest(source, params, "POST", "updateArticle" + field, false)
            break
        }
        return
    }

    function logout() {
        var xhr = new XMLHttpRequest
        xhr.open("POST", plasmoid.configuration.ttrssUrl + "/api/")
        xhr.setRequestHeader("Content-Type", "application/json; charset=UTF-8")
        xhr.setRequestHeader("X-Accept", "application/json")
        xhr.onreadystatechange = function () {
            if (xhr.readyState === XMLHttpRequest.DONE && xhr.status == 200) {
                var json = JSON.parse(xhr.responseText)
                console.log("login response: " + xhr.responseText)
                var ok = json['status']
                console.log("DONE! logout first:" + ok)
            } else {
                ttrss.loginFail = "Could not get sid"
            }
        }
        xhr.send(JSON.stringify({
                                    op: "logout",
                                    sid: ttrss.sid
                                }))
    }

    function sendRequest(source, params, method, resource, withLoadData) {
        var xhr = new XMLHttpRequest()
        xhr.open(method, source, true)
        xhr.setRequestHeader("Content-Type", "application/json; charset=UTF-8")
        xhr.setRequestHeader("X-Accept", "application/json")
        xhr.setRequestHeader("ttrss_api_sid", "") //DOES NOTHING-
        xhr.setRequestHeader("Cookie", "") //DOES NOTHING-
        xhr.onreadystatechange = function () {
            console.log(JSON.stringify(xhr.responseText))
            if (xhr.readyState === XMLHttpRequest.DONE) {
                ttrss.countLoading = Math.max(ttrss.countLoading - 1, 0)
                if (xhr.status === 200) {
                    try {
                        var result = xhr.responseText
                        //console.debug("------- " + result + "----------")
                        var resultObject = JSON.parse(result)
                        if (resource == "login") {
                            processLogin(resultObject, withLoadData)
                        }
                        if (resource == "updateArticle" + TTRSS.Headline.Starred) {
                            console.log("toggle STAR")
                        }
                        if (resource == "updateArticle" + TTRSS.Headline.Unread) {
                            console.log("set unRead False")
                        }
                    } catch (e) {
                        console.log("sendRequest: parse failed: " + e)
                    }
                    //TODO: FULFILL "something wrong" appearing in someway
                } else if (xhr.status === 400) {
                    console.log("xhr.status: 400 - Invalid request, please make sure you follow the documentation for proper syntax")
                } else if (xhr.status === 401) {
                    console.log("xhr.status: 401 - Not authorized")
                    ttrss.requestToken = ""
                } else if (xhr.status === 403) {
                    console.log("https.status: 403 - User was authenticated, but access denied due to lack of permission or rate limiting")
                } else if (xhr.status === 0) {
                    ttrss.countLoading = 0
                } else {
                    console.log("error in onreadystatechange: " + xhr.status + " "
                                + xhr.statusText + ", " + xhr.getAllResponseHeaders(
                                    ) + "," + xhr.responseText)
                }
            }
        }
        ttrss.countLoading++
        //MUSTBE CLEANER but Oauth is not implemented in ttrss: xhr.send(JSON.stringify(oauth)); 
        xhr.send(JSON.stringify(params)) 
    }

    function processLogin(resultObject, withLoadData) {
        var seq = 0
        var status = 0
        if (resultObject.seq !== undefined) {
            seq = resultObject.seq
        }
        if (resultObject.status !== undefined) {
            status = resultObject.status
        }
        if (resultObject.content != undefined) {
            if (resultObject.content.session_id == "deleted") {
                ttrss.loginFail = "Could not get sid"
                ttrss.authenticated = false
            } else {
                ttrss.sid = resultObject.content.session_id
                ttrss.loginFail = ""
                ttrss.authenticated = true
                console.log("id set to " + ttrss.sid)
                if (withLoadData) {
                    categoriesIndexList.currentIndex = -1
                    getCategories.refresh()
                }
            }
        }
    }
}
