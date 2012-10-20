iConsent
========

*What is it?*
-------------
A system for psychologists designed to manage and collect informed consent using iPads.  Ditch the file 
cabinets full of papers!  Join the future!  It's easy!

*What does it do?*
-----------------
The software provides an iOS application that runs on iPads that communicates with a server processes
running on a computer of your choice.  The application presents informed consent forms to a participant,
allows them to sign using their finger, collects demographic information, and sends the results (including
an image of the signature) up to the server for centralized logging.  In addition, the system can 
coordinate subject identification numbers and counterbalance experimental conditions across multiple 
testing sites.

*What does it NOT do?*
----------------------
While the code might be the starting point for designing iPad based experiments, it is meant to
be a stand-alone app simply for coordinating the informed consent component of any experiment
(computer-based or not).  Thus, it is ideal for things like developmental studies or field work
where you might not use a computer for the actual experiment, but might still want computerized
records of the informed consent.  The code can easily be merged into other iPad-based experiments
to provide a seamless and professional workflow.

*How does it work?*
-------------------
The software setup is pretty simple:

1. You clone a copy of the project from Github.
1. You customize a few of the configuration files for your particular set up.  
1. You use the [iOS developer tools](https://developer.apple.com/devcenter/ios/index.action) (XCode) to compile the application and install it on your iPad using USB.  
1. You install MySQL someplace (optional).
1. You launch the server code and leave it running in the background on a computer with a constant Internet connection. 
1. You take the iPad out into the world and do awesome science!

*Dependencies*
-------------------
You will need a relatively recent version of Python with the following modules installed

- [Flask](http://flask.pocoo.org/) - A lightweight web framework
- [SQLAlchemy](http://www.sqlalchemy.org/) - A powerful SQL abstraction layer

You can install these items with the following commands:

```
easy_install Flask-SQLAlchemy
easy_install Flask
```

To serve the experiment you will need to run the code from a web server connected to the Internet.
A further (optional) dependency is an installation of MySQL running on a Internet accessible 
computer.

In addition you will need the most recent copy of Apple's XCode software and an [iOS developer](https://developer.apple.com/devcenter/ios/index.action)
account (to compile and install the app).