@ECHO OFF
rem Best resource: http://steve-jansen.github.io/guides/windows-batch-scripting/part-2-variables.html

rem Runs on Windows 10 from a basic command prompt
rem Example usage(s):
rem   checksig.cmd -f ProgramFilename.exe -s SignatureFilename.txt -a SHA256 -v
rem   checksig.cmd -s "SignatureFilename.txt" -f "ProgramFilename.exe"

rem 3 parameters:
rem   file to check
rem   file containing signature for comparison
rem   type of hash to generate

rem TODO: make filenames with spaces work
rem TODO: accept either a file containing a signature to compare, or the signature directly

SETLOCAL

SET CHECKSIG_DEBUG=0
SET CHECKSIG_VERBOSE=0

SET CHECKSIG_HASHTYPE=SHA256
SET CHECKSIG_FILENAME=
SET CHECKSIG_SIGFILE=
SET CHECKSIG_SIG_O=
SET CHECKSIG_SIG_F=

rem Assign command line parameters to variables
rem -f -s -a -v
:ARGS
IF "%1"=="" ( GOTO ARGS_PARSED )
IF "%1"=="-f" (
	SET CHECKSIG_FILENAME=%~f2
	SHIFT
	GOTO ARGS_NEXT
)
IF "%1"=="-s" (
	SET CHECKSIG_SIGFILE=%~f2
	SHIFT
	GOTO ARGS_NEXT
)
IF "%1"=="-a" (
	SET CHECKSIG_HASHTYPE=%~2
	SHIFT
	GOTO ARGS_NEXT
)
IF "%1"=="-v" (
	SET CHECKSIG_VERBOSE=1
	GOTO ARGS_NEXT
)
:ARGS_NEXT
SHIFT
GOTO ARGS
:ARGS_PARSED

rem Validate input
IF "%CHECKSIG_FILENAME%"=="" (
	ECHO Missing parameter: name of file to check.
	EXIT /B 1
)
IF NOT EXIST "%CHECKSIG_FILENAME%" (
	ECHO File to check does not exist.
	EXIT /B 2
)
IF "%CHECKSIG_SIGFILE%"=="" (
	ECHO Missing parameter: name of signature file.
	EXIT /B 1
)
IF NOT EXIST "%CHECKSIG_SIGFILE%" (
	ECHO Signature file does not exist.
	EXIT /B 2
)
IF NOT "%CHECKSIG_HASHTYPE%"=="MD2" (
IF NOT "%CHECKSIG_HASHTYPE%"=="MD4" (
IF NOT "%CHECKSIG_HASHTYPE%"=="MD5" (
IF NOT "%CHECKSIG_HASHTYPE%"=="SHA1" (
IF NOT "%CHECKSIG_HASHTYPE%"=="SHA256" (
IF NOT "%CHECKSIG_HASHTYPE%"=="SHA384" (
IF NOT "%CHECKSIG_HASHTYPE%"=="SHA512" (
	ECHO The hash algorithm must be specified as one of the following:
	ECHO MD2, MD4, MD5, SHA1, SHA256, SHA384, SHA512
	EXIT /B 3
)))))))

IF /I "%CHECKSIG_DEBUG%" EQU "1" (
	ECHO Filename: %CHECKSIG_FILENAME%
	ECHO Signature file: %CHECKSIG_SIGFILE%
	ECHO Hash algorithm: %CHECKSIG_HASHTYPE%
)

IF /I "%CHECKSIG_VERBOSE%" EQU "1" (
	ECHO Using hash type %CHECKSIG_HASHTYPE%
)

rem Generate the signature of the file
CertUtil -hashfile %CHECKSIG_FILENAME% %CHECKSIG_HASHTYPE% | findstr /V ":" > checksig_temp.txt
SET /p CHECKSIG_OUT_CERTUTIL=<checksig_temp.txt
DEL checksig_temp.txt

rem Check status of CertUtil ... kinda
rem Notify that CertUtil seems to have returned an error
IF "%CHECKSIG_OUT_CERTUTIL%"=="" (
	ECHO CertUtil encountered an error
	rem ECHO %CHECKSIG_OUT_CERTUTIL%
	EXIT /B 4
)

rem Remove any whitespace
SET CHECKSIG_SIG_F=%CHECKSIG_OUT_CERTUTIL: =%
rem Get the signature to verify against, and remove any whitespace
SET /p CHECKSIG_SIG_O=<%CHECKSIG_SIGFILE%
SET CHECKSIG_SIG_O=%CHECKSIG_SIG_O: =%

IF /I "%CHECKSIG_DEBUG%" EQU "1" (
	ECHO %CHECKSIG_SIG_F%
	ECHO %CHECKSIG_SIG_O%
)

rem Compare the signatures and output the results
SET RESULT=0
IF "%CHECKSIG_SIG_F%"=="%CHECKSIG_SIG_O%" (
	SET RESULT=1
)
IF /I "%RESULT%" EQU "1" (
	ECHO Signatures match.
) 
IF /I "%RESULT%" EQU "0" (
	ECHO Signatures did not match.
)

IF /I "%CHECKSIG_VERBOSE%" EQU "1" (
	ECHO Generated signature, followed by the signature provided as a parameter:
	ECHO %CHECKSIG_SIG_F%
	ECHO %CHECKSIG_SIG_O%
)

ENDLOCAL
rem End of file