# Console panel package

a thera console view, which allows you to log text using static calls, to easily exec command line

![](https://img.alicdn.com/tps/TB1OG1tPVXXXXagXFXXXXXXXXXX-562-300.png)

## API reference

When consuming console panel you'll get instance of ConsoleManager which has following methods:

' toggle() '

Toggles console panel.

' log(message, level='info') '

Logs a message. message can be String or a custom View that will be appended.

' error(message) '

Logs an error.

' warn(message) '

Logs a warning.

' notice(message) '

Logs a notice.

' debug(message) '

Logs an debug message.

' raw(rawText, level='info', lineEnding="\n") '

Logs a raw message. rawText will be split by lineEnding and each line will be added separately as level.

' clear() '

Clears whole console.

## Used

[consolepanle](https://github.com/spark/console-panel)
