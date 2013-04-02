idevice-packet-analyzer
=======================
iOS device usb packet analyser and prettifier
To listen to usb traffic use [socat](http://www.dest-unreach.org/socat/)

It can be installed with [homebrew](http://mxcl.github.com/homebrew/)

    brew install socat

iOS-based devices talk with host via usbmuxd process and it's unix socket /var/run/usbmuxd. 
To sniff the traffic you must replace original socket with fake one, redirect the traffic and log data.

    sudo mv /var/run/usbmuxd /var/run/usbmuxd_real
    sudo socat -t100 -x -v \
      UNIX-LISTEN:/var/run/usbmuxd,mode=777,reuseaddr,fork \
      UNIX-CONNECT:/var/run/usbmuxd_real \
      > /tmp/usbmuxd.log 2>&1

Use ioslog2html.sh to convert your log to html representation:

    /bin/bash ioslog2html.sh /tmp/usbmuxd.log ~/Desktop/usbmuxd.log.html

You may have issues with base64-encoded images transfers, they may corrupt log, working on it.
