# Problem
I was training a deep learning model on Google Colab. I had to go somewhere for an emergency work. When I came back, I realized that Colab was disconnected; Therefore, I had to run the whole model again.

# Solution

>[!Important]
>As of July 2024, the original solution (hidden behind an expando below) no longer works, as such I've included several solutions from Stack Overflow that posters claim still work.  I will update this post after testing each.

<details><summary><strong> Original (Outdated) Solution)</strong></summary>
  
I searched on the Internet to solve this problem. I noticed that Colab will be disconnected if you don't click on the page. Here is an answer that I find:

```
function ClickConnect() {
  console.log('Working')
  document
    .querySelector('#top-toolbar > colab-connect-button')
    .shadowRoot.querySelector('#connect')
    .click()
}
intervalTiming = setInterval(ClickConnect, 60000)
```

Copy this code above to the page Console and press enter.

60000(ms) means that every 1 minute it clicks on the page.

If you don't know how to open the page Console, you can either press f12 or right_click + inspect then select the Console.

When you're done, you can reset this by typing the code bellow in the page Console:

```
clearInterval(intervalTiming);
```
</details>

## Possible Alternatives

### Method 1 (enter in browser console)

Javascript code for preventing Google colab from disconnecting due to inactivity.

```javascript
 function keepAliveProgrammatically() {
  document.querySelector('colab-connect-button').shadowRoot.querySelector("#connect").click();
}
```

The function above is responsible for clicking the compute resources button It is clicked after every 6 seconds. The code snippet below is responsible for running the function.

```javascript
const keepAliveProgrammaticallyInterval = setInterval(() => {
    keepAliveProgrammatically();
}, 6000);
```
To stop the code, use the code snippet below.
```
clearInterval(keepAliveProgrammaticallyInterval);
```

### Method 2 (Enter into cell of notebook directly)

This snippet when run in colab seems to work:
```python
from IPython.display import Audio
import numpy as np

Audio(np.array([0] * 2 * 3600 * 3000, dtype=np.int8), normalize=False, rate=3000, autoplay=True)

# Audio([None] * 2 * 3600 * 3000, normalize=False, rate=3000, autoplay=True)
```
Explanation: the basic idea is to generate a large engouh numpy array and play it as an audioclip with a counter running.

`[None] * 2 * 3600 * 3000`: enough values to play for 2 hours to keep the session alive
`dtype=np.int8`: allocate a single byte, it's all zero anyway.
`2 * 3600`: 2 hours, `3000` is the smallest sample rate (see below) to enable a running counter.
`rate`: sample rate
`normalize=False`: since it's all zero, the default normalize=True will result in a divide by zerro warning
`autoplay=True`: no need to click to play the clip.

It takes a few seconds for the widget to appear and another few seconds for the clip to start autoplaying.

Data for one hour: (`np.array([0] * 2 * 3600 * 3000, dtype=np.int8)`) appears to require 100M RAM.

The alternative (`Audio([None] * 2 * 3600 * 3000, normalize=False, rate=3000, autoplay=True)`) wont need the numpy lib but will require more RAM.

**`Audio`** can also play a local audiofile or something from a url. Check **`Audio`**'s doc for more details.


### Method 3 (for browser console)

```javascript
function ConnectButton() {
    console.log("trying to click connect button");

    let colabConnectButton = document.querySelector("colab-connect-button");
    if (colabConnectButton && colabConnectButton.shadowRoot) {
        let actualButton = colabConnectButton.shadowRoot.querySelector("colab-toolbar-button#connect");
        if (actualButton) {
            actualButton.click();
            console.log("connect button clicked");
        } else {
            console.log("button not found");
        }
    } else {
        console.log("button not found");
    }
}
setInterval(ConnectButton, 60000);
Share
Edit
Follow
answered Jul 3, 2023 at 17:06
A. Mair's user avatar
A. Mair
6144 bronze badges
Add an explanation, please. – 
sanitizedUser
 CommentedJul 10, 2023 at 0:39 
Can't say conclusively, but this seems to work. thank you. – 
Ghulam
 CommentedJul 30, 2023 at 16:45 
Add a comment
8

You can bookmark the notebook to make it stay connected:

function ClickConnect(){
    console.log("Clicked on star button"); 
    document.querySelector("iron-icon#star-icon").click()
}
setInterval(ClickConnect, 60000)
```
Now you can see the blinking of the star every minute.

>[!caution]
>`document.querySelector("iron-icon#star-icon")` is now null. 
>Find `jspath` for an expand button on the Colab interface and replace the star icon element with that expand element: 
>1. In the elements panel, right-click that expand icon element. 
>2. <input>copy</input> -> <input>copy jspath</input>. 
>Example:
>```javascript
>document.querySelector("#cell-bbKbx185zqlz > div.main-content > div.editor-container.horizontal > div.text-top-div > div > span > h1 > paper-icon-button").shadowRoot.querySelector("#icon")
>```
>Note that this only works for a certain amount of time until a captcha prompt appears.