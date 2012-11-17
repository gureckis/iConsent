#  app.py
#  RectangleGame_v1
#
#  Created by Todd Gureckis on 3/12/12.
#  Copyright (c) 2012 New York University. All rights reserved.

from flask import Flask, render_template, request, Response, jsonify, send_from_directory
from werkzeug import secure_filename
from string import split
import os
import time
import datetime
import os.path
from random import choice, shuffle, seed, getstate, setstate
import sys
from sqlalchemy import *
from functools import wraps

from config import config

DATABASE = config.get('Database Parameters', 'database_url')
TABLENAME = config.get('Database Parameters', 'table_name')
UPLOAD_FOLDER = config.get('Database Parameters', 'upload_folder')

ALLOWED_EXTENSIONS = set(['jpg', 'jpeg'])
CONSENTED = 1
STARTED = 2
COMPLETED = 3
DEBRIEFED = 4
QUITEARLY = 5

app = Flask(__name__)
#app.config['UPLOAD_FOLDER']=UPLOAD_FOLDER

# Column('subjID', Integer, primary_key=True),
# Column('ipaddress', String(128)),
# Column('deviceID', String(128)),
# Column('processID', String(128)),
# Column('firstName', String(128)),
# Column('lastName', String(128)),
# Column('gender', String(128)),
# Column('birthDate', String(128)),
# Column('location', String(128)),
# Column('consent', Boolean),
# Column('signature', String(128)), # this probably needs a different datatype
# Column('reservationTimeStamp', DateTime(), nullable=True),
# Column('beginExpTimeStamp', DateTime(), nullable=True),
# Column('endExpTimeStamp', DateTime(), nullable=True),
# Column('status', Integer),
# Column('debriefed', Boolean),
# Column('cond', Integer),
# Column('counterbalance', Integer),
# Column('datafile', Text, nullable=True),  #the data from the exp


#----------------------------------------------
# lists the subject info
#----------------------------------------------
@app.route('/subjectinfo', methods=['POST'])
def update_subject():
    if request.method == 'POST':
        #print "GOT A POST REQUEST", request.form.keys()
        if request.form.has_key('subjid') and request.form.has_key('firstName') and request.form.has_key('lastName') and request.form.has_key('gender') \
            and request.form.has_key('birthdate') and request.form.has_key('location'):
            subjid = request.form['subjid']
            firstName = request.form['firstName']
            lastName = request.form['lastName']
            gender = request.form['gender']
            birthDate = request.form['birthdate']
            location = request.form['location']
            print firstName, lastName, gender, birthDate, location
            # # see if this pair already exists
            conn = engine.connect()
            results = conn.execute(participantsdb.update().where(participantsdb.c.subjID==subjid).values( \
                firstName=firstName, lastName=lastName, gender=gender, birthDate=birthDate, location=location, beginExpTimeStamp=datetime.datetime.now(), status=STARTED))
            conn.close()
            return jsonify(state="success")
        else:
            print "ERROR"
            return jsonify(status="error")


#----------------------------------------------
# allowed file names for signature upload
#----------------------------------------------
def allowed_file(filename):
    return '.' in filename and filename.rsplit('.', 1)[1] in ALLOWED_EXTENSIONS


#----------------------------------------------
# reserve a subject number
#----------------------------------------------
@app.route('/reserve', methods=['POST'])
def reserve_new_subject():
    if request.method == 'POST':
        #print "GOT A POST REQUEST", request.form.keys()
        if request.form.has_key('deviceID') and request.form.has_key('processID'):
            deviceID = request.form['deviceID']
            processID = request.form['processID']
            print deviceID, processID
            # see if this pair already exists
            conn = engine.connect()
            s = select([participantsdb.c.subjID])
            s = s.where(and_(participantsdb.c.processID==processID, participantsdb.c.deviceID==deviceID))
            result = conn.execute(s)
            matches = [row for row in result]
            numrecs = len(matches)
            if numrecs == 0:
                # doesn't exist, assign condition number and counterbalancing condition
                print "this process doesn't exist"
                
                
                subj_cond = 10
                subj_counter = 100
                
                if request.remote_addr == None:
                    myip = "UNKNOWNIP"
                else:
                    myip = request.remote_addr
                    
                # set these up and insert into database
                result = conn.execute(participantsdb.insert(),
                    ipaddress = myip,
                    deviceID = deviceID,
                    processID = processID,
                    cond=subj_cond,
                    consent=True,
                    counterbalance = subj_counter,
                    status = CONSENTED,
                    signatureRecv = False,
                    reservationTimeStamp = datetime.datetime.now()
                )
                
                myid = result.inserted_primary_key[0]
                
                if request.files.has_key('signature'):
                    file = request.files['signature']
                    if file and allowed_file(file.filename):
                        filename = str(myid)+'.jpg'
                        file.save(os.path.join(app.config['UPLOAD_FOLDER'], filename))
                        results = conn.execute(participantsdb.update().where(participantsdb.c.subjID==myid).values(signatureRecv=True))
                conn.close()
                return jsonify(subjid=myid, cond=subj_cond, counterbalance=subj_counter)
            else:
                # this already exists.  something weird is happening
                print "it seems thie device/process id exist already"
                conn.close()
                return jsonify(status="error")
        else:
            print "didn't get the device and processid"
            return jsonify(status="error")


#----------------------------------------------
# get organization name
#----------------------------------------------
@app.route('/GetOrganizationName', methods=['GET'])
def get_org_name():
    myorg = "New York Universitae"
    return jsonify(org_name=myorg)

#----------------------------------------------
# get experiment parameters
#----------------------------------------------
@app.route('/GetExperimentNames', methods=['GET'])
def get_experiment_names():
    mylist = ["Entomologist", "Causal Learning", "Tree Game", "Social Learning"]
    return jsonify(json_result=mylist)

#----------------------------------------------
# get location parameters
#----------------------------------------------
@app.route('/GetLocationNames', methods=['GET'])
def get_location_names():
    mylist = ["AMNH", "CMOM", "NYU - Somewhere else", "NYU - Gureckis Lab", "NYU - Rhodes Lab"]
    return jsonify(json_result=mylist)

#----------------------------------------------
# load the consent form
#----------------------------------------------
@app.route('/consent', methods=['GET'])
def give_consent():
    return render_template('consent.html')

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

#----------------------------------------------
# database management
#----------------------------------------------
def createdatabase(engine, metadata):
    
    # try to load tables from a file, if that fails create new tables
    try:
        participants = Table(TABLENAME, metadata, autoload=True)
    except: # can you put in the specific exception here?
        # ok will create the database
        print "ok will create the participant database"
        participants = Table(TABLENAME, metadata,
          Column('subjID', Integer, primary_key=True),
          Column('ipaddress', String(128)),
          Column('deviceID', String(128)),
          Column('processID', String(128)),
          Column('firstName', String(128)),
          Column('lastName', String(128)),
          Column('gender', String(128)),
          Column('birthDate', String(128)),
          Column('location', String(128)),
          Column('consent', Boolean),
          Column('signatureRecv', Boolean), # this probably needs a different datatype
          Column('reservationTimeStamp', DateTime(), nullable=True),
          Column('beginExpTimeStamp', DateTime(), nullable=True),
          Column('endExpTimeStamp', DateTime(), nullable=True),
          Column('status', Integer),
          Column('debriefed', Boolean),
          Column('cond', Integer),
          Column('counterbalance', Integer),
          Column('datafile', Text, nullable=True),  #the data from the exp
        )
        participants.create()
    return participants


#----------------------------------------------
# loaddatabase from scratch
#----------------------------------------------
def loaddatabase(engine, metadata):
    # try to load tables from a file, if that fails create new tables
    try:
        participants = Table(TABLENAME, metadata, autoload=True)
    except: # can you put in the specific exception here?
        print "Error, participants table doesn't exist"
        exit()
    return participants


###########################################################
# let's start
###########################################################
if __name__ == '__main__':
    if len(sys.argv) == 1:
        print "Useage: python webapp.py [initdb/server]"
    elif len(sys.argv)>1:
        engine = create_engine(DATABASE, echo=False) 
        metadata = MetaData()
        metadata.bind = engine
        if sys.argv[1]=='initdb':
            print "initializing database"
            createdatabase(engine, metadata)
            pass
        elif sys.argv[1]=='server':
            print "starting webserver"
            participantsdb = loaddatabase(engine, metadata)
            # by default just launch webserver
            app.run(debug=True, host='0.0.0.0', port=5003)

