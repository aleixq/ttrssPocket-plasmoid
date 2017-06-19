
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
import QtQuick.Controls 1.4 as QtControls
import QtQuick.Layouts 1.1

import QtWebEngine 1.5



//FIXME this causes a crash in Oxygen style
//QtControls.GroupBox {
Item {
    id: pocketManager
    anchors.fill: parent
    property string code: ""
    property string accessToken
    property string username
    property string requestToken: ""
    property string consumerKey: plasmoid.configuration.pocketConsumerKey
    property int countLoading: 0
    property string lastUpdate: "0"
    signal authenticated
    signal getReady(variant Items)
    signal newData(variant someData)
    signal claimPage

    function needConfig() {
        if (plasmoid.configuration.pocketAccessToken === "") {
            console.debug("Pocket needs to be configured")
            return true
        } else {
            console.log("Pocket configuration exists")
            return false
        }
    }
    function launchConfig() {
        if (plasmoid.configuration.pocketAccessToken === "") {
            claimPage()
            auth_refresh()
        } else {
            console.debug("Pocket configuration exists, disconnect first in settings")
        }
    }
    Item {
        id: fields
        width: parent.width
        height: showPocketConsumerKey.height

        Component.onCompleted: {
        }

        RowLayout {
            spacing: 10
            QtControls.Label {
                text: i18n("Pocket Consumer key:")
            }
            QtControls.Label {
                id: showPocketConsumerKey
                width: units.gridUnit * 5
                font.pointSize: 20
            }
            QtControls.Label {
                text: i18n("Pocket Access token:")
            }
            QtControls.Label {
                id: showPocketAccesToken
                width: units.gridUnit * 5
                font.pointSize: 20
            }
            QtControls.Label {
                text: i18n("Pocket username:")
            }
            QtControls.Label {
                id: showPocketUsername
                width: units.gridUnit * 5
                font.pointSize: 20
            }
        }
    }
    QtControls.ScrollView {
        anchors.bottom: parent.bottom
        anchors.top: fields.bottom
        anchors.left: pocketManager.left
        anchors.right: pocketManager.right
        clip: true

        WebEngineView {
            id: webview
            visible: false
            url: "https://getpocket.com"
            zoomFactor: units.devicePixelRatio
            //experimental.preferences.privateBrowsingEnabled: true
            onLoadingChanged: {
                console.log("webview " + loading)
                if (loading) {
                    pocketManager.countLoading++
                } else {
                    pocketManager.countLoading--
                    var str = loadRequest.url.toString()
                    var i = str.indexOf("linksbag:authorizationFinished", 0)
                    if (!i) {
                        pocketManager.requestAccessToken()
                    }
                }
            }
            Text {
                id: webviewBusyIndicator
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: parent.bottom
                visible: webview.loading
                text: "LOADING"
                //running: true;
            }
        }
    }

    onAccessTokenChanged: {
        if (accessToken === undefined || accessToken === "")
            return
        console.log("access token changed ! " + accessToken)
        webview.visible = false
        plasmoid.configuration.pocketAccessToken = accessToken
        authenticated()
        //authenticated, refresh articles
        loadBookmarks(pocket.pocketManager.lastUpdate)
    }

    onRequestTokenChanged: {
        if (requestToken === undefined || requestToken === "")
            return
        console.log("request token changed ! " + requestToken)
        webview.visible = true
        webview.url = "https://getpocket.com/auth/authorize?request_token="
                + requestToken + "&redirect_uri=linksbag:authorizationFinished"
    }
    onUsernameChanged: {
        console.log("user name changed ! " + username)
        plasmoid.configuration.pocketUsername = username
    }

    function auth_refresh() {
        console.debug("[PocketManager] refreshing auth")
        //first sign out as we cannot clear cookies...
        webview.url = "https://getpocket.com/lo/"
        obtainRequestCode()
    }
    function obtainRequestCode() {
        var source = "https://getpocket.com/v3/oauth/request"
        var params = "{ \"consumer_key\": \"" + consumerKey
                + "\", \"redirect_uri\": \"linksbag://authorizationFinished\" }"
        sendRequest(source, params, "POST")
    }
    function requestAccessToken() {
        var source = "https://getpocket.com/v3/oauth/authorize"
        var params = "{ \"consumer_key\": \"" + consumerKey + "\", \"code\": \""
                + requestToken + "\" }"
        sendRequest(source, params, "POST")
    }
    function gotBookmarks(sinceDate) {
        pocketManager.lastUpdate = sinceDate
    }

    function add(url) {
        var source = "https://getpocket.com/v3/add"
        var params = "{ \"url\": \"" + url +
                "\", \"consumer_key\": \"" + consumerKey + "\","
                + " \"access_token\": \"" + accessToken + "\"}"
        sendRequest(source, params, "POST")
    }

    function loadBookmarks(sinceDate) {
        console.log("[GET ARTICLES]")
        var source = "https://getpocket.com/v3/get"
        var params = "{ \"consumer_key\": \"" + consumerKey + "\","
                + " \"access_token\": \"" + accessToken + "\","
                + " \"state\": \"all\", \"sort\": \"newest\", \"detailType\": \"complete\","
                + " \"since\": \"" + sinceDate + "\"}"
        sendRequest(source, params, "POST")
    }
    function sendRequest(source, params, method) {
        console.log(method + ": " + source + "?" + params)

        //         var pocket =
        //         {
        //             'base':    "https://getpocket.com",
        //             'login':    "/v3/oauth/authorize",
        //         }
        //
        //         var url = pocket.base + pocket.login;
        var xhr = new XMLHttpRequest()
        xhr.open(method, source, true)

        xhr.setRequestHeader("Content-Type", "application/json; charset=UTF-8")
        xhr.setRequestHeader("X-Accept", "application/json")
        xhr.onreadystatechange = function () {

            if (xhr.readyState === XMLHttpRequest.DONE) {
                pocketManager.countLoading = Math.max(
                            pocketManager.countLoading - 1, 0)
                if (xhr.status === 200) {
                    try {
                        var result = xhr.responseText
                        //console.log("XXXXXXXXXXXXXXX " + result + "YYYYYYYYYYYYYYYYYYYYY")
                        var resultObject = JSON.parse(result)

                        if (resultObject.code !== undefined) {
                            requestToken = resultObject.code
                        }

                        if (resultObject.username !== undefined) {
                            username = resultObject.username
                        }

                        if (resultObject.access_token !== undefined) {
                            accessToken = resultObject.access_token
                        }

                        if (resultObject.list !== undefined) {
                            var list = resultObject.list
                            for (var key in list) {
                                var item = list[key]
                                console.debug(JSON.stringify(item))
                                var uid = item.item_id
                                var url = item.resolved_url
                                var title = item.resolved_title
                                var excerpt = item.excerpt
                                if (!title || title.length === 0)
                                    title = item.given_title
                                if (!title || title.length === 0)
                                    title = url
                                var favorite = item.favorite !== "0"
                                var read = item.status === "1"
                                var tagsList = item.tags
                                var addedTime = item.time_added
                                var resolvedUrl = item.resolved_url
                                var image = undefined
                                if (item.has_image == "1"){
                                    for (var itImage in item.images){
                                        image = item.images[itImage].src
                                        continue
                                    }
                                }
                                console.debug("SETTING IMAG: "+ image)
                                var tags = ""
                                for (var tag in tagsList) {
                                    if (tag === undefined)
                                        continue
                                    if (tags && tags.length !== 0)
                                        tags += ", "
                                    tags += tag
                                }

                                var sortId = item.sort_id

                                var data = {
                                    uid: uid,
                                    url: url,
                                    title: title,
                                    favorite: favorite,
                                    read: read,
                                    tags: tags,
                                    sortId: sortId,
                                    addedTime: addedTime,
                                    excerpt: excerpt,
                                    image: image,
                                    resolvedUrl: resolvedUrl,
                                }
                                //                                         var pocketItem={
                                //                                             "newTitle": item.resolved_title,
                                //                                             "newContent": item.resolved_title,
                                //                                             "newSummary": item.resolved_title,
                                //                                             "newUpdated": "",
                                //                                             "newSource": "Pocket",
                                //                                             "newAuthor": "",
                                //                                             "newLink": item.resolved_url,
                                //                                             "newMedia": "",
                                //                                             "newMediaType": ""
                                //                                         }
                                newData(data)

                                //                                 if (item.status === "2")
                                //                                     runtimeCache.removeItem(uid)
                                //                                 else
                                //                                     runtimeCache.addItem(data)
                            }
                            console.log("Got list of bookmarks,treat populated list")
                            gotBookmarks(resultObject.since)
                            if (list.length == 0) {
                                newData(false) //fake data to trig the end of the update overlay
                            }
                        }

                        if (resultObject.action_results !== undefined) {
                            console.log("Initial LOAD of BOOKMARKS:")
                            loadBookmarks(0)
                        }
                    } catch (e) {
                        console.log("sendRequest: parse failed: " + e)
                    }
                } else if (xhr.status === 400) {
                    console.log("[POCKETMANAGER] xhr.status: 400 - Invalid request, please make sure you follow the documentation for proper syntax")
                } else if (xhr.status === 401) {
                    console.log("[POCKETMANAGER] xhr.status: 401 - Not authorized")
                    pocketManager.requestToken = ""
                } else if (xhr.status === 403) {
                    console.log("[POCKETMANAGER] https.status: 403 - User was authenticated, but access denied due to lack of permission or rate limiting")
                } else if (xhr.status === 503) {
                    console.log("[POCKETMANAGER] xhr.status: 503 - Pocket's sync server is down for scheduled maintenance")
                } else if (xhr.status === 0) {
                    pocketManager.countLoading = 0
                } else {
                    console.log("error in onreadystatechange: " + xhr.status + " "
                                + xhr.statusText + ", " + xhr.getAllResponseHeaders(
                                    ) + "," + xhr.responseText)
                }
            }
        }
        pocketManager.countLoading++
        xhr.send(params) //MUSTBE CLEANER:                xhr.send(JSON.stringify(oauth));
    }
}
