

[Setup]
AppName=NfeServer
AppVerName=NfeServer 1.0
AppPublisher=NfeServer
AppPublisherURL=http://www.wsinformatica.com.br
AppSupportURL=http://www.wsinformatica.com.br
AppUpdatesURL=http://www.wsinformatica.com.br
DefaultDirName={pf}\NfeServer\ 
DefaultGroupName=NfeServer
OutputDir=..\bin
OutputBaseFilename=NfeServerInstall
Compression=lzma
SolidCompression=yes

[Languages]
Name: brazilianportuguese; MessagesFile: compiler:Languages\BrazilianPortuguese.isl



[Files]


Source: ..\Dlls\*.*; DestDir: {app}; Flags: overwritereadonly  

Source: ..\bin\web\*.*; DestDir: {app}\web; Flags: ignoreversion recursesubdirs  
Source: ..\bin\Schemas\*.*; DestDir: {app}\Schemas; Flags: ignoreversion recursesubdirs  
Source: ..\bin\DfeServiceWin32.exe; DestDir: {app}; Flags: overwritereadonly  

[Run]

Filename: "{app}\DfeServiceWin32.exe"; Parameters: "-install"
 








