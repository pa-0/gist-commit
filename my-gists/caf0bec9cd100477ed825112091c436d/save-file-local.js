/*
* Save a text file locally with a filename by triggering a download
*/

var text = "hello world",
    blob = new Blob([text], { type: 'text/plain' }),
    anchor = document.createElement('a');

anchor.download = "hello.txt";
anchor.href = (window.webkitURL || window.URL).createObjectURL(blob);
anchor.dataset.downloadurl = ['text/plain', anchor.download, anchor.href].join(':');
anchor.click();