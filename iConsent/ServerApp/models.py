import datetime
from sqlalchemy import Column, Integer, String, DateTime, Boolean, Text, ForeignKey
from sqlalchemy.orm import relationship

from db import Base
from config import config

PARTICIPANT_TABLENAME = config.get('Database Parameters', 'participant_table_name')
LOCATION_TABLENAME = config.get('Database Parameters', 'location_table_name')
EXPERIMENT_TABLENAME = config.get('Database Parameters', 'experiment_table_name')
EMAIL_TABLENAME = config.get('Database Parameters', 'emaillist_table_name')

# possible statuses for a participant in the database
RESERVED = 0
CONSENTED = 1
INFORECVD = 2
STARTED = 3
COMPLETED = 4
DEBRIEFED = 5
QUITEARLY = 6

###########################################################
# the model
###########################################################

class Experiment(Base):
    __tablename__ = EXPERIMENT_TABLENAME
    expid = Column(Integer, primary_key=True)
    expname = Column(String(256), unique=True)
    active = Column(Boolean)
    
    def __init__(self, name, active):
        self.expname = name
        self.active = active

class Location(Base):
    __tablename__ = LOCATION_TABLENAME
    locid = Column(Integer, primary_key=True)
    locname = Column(String(256), unique=True)
    
    def __init__(self, name):
        self.locname = name
    
    def __repr__(self):
        return '<User %r,%r, %r>' % (self.username, self.email, self.balance)

class Participant(Base):
    __tablename__ = PARTICIPANT_TABLENAME
    
    pid = Column(Integer, primary_key=True)
    ipaddress = Column(String(11))
    deviceid = Column(String(128))
    processid = Column(String(128))
    status = Column(Integer)
    signaturerecv = Column(Boolean)
    reservationtimestamp = Column(DateTime,nullable=True)
    expid = Column(Integer, ForeignKey('experiments.expid'))
    locid = Column(Integer, ForeignKey('locations.locid'))
    exp = relationship('Experiment', lazy='joined', uselist=False, primaryjoin=expid==Experiment.expid)
    loc = relationship('Location', lazy='joined', uselist=False, primaryjoin=locid==Location.locid)
    subjectid = Column(String(10))
    child = Column(Boolean)
    age_in_months = Column(Integer)
    age_in_years = Column(Integer)
    gender = Column(String(1))
    name = Column(String(256))
    participantinfo = Column(Text)
    
    def __init__(self, ipaddress, deviceid, processid):
        self.ipaddress = ipaddress
        self.deviceid = deviceid
        self.processid = processid
        self.status = RESERVED
        self.reservationtimestamp = datetime.datetime.now()
    
    def __repr__(self):
        return '<Participant %r,%r, %r>' % (self.status, self.processid, self.status)

class EmailListItem(Base):
    __tablename__ = EMAIL_TABLENAME
    emailid = Column(Integer, primary_key=True)
    emailaddress = Column(String(128))
    expid = Column(Integer, ForeignKey('experiments.expid'))
    locid = Column(Integer, ForeignKey('locations.locid'))
    exp = relationship('Experiment', lazy='joined', uselist=False, primaryjoin=expid==Experiment.expid)
    loc = relationship('Location', lazy='joined', uselist=False, primaryjoin=locid==Location.locid)
    active = Column(Boolean)
    
    def __init__(self, email):
        self.emailaddress = email
        self.active = True

# how to serialize (i.e., JSONify) an obect
#    def serialize(self, owned, pricethreshold):
#        affordable = True if self.price < pricethreshold else False
#        return {
#            'bid': str(self.bid),
#            'bandname': str(self.bandname),
#            'price': str(self.price),
#            'image': str(self.image),
#            'owned': str(owned),
#            'affordable': str(affordable)
#            }