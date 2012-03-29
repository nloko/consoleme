consoleme
=========

View the system log on any iOS device running OS version 4.x and up.

Details
-------

The log is filtered to 30 mins of data and up to 125 log entries.

See constansts...

    static const int kMaxMinutes = 30;
    static const int kMaxLines = 125; 

...at the top of `ConsoleMeViewController.m`. You can change these to tweak to your liking.

Configuration
-------------

Edit the `NLOEmail` value in `consoleme-Info.plist` to set the address that
will be used for e-mailing the logs.

Usage
-----

On application start, the log will be retrived and displayed. You can scroll to view
the log and tap to view applicable actions.

Copyright and License
---------------------

Copyright 2012 Neil Loknath

[Apache licensed](http://www.apache.org/licenses/LICENSE-2.0)

Enjoy!
