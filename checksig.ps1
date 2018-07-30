param (
	[string]$FILENAME,
	[string]$SIGFILE,
	[string]$HASHTYPE = "SHA256",
	[switch]$_VERBOSE = $false
)

# Runs on Windows 10, Powershell 5.1

# TODO: make sure that quoted filenames and filenames with spaces work
# TODO: accept either a file containing a signature to compare, or the signature directly

$_DEBUG = $False;

$SIG_O="";
$SIG_F="";

# Validate input
if ( !( Test-Path $FILENAME ) )
{
	Write-Host "File to check does not exist.";
	exit 2;
}
if ( !( Test-Path $SIGFILE ) )
{
	Write-Host "Signature file does not exist.";
	exit 2;
}
if ( $HASHTYPE -ne "MD2" -and $HASHTYPE -ne "MD4" -and $HASHTYPE -ne "MD5" -and $HASHTYPE -ne "SHA1" -and $HASHTYPE -ne "SHA256" -and $HASHTYPE -ne "SHA384" -and $HASHTYPE -ne "SHA512" )
{
	Write-Host "The hash algorithm must be specified as one of the following:";
	Write-Host "MD2, MD4, MD5, SHA1, SHA256, SHA384, SHA512";
	exit 3;
}  

if ( $_DEBUG )
{
	Write-Host "Filename: $FILENAME";
	Write-Host "Signature file: $SIGFILE";
	Write-Host "Hash algorithm: $HASHTYPE";
}

if ( $_VERBOSE )
{
	Write-Host "Using hash type $HASHTYPE";
}

# Generate the signature of the file
$_OUT_CERTUTIL = CertUtil -hashfile $FILENAME $HASHTYPE
# Check status of CertUtil
if ( $? )
{
	# Strip the generated signature from the output, and remove any whitespace
	$SIG_F = $_OUT_CERTUTIL | Select-Object -Index 1
	$SIG_F = $SIG_F -replace '\s',''
	# Get the signature to verify against, and remove any whitespace
	$SIG_O = Get-Content -path $SIGFILE
	$SIG_O = $SIG_O -replace '\s',''
	
	if ( $_DEBUG )
	{
		Write-Host "$SIG_F"
		Write-Host "$SIG_O"
	}
	
	# Compare the signatures and output the results
	if ( $SIG_F -eq $SIG_O )
	{
		Write-Host "Signatures match."
	}
	else
	{
		Write-Host "Signatures did not match."
	}
	if ( $_VERBOSE )
	{
		Write-Host "Generated signature, followed by the signature provided as a parameter:"
		Write-Host "$SIG_F"
		Write-Host "$SIG_O"
	}
}
# Display output of CertUtil if it returned an error
else
{
	Write-Host "CertUtil encountered an error: `n$_OUT_CERTUTIL";
}
