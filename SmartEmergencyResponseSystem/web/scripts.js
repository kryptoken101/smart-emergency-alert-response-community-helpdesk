var PR_MODEL_URL =
'http://sketchup.google.com/3dwarehouse/download?'
+ 'mid=79240f1df13a79da1ab9df4be75138d0&rtyp=zip&'
+ 'fn=fireman&ctyp=other&ts=1223354336000'

//var RC_MODEL_URL = //is scaled by a factor 0.75 when loaded 
//'http://sketchup.var PR_MODEL_URL =
'http://sketchup.google.com/3dwarehouse/download?'
+ 'mid=79240f1df13a79da1ab9df4be75138d0&rtyp=zip&'
+ 'fn=fireman&ctyp=other&ts=1223354336000'

//var RC_MODEL_URL = //is scaled by a factor 0.75 when loaded 
//'http://sketchup.google.com/3dwarehouse/download?'
//+ 'mid=79af699573e9aa36c53862de621cdf23&rtyp=zip&'
//+ 'fn=Untitled&ctyp=other&ts=1248712558000';

var RC_MODEL_URL = 
'http://msdl.cs.mcgill.ca/people/mosterman/calls/interns2013/arducopter_v4.zip';

var AR_MODEL_URL = 
'http://msdl.cs.mcgill.ca/people/mosterman/calls/interns2013/ar_drone_2_v3.zip';

var FW_MODEL_URL =
'http://msdl.cs.mcgill.ca/people/mosterman/calls/interns2013/faser_v1.zip';

var AT_MODEL_URL =
'http://msdl.cs.mcgill.ca/people/mosterman/calls/interns2013/Robot_III.kmz'; 

var KK_MODEL_URL = 
'http://msdl.cs.mcgill.ca/people/mosterman/calls/interns2013/Sketchyphysics_3_Robotic_arm.kmz';

var BB_MODEL_URL =
'http://msdl.cs.mcgill.ca/people/mosterman/calls/interns2013/Dog.kmz';

//var FW_MODEL_URL =
//'http://sketchup.google.com/3dwarehouse/download?'
//+ 'mid=6826af6513566b12f4aab844bf68e35e&rtyp=zip&'
//+ 'fn=Halifax&ctyp=other&ts=1247980274000';

var AID_MODEL_URL =
'http://sketchup.google.com/3dwarehouse/download?'
+ 'mid=9f7ed9cdd4caa7306c8adaa492071bd8&rtyp=zip&'
+ 'fn=First+Aid+Kit&ctyp=other&prevstart=0&ts=1292661509000'

var GV_MODEL_URL =
'http://msdl.cs.mcgill.ca/people/mosterman/calls/interns2013/ford_escape_v1.zip';

//'http://sketchup.google.com/3dwarehouse/download?'
//+ 'mid=d754f935509b45af30714334794526d4&rtyp=zip&'
//+ 'fn=Ford+Escape+Xls&ctyp=other&ts=1288753398000'

var aKmlVehicle; //kmlObject

var la = new Array; //LookAt

var prP = new Array; //placemark kmlFeature
var pr = new Array; //person kmlGeometry
var prL = new Array; //person location
var prO = new Array; //person orientation

var gvP = new Array; //placemark kmlFeature
var gv = new Array; //ground vehicle kmlGeometry
var gvL = new Array; //ground vehicle location
var gvO = new Array; //ground vehicle orientation

var fwP = new Array; //placemark kmlFeature
var fw = new Array; //fixed wing vehicle kmlGeometry
var fwL = new Array; //fixed wing vehicle location
var fwO = new Array; //fixed wing vehicle orientation

var rcP = new Array; //placemark kmlFeature
var rc = new Array; //rotor craft vehicle kmlGeometry
var rcL = new Array; //rotor craft vehicle location
var rcO = new Array; //rotor craft vehicle orientation

var arP = new Array; //placemark kmlFeature
var ar = new Array; //rotor craft vehicle kmlGeometry
var arL = new Array; //AR.Drone location
var arO = new Array; //AR.Drone orientation

var atP = new Array; //placemark kmlFeature
var at = new Array; //atlas kmlGeometry
var atL = new Array; //atlas location
var atO = new Array; //atlas orientation

var kkP = new Array; //placemark kmlFeature
var kk = new Array; //kuka kmlGeometry
var kkL = new Array; //kuka location
var kkO = new Array; //kuka orientation

var bbP = new Array; //placemark kmlFeature
var bb = new Array; //biobot kmlGeometry
var bbL = new Array; //biobot location
var bbO = new Array; //biobot orientation

var cm = new Array; //Camera

var laNr = 0;
var prNr = 0;
var gvNr = 0;
var fwNr = 0;
var rcNr = 0;
var arNr = 0;
var atNr = 0;
var kkNr = 0;
var bbNr = 0;
var cmNr = 0;

function synchronousUpdate(laI, prI, gvI, fwI, rcI, arI, bbI, kkI, atI) {
  // The function google.earth.executeBatch guarantees a synchronous update of 
  // the world with the moved objects for nice smooth animation
  google.earth.executeBatch(ge, function() {
    moveObjects(laI, prI, gvI, fwI, rcI, arI, bbI, kkI, atI);
  });
}


function moveObjects(laI, prI, gvI, fwI, rcI, arI, bbI, kkI, atI){
    if(laI != -1){
        ge.getView().setAbstractView(la[laI]);
    }

    if(prI != -1){
        for(var i=0;i<prNr;i++){
            pr[i].getLocation().setLatLngAlt(prL[i].getLatitude(), prL[i].getLongitude(), prL[i].getAltitude());
            pr[i].getOrientation().set(prO[i].getHeading(), prO[i].getTilt(), prO[i].getRoll());
        }
    }

    if(fwI != -1){
        for(var i=0;i<fwNr;i++){
            fw[i].getLocation().setLatLngAlt(fwL[i].getLatitude(), fwL[i].getLongitude(), fwL[i].getAltitude());
            fw[i].getOrientation().set(fwO[i].getHeading(), fwO[i].getTilt(), fwO[i].getRoll());
        }
    }

    if(gvI != -1){
        for(var i=0;i<gvNr;i++){
            gv[i].getLocation().setLatLngAlt(gvL[i].getLatitude(), gvL[i].getLongitude(), gvL[i].getAltitude());
            gv[i].getOrientation().set(gvO[i].getHeading(), gvO[i].getTilt(), gvO[i].getRoll());
        }
    }

    if(rcI != -1){
        for(var i=0;i<rcNr;i++){
            rc[i].getLocation().setLatLngAlt(rcL[i].getLatitude(), rcL[i].getLongitude(), rcL[i].getAltitude());
            rc[i].getOrientation().set(rcO[i].getHeading(), rcO[i].getTilt(), rcO[i].getRoll());
        }
    }

    if(arI != -1){
        for(var i=0;i<arNr;i++){
            ar[i].getLocation().setLatLngAlt(arL[i].getLatitude(), arL[i].getLongitude(), arL[i].getAltitude());
            ar[i].getOrientation().set(arO[i].getHeading(), arO[i].getTilt(), arO[i].getRoll());
        }
    }
	
	if(kkI != -1){
        for(var i=0;i<kkNr;i++){
            kk[i].getLocation().setLatLngAlt(kkL[i].getLatitude(), kkL[i].getLongitude(), kkL[i].getAltitude());
            kk[i].getOrientation().set(kkO[i].getHeading(), kkO[i].getTilt(), kkO[i].getRoll());
        }
    }
	
	if(bbI != -1){
        for(var i=0;i<bbNr;i++){
            bb[i].getLocation().setLatLngAlt(bbL[i].getLatitude(), bbL[i].getLongitude(), bbL[i].getAltitude());
            bb[i].getOrientation().set(bbO[i].getHeading(), bbO[i].getTilt(), bbO[i].getRoll());
        }
    }
	
	if(atI != -1){
        for(var i=0;i<atNr;i++){
            at[i].getLocation().setLatLngAlt(atL[i].getLatitude(), atL[i].getLongitude(), atL[i].getAltitude());
            at[i].getOrientation().set(atO[i].getHeading(), atO[i].getTilt(), atO[i].getRoll());
        }
    }
}    

function teleportTo(lat, lon, heading){
    var lookAt = ge.createLookAt('');
    lookAt.set(lat, lon, 10, ge.ALTITUDE_RELATIVE_TO_SEA_FLOOR, heading, 80, 50);
    
    ge.getView().setAbstractView(lookAt);

    groundAlt = ge.getGlobe().getGroundAltitude(lat, lon);
}


function addPerson(){
    google.earth.fetchKml(ge, PR_MODEL_URL, function(kmlObject){
        if (kmlObject){
            ge.getFeatures().appendChild(kmlObject);
            aKmlVehicle = kmlObject;
        }
    });
}

function addAtlas(){
    google.earth.fetchKml(ge, AT_MODEL_URL, function(kmlObject){
        if (kmlObject){
            ge.getFeatures().appendChild(kmlObject);
            aKmlVehicle = kmlObject;
        }
    });
}

function addBiobot(){
    google.earth.fetchKml(ge, BB_MODEL_URL, function(kmlObject){
        if (kmlObject){
            ge.getFeatures().appendChild(kmlObject);
            aKmlVehicle = kmlObject;
        }
    });
}

function addKuka(){
    google.earth.fetchKml(ge, KK_MODEL_URL, function(kmlObject){
        if (kmlObject){
            ge.getFeatures().appendChild(kmlObject);
            aKmlVehicle = kmlObject;
        }
    });
}

function addGroundVehicle(){
    google.earth.fetchKml(ge, GV_MODEL_URL, function(kmlObject){
        if (kmlObject){
            ge.getFeatures().appendChild(kmlObject);
            aKmlVehicle = kmlObject;
        }
    });
}

function addFixedWingVehicle(){
    google.earth.fetchKml(ge, FW_MODEL_URL, function(kmlObject){
        if (kmlObject){
            ge.getFeatures().appendChild(kmlObject);
            aKmlVehicle = kmlObject;
        }
    });
}

function addRotorCraftVehicle(){
    google.earth.fetchKml(ge, RC_MODEL_URL, function(kmlObject){
        if (kmlObject){
            ge.getFeatures().appendChild(kmlObject);
            aKmlVehicle = kmlObject;
        }
    });
}


function addArDroneVehicle(){
    google.earth.fetchKml(ge, AR_MODEL_URL, function(kmlObject){
        if (kmlObject){
            ge.getFeatures().appendChild(kmlObject);
            aKmlVehicle = kmlObject;
        }
    });
}


function addLaView(range, tilt, altitude){
    la[laNr] = ge.createLookAt('');

    la[laNr].setAltitudeMode(ge.ALTITUDE_ABSOLUTE);
    la[laNr].setAltitude(altitude);

    la[laNr].setTilt(tilt);
    la[laNr].setRange(range);

    ge.getView().setAbstractView(la[laNr]);

    laNr = laNr + 1;
}


function addPRModel(lat, lon, heading){
    var placemark = ge.createPlacemark('');
    placemark.setName('PRmodel');
    placemark = addKmlModel(placemark);

    prP[prNr] = placemark; //keep separate record to avoid many 'getGeometry()' calls
    pr[prNr] = placemark.getGeometry();
    pr[prNr].setAltitudeMode(ge.ALTITUDE_RELATIVE_TO_GROUND);

    prL[prNr] = ge.createLocation('');
    prO[prNr] = ge.createOrientation('');

    prL[prNr].setLatitude(lat);
    prL[prNr].setLongitude(lon);
    prL[prNr].setAltitude(0);
    pr[prNr].setLocation(prL[prNr]);

    prNr = prNr + 1;
}

function addATModel(lat, lon, heading){
    var placemark = ge.createPlacemark('');
    placemark.setName('ATmodel');
    placemark = addKmlModel(placemark);

    atP[atNr] = placemark; //keep separate record to avoid many 'getGeometry()' calls
    at[atNr] = placemark.getGeometry();
    at[atNr].setAltitudeMode(ge.ALTITUDE_RELATIVE_TO_GROUND);

    atL[atNr] = ge.createLocation('');
    atO[atNr] = ge.createOrientation('');

    atL[atNr].setLatitude(lat);
    atL[atNr].setLongitude(lon);
    atL[atNr].setAltitude(0);
    at[atNr].setLocation(atL[atNr]);

    atNr = atNr + 1;
}

function addKKModel(lat, lon, heading){
    var placemark = ge.createPlacemark('');
    placemark.setName('KKmodel');
    placemark = addKmlModel(placemark);

    kkP[kkNr] = placemark; //keep separkke record to avoid many 'getGeometry()' calls
    kk[kkNr] = placemark.getGeometry();
    kk[kkNr].setAltitudeMode(ge.ALTITUDE_RELATIVE_TO_GROUND);

    kkL[kkNr] = ge.createLocation('');
    kkO[kkNr] = ge.createOrientation('');

    kkL[kkNr].setLatitude(lat);
    kkL[kkNr].setLongitude(lon);
    kkL[kkNr].setAltitude(0);
    kk[kkNr].setLocation(kkL[kkNr]);

    kkNr = kkNr + 1;
}

function addBBModel(lat, lon, heading){
    var placemark = ge.createPlacemark('');
    placemark.setName('BBmodel');
    placemark = addKmlModel(placemark);

    bbP[bbNr] = placemark; //keep separbbe record to avoid many 'getGeometry()' calls
    bb[bbNr] = placemark.getGeometry();
    bb[bbNr].setAltitudeMode(ge.ALTITUDE_RELATIVE_TO_GROUND);

    bbL[bbNr] = ge.createLocation('');
    bbO[bbNr] = ge.createOrientation('');

    bbL[bbNr].setLatitude(lat);
    bbL[bbNr].setLongitude(lon);
    bbL[bbNr].setAltitude(0);
    bb[bbNr].setLocation(bbL[bbNr]);

    bbNr = bbNr + 1;
}




function addGVModel(lat, lon, heading){
    var placemark = ge.createPlacemark('');
    placemark.setName('GVmodel');
    placemark = addKmlModel(placemark);

    gvP[gvNr] = placemark; //keep separate record to avoid many 'getGeometry()' calls
    gv[gvNr] = placemark.getGeometry();
    gv[gvNr].setAltitudeMode(ge.ALTITUDE_RELATIVE_TO_GROUND);

    gvL[gvNr] = ge.createLocation('');
    gvO[gvNr] = ge.createOrientation('');

    gvL[gvNr].setLatitude(lat);
    gvL[gvNr].setLongitude(lon);
    gvL[gvNr].setAltitude(0);

    gvNr = gvNr + 1;
}

function addFWModel(lat, lon, heading){
    var placemark = ge.createPlacemark('');
    placemark.setName('FWmodel');
    placemark = addKmlModel(placemark);

    fwP[fwNr] = placemark; //keep separate record to avoid many 'getGeometry()' calls
    fw[fwNr] = placemark.getGeometry();
    fw[fwNr].setAltitudeMode(ge.ALTITUDE_ABSOLUTE);

    fwL[fwNr] = ge.createLocation('');
    fwL[fwNr].setLatitude(lat);
    fwL[fwNr].setLongitude(lon);
    fwL[fwNr].setAltitude(0);

    fwO[fwNr] = ge.createOrientation('');

    fwNr = fwNr + 1;
}

function addRCModel(lat, lon, heading){
    var placemark = ge.createPlacemark('');
    placemark.setName('RCmodel');
    placemark = addKmlModel(placemark);

    rcP[rcNr] = placemark; //keep separate record to avoid many 'getGeometry()' calls
    rc[rcNr] = placemark.getGeometry();
    rc[rcNr].setAltitudeMode(ge.ALTITUDE_ABSOLUTE);

    rcL[rcNr] = ge.createLocation('');
    rcO[rcNr] = ge.createOrientation('');

    rcL[rcNr].setLatitude(lat);
    rcL[rcNr].setLongitude(lon);
    rcL[rcNr].setAltitude(0);

    var loc = ge.createLocation('');
    loc.setLatitude(lat);
    loc.setLongitude(lon);
    loc.setAltitude(0);

    rc[rcNr].setLocation(loc);

    var or = ge.createOrientation('');
    or.setHeading(heading);

    rc[rcNr].setOrientation(or);

//    var aScale = ge.createScale(''); //if you name this, the ID string must be uniquified
//    aScale.set(0.75, 0.75, 0.75);
//    rc[rcNr].setScale(aScale);

    rcNr = rcNr + 1;
}


function addARModel(lat, lon, heading){
    var placemark = ge.createPlacemark('');
    placemark.setName('ARmodel');
    placemark = addKmlModel(placemark);

    arP[arNr] = placemark; //keep separate record to avoid many 'getGeometry()' calls
    ar[arNr] = placemark.getGeometry();
//    ar[arNr].setAltitudeMode(ge.ALTITUDE_RELATIVE_TO_GROUND); 
//    Relative to ground may cause the drone to respond to bumps in the road ...
    ar[arNr].setAltitudeMode(ge.ALTITUDE_ABSOLUTE);

    arL[arNr] = ge.createLocation('');
    arO[arNr] = ge.createOrientation('');

    arL[arNr].setLatitude(lat);
    arL[arNr].setLongitude(lon);
    arL[arNr].setAltitude(0);

    var loc = ge.createLocation('');
    loc.setLatitude(lat);
    loc.setLongitude(lon);
    loc.setAltitude(0);

    ar[arNr].setLocation(loc);

    var or = ge.createOrientation('');
    or.setHeading(heading);

    ar[arNr].setOrientation(or);

    arNr = arNr + 1;
}


function addKmlModel(placemark){
    walkKmlDom(aKmlVehicle, function() {
        if (this.getType() == 'KmlPlacemark' &&
            this.getGeometry() &&
            this.getGeometry().getType() == 'KmlModel')
            placemark = this;
    });

    // add the model placemark to Earth
    ge.getFeatures().appendChild(placemark);
    return placemark;
}


function movePR(lat, lon, alt, heading){
    for(var i=0;i<prNr;i++){
        prL[i].setLatitude(lat[i]);
        prL[i].setLongitude(lon[i]);
        prL[i].setAltitude(alt[i]);

        prO[i].setHeading(heading[i]);
    }
}

function moveGV(lat, lon, alt, heading){
    for(var i=0;i<gvNr;i++){
        gvL[i].setLatitude(lat[i]);
        gvL[i].setLongitude(lon[i]);
        gvL[i].setAltitude(alt[i]);

        gvO[i].setHeading(heading[i]);
    }
}

function move6GV(lat, lon, alt, heading, tilt, roll){
    for(var i=0;i<gvNr;i++){
        gvL[i].setLatitude(lat[i]);
        gvL[i].setLongitude(lon[i]);
        gvL[i].setAltitude(alt[i]);

        gvO[i].setHeading(heading[i]);
        gvO[i].setTilt(tilt[i]);
        gvO[i].setRoll(roll[i]);
    }
}

function moveFW(lat, lon, alt, heading){
    for(var i=0;i<fwNr;i++){    
        fwL[i].setLatitude(lat[i]);
        fwL[i].setLongitude(lon[i]);
        fwL[i].setAltitude(alt[i]);

        fwO[i].setHeading(heading[i]);
    }
}

function move6FW(lat, lon, alt, heading, tilt, roll){
    for(var i=0;i<fwNr;i++){    
        fwL[i].setLatitude(lat[i]);
        fwL[i].setLongitude(lon[i]);
        fwL[i].setAltitude(alt[i]);

        fwO[i].setHeading(heading[i]);
        fwO[i].setTilt(tilt[i]);
        fwO[i].setRoll(roll[i]);
    }
}

function moveRC(lat, lon, alt, heading){
    for(var i=0;i<rcNr;i++){    
        rcL[i].setLatitude(lat[i]);
        rcL[i].setLongitude(lon[i]);
        rcL[i].setAltitude(alt[i]);

        rcO[i].setHeading(heading[i]);
    }
}

function move6RC(lat, lon, alt, heading, tilt, roll){
    for(var i=0;i<rcNr;i++){    
        rcL[i].setLatitude(lat[i]);
        rcL[i].setLongitude(lon[i]);
        rcL[i].setAltitude(alt[i]);

        rcO[i].setHeading(heading[i]);
        rcO[i].setTilt(tilt[i]);
        rcO[i].setRoll(roll[i]);
    }
}

function moveAR(lat, lon, alt, heading){
    for(var i=0;i<arNr;i++){    
        arL[i].setLatitude(lat[i]);
        arL[i].setLongitude(lon[i]);
        arL[i].setAltitude(alt[i]);

        arO[i].setHeading(heading[i]);
    }
}


function move6AR(lat, lon, alt, heading, tilt, roll){
    for(var i=0;i<arNr;i++){    
        arL[i].setLatitude(lat[i]);
        arL[i].setLongitude(lon[i]);
        arL[i].setAltitude(alt[i]);

        arO[i].setHeading(heading[i]);
        arO[i].setTilt(tilt[i]);
        arO[i].setRoll(roll[i]);
    }
}

function moveAT(lat, lon, alt, heading){
    for(var i=0;i<atNr;i++){
        atL[i].setLatitude(lat[i]);
        atL[i].setLongitude(lon[i]);
        atL[i].setAltitude(alt[i]);

        atO[i].setHeading(heading[i]);
    }
}

function move6AT(lat, lon, alt, heading, tilt, roll){
    for(var i=0;i<atNr;i++){
        atL[i].setLatitude(lat[i]);
        atL[i].setLongitude(lon[i]);
        atL[i].setAltitude(alt[i]);

        atO[i].setHeading(heading[i]);
        atO[i].setTilt(tilt[i]);
        atO[i].setRoll(roll[i]);
    }
}

function moveBB(lat, lon, alt, heading){
    for(var i=0;i<bbNr;i++){
        bbL[i].setLatitude(lat[i]);
        bbL[i].setLongitude(lon[i]);
        bbL[i].setAltitude(alt[i]);

        bbO[i].setHeading(heading[i]);
    }
}

function move6BB(lat, lon, alt, heading, tilt, roll){
    for(var i=0;i<bbNr;i++){
        bbL[i].setLatitude(lat[i]);
        bbL[i].setLongitude(lon[i]);
        bbL[i].setAltitude(alt[i]);

        bbO[i].setHeading(heading[i]);
        bbO[i].setTilt(tilt[i]);
        bbO[i].setRoll(roll[i]);
    }
}

function moveKK(lat, lon, alt, heading){
    for(var i=0;i<kkNr;i++){
        kkL[i].setLatitude(lat[i]);
        kkL[i].setLongitude(lon[i]);
        kkL[i].setAltitude(alt[i]);

        kkO[i].setHeading(heading[i]);
    }
}

function move6KK(lat, lon, alt, heading, tilt, roll){
    for(var i=0;i<kkNr;i++){
        kkL[i].setLatitude(lat[i]);
        kkL[i].setLongitude(lon[i]);
        kkL[i].setAltitude(alt[i]);

        kkO[i].setHeading(heading[i]);
        kkO[i].setTilt(tilt[i]);
        kkO[i].setRoll(roll[i]);
    }
}


function setRCProperties(vis){
    for(var i=0;i<rcNr;i++){    
        rcP[i].setVisibility(vis[i]);
    }
}


function moveLaView(index, lat, lon, alt, head){
    la[index].setLatitude(lat[index]); 
    la[index].setLongitude(lon[index]);
    la[index].setAltitude(alt[index]);
    la[index].setHeading(head[index]); 
}

function moveFullCmView(index, lat, lon, alt, head, tilt, range){
    cm[index].setLatitude(lat[index]); 
    cm[index].setLongitude(lon[index]);
    cm[index].setAltitude(alt[index]);

    cm[index].setHeading(head[index]); 
    cm[index].setTilt(tilt[index]);
    cm[index].setRoll(range[index]);

//    ge.getView().setAbstractView(la[index]);
}

function addCmView(lat, lon, alt, head, tilt, roll){
    cm[cmNr] = ge.createCamera('');

    cm[cmNr].setAltitudeMode(ge.ALTITUDE_RELATIVE_TO_GROUND);
    cm[cmNr].setLatitude(lat);
    cm[cmNr].setLongitude(lon);
    cm[cmNr].setAltitude(alt);

    cm[cmNr].setHeading(head);
    cm[cmNr].setTilt(tilt);
    cm[cmNr].setRoll(roll);

    ge.getView().setAbstractView(cm[cmNr]);

    cmNr = cmNr + 1;
}

function moveFullLaView(index, lat, lon, alt, mode, head, tilt, range){
    if(mode[index] == 0){
        la[index].setAltitudeMode(ge.ALTITUDE_ABSOLUTE);
    } else {
        la[index].setAltitudeMode(ge.ALTITUDE_RELATIVE_TO_GROUND);
    }
    
//    la[index].set(lat[index],lon[index],alt[index],modeEnum,tilt[index],range[index],head[index]);
    la[index].setLatitude(lat[index]); 
    la[index].setLongitude(lon[index]);
    la[index].setAltitude(alt[index]);

//    la[index].setAltitudeMode(modeEnum);

    la[index].setTilt(tilt[index]);
    la[index].setRange(range[index]);
    la[index].setHeading(head[index]); 
}