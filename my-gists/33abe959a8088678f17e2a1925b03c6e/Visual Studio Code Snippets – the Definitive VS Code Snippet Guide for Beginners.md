# Visual Studio Code Snippets - the Definitive VS Code Snippet Guide for Beginners

If you want to track down the source file yourself, the built-in snippets live inside each individual
language extension directory. The file is located at «app
root»\resources\app\extensions\«language»\snippets\«language».code-snippets on
Windows. The location is similar for Mac and Linux.
To create the snippets file, run the 'Preferences: Configure User Snippets' command, which
opens a quickpick dialog as below. Your selection will open a file for editing.
Example
Here is a markdown snippet that comes with VS Code.

```json
{
 "Insert heading level 1": {
 "prefix": "heading1",
 "body": ["# ${1:${TM_SELECTED_TEXT}}$0"],
 "description" : "Insert heading level 1"
 }
}
```

This snippet inserts a level 1 heading which wraps the markdown around the current selection (if there is one).
A snippet has the following properties:

1. "Insert heading level 1"is the snippet name. This is the value that is displayed in the
IntelliSense suggestion list if no description is provided.
2. The prefix property defines the trigger phrase for the snippet. It can be a string or an
array of strings (if you want multiple trigger phrases). Substring matching is performed on
prefixes, so in this case, typing "h1" would match our example snippet.
3. The body property is the content that is inserted into the editor. It is an array of strings,
which is one or more lines of content. The content is joined together before insertion.
4. The description property can provide more information about the snippet. It is
optional.
5. The scope property allows you to target specific languages, and you can supply a
comma-separated list in the string. It is optional. Of course, it is redundant for a languagespecific snippet file.
The body of this snippet has 2 tab stops and uses the variable ${TM_SELECTED_TEXT} .
Let's get into the syntax to understand this fully.
Snippet syntax
VS Code's snippet syntax is the same as the TextMate snippet syntax. However, it does not
support 'interpolated shell code' and the use of the \u transformation.

The body of a snippet supports the following features

1. Tab Stops
Tab stops are specified by a dollar sign and an ordinal number e.g. $1 . $1 will be the first
location, $2 will the second location, and so on. $0 is the final cursor position, which exits the
snippet mode.
For example, let's say we want to make an HTML div snippet and we want the first tab stop to be
between the opening and closing tags. We also want to allow the user to tab outside of the tags
to finish the snippet.
Then we could make a snippet like this:

```json
 "Insert div": {
 prefix: "div",
 body: ["<div>","$1","</div>", "$0"]
 }

```

Mirrored Tab Stops
There are times when you need to provide the same value in several places in the inserted text.
In these situations you can re-use the same ordinal number for tab stops to signal that you want
them mirrored. Then your edits are synced.
A typical example is a for loop which uses an index variable multiple times. Below is a JavaScript
example of a for loop.

```json
 "For Loop": {
 "prefix": "for",
 "body": [
 "for (let ${1:index} = 0; ${1:index} < ${2:array}.length; ${1:index}++) {",
 "\tconst ${3:element} = ${2:array}[${1:index}];",
 "\t$0",
 "}"
 ]
}
```

1. Placeholders
Placeholders are tab stops with default values. They are wrapped in curly braces, for example
${1:default} . The placeholder text is selected on focus such that it can be easily edited.
Placeholders can be nested, like this: ${1:first ${2:second}} .

1. Choices
Choices present the user with a list of values at a tab stop. They are written as a commaseparated list of values enclosed in pipe-characters e.g. ${1|yes,no|} .
This is the code for the markdown example shown earlier for inserting a task list. The choices are'x' or a blank space.

```json
 "Insert task list": {
 "prefix": "task",
 "body": ["- [${1| ,x|}] ${2:text}", "${0}"]
}
```

Variables
There is a good selection of variables you can use. You simply prefix the name with a dollar sign
to use them, for example $TM_SELECTED_TEXT .
For example, this snippet will create a block comment for any language with today's date:

```json
{
 "Insert block comment with date": {
 prefix: "date comment",
 body: ["${BLOCK_COMMENT_START}",
 "${CURRENT_YEAR}/${CURRENT_MONTH}/${CURRENT_DATE} ${1}",
 "${BLOCK_COMMENT_END}"]
 }
}
```

You can specify a default for a variable if you wish, like ${TM_SELECTED_TEXT:default} . If a
variable does not have a value assigned, the default or an empty string is inserted.
If you make a mistake and include a variable name that is not defined, the name of the variable is
transformed into a placeholder.
The following workspace variables can be used:

**TM_SELECTED_TEXT** : The currently selected text or the empty string,
TM_CURRENT_LINE : The contents of the current line,
TM_CURRENT_WORD : The contents of the word under cursor or the empty string,
TM_LINE_INDEX : The zero-index based line number,
TM_LINE_NUMBER : The one-index based line number,
TM_FILENAME : The filename of the current document,
TM_FILENAME_BASE : The filename of the current document without its extensions,
TM_DIRECTORY : The directory of the current document,
TM_FILEPATH : The full file path of the current document,
CLIPBOARD : The contents of your clipboard,
WORKSPACE_NAME : The name of the opened workspace or folder.
The following time-related variables can be used:
CURRENT_YEAR : The current year,
CURRENT_YEAR_SHORT : The current year's last two digits,
CURRENT_MONTH : The month as two digits (example '07'),
CURRENT_MONTH_NAME : The full name of the month (example 'July'),
CURRENT_MONTH_NAME_SHORT : The short name of the month (example 'Jul'),
CURRENT_DATE : The day of the month,
CURRENT_DAY_NAME : The name of day (example 'Monday'),
CURRENT_DAY_NAME_SHORT : The short name of the day (example 'Mon'),
CURRENT_HOUR : The current hour in 24-hour clock format,
CURRENT_MINUTE : The current minute,
CURRENT_SECOND : The current second,
CURRENT_SECONDS_UNIX : The number of seconds since the Unix epoch.
The following comment variables can be used. They honour the syntax of the document's
language:
BLOCK_COMMENT_START : For example, <!-- in HTML,
BLOCK_COMMENT_END : For example , --> in HTML,
LINE_COMMENT : For example, // in JavaScript.

1. Transformations
Transformations can be applied to a variable or a placeholder. If you are familiar with regular
expressions (regex), most of this should be familiar.
The format of a transformation is: ${«variable or placeholder»/«regex»/«replacement
string»/«flags»} . It is similar to String.protoype.replace() in JavaScript. The "parameters" do
the following:
«regex» : This is a regular expression that is matched against the value of the variable or
placeholder. The JavaScript regex syntax is supported.
«replacement string» : This is the string you want to replace the original text with. It can
reference capture groups from the «regex» , perform case formatting (using the special
functions: /upcase , /downcase , and /capitalize ), and perform conditional insertions.
See TextMate Replacement String Syntax for more in-depth information.
«flags» : Flags that are passed to the regular expression. The JavaScript regex flags can
be used:
g : Global search,
i : Case-insensitive search,
m : Multi-line search,
s : Allows . to match newline characters,
u : Unicode. Treat the pattern as a sequence of Unicode code points,
y : Perform a "sticky" search that matches starting at the current position in the
target string.
To reference a capture group, use $n where n is the capture group number. Using $0 means
the entire match.
This can be a bit confusing since tab stops have the same syntax. Just remember that if it is
contained within forward slashes, then it is referencing a capture group.
The easiest way to understand the syntax fully is to check out a few examples.

```code
| SNIPPET BODY | INPUT | OUTPUT| EXPLANATION |
| ------------ | ----- | ----- | ----------- |
| ["${TM_SELECTED_TEXT/^.+$/• $0/gm}"] | line1 | line2 | • line1 | • line2 | Put a bullet point before each non-empty line of the selected text.
| ["${TM_SELECTED_TEXT/^(\\w+)/${1:/capitalize}/}"] | the cat is on the mat. | The cat is on the mat. | Capitalize the first word of selected text.
| ["${TM_FILENAME/.*/${0:/upcase}/}"] | example.js | EXAMPLE.JS | Insert the filename of the current file uppercased.
| ["[","${CLIPBOARD/^(.+)$/'$1',/gm}","]"] | line1 line2 | ['line1', 'line2',] | Turn the contents of the clipboard into a string array. | Each non-empty line is an element.
```

As you can see from the second example above, metacharacter sequences must be escaped, for
example insert \\w for a word character.

Placeholder Transformations
Placeholder transforms do not allow a default value or choices! Maybe it is more suitable to
call them tab stop transformations.
The example below will uppercase the text of the first tab stop.

```json
 "Uppercase first tab stop": {
 "prefix": "up",
 "body": ["${1/.*/${0:/upcase}/}", "$0"]
 }
```

You can have a placeholder and perform a transformation on a mirrored instance. The
transformation will not be performed on the initial placeholder.?
Would you use this behaviour somewhere?I find it confusing initially, so it may have the same
affect on others.

```json
 "Uppercase second tab stop instance only": {
 "prefix": "up",
 "body": ["${1:title}", "${1/(.*)/${1:/upcase}/}", "$0"]
 }

```

How do I assign Keyboard Shortcuts for snippets?
By adding your shortcuts to keybindings.json . You can open the file by running the

'Preferences: Open Keyboard Shortcuts File (JSON)' command.
For example, to add a shortcut for the built-in markdown snippet"Insert heading level 1":

```json
{
 "key": "ctrl+m ctrl+1",
 "command": "editor.action.insertSnippet",
 "when": "editorTextFocus && editorLangId == markdown",
 "args": {
 "langId": "markdown",
 "name": "Insert heading level 1"
 }
}
```

You define a shortcut by specifying the key combination you want to use, the command ID, and
an optional when clause context for the context when the keyboard shortcut is enabled.
Through the args object, you can target an existing snippet by using the langId and name
properties. The langId argument is the language ID of the language that the snippets were
written for. The name is the snippet's name as it is defined in the snippet file.

You can define an inline snippet if you wish using the snippet property.

```json
 {
 "key": "ctrl+k 1",
 "command": "editor.action.insertSnippet",
 "when": "editorTextFocus",
 "args": {
 "snippet": "${BLOCK_COMMENT_START}${CURRENT_YEAR}/${CURRENT_MONTH}/${CURRENT_DATE} ${1} ${BLOCK}
 }
}
```

You can use the Keyboard Shortcuts UI also, but it does not have the ability to add a new shortcut.
Another downside of the UI is that it does not show the args object, which makes it more
