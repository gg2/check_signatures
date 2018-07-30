# Signature Comparison Scripts Using CertUtil

A set of different scripts for Windows that run CertUtil to get the signature for a file, and compare it to a provided signature. The .cmd file is a basic Windows batch file that can be run from any command prompt. The .sh file is a Linux-style script that requires Cygwin or some other Bash-compatible shell to run. The .ps1 is a Powershell script ... runs in Powershell.

Each script accepts 4 parameters in any order, accompanied by appropriate flags:  
* **-f (String)**: Filename of file to generate signature for. Provided directly to CertUtil's -hashfile parameter.
* **-s (String)**: Filename of file containing a signature (and only the signature) to compare against. Any spaces are removed by each script (theoretically; TODO: needs complete testing).
* **-a (String)**: The cryptographic algorithm type to use to generate the script. Provided directly to CertUtil as the last parameter.  
  Default: SHA256
  Accepts: MD2, MD4, MD5, SHA1, SHA256, SHA384, SHA512
* **-v (Boolean)**: Whether or not to run verbosely
  True == run verbosely, including listing the signatures that were compared; 
  False == output only a statement of the result


Currently only tested on **Windows 10**. I opted for the Get-FileHash commandlet for the Powershell script, instead of using CertUtil, since it turned out to be easy to fetch the hash from it.


* **TODO**: Need to make sure all three run smoothly with or without quotes around path/filenames, and if path/filenames contain spaces.
* **TODO**: Allow each script to accept the check signature directly, rather than having to save it to a file first.
* **TODO**: The .cmd requires creating a temporary file and deleting it in its current directory. Need to either ensure it can do that, rework it so it doesn't need to do that, or ignore it, because who is really ever going to use these? (Famous last words?)
* **TODO**: Add an option that will allow running simply to output the generated signature.
* **TODO**: Add an option that will simply return the comparison signature. (Would this be useful at all vs simply opening the file? ... Maybe.)
