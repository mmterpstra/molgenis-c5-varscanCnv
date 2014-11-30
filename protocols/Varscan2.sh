#MOLGENIS walltime=35:59:00 mem=4gb


#Parameter mapping  #why not string foo,bar? instead of string foo\nstring bar
#string stage
#string checkStage
#string varScanVersion
#string samtoolsVersion
#string tempDir
#string intermediateDir
#string samtoolsCopynumberErr
#string varscanCopynumberPrefix
#string varscanCopynumber
#string varscanCopynumberOut
#string varscanCopynumberErr
#string varscanCopycaller
#string varscanCopycallerHomdels
#string varscanCopycallerOut
#string varscanCopycallerErr
#string indexFile
#string controlInputBam
#string inputBam
#string tmpSamtoolsCopynumberErr
#string tmpVarscanCopynumberPrefix
#string tmpVarscanCopynumber
#string tmpVarscanCopynumberOut
#string tmpVarscanCopynumberErr
#string tmpVarscanCopycaller
#string tmpVarscanCopycallerHomdels
#string tmpVarscanCopycallerOut
#string tmpVarscanCopycallerErr

##echo.....
echo $stage
echo $checkStage
echo $varScanVersion
echo $samtoolsVersion
echo $tempDir
echo $intermediateDir
echo $samtoolsCopynumberErr
echo $varscanCopynumberPrefix
echo $varscanCopynumber
echo $varscanCopynumberOut
echo $varscanCopynumberErr
echo $varscanCopycaller
echo $varscanCopycallerHomdels
echo $varscanCopycallerOut
echo $varscanCopycallerErr
echo $indexFile
echo $controlInputBam
echo $inputBam

echo $tmpSamtoolsCopynumberErr
echo $tmpVarscanCopynumberPrefix
echo $tmpVarscanCopynumber
echo $tmpVarscanCopynumberOut
echo $tmpVarscanCopynumberErr
echo $tmpVarscanCopycaller
echo $tmpVarscanCopycallerHomdels
echo $tmpVarscanCopycallerOut
echo $tmpVarscanCopycallerErr



function CheckReturnAndMoveAndPutOutput {
	if [ $1 -eq 0 ]
	then
		echo
		echo "##" $(basename $0 )" ## Finished moving file '$2' to project files:'$3'"
		mv ${2} ${3}
		putFile "${3}"
	else
		echo "##" $(basename $0 )" ## Error on program run($1). mv to project files with .error extention"
		mv ${2} ${3}.error
    		exit -$1
	fi
}

#Function to check if array contains value
array_contains () {
	local array="$1[@]"
	local seeking=$2
	local in=1
	for element in "${!array}"; do
		if [[ $element == $seeking ]]; then
			in=0
	        	break
		fi
	done
	return $in
}

#Check if output exists
alloutputsexist \
"${varscanCopynumber}" \
"${varscanCopynumberOut}" \
"${varscanCopycaller}" \
"${varscanCopycallerHomdels}"

#dunno what this does.. but i needs $indexFile $controlInputBam $inputBam $controlInputBamIdx $inputBamIdx and generates $tmpVarscanCopycaller/$varscanCopycaller $tmpVarscanCopynumberOut/$varscanCopynumberOut $tmpVarscanCopycaller/$varscanCopycaller $tmpVarscanCopycallerHomdels/$varscanCopycallerHomdels
getFile $indexFile
getFile $inputBam
getFile $inputBamIdx
getFile $controlInputBam
getFile $controlInputBamIdx

#Load modules
${stage} VarScan/${varScanVersion}
${stage} samtools/${samtoolsVersion}


${checkStage}
set -x
Prog=Varscan2copynumber
echo $Prog
mkdir -p $(dirname $tmpVarscanCopynumber)
mkdir -p $(dirname $varscanCopynumber)
#this program performs data reduction of the bam files by selecting intervals and collecting statistics on the intervals
if [ ! -e $varscanCopynumber ]; then

	samtools mpileup \
	 -R -q 40 -f ${indexFile} \
	 $controlInputBam $inputBam 2>$tmpSamtoolsCopynumberErr| \
	java -Xmx4g -jar ${VARSCAN_HOME}VarScan.jar copynumber \
	 - $tmpVarscanCopynumberPrefix \
	 --mpileup --min-segment-size 200 --max-segment-size 500 \
	1>$tmpVarscanCopynumberOut \
	2>$tmpVarscanCopynumberErr
	

	#not $?	
	PSA=( "${PIPESTATUS[@]}" )
	returnCode=${PSA[0]}
	echo "PIPESTATUS ${PSA[*]}"

	set +x			#disable debugging
	CheckReturnAndMoveAndPutOutput $returnCode $tmpVarscanCopynumber $varscanCopynumber
	CheckReturnAndMoveAndPutOutput $returnCode $tmpVarscanCopynumberOut $varscanCopynumberOut
fi
if [ ! -z "$PBS_JOBID" ]; then
	qstat -f $PBS_JOBID
fi
#Load modules
#${stage} VarScan/${varScanVersion}		
Prog=Varscan2copyCaller
#this program performs GC normalisation
if [ ! -e $varscanCopycaller ];then

	java -jar -Xmx4g -jar ${VARSCAN_HOME}VarScan.jar copyCaller $varscanCopynumber --output-file $tmpVarscanCopycaller --output-homdel-file $tmpVarscanCopycallerHomdels\
	1>$tmpVarscanCopycallerOut \
	2>$tmpVarscanCopycallerErr
		
	returnCode=$?
	
	set +x			#disable debugging
	CheckReturnAndMoveAndPutOutput $returnCode $tmpVarscanCopycaller $varscanCopycaller
	CheckReturnAndMoveAndPutOutput $returnCode $tmpVarscanCopycallerHomdels $varscanCopycallerHomdels
	
fi
if [ ! -z "$PBS_JOBID" ]; then
	qstat -f $PBS_JOBID
fi
