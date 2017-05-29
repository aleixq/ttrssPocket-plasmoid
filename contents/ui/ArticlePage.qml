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
import QtQuick.Window 2.2

import QtQuick.Controls 1.4
import QtQuick.Layouts 1.1

import QtWebKit 3.0
import QtWebKit.experimental 1.0

PlasmaComponents.Page {

    property string title: ""
    property string bodyContent: ""
    property string source: ""
    property string originalLink: ""
    property string authoring: ""
    property string startUrl
    property string localStartUrl
    id: article
    anchors.centerIn: parent
    anchors.fill: parent
    signal back
    signal toPocket(string link)
    Item {
        anchors.fill: parent
        Rectangle {
            id: navWrapper
            width: parent.width
            height: backer.height
            color: "transparent"
            RowLayout {
                spacing: 10
                id: navRow
                width: parent.width
                height: backer.height
                PlasmaComponents.ToolButton {
                    id: back
                    Layout.minimumWidth: units.gridUnit * 3 //backLabel.width+50
                    Layout.minimumHeight: units.gridUnit * 3
                    iconSource: "draw-arrow-back"
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                        onClicked: {
                            //Emit back signal
                            article.back()
                        }
                        }
                    }
                }
                PlasmaExtras.Title {
                    id: articleTitle
                    text: title
                    font.pointSize: 16
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            //Emit back signal
                            article.back()
                        }
                    }
                }
                PlasmaComponents.TextField {
                    id: locationField
                    text: articleWeb.url
                    clearButtonShown: true
                    font.pointSize: 10
                    Layout.minimumHeight: units.gridUnit * 3
                    Layout.minimumWidth: units.gridUnit * 10
                    onAccepted: {
                        articleWeb.url = locationField.text
                    }
                }
                PlasmaComponents.ToolButton {
                    id: pocket
                    Layout.minimumWidth: units.gridUnit * 3
                    Layout.minimumHeight: units.gridUnit * 3
                    iconSource: "download-later"
                    text: i18n("Add to pocket")
                    onClicked: article.toPocket(
                                   locationField.text) //requestOp(field)
                }
                PlasmaComponents.ToolButton {
                    id: openExternal
                    Layout.minimumWidth: units.gridUnit * 3
                    Layout.minimumHeight: units.gridUnit * 3
                    iconSource: "window-new"
                    text: i18n("Open in browser")
                    onClicked: {
                        if (locationField.text == "about:blank"){
                            // Means we open the article source link
                            Qt.openUrlExternally(article.originalLink)
                        } else{
                            // Open the current page
                            Qt.openUrlExternally(articleWeb.url)
                        }
                    }
                }
                PlasmaComponents.ToolButton {
                    id: backer
                    Layout.minimumWidth: units.gridUnit * 3 //backLabel.width+50
                    Layout.minimumHeight: units.gridUnit * 3
                    iconSource: "draw-arrow-back"
                    opacity: articleWeb.canGoBack
                             && articleWeb.url != article.startUrl
                             && articleWeb.url != "about:blank" ? 1 : 0.1
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            if (articleWeb.canGoBack
                                    && articleWeb.url != article.startUrl
                                    && articleWeb.url != "about:blank") {
                                articleWeb.goBack()
                            }
                        }
                    }
                }
                PlasmaComponents.ToolButton {
                    id: forwarderer
                    Layout.minimumWidth: units.gridUnit * 3 //backLabel.width+50
                    Layout.minimumHeight: units.gridUnit * 3
                    iconSource: "draw-arrow-forward"
                    opacity: articleWeb.canGoForward
                             && articleWeb.url != "about:blank" ? 1 : 0.1
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            if (articleWeb.canGoForward
                                    && articleWeb.url != "about:blank") {
                                articleWeb.goForward()
                            }
                        }
                    }
                }
                PlasmaComponents.ToolButton {
                    id: closer
                    Layout.minimumWidth: units.gridUnit * 3 //backLabel.width+50
                    Layout.minimumHeight: units.gridUnit * 3
                    iconSource: "tab-close"
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            //Emit back signal
                            article.back()
                        }
                    }
                }
            }
        }
        Rectangle{
            id: readProgress
            anchors.top: navWrapper.bottom
            z:1
            height: units.gridUnit / 5
            width: {
                if ((articleWeb.contentHeight-webWrapper.height) < 1){
                    // if on Yend = width to 100%
                    return webWrapper.width
                }
                //else do progress bar width processing
                return (articleWeb.contentY * webWrapper.width)/(articleWeb.contentHeight-webWrapper.height)
            }
            color: theme.highlightColor
        }
        Rectangle {
            id: webWrapper
            anchors.top: navWrapper.bottom
            anchors.bottom: parent.bottom
            width: parent.width
            color: "transparent"
            WebView {
                id: articleWeb
                anchors.fill: parent
                focus: true
                experimental.preferences.navigatorQtObjectEnabled: true
                /*onContentYChanged:{
                    Done at readProgress width binding.
                    Calculate the readProgress width...
                    var docHeight = articleWeb.contentHeight
                    var winHeight = webWrapper.height
                    var max = docHeight -winHeight
                    var value = contentY
                    readProgress.width = (value * parent.width)/max
                    readProgress.width = (contentY * parent.width)/(articleWeb.contentHeight-webWrapper.height)
                }*/
                experimental.onMessageReceived: {
                    console.debug(message)
                    console.log('onMessageReceived: ' + message.data)
                    var data = null
                    try {
                        data = JSON.parse(message.data)
                    } catch (error) {
                        console.log('onMessageReceived: ' + message.data)
                        return
                    }
                    switch (data.type) {
                    case 'link':
                    {
                        updateContextMenu(data.pageX, data.pageY, data.href)
                        if (data.target === '_blank') {
                            // open link in new tab
                            bounce.start()
                            openNewTab('page-' + salt(), data.href)
                        }
                        break
                    }
                    case 'longpress':
                    {
                        updateContextMenu(data.pageX, data.pageY,
                                          fixUrl(data.href))
                    }
                    case 'input':
                    {
                        keyboard.state = data.state
                        break
                    }
                    }
                }
                onNavigationRequested: {
                    // detect URL scheme prefix, most likely an external link
                    console.log("print request" + request.url + "\n navtype:"
                                + request.navigationType)
                    var schemaRE = /^\w+:/
                    if (schemaRE.test(request.url)) {
                        request.action = WebView.AcceptRequest
                    } else {
                        request.action = WebView.IgnoreRequest
                        // delegate request.url here
                    }
                }
                onUrlChanged: {
                    locationField.text = url
                    if (url == article.startUrl && url == "about:blank") {
                        console.log("We are on Start url, Reloading...")
                        article.updateContent()
                    }
                }
                Component.onCompleted: {
                    console.log("Define local start Url as: " + locationField.text)
                    article.localStartUrl = locationField.text
                }
            }
        }

        PlasmaComponents.Label {
            id: statusLabel
            text: articleWeb.loading ? "Loading" + " (%1%)".arg(
                                           articleWeb.loadProgress) : "Page loaded"
            anchors.bottom: parent.bottom
            z: 10
        }
    }
    function updateContent() {
        articleWeb.url = article.localStartUrl
        var headingFont = plasmoid.configuration.articleViewHeadingFont == 'default' ? theme.defaultFont.family : plasmoid.configuration.articleViewHeadingFont
        var bodyFont = plasmoid.configuration.articleViewBodyFont == 'default' ? 'serif' : plasmoid.configuration.articleViewBodyFont
        if (plasmoid.configuration.articleViewColors == 'theme'){
            var backgroundColor = theme.backgroundColor
            var textColor = theme.textColor
        }
        else if (plasmoid.configuration.articleViewColors == 'light'){
            var backgroundColor = "#f4f4f6"
            var textColor = "#313131"
        }
        else if (plasmoid.configuration.articleViewColors == 'sepia'){
            var backgroundColor = "#fbf0d9"
            var textColor = "#5b4636"
        }
        else if (plasmoid.configuration.articleViewColors == 'dark'){
            var backgroundColor = "#333333"
            var textColor = "#eeeeee"
        }
       var styleVert = '<style>body {'+
'    margin-top: ' + (80 * units.devicePixelRatio)  + 'px;'+
'    font-family: '+ bodyFont +', Arial, Helvetica, sans-serif;'+
'    content: "large";'+
'    background-color: ' + backgroundColor + ';'+
'    color:'+ textColor + ';' +
'    opacity: 0.9; '+
'    -webkit-font-smoothing: antialiased !important;'+
'    text-rendering: optimizelegibility !important;'+
'    letter-spacing: ' + (0.02 * units.devicePixelRatio)  + 'em;'+
'    text-align:center;'+
'    /*max-width:' + (12 * units.devicePixelRatio)  + 'em !important;*/'+
'    font-size: ' + (1.5 * units.devicePixelRatio)  + 'em;'+
'}'+
''+
'a {'+
'    color: #46aaa9;'+
'}'+
'body.loaded {'+
'  transition: color 0.4s, background-color 0.4s;'+
'}'+
''+
'header,article {'+
'    margin: 0 auto;'+
'    line-height: ' + (1.2 * units.devicePixelRatio)  + 'em;'+
'    max-width:' + (20 * units.devicePixelRatio)  + 'em !important;'+
''+
'}'+
''+
'h1 {'+
'    font-size: ' + (1.5 * units.devicePixelRatio)  + 'em;'+
'    text-align:center;'+
'    font-family:' + headingFont + ';'+
'    opacity: 0.8; '+
'    clear: both; '+
'    line-height: ' + (1 * units.devicePixelRatio)  + 'em;'+
'    max-width:' + (20 * units.devicePixelRatio)  + 'em !important;'+
'}'+
''+
'article p, .content div {'+
'    text-align: left;'+
'}'+
''+
'article {'+
'    text-align: justify;'+
'    margin: 0 auto;'+
'}'+
''+
'img {'+
'    margin: ' + (20 * units.devicePixelRatio)  + 'px;'+
'    display:block;'+
'    text-align: center;'+
'    margin: auto auto;max-width:100%;'+  
'}'+
'    '+
'#authoring {'+
'    float:left;'+
'}'+
'' +
'#authoring, #source {'+
'    font-size: ' + (0.4 * units.devicePixelRatio)  + 'em;'+
'    opacity: 0.5;'+
'}'+
''+
'#source{'+
'    text-align:center;'+
'}'+
''+
'/*'+
'@media only screen and (-webkit-min-device-pixel-ratio: 1.3), only screen and (-o-min-device-pixel-ratio: 13/10), only screen and (min-resolution: 120dpi) {'+
'    body {'+
'        font-size:200%;'+
'    }'+
''+
'    /* Your code to swap higher DPI images */'+
'}'+
''+
'/** sample media query for pixel-ratio=2" **/'+
'/*@media (-webkit-min-device-pixel-ratio: 1.3), (min-resolution: 105dpi) {'+
'    .pixel-ratio-holder:before {'+
'        content: "2sa";'+
'    }'+
'}*/</style>'
        var head = '<head>' + styleVert
                + '<script>function noBlanks() { var links = document.getElementsByTagName("a"); \
for (var i = 0; i < links.length; i++) { \
links[i].target = "_self"; \
} \

}</script> \
</head>'
        var html = '\
<html>' + head + 
'   <body onload="noBlanks();">\
        <header>\
            <span id="authoring">' + article.authoring + '</span>\
        \
        <h1>'+ 
        article.title + 
        '</h1>' +
        '<a id="source" href="' + article.originalLink + '">source</a></header>'+
        '<article>' + article.bodyContent +
            '</article><a href="' + article.originalLink + '">source</a>\
    </body>\
</html>'

        //article.startUrl=articleWeb.url
        //console.debug(html)
        articleWeb.loadHtml(html)
    }
    function setUrl() {
        //Set url from originalLink and set start url as original link
        articleWeb.url = article.originalLink
        pinStartUrl()
    }
    function pinStartUrl() {
        //Set currenturl as startUrl
        article.startUrl = articleWeb.url
        console.debug("Define Start Url as: " + locationField.text)
        article.startUrl = locationField.text
    }
}
