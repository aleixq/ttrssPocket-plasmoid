## Description
This plasmoid will give you a nice full-screen touch friendly qml interface to tiny tiny rss and pocket.

This plasmoid was started in autumn of 2014 and upgraded in 2017. So maybe some mixing of qt modules are there (qtControls 2.0 and 1.0 sure). I 'll clean asap.

###build:
 zip -r ttrssPocket.zip /path/to/ttrssPocket

###Install:
plasmapkg2 -t plasmoid -i /path/to/ttrssPocket.zip

###Uninstall:
plasmapkg2 -t plasmoid -r /path/to/ttrssPocket.zip

##TODO
* It's not implemented any pager or categories browsing of Pocket.

##DEPENDS

It needs these qml modules:
* QtQuick 2.0
* QtQuick.Controls 2.0 
* QtQuick.Controls 1.4
* QtQuick.Layouts 1.1
* QtGraphicalEffects 1.0
* QtQuick.XmlListModel 2.0
* import QtQuick.Extras 1.4
* org.kde.plasma.core 2.0
* org.kde.plasma.components 2.0
* org.kde.plasma.extras 2.0
* org.kde.plasma.plasmoid 2.0
* QtQuick.XmlListModel 2.0
* QtWebKit 3.0 and experimental
* QtQuick.Window 2.2

In ubuntu/kde-neon some names of packages are: 
qml-module-qtquick-extras, qml-module-qtquick-xmllistmodel qml-module-qtquick-controls qml-module-qtquick-extras among others.
