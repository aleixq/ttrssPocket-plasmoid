
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
import QtQuick 2.0
import QtQuick.Controls 2.0 as QtControls
import QtQuick.Layouts 1.1


ColumnLayout {
    id: style
    property alias cfg_shadows: shadow.checked
    property string cfg_articleViewColors: "theme"
    property string cfg_articleViewHeadingFont
    property string cfg_articleViewBodyFont
    
    onCfg_articleViewHeadingFontChanged: {
        // HACK by the time we populate our model and/or the ComboBox is finished the value is still undefined
        if (cfg_articleViewHeadingFont) { 
            for (var i = 0, j = headingsFontsModel.count; i < j; ++i) {
                if (headingsFontsModel.get(i).value == cfg_articleViewHeadingFont) {
                    articleViewHeadingFont.currentIndex = i
                    break
                }
            }
        }
    }
    onCfg_articleViewBodyFontChanged: {
        // HACK by the time we populate our model and/or the ComboBox is finished the value is still undefined
        if (cfg_articleViewBodyFont) { 
            for (var i = 0, j = bodyFontsModel.count; i < j; ++i) {
                if (bodyFontsModel.get(i).value == cfg_articleViewBodyFont) {
                    articleViewBodyFont.currentIndex = i
                    break
                }
            }
        }
    }
    
    signal configurationChanged
    ListModel {
        id: bodyFontsModel
        Component.onCompleted: {
            var arr = [] 
            arr.push({text: i18nc("Use default font", "Default"), value: ""})
            
            var fonts = Qt.fontFamilies()
            var foundIndex = 0
            for (var i = 0, j = fonts.length; i < j; ++i) {
                arr.push({text: fonts[i], value: fonts[i]})
            }
            append(arr)
            foundIndex = articleViewBodyFont.find(plasmoid.configuration.articleViewBodyFont)
            articleViewBodyFont.currentIndex = foundIndex;
        }
    }
    ListModel {
        id: headingsFontsModel
        Component.onCompleted: {
            var arr = [] 
            arr.push({text: i18nc("Use default font", "Default"), value: ""})
            
            var fonts = Qt.fontFamilies()
            var foundIndex = 0
            for (var i = 0, j = fonts.length; i < j; ++i) {
                arr.push({text: fonts[i], value: fonts[i]})
                if (arr[i]["text"] == plasmoid.configuration.articleViewHeadingFont){
                    foundIndex = i
                }
            }
            append(arr)
            foundIndex = articleViewHeadingFont.find(plasmoid.configuration.articleViewHeadingFont)
            articleViewHeadingFont.currentIndex = foundIndex;
        }
    }    
    GridLayout {
        columns: 2
        anchors.top:parent.top
        QtControls.Label {
            text: i18n("Show thumbnail shadow effects")
        }
        QtControls.CheckBox {
            id: shadow
            Layout.preferredWidth: 600
        }

        QtControls.Label {
            text: i18n("Article view colors")
        }
        QtControls.ComboBox {
            id: articleViewColors
            Layout.preferredWidth: 600
            textRole: "label"
            model: [
                {
                    'label': i18n("Theme"),
                    'name': "theme"
                },
                {
                    'label': i18n("Light"),
                    'name': "light"
                },
                {
                    'label': i18n("Sepia"),
                    'name': "sepia"
                },                
                {
                    'label': i18n("Dark"),
                    'name': "dark"
                }
            ]  
            onCurrentIndexChanged: cfg_articleViewColors = model[currentIndex]["name"]
            Component.onCompleted: {
              
                          for (var i = 0; i < model.length; i++) {
                              if (model[i]["name"] == plasmoid.configuration.articleViewColors) {
                                  articleViewColors.currentIndex = i;
                              }
                          }
                      }
        }

        QtControls.Label {
            text: i18n("Article heading font")
        }
        QtControls.ComboBox {
            id: articleViewHeadingFont
            Layout.preferredWidth: 600
            model: headingsFontsModel
            // doesn't autodeduce from model because we manually populate it
            textRole: "text"

            onCurrentIndexChanged: {
                var current = model.get(currentIndex)
                if (current) {
                    cfg_articleViewHeadingFont = current.value
                    style.configurationChanged()
                }
            }
        }
        QtControls.Label {
            text: i18n("Article body font")
        }
        QtControls.ComboBox {
            id: articleViewBodyFont
            Layout.preferredWidth: 600
            model: bodyFontsModel
            // doesn't autodeduce from model because we manually populate it
            textRole: "text"

            onCurrentIndexChanged: {
                var current = model.get(currentIndex)
                if (current) {
                    cfg_articleViewBodyFont = current.value
                    style.configurationChanged()
                }
            }
        }
    }
    Rectangle{
        property var textColor : { 
            "sepia" : {"background" : "#fbf0d9", "textColor" : "#5b4636"}, 
            "theme" : {"background" : theme.backgroundColor, "textColor" : theme.textColor } , 
            "dark": {"background" : "#333333", "textColor" : "#eeeeee"},
            "light": {"background" : "#f4f4f6", "textColor" : "#313131"}
        }
        color: textColor[cfg_articleViewColors]["background"]
        Layout.fillWidth: true
        height: units.gridUnit * 10
        QtControls.Label {
            id: headingSample
            text: "<h1>" +i18n("Heading") +"</h1>"
            color: parent.textColor[cfg_articleViewColors]['textColor']
            font.family : cfg_articleViewHeadingFont
            anchors.horizontalCenter:parent.horizontalCenter
        }
        QtControls.Label {
            text: i18n("Sample body text.")
            color: parent.textColor[cfg_articleViewColors]['textColor']
            font.family : cfg_articleViewBodyFont
            anchors.top:headingSample.bottom
            anchors.horizontalCenter:parent.horizontalCenter
        }
    }    
}
