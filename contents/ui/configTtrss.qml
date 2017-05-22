
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
import QtQuick.Controls 1.4 as QtControls
import QtQuick.Layouts 1.1


ColumnLayout {
    property alias cfg_ttrssUrl: showTtrssUrl.text
    property alias cfg_ttrssUser: showTtrssUser.text
    property alias cfg_ttrssPw: showTtrssPw.text

    GridLayout {
        columns: 2
        anchors.top:parent.top
        QtControls.Label {
            text: i18n("Ttrss url:")
        }
        QtControls.TextField {
            id: showTtrssUrl
            Layout.preferredWidth: 600
        }

        QtControls.Label {
            text: i18n("Ttrss user:")
        }
        QtControls.TextField {
            id: showTtrssUser
            Layout.preferredWidth: 300
        }
        QtControls.Label {
            text: i18n("Ttrss password:")
        }
        QtControls.TextField {
            id: showTtrssPw
            echoMode: TextInput.PasswordEchoOnEdit
            Layout.preferredWidth: 300
        }
    }
}
