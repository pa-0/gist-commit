This tries to fix the annoying need to launch Putty prior to using it with WinSCP portable. Both, by the way, are excellant pieces of code  and I am in debt to their author(s).

## Links

* http://portableapps.com/node/17274
* http://seb.roth.free.fr/Tools/WinSCPPortable/Other/Source/PuTTYPortableLinkerU.nsi

Make the changes as suggested in the last comment of the first link
```
Edit PuTTYPortableLinkerU.nsi

Insert Line after line 78 before:
FindProcDLL::FindProc "PuTTYPortable.exe"
StrCmp $R0 "1" GetPassedParameters WarnAnotherInstance

after:
FindProcDLL::FindProc "PuTTYPortable.exe"
StrCmp $R0 "0" GetPassedParameters
StrCmp $R0 "1" GetPassedParameters WarnAnotherInstance

Recompile NSIS and save PortableApps\WinSCPPortable\App\winscp\PuTTYPortableLinker.exe

Done.

```
You can get the nsis compiler from 

* http://portableapps.com/apps/development/nsis_portable [use the unicode one]

Just load the edited nsi file into the compiler window and let it do its thing. You'll need PuTTYPortableLinker.ico as well - can be found via google, or base64 decode the string below and save as PuTTYPortableLinker.ico using a online tool such as:

* http://www.myriap.com/en/apps/base64_encoder_decoder


