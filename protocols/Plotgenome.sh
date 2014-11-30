#MOLGENIS walltime=35:59:00 mem=4gb


#Parameter mapping  #why not string foo,bar? instead of string foo\nstring bar
#string stage
#string checkStage
#string tempDir
#string intermediateDir
#string dictFile
#string varscanCopycaller
#string varscanCopycallerHomdels
#string RVersion
#string plotScriptPl
#string tmpVarscanCopycaller
#string tmpVarscanCopycallerHomdels
#string tmpPlotScriptErr
#string tmpPlotScriptOut
#string tmpDnaCopyRScript
#string tmpSegFile
#string tmpSegTableFile
#string tmpCnvPlotPdfRscript
#string tmpSegmentsPlotPdf
#string tmpCnvPlotPdf
#string segFile
#string segmentsPlotPdf
#string cnvPlotPdf

##you can also add an F score to the genotypes (based on AD) and integrate it into the plot == added value
##a string tmpSnpVariantsTableTable {intermediateDir}/tmp/{project}.SnpsToTab.tab.table

##echo.....
echo $stage
echo $checkStage
echo $tempDir
echo $intermediateDir
echo $dictFile
echo $varscanCopycaller
echo $varscanCopycallerHomdels
echo $RVersion
echo $plotScriptPl
echo $tmpVarscanCopycaller
echo $tmpVarscanCopycallerHomdels
echo $tmpPlotScriptErr
echo $tmpPlotScriptOut
echo $tmpSegFile
echo $tmpDnaCopyRScript
echo $tmpSegTableFile
echo $tmpCnvPlotPdfRscript
echo $tmpSegmentsPlotPdf
echo $tmpCnvPlotPdf
echo $segFile
echo $segmentsPlotPdf
echo $cnvPlotPdf


function CheckReturnAndMoveAndPutOutput {
#retcode=$1
#tmpFile=$2
#permFile=$3	
if [ $1 -eq 0 ]
	then
		echo
		echo "##" $(basename $0 )" ## Finished moving file '$2' to project files:'$3'"
		mv ${2} ${3}
		putFile "${3}"
	else
		echo "##" $(basename $0 )" ## Error on program run($1). mv to project files with .error extention:'${3}.error'"
		mv ${2} ${3}.error
		putFile "${3}.error"
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
"${segFile}" \
"${segmentsPlotPdf}" \
"${cnvPlotPdf}" 

#getfile declarations
getFile $varscanCopycaller
getFile $varscanCopycallerHomdels
getfile $dictFile

if [ ! -e $tmpVarscanCopycaller ]; then
	echo "for directory control moving the 'varscanCopycaller' file back to tmpVarscanCopycaller" 
	cp $varscanCopycaller $tmpVarscanCopycaller
fi
if [ ! -e $tmpVarscanCopycallerHomdels ]; then
	echo "for directory control moving the 'varscanCopycallerHomdels' file back to tmpVarscanCopycallerHomdels" 
	cp $varscanCopycallerHomdels $tmpVarscanCopycallerHomdels
fi

$stage R/$RVersion
$checkStage
#run script perl PlotFloatsOnInterVals0.0.2.pl -R Rscript -d $dictFile $varscanCopycaller [variantstable.table]

set -x
Prog=Varscan2copynumber

if [ ! -e $cnvPlotPdf ]; then

	perl $plotScriptPl \
	-R Rscript \
	-d $dictFile \
	$tmpVarscanCopycaller \
	1>$tmpPlotScriptOut \
	2>$tmpPlotScriptErr
			
	returnCode=$?
	set +x
	CheckReturnAndMoveAndPutOutput $returnCode $tmpSegFile $segFile
	CheckReturnAndMoveAndPutOutput $returnCode $tmpSegmentsPlotPdf $segmentsPlotPdf
	CheckReturnAndMoveAndPutOutput $returnCode $tmpCnvPlotPdf $cnvPlotPdf
fi
if [ ! -z "$PBS_JOBID" ]; then
	qstat -f $PBS_JOBID
fi

