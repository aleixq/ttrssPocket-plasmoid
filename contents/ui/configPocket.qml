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
import QtQuick.Extras 1.4
import QtQuick.Layouts 1.1


ColumnLayout {
    id: pocketConf
    property alias cfg_pocketConsumerKey: showPocketConsumerKey.text
    property alias cfg_pocketAccessToken: showPocketAccesToken.text
    property alias cfg_pocketUsername: showPocketUsername.text
    signal disconnectAccount
    signal connectAccount

    GridLayout {
        columns:2
        anchors.top:parent.top
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
        DelayButton{
            text: i18n("disconnect pocket account")
            onActivated: {
              showPocketUsername.text = ""
              showPocketAccesToken.text = ""
              text = i18n("account disconnected, click apply to process")
            
            }
        }
    }
}
