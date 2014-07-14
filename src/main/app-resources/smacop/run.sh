#!/bin/bash

# source the ciop functions (e.g. ciop-log)
source ${ciop_job_include}

# define the exit codes
SUCCESS=0
ERR_NOINPUT=1
ERR_BEAM=2
ERR_NOPARAMS=5

# add a trap to exit gracefully
function cleanExit ()
{
   local retval=$?
   local msg=""
   case "$retval" in
     $SUCCESS)      msg="Processing successfully concluded";;
     $ERR_NOPARAMS) msg="Expression not defined";;
     $ERR_BEAM)    msg="Beam failed to process product $product (Java returned $res).";;
     *)             msg="Unknown error";;
   esac
   [ "$retval" != "0" ] && ciop-log "ERROR" "Error $retval - $msg, processing aborted" || ciop-log "INFO" "$msg"
   exit $retval
}
trap cleanExit EXIT

# create the output folder to store the output products
mkdir -p $TMPDIR/output
export OUTPUTDIR=$TMPDIR/output

# loop and process all MERIS products
while read inputfile 
do
  # report activity in log
  ciop-log "INFO" "Retrieving $inputfile from storage"
  
  # retrieve the remote geotiff product to the local temporary folder
  retrieved=`ciop-copy -o $TMPDIR $inputfile`
  
  # check if the file was retrieved
  [ "$?" == "0" -a -e "$retrieved" ] || exit $ERR_NOINPUT
  
  # report activity
  ciop-log "INFO" "Retrieved `basename $retrieved`, moving on to expression"
  outputname=`basename $retrieved`
  
  BEAM_REQUEST=$TMPDIR/beam_request.xml

  cat << EOF > $BEAM_REQUEST
<?xml version="1.0" encoding="UTF-8"?>
<graph>
  <version>1.0</version>
  <node id="1">
    <operator>Read</operator>
      <parameters>
        <file>$retrieved</file>
      </parameters>
  </node>
    <node id="someNodeId">
      <operator>SmacOp</operator>
      <sources>
        <source>${source}</source>
      </sources>
      <parameters>
        <tauAero550>float</tauAero550>
        <uH2o>float</uH2o>
        <uO3>float</uO3>
        <surfPress>float</surfPress>
        <useMerisADS>boolean</useMerisADS>
        <aerosolType>aEROSOL_TYPE</aerosolType>
        <invalidPixel>float</invalidPixel>
        <maskExpression>string</maskExpression>
        <maskExpressionForward>string</maskExpressionForward>
        <bandNames>string,string,string,...</bandNames>
      </parameters>
    </node>
  <node id="write">
    <operator>Write</operator>
    <sources>
       <source>2</source>
    </sources>
    <parameters>
      <file>$OUTPUTDIR/$outputname</file>
   </parameters>
  </node>
</graph>
EOF
   
  $_CIOP_APPLICATION_PATH/shared/bin/gpt.sh $BEAM_REQUEST 
  res=$?
  [ $res != 0 ] && exit $ERR_BEAM
  
  outputname=`echo $(basename $retrieved)`
  
  tar -C $OUTPUTDIR -czf $TMPDIR/$outputname.tgz $outputname.dim $outputname.data
  
  ciop-log "INFO" "Publishing $outputname.tgz"
  ciop-publish $TMPDIR/$outputname.tgz
  
  # cleanup
  rm -fr $retrieved $OUTPUTDIR/$outputname.d* $TMPDIR/$outputname.tgz 

done

exit 0

