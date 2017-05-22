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

/*
* NOTE
* The ordering in this file is as follows:
* - Variables
* - Functions without any network traffic
* - Functions with network traffic (beginning with login())
*/
/** @public */
// mode (integer) - type of operation to perform (0 - set to false, 1 - set to true, 2 - toggle)
var Toggle=2


var Headline = {
    //field (integer) - field to operate on (0 - starred, 1 - published, 2 - unread, 3 - article note since api level 1)
    'Starred': 0,
    'Published': 1,
    'Unread': 2,
    'ArticleNote': 3
}
var Feeds ={
    //-1 - starred, -2 - published    -3 - fresh    -4 - all articles    0 - archived    IDs < -10 - labels
    'Archived': 0,
    'Starred': -1,
    'Published': -2,
    'Fresh': -3,
    'All': -4,
    'Recently': -6
}


function firstImg(html) {    
    var m
    var urls = []
    var imgRegex = /<img[^>]+src="(http:\/\/.*?[jpg|jpeg|gif|png][^">]+)"/g;
    var imgRegex = /<img[^>]+src="(.*?[jpg|jpeg|gif|png][^"]+)"/g;
    var imgRegex = /<p.*?<img\b[^>]+?src\s*=\s*['"]?([^\s'"?#>]+)/g;
    var imgs=imgRegex.exec(html)

    /*
    If we want to iterate looking for more images
    while ( m = imgRegex.exec( html ) ) {
        urls.push( m[1] );
    }
    for (var i in imgs){
        console.debug("[ttrssJS]--found image--"+i+"->"+imgs[i])
        }
    */
    if (imgs){
      return imgs.length>0?imgs[1]:undefined
    }else{
      return undefined
    }
}
