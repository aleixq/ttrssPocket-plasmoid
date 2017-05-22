
/* JSONListModel - a QML ListModel with JSON and JSONPath support
*
* Copyright (c) 2012 Romain Pokrzywka (KDAB) (romain@kdab.com)
* Licensed under the MIT licence (http://opensource.org/licenses/mit-license.php)
*/
import QtQuick 2.0
import "../code/jsonpath.js" as JSONPath

Item {
    property string source: ""
    property string contentType: "application/json; charset=UTF-8"
    property string postData: ""
    property string requestType: "GET"
    property string json: ""
    property string query: ""

    property bool doResetModel: true
    property bool loading: false
    property bool listModelUpdate: false

    property ListModel model: ListModel {
        id: jsonModel
        dynamicRoles: true
    }
    property alias count: jsonModel.count

    property string status
    property string readyState

    function refresh() {
        if (loading === true){
            //semafor to prevent too much posts 
            console.debug("Http requester is busy already")
            return
        }
        loading = true
        var xhr = new XMLHttpRequest()
        xhr.open(requestType, source, true)
        xhr.setRequestHeader("Content-Type", contentType)
        xhr.setRequestHeader("X-Accept", "application/json")
        xhr.onreadystatechange = function () {
            readyState = xhr.readyState
            if (xhr.readyState === XMLHttpRequest.DONE) {
                status = xhr.status
                if (xhr.status === 200) {
                    //                     console.log("ZZZZZZZZZZZZZZZZZ"+xhr.responseText+"VVVVVVVVVVVVVVV");
                    // Trigs onJsonChanged to process
                    json = xhr.responseText
                } else if (xhr.status === 400) {
                    console.log("xhr.status: 400 - Invalid request, please make sure you follow the documentation for proper syntax")
                } else if (xhr.status === 401) {
                    //NOT IMPLEMENTED IN TTRSS
                    console.log("xhr.status: 401 - Not authorized") 
                    //ttrss.requestToken = ""
                } else if (xhr.status === 503) {
                    //NOT IMPLEMENTED IN TTRSS
                    console.log("xhr.status: 503 - TTRSS Server is down for scheduled maintenance")
                } else if (xhr.status === 0) {
                    ttrss.countLoading = 0
                } else {
                    console.log("error in onreadystatechange: " + xhr.status + " "
                                + xhr.statusText + ", " + xhr.getAllResponseHeaders(
                                    ) + "," + xhr.responseText)
                }
                loading = false
            }
        }
        //console.log("Sending request to JSON API")
        if (requestType == "POST") {
            xhr.send(postData)
        } else {
            xhr.send()
        }
    }
    onSourceChanged: {
        doResetModel = true
        refresh()
    }
    onJsonChanged: {console.debug("JSON changed");updateJSONModel()}
    onQueryChanged: {
        doResetModel = true
        console.debug("query changed to:" + query)
    }
    onPostDataChanged: {
        console.debug("Setting post data to: " + JSON.stringify(postData))
        refresh()
    }
    onDoResetModelChanged: {

        //         console.trace()
        //         console.log("RESET MODEL CHANGED to "+doResetModel)
    }

    function updateJSONModel() {
        console.debug("update json model " + json.substring(0, 1000) + "... ")
        if (jsonModel.count > 0 && doResetModel) {
            jsonModel.clear()
        }

        if (json === "") {
            loading = false
            return
        }

        var objectArray = parseJSONString(json, query)
        var i = 0
        for (var key in objectArray) {
            console.debug(i+")- ["+key+"] : " + objectArray[key]['title'])
            var jo = objectArray[key]
            jsonModel.append(jo)
            i=i+1
        }
        loading = false
        listModelUpdate = !listModelUpdate
    }

    function parseJSONString(jsonString, jsonPathQuery) {
        var objectArray = JSON.parse(jsonString)
        if (jsonPathQuery !== "") {
            objectArray = JSONPath.jsonPath(objectArray, jsonPathQuery)
        }
        //console.debug("will parse: "+jsonString+" through : \""+ jsonPathQuery +"\" to: " + JSON.stringify(objectArray))
        return objectArray
    }

    function clear() {
        jsonModel.clear()
    }
}
