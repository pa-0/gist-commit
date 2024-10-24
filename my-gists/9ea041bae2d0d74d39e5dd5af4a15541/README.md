# Pipe contents of windows clipboard to another command

## Usage

To pipe the contents of the clipboard to another command (e.g. grep):

    paste | grep pattern

To save the contents of the clipboard to a file:

    paste > file.txt

## Building

You can compile paste.cs with a single command on any Windows machine without
the need to install any extra tools. Just run this command:

    %SystemRoot%\Microsoft.NET\Framework\v3.5\csc /o paste.cs

Prebuild version is included here as paste.zip

## Installing

Put the resulting `paste.exe` in your path.
