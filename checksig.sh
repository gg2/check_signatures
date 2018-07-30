#!/bin/sh

# Runs on Windows in a Linux compatible shell, such as Cygwin
# Example usage(s):
#   ./checksig.sh -f ProgramFilename.exe -s SignatureFilename.txt -a SHA256 -v
#   ./checksig.sh -s SignatureFilename.txt -f ProgramFilename.exe

# 3 parameters:
#   file to check
#   file containing signature for comparison
#   type of hash to generate

# TODO: make sure that quoted filenames and filenames with spaces work
# TODO: accept either a file containing a signature to compare, or the signature directly


_DEBUG=0
_VERBOSE=0

HASHTYPE="SHA256"
FILENAME=""
SIGFILE=""
SIG_O=""
SIG_F=""

# Assign command line parameters to variables
# https://stackoverflow.com/questions/192249/how-do-i-parse-command-line-arguments-in-bash
# A POSIX variable
OPTIND=1         # Reset in case getopts has been used previously in the shell.

while getopts "f:s:a:v" opt; do
    case "$opt" in
    f)
			FILENAME=$OPTARG
			;;
		s)
			SIGFILE=$OPTARG
			;;
		a)
			HASHTYPE=$OPTARG
			;;
    v)
			_VERBOSE=1
			;;
    esac
done

#shift $((OPTIND-1))
#[ "${1:-}" = "--" ] && shift


# Validate input
if [[ -z "${FILENAME// }" ]] ;
then
	echo "Missing parameter: name of file to check."
	exit 1
fi
if [ ! -e $FILENAME ] ;
then
	echo "File to check does not exist."
	exit 2
fi
if [[ -z "${SIGFILE// }" ]] ;
then
	echo "Missing parameter: name of signature file."
	exit 1
fi
if [ ! -e $SIGFILE ] ;
then
	echo "Signature file does not exist."
	exit 2
fi
if [[ $HASHTYPE != "MD2" && $HASHTYPE != "MD4" && $HASHTYPE != "MD5" && $HASHTYPE != "SHA1" && $HASHTYPE != "SHA256" && $HASHTYPE != "SHA384" && $HASHTYPE != "SHA512" ]] ;
then
	echo "The hash algorithm must be specified as one of the following:"
	echo "MD2, MD4, MD5, SHA1, SHA256, SHA384, SHA512"
	exit 3
fi  

if [[ $_DEBUG -eq 1 ]] ;
then
	echo "Filename: $FILENAME"
	echo "Signature file: $SIGFILE"
	echo "Hash algorithm: $HASHTYPE"
fi

if [[ $_VERBOSE -eq 1 ]] ;
then
	echo "Using hash type $HASHTYPE"
fi

# Generate the signature of the file
_OUT_CERTUTIL=`CertUtil -hashfile $FILENAME $HASHTYPE`
# Check status of CertUtil
if [ $? -eq 0 ] ;
then
	# Strip the generated signature from the output, and remove any whitespace
	SIG_F=`sed -n 2p <<< $_OUT_CERTUTIL | tr -d '[:space:]'`
	# Get the signature to verify against, and remove any whitespace
	SIG_O=`cat ${SIGFILE// } | tr -d '[:space:]'`
	
	if [[ $_DEBUG -eq 1 ]] ;
	then
		echo "$SIG_F"
		echo "$SIG_O"
	fi
	
	# Compare the signatures and output the results
	if [ "$SIG_F" == "$SIG_O" ];
	then
		echo "Signatures match."
	else
		echo "Signatures did not match."
	fi
	if [[ $_VERBOSE -eq 1 ]] ;
	then
		echo "Generated signature, followed by the signature provided as a parameter:"
		echo "$SIG_F"
		echo "$SIG_O"
	fi
# Display output of CertUtil if it returned an error
else
	echo "CertUtil encountered an error:"
	echo "$_OUT_CERTUTIL"
fi

# End of file