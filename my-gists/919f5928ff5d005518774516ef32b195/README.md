On Twitter, [Will McGuan](https://twitter.com/willmcgugan) posted a perspective [screenshot](https://twitter.com/willmcgugan/status/1488204827540742146?s=20&t=iFSfVzJpLZwSbq5GnCGo6g).

This gist provides few basic steps, using [ImageMagick](https://imagemagick.org), to produce some similar looking.

Following steps were processed.

- starting with a screenshot of the Rich CLI help in a terminal

![image](https://user-images.githubusercontent.com/653288/152007641-7c8612b1-4915-49d3-9618-da6ed1fe8c09.png)

- create a perspective view of the screenshot

![image](https://user-images.githubusercontent.com/653288/152007748-a77445ba-d4b1-42ad-9f02-3b913ed599fe.png)

- add shadow to the perspective

![image](https://user-images.githubusercontent.com/653288/152007912-9fc928a0-4a2f-4a25-890a-a9cf7708fa09.png)

- create a gradient for the background

![image](https://user-images.githubusercontent.com/653288/152007958-32abbac8-dd48-4762-a0a5-6d6904e2e1f6.png)

- combine both images

![image](https://user-images.githubusercontent.com/653288/152007996-78a6fa00-e427-4e5c-8f46-253c29667526.png)


The script `create.sh`  process all the mentioned steps.


**note**: The aim was to provide the basic steps and not a fully optimized version of the workflow. Some imagemagick steps could be combined, but were not for clarity.
