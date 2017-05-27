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

MouseArea {
    id: swipeArea

    property bool capture: false

    property int start_x
    property int start_y

    signal swipeUp
    signal swipeDown(int track)
    signal swipeLeft
    signal swipeRight

    onPressed: {
        if (!capture) {
            capture = true
            start_x = mouseX
            start_y = mouseY
        }
    }

    onPositionChanged: {
        if (capture) {
            var x_diff = mouseX - start_x
            var y_diff = mouseY - start_y

            var abs_x_diff = Math.abs(x_diff)
            var abs_y_diff = Math.abs(y_diff)

            if (abs_x_diff != abs_y_diff) {
                if (abs_x_diff > abs_y_diff) {
                    if (abs_x_diff > 50) {
                        if (x_diff > 0) {
                            swipeRight()
                        } else if (x_diff < 0) {
                            swipeLeft()
                        }
                        capture = false
                    }
                } else if (abs_y_diff > abs_x_diff) {
                    if (abs_y_diff > 50) {
                        if (y_diff > 0) {
                            swipeDown(y_diff)
                        } else if (y_diff < 0) {
                            swipeUp()
                        }
                        capture = false
                    }
                }
            }
        }
    }

    onClicked: {
        swipeUp()
    }

    onReleased: {
        capture = false
    }
}
