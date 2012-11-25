import datetime
from sqlalchemy import Column, Integer, String, DateTime, Boolean, Text, ForeignKey
from sqlalchemy.orm import relationship

from db import Base
from config import config

PARTICIPANT_TABLENAME = config.get('Database Parameters', 'participant_table_name')
LOCATION_TABLENAME = config.get('Database Parameters', 'location_table_name')
EXPERIMENT_TABLENAME = config.get('Database Parameters', 'experiment_table_name')

# possible statuses for a participant in the database
RESERVED = 0
CONSENTED = 1
STARTED = 2
COMPLETED = 3
DEBRIEFED = 4
QUITEARLY = 5

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
    
    def __init__(self, ipaddress, deviceid, processid):
        self.ipaddress = ipaddress
        self.deviceid = deviceid
        self.processid = processid
        self.status = RESERVED
        self.reservationtimestamp = datetime.datetime.now()
    
    def __repr__(self):
        return '<Band %r,%r, %r>' % (self.bandname, self.price, self.nowned)
# # create parent, append a child via association
# p = Parent()
# a = Association(extra_data="some data")
# a.child = Child()
# p.children.append(a)


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