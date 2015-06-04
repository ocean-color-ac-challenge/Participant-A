#!/bin/bash

# source the ciop functions (e.g. ciop-log)
source ${ciop_job_include}

# define the exit codes
SUCCESS=0
ERR_NOINPUT=1
ERR_BEAM=2
ERR_NOPARAMS=5
ERR_JAVAVERSION=10

# add a trap to exit gracefully
function cleanExit ()
{
   local retval=$?
   local msg=""
   case "$retval" in
     $SUCCESS)      msg="Processing successfully concluded";;
     $ERR_NOPARAMS) msg="Expression not defined";;
     $ERR_BEAM)    msg="Beam failed to process product $product (Java returned $res).";;
     $ERR_JAVAVERSION)	msg="The version of the JVM must be at least 1.7";;
     *)             msg="Unknown error";;
   esac
   [ "$retval" != "0" ] && ciop-log "ERROR" "Error $retval - $msg, processing aborted" || ciop-log "INFO" "$msg"
   exit $retval
}
trap cleanExit EXIT

ciop-log "INFO" "Checking Java version"
$_CIOP_APPLICATION_PATH/shared/bin/detect_java.sh
[ "$?" == "0" ] || exit $ERR_JAVAVERSION

# create the output folder to store the output products
mkdir -p $TMPDIR/output
export OUTPUTDIR=$TMPDIR/output
format="`ciop-getparam format`"

[ "$format" != "BEAM-DIMAP" ] && [ "$format" != "GeoTIFF" ] && exit $ERR_FORMAT

aerosolType="`ciop-getparam aerosolType`"
bandNames="`ciop-getparam bandNames`"
invalidPixel="`ciop-getparam invalidPixel`"
maskExpression="`ciop-getparam maskExpression`"
surfPress="`ciop-getparam surfPress`"
tauAero550="`ciop-getparam tauAero550`"
uH2o="`ciop-getparam uH2o`"
uO3="`ciop-getparam uO3`"
useMerisADS="`ciop-getparam useMerisADS`"


# loop and process all MERIS products
while read inputfile 
do
  # report activity in log
  ciop-log "INFO" "Retrieving $inputfile from storage"
  
  # retrieve the remote geotiff product to the local temporary folder
  retrieved="`opensearch-client "$inputfile" enclosure | ciop-copy -o $TMPDIR -`"
  
  # check if the file was retrieved
  [ "$?" == "0" -a -e "$retrieved" ] || exit $ERR_NOINPUT
  
  # report activity
  ciop-log "INFO" "Retrieved `basename $retrieved`, moving on to smac operator"
	
outputname=`basename $retrieved`
  
  $_CIOP_APPLICATION_PATH/shared/bin/gpt.sh SmacOp \
    -SsourceProduct=$retrieved \
    -f $format \
    -t $OUTPUTDIR/$outputname \
    -PaerosolType=$aerosolType \
    -PbandNames="$bandNames" \
    -PinvalidPixel=$invalidPixel \
    -PmaskExpression="$maskExpression" \
    -PsurfPress=$surfPress \
    -PtauAero550=$tauAero550 \
    -PuH2o=$uH2o \
    -PuO3=$uO3 \
    -PuseMerisADS=$useMerisADS 
  
  res=$?
  [ $res != 0 ] && exit $ERR_BEAM
  
  tar -C $OUTPUTDIR -cvzf $TMPDIR/$outputname.tgz $outputname.dim $outputname.data
  
  ciop-log "INFO" "Publishing $outputname.tgz"
  ciop-publish -m $TMPDIR/$outputname.tgz
  
  # cleanup
  rm -fr $retrieved $OUTPUTDIR/$outputname.d* $TMPDIR/$outputname.tgz 

done

exit 0

