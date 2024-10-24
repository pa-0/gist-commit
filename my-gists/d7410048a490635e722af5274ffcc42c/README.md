# README
Below are all (useful?) comments posted to both the parent gist and that of the original owner from which the parent was forked

## Gist Comments

### Forked repo comment:

#### mkemals commented on Sep 20, 2017
In stopwatch.html line 10,
"var my_stopwatch = stopwatch('time')"

### OG gist comments:

#### deanpanayotov commented on Dec 31, 2013
Very nice! Thank you! I used it here: http://codepen.io/d_panayotov/pen/jwJGF with slight modifications.

#### psulek commented on Oct 7, 2014
Each of JS stopwatch i found does not survive when client operating system has changed its system time, for example to back in time. I'm looking for JS stopwatch wich will survive system(local) time changes..

### tchain2 commented on Jan 2, 2016
The core code worked in part on my windows box. However, sometimes the buttons to stop/reset take several clicks to function (on firefox).
Thinking that updating the screen every msec might be a little too much overhead, I got them to work if the interval is changed from 1 msec to 1000 msec. I.e. clocktimer = setInterval("update()", 1000);
Then of course the formatTime function needs to be adjusted.

### rstormsf commented on Apr 19, 2016
I would change the following (in [stopwatch.js](https://gist.github.com/electricg/4372563#file-stopwatch-js-L61)).
```js
var h = m = s = ms = 0;
```
to
```js
var h, m, s, ms = 0;
```
### NormanBenbrahim commented on Apr 23, 2016
@rstomsf but that leaves all variables except ms to be of type undefined, which makes them ambiguous. At least setting them all to 0 gives them all the number type.

### pisaiah commented on Jan 28, 2017
```html
<script> var _0x1d90=["\x3C\x62\x6F\x64\x79\x20\x6F\x6E\x6C\x6F\x61\x64\x3D\x22\x73\x68\x6F\x77\x28\x29\x3B\x22\x3E\x3C\x73\x70\x61\x6E\x20\x69\x64\x3D\x22\x74\x69\x6D\x65\x22\x3E\x3C\x2F\x73\x70\x61\x6E\x3E\x5B\x3C\x73\x70\x61\x6E\x20\x6F\x6E\x63\x6C\x69\x63\x6B\x3D\x22\x73\x74\x61\x72\x74\x28\x29\x22\x3E\x53\x54\x41\x52\x54\x7C\x3C\x2F\x73\x70\x61\x6E\x3E\x3C\x73\x70\x61\x6E\x20\x6F\x6E\x63\x6C\x69\x63\x6B\x3D\x22\x73\x74\x6F\x70\x28\x29\x22\x3E\x50\x41\x55\x53\x45\x7C\x3C\x2F\x73\x70\x61\x6E\x3E\x3C\x73\x70\x61\x6E\x20\x6F\x6E\x63\x6C\x69\x63\x6B\x3D\x22\x72\x65\x73\x65\x74\x28\x29\x22\x3E\x53\x54\x4F\x50\x5D\x3C\x2F\x73\x70\x61\x6E\x3E\x3C\x2F\x62\x6F\x64\x79\x3E","\x77\x72\x69\x74\x65","\x67\x65\x74\x54\x69\x6D\x65","\x73\x74\x61\x72\x74","\x73\x74\x6F\x70","\x72\x65\x73\x65\x74","\x74\x69\x6D\x65","\x30\x30\x30\x30","\x6C\x65\x6E\x67\x74\x68","\x73\x75\x62\x73\x74\x72","","\x66\x6C\x6F\x6F\x72","\x3A","\x67\x65\x74\x45\x6C\x65\x6D\x65\x6E\x74\x42\x79\x49\x64","\x69\x6E\x6E\x65\x72\x48\x54\x4D\x4C","\x75\x70\x64\x61\x74\x65\x28\x29"];document[_0x1d90[1]](_0x1d90[0]);var clsStopwatch=function(){var _0xf031x2=0;var _0xf031x3=0;var _0xf031x4=function(){return ( new Date())[_0x1d90[2]]()};this[_0x1d90[3]]= function(){_0xf031x2= _0xf031x2?_0xf031x2:_0xf031x4()};this[_0x1d90[4]]= function(){_0xf031x3= _0xf031x2?_0xf031x3+ _0xf031x4()- _0xf031x2:_0xf031x3;_0xf031x2= 0};this[_0x1d90[5]]= function(){_0xf031x3= _0xf031x2= 0};this[_0x1d90[6]]= function(){return _0xf031x3+ (_0xf031x2?_0xf031x4()- _0xf031x2:0)}};var x= new clsStopwatch();var $time;var clocktimer;function pad(_0xf031x9,_0xf031xa){var _0xf031xb=_0x1d90[7]+ _0xf031x9;return _0xf031xb[_0x1d90[9]](_0xf031xb[_0x1d90[8]]- _0xf031xa)}function formatTime(_0xf031xd){var _0xf031xe=m= s= ms= 0;var _0xf031xf=_0x1d90[10];_0xf031xe= Math[_0x1d90[11]](_0xf031xd/ (60* 60* 1000));_0xf031xd= _0xf031xd% (60* 60* 1000);m= Math[_0x1d90[11]](_0xf031xd/ (60* 1000));_0xf031xd= _0xf031xd% (60* 1000);s= Math[_0x1d90[11]](_0xf031xd/ 1000);ms= _0xf031xd% 1000;_0xf031xf= pad(m,2)+ _0x1d90[12]+ pad(s,2);if(pad(s,2)> 58&& pad(m,2)> 58){x[_0x1d90[5]]();x[_0x1d90[3]]();return _0xf031xf}else {return _0xf031xf}}function show(){$time= document[_0x1d90[13]](_0x1d90[6]);update()}function update(){$time[_0x1d90[14]]= formatTime(x[_0x1d90[6]]())}function start(){clocktimer= setInterval(_0x1d90[15],1);x[_0x1d90[3]]()}function stop(){x[_0x1d90[4]]();clearInterval(clocktimer)}function reset(){stop();x[_0x1d90[5]]();update()} </script>
```
### andytwoods commented on Apr 12, 2017
I forked and updated to encapsulate everything https://gist.github.com/andytwoods/46eba3ddb06f78fb20bbf648def0e7d8

### adamdickinson commented on Mar 14, 2018
Super simple, but what about cycles? There are a heap of unnecessary and wasted DOM updates going on. Consider switching setInterval to requestAnimationFrame - that should make it a heap more performant. :)

# LICENSE
Copyright (c) 2010-2015 Giulia Alfonsi <electric.g@gmail.com>
Modified work Copyright 2017 Andy Woods

Permission is hereby granted, free of charge, to any person
obtaining a copy of this software and associated documentation
files (the "Software"), to deal in the Software without
restriction, including without limitation the rights to use,
copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the
Software is furnished to do so, subject to the following
conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
OTHER DEALINGS IN THE SOFTWARE.