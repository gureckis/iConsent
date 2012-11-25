#  app.py
#  RectangleGame_v1
#
#  Created by Todd Gureckis on 3/12/12.
#  Copyright (c) 2012 New York University. All rights reserved.

from string import split
import os
import time
import datetime
import os.path
from random import choice, shuffle, seed, getstate, setstate
import sys
from sqlalchemy import *
from functools import wraps

# importing the Flask library
from flask import Flask, render_template, request, Response, jsonify, send_from_directory
from werkzeug import secure_filename

# Database setup
from db import db_session, init_db
from models import Participant, Experiment, Location
from sqlalchemy import or_, and_

# loads configuation
from config import config

UPLOAD_FOLDER = config.get('Database Parameters', 'upload_folder')
ALLOWED_EXTENSIONS = set(['jpg', 'jpeg'])


app = Flask(__name__)
#app.config['UPLOAD_FOLDER']=UPLOAD_FOLDER

#----------------------------------------------
# allowed file names for signature upload
#----------------------------------------------
def allowed_file(filename):
    return '.' in filename and filename.rsplit('.', 1)[1] in ALLOWED_EXTENSIONS

#/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*
# db setup
#/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*

#----------------------------------------------
# DB setup
#----------------------------------------------
@app.teardown_request
def shutdown_session(exception=None):
    db_session.remove()


#/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*
# routes
#/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*


###########################################################
# informational
###########################################################

#----------------------------------------------
# get general experiment info
#----------------------------------------------
@app.route('/GetServerInfo', methods=['GET'])
def get_server_info():
    org = config.get('General Info', 'org_name')
    locations = Location.query.all()
    mylocs = [i.locname for i in locations]
    experiments = Experiment.query.filter_by(active=True).all()
    myexps = [i.expname for i in experiments]
    db_session.commit()
    return jsonify(org_name=org, locations=mylocs, experiments=myexps)


###########################################################
# take action!
###########################################################

#----------------------------------------------
# reserve a subject number
#----------------------------------------------
@app.route('/MakeReservation', methods=['POST'])
def reserve_new_subject():
    if request.method == 'POST':
        if request.form.has_key('deviceID') and request.form.has_key('processID'):

            deviceID = request.form['deviceID']
            processID = request.form['processID']
            
            # see if this pair already exists
            matches = Participant.query.filter_by(deviceid=deviceID).filter_by(processid=processID).all()
            numrecs = len(matches)
            if numrecs == 0:
                ipaddr = request.remote_addr
                if ipaddr == None:
                    ipaddr = "UNKNOWNIP"
                    
                # set these up and insert into database
                part = Participant(ipaddr, deviceID, processID)
                db_session.add(part)
                db_session.commit()
                return jsonify(subjid=str(part.pid))
            else:
                # this already exists.  something weird is happening
                msg = "this device/process id exist already"
                print msg
                db_session.commit()
                return jsonify(status="error", msg=msg)
        else:
            msg = "didn't get the device and processid"
            print msg
            return jsonify(status="error", msg = msg)
    else:
        msg = "didn't get a POST"
        print msg
        return jsonify(status="error, no POST data")

#----------------------------------------------
# finished with study info
#----------------------------------------------
@app.route('/StudyInfoFinished', methods=['POST'])
def study_info_finished():
    if request.method == 'POST':
        if request.form.has_key('deviceID') and request.form.has_key('processID') \
            and request.form.has_key('subjectID') and request.form.has_key('childStudy') \
            and request.form.has_key('currentExperiment') and request.form.has_key('currentLocation'):
            
            deviceID = request.form['deviceID']
            processID = request.form['processID']
            subjectID = request.form['subjectID']
            childStudy = request.form['childStudy']
            currentExperiment = request.form['currentExperiment']
            currentLocation = request.form['currentLocation']
            
            print subjectID, childStudy, currentExperiment, currentLocation
            # see if this pair already exists
            person = Participant.query.filter_by(deviceid=deviceID).filter_by(processid=processID).one()
            if person:
                person.subjectid = subjectID
                person.child = childStudy
                exp = Experiment.query.filter_by(expname=currentExperiment).one()
                if exp:
                    person.expid = exp.expid
                else:
                    msg = "Error looking up experiment"
                    print msg
                    return jsonify(status="error", msg=msg)
                loc = Location.query.filter_by(locname=currentLocation).one()
                if loc:
                    person.locid = loc.locid
                else:
                    msg = "Error looking up location"
                    print msg
                    return jsonify(status="error", msg=msg)
                db_session.add(person)
                db_session.commit()
                # this already exists.  something weird is happening
                msg = "everything seems to have gone ok"
                print msg
                return jsonify(status="success", msg=msg)
            else:
                # this already exists.  something weird is happening
                msg = "this device/process id exists already"
                print msg
                db_session.commit()
                return jsonify(status="error", msg=msg)
        else:
            msg = "didn't get the device and processid"
            print msg
            return jsonify(status="error", msg = msg)
    else:
        msg = "didn't get a POST"
        print msg
        return jsonify(status="error, no POST data")

#----------------------------------------------
# load the consent form
#----------------------------------------------
@app.route('/consent', methods=['GET'])
def give_consent():
    return render_template('consent.html')

#@app.route('/demo', methods=['GET'])
#def demo():
#
#    # add an experiment
#    exp = Experiment('Causal Learning', True)
#    db_session.add(exp)
#    db_session.commit()
#
#    # add a location
#    loc = Location('NYU - Gureckis lab')
#    db_session.add(loc)
#    db_session.commit()
#
#    # add a first person
#    part = Participant('myipaddress', 'mydeviceid', 'processid')
#    part.exp = exp
#    part.loc = loc
#    db_session.add(part)
#    db_session.commit()
#    
#    # add a second person
#    part = Participant('myipaddres2', 'mydeviceid2', 'processid2')
#    part.exp = exp
#    part.loc = loc
#    db_session.add(part)
#    db_session.commit()
#
#    # participant
#    part = Participant.query.\
#        filter(Participant.ipaddress == 'myipaddress').\
#        one()
#    print part.expid
#    print part.exp.expname

#----------------------------------------------
# generic route
#----------------------------------------------
@app.route('/<pagename>')
#@requires_auth
def regularpage(pagename=None):
    if pagename==None:
        print "error"
    else:
        return render_template(pagename)

#----------------------------------------------
# favicon issue - http://flask.pocoo.org/docs/patterns/favicon/
#----------------------------------------------
@app.route('/favicon.ico')
def favicon():
    return send_from_directory(os.path.join(app.root_path, 'static'),
            'favicon.ico', mimetype='image/vnd.microsoft.icon')

###########################################################
# let's start
###########################################################

# intialize database if necessary
init_db()

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5003)

