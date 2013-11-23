#!/bin/bash

# create KIS_VPN_HOME
KIS_VPN_HOME=$HOME/kis-vpn
test ! -e $KIS_VPN_HOME && mkdir $KIS_VPN_HOME
cd $KIS_VPN_HOME

# download firefox 18 32bit -> firefox 19 breaks kis juniper vpn host check
if [ ! -e firefox ]; then
	wget --no-check-certificate https://ftp.mozilla.org/pub/mozilla.org/firefox/releases/18.0.2/linux-i686/de/firefox-18.0.2.tar.bz2 -O firefox.tar.bz2
	tar xjvf firefox.tar.bz2
fi
# download java 32bit
if [ ! -e jre ]; then
	wget --no-cookies --no-check-certificate --header "Cookie: gpw_e24=http%3A%2F%2Fwww.oracle.com%2F" http://download.oracle.com/otn-pub/java/jdk/7u45-b18/jre-7u45-linux-i586.tar.gz -O jre.tar.gz
	tar xzvf jre.tar.gz
	mv jre1* jre
fi
# setup java
export JAVA_HOME=$KIS_VPN_HOME/jre
export PATH=$JAVA_HOME/bin:$PATH

# desc: http://kb.mozillazine.org/About:config_entries#Extensions.
echo "pref(\"browser.shell.checkDefaultBrowser\", \"false\");" > $FIREFOX_HOME/defaults/pref/kis-vpn-prefs.js
echo "pref(\"extensions.enabledScopes\", \"1\");" >> $FIREFOX_HOME/defaults/pref/kis-vpn-prefs.js 
echo "pref(\"extensions.autoDisableScopes\", \"15\");" >> $FIREFOX_HOME/defaults/pref/kis-vpn-prefs.js 

# create firefox profile
FIREFOX_PROFILE=kis-vpn-profile
FIREFOX_HOME=$KIS_VPN_HOME/firefox
test ! -e $KIS_VPN_HOME/$FIREFOX_PROFILE && $FIREFOX_HOME/firefox -CreateProfile "$FIREFOX_PROFILE $KIS_VPN_HOME/$FIREFOX_PROFILE"
# force plugin scan with new scopes
test -e $KIS_VPN_HOME/$FIREFOX_PROFILE/pluginreg.dat && rm $KIS_VPN_HOME/$FIREFOX_PROFILE/pluginreg.dat

# link java-browser-plugin
test ! -e $KIS_VPN_HOME/$FIREFOX_PROFILE/plugins && mkdir $KIS_VPN_HOME/$FIREFOX_PROFILE/plugins
test ! -e $KIS_VPN_HOME/$FIREFOX_PROFILE/plugins/mozilla-javaplugin.so && ln -s $JAVA_HOME/lib/i386/libnpjp2.so $KIS_VPN_HOME/$FIREFOX_PROFILE/plugins/mozilla-javaplugin.so
# start firefox with kis-vpn profile
setarch i686 $FIREFOX_HOME/firefox -no-remote -P $FIREFOX_PROFILE -new-window $1