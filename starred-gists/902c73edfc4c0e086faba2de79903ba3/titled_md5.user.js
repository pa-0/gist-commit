// ==UserScript==
// @name         AHK Forum: Better Download Names
// @version      0.1.29
// @description  Fix download names over at the ahk forums
// @author       menixator
// @match        https://www.autohotkey.com/boards/viewtopic.php?*
// @icon         https://www.autohotkey.com/favicon.ico
// @updateURL    https://gist.github.com/raw/59e7197f71fe6570c6070ec29f9597f2/titled_md5.user.js
// @downloadURL  https://gist.github.com/raw/59e7197f71fe6570c6070ec29f9597f2/titled_md5.user.js
// @homepage     https://gist.github.com/59e7197f71fe6570c6070ec29f9597f2
// @require      https://cdnjs.cloudflare.com/ajax/libs/crypto-js/4.1.1/core.min.js
// @require      https://cdnjs.cloudflare.com/ajax/libs/crypto-js/4.1.1/md5.min.js
// @grant        none
// ==/UserScript==

(function() {
  // How many times to retry if user enters an empty string
  const NUM_RETRIES_ON_EMPTY = 0;

  // Turn this on to remove the classic download button and leave only the "Download As" button
  const REMOVE_CLASSIC_DOWNLOAD_BUTTON = false;

  // Decide on how to generate a suffix
  // LENGTH: uses the first n digits of the hexadecimal representation of the code
  // block's length
  // MD5: uses the first n characters of an md5 checksum(overkill)
  const SUFFIX_STRATEGY = "MD5";

  // Limit the number of suffix characters for the length strategy.
  // Any number equal to 0 or less here will make the userscript use the entire
  // string
  const SUFFIX_STRATEGY_LENGTH_LIMIT = 5;

  // Sometimes, users will add legitimate names to the files. Turn this on if
  // you dont want to discard them
  const DISCARD_POSTERS_FILE_NAMES = false;

  // How many characters to take from the beginning of the md5 sum.
  // Any number equal to 0 or less here will make the userscript use the entire
  // string
  const SUFFIX_STRATEGY_MD5_LIMIT = 5;

  // You are free to edit these functions however you want without breaking the script
  // Default format is :
  // For AHK files: %SANITIZED_TOPIC_NAME%%SUFFIX%
  // For Others: T%TOPIC_ID%:P%POST_ID%: %SANITIZED_TOPIC_NAME%%SUFFIX%
  /* Customizations here */
  function generateFileName(info) {
    switch (info.language) {
      case "autohotkey":
        // Only for autohotkey files
        return `${info.topicTitle}${generateSuffix(info)}`;
    }

    return `${info.topicTitle}_T${info.topicId}:P${info.postId}${generateSuffix(
      info
    )}`;
  }

  function postProcessUserInputFileName(_info, enteredFileName) {
    return enteredFileName;
  }

  function transformCodeBlock(info, data) {
    switch (info.language) {
      case "autohotkey":
        // Add anything you want to add to the code here
        /* Customizations here */
        let contents = [
          `; TOPIC NAME: ${info.initialTopicTitle}`,
          `; POST LINK: https://www.autohotkey.com/boards/viewtopic.php?t=${info.topicId}#p${info.postId}`,
          `; TOPIC LINK: https://www.autohotkey.com/boards/viewtopic.php?t=${info.topicId}`,
          "",
          "",
          data
        ].join("\n");
        return contents;
    }

    return data;
  }

  function finalFileNameTransform(info, fileName) {
    switch (info.language) {
      case "autohotkey":
        if (!fileName.match(/.ahk$/)) {
          return `${fileName}.ahk`;
        }
    }

    // If there was an extension extracted and if the fileName does not have an
    // extension, add it
    if (info.extension && !fileName.match(/\.\w{1,}$/)) {
      fileName += `.${info.extension}`;
    }
    return fileName;
  }

  function topicTitleTransform(topicTitle) {
    return sanitizeFileName(
      topicTitle.replace(/\[\s*solved\s*\]/gi, "")
    ).toLowerCase();
  }

  // Try to generate a somewhat reproducable suffix. The idea is to try and
  // have the filename be the same for the codeblock in quoted contexts.
  // TODO: improve this
  function generateSuffix(info) {
    let content = info.data.trim();

    if (info.suffix) {
      return suffix;
    }

    if (content.length == 0) {
      info.codeboxId = "0";
      info.suffix = "_0";
      return info.suffix;
    }

    switch (SUFFIX_STRATEGY) {
      case "MD5":
        let contentHash = CryptoJS.MD5(info.data).toString();

        if (SUFFIX_STRATEGY_MD5_LIMIT !== -1) {
          contentHash = contentHash.slice(0, SUFFIX_STRATEGY_MD5_LIMIT);
        }
        info.codeBoxId = contentHash;
        info.suffix = `_${info.codeBoxId}`;
        break;

      default:
      case "LENGTH":
        info.codeBoxId = content.length.toString(16);
        if (
          SUFFIX_STRATEGY_LENGTH_LIMIT > 0 &&
          SUFFIX_STRATEGY_LENGTH_LIMIT !== -1
        ) {
          info.codeBoxId = info.codeBoxId.slice(
            0,
            SUFFIX_STRATEGY_LENGTH_LIMIT
          );
        }

        info.suffix = `_${info.codeBoxId}`;
        break;
    }
    invariant(
      info.suffix && info.suffix.length > 0,
      "Suffix was empty, check your config"
    );
    return info.suffix;
  }

  // ----------------------------------------------------------
  // These can be edited but you might break the script

  function download() {
    let codebox = this.closest(".codebox");

    let infoStr = codebox.getAttribute("data-userscript-blob");

    if (!infoStr || infoStr === null || infoStr === "") {
      return false;
    }

    let info = JSON.parse(infoStr);

    if (!info.language && info.language !== null) {
      let language =
        [...codebox.querySelector("code").classList].find(className =>
          className.startsWith("language-")
        ) || null;

      if (language !== null) {
        language = language.trim().slice("language-".length);
      }
      info.language = language;
      codebox.setAttribute("data-userscript-blob", JSON.stringify(info));
    }

    let code = codebox.querySelector("pre");
    let data = code.textContent || "";

    let newFileName = info.defaultFileName;

    if (DISCARD_POSTERS_FILE_NAMES || !info.defaultFileName) {
      let generatedFileName;

      if (info.generatedFileName) {
        generatedFileName = info.generatedFileName;
      } else {
        generatedFileName = generateFileName(
          Object.assign({ data: data }, info)
        );

        invariant(
          generatedFileName && generatedFileName.length > 0,
          "Generated filename was null/empty"
        );
        info.generatedFileName = generatedFileName;
        codebox.setAttribute("data-userscript-blob", JSON.stringify(info));
      }
      newFileName = generatedFileName;
    }

    data = transformCodeBlock(info, data);
    invariant(data, "transformCodeBlock returned null/undefined");

    if (this.hasAttribute("data-userscript-ask-input")) {
      let i = 0;
      do {
        // Prompt will have the newFileName prefilled
        newFileName = prompt("Save code block as:", newFileName);
        // User cancelled or pressed escape
        if (newFileName === null) {
          return false;
        }
      } while (newFileName.length === 0 && ++i < NUM_RETRIES_ON_EMPTY);

      // User entered an empty string
      if (newFileName.length === 0) {
        return;
      }

      newFileName = postProcessUserInputFileName(newFileName);
      invariant(
        newFileName && newFileName.length > 0,
        "postProcessUserInputFileName returned null/empty"
      );
    }

    downloadTextFile(info, data, newFileName);
  }

  // Yoinked from site code
  // I'll leave joe's comment here

  // joedf: modified from https://stackoverflow.com/a/33542499/883015

  function downloadTextFile(info, data, fileName) {
    fileName = finalFileNameTransform(info, fileName);
    invariant(
      fileName && fileName.length > 0,
      "finalFileNameTransform returned null/empty string"
    );

    var blob = new Blob([data], { type: "text/plain" });
    if (window.navigator.msSaveOrOpenBlob) {
      window.navigator.msSaveBlob(blob, fileName);
    } else {
      var elem = window.document.createElement("a");
      elem.href = window.URL.createObjectURL(blob);
      elem.download = fileName;
      document.body.appendChild(elem);
      elem.click();
      document.body.removeChild(elem);
    }
    return false;
  }

  function invariant(value, message) {
    if (!value) {
      throw new Error(message);
    }
  }

  function sanitizeWindowsFileName(fileName) {
    return (
      fileName
        .replace(/\n/g, " ")
        .replace(/[<>:"/\\|?*\x00-\x1F]| +$/g, "_")
        .replace(/^(CON|PRN|AUX|NUL|COM[1-9]|LPT[1-9])$/, x => x + "_")
        .replace(/__/g, "")
        // Remove underscores from the beginning and the end
        .replace(/^_|_$/g, "")
    );
  }

  function sanitizeFileName(fileName) {
    return (
      sanitizeWindowsFileName(fileName)
        .replace(/,/, "")
        .replace(/\s/g, "_")
        .replace(/__/g, "_")
        // Remove underscores from the beginning and the end
        .replace(/^_|_$/g, "")
    );
  }
  //

  if (document.readyState == "complete") {
    run();
  } else {
    window.addEventListener("load", run);
  }

  function run() {
    if (SUFFIX_STRATEGY === "MD5" && !CryptoJS) {
      alert("Using MD5 suffix strategy but CryptoJS was not found!");
      return;
    }

    let topicTitle = document.querySelector(".topic-title>a");

    if (!topicTitle || topicTitle === null) {
      return;
    }

    topicTitle = topicTitle.textContent;

    let threadInformation = {
      initialTopicTitle: topicTitle,
      topicTitle: topicTitleTransform(topicTitle),
      topicId: document.querySelector(
        `#topic-search > fieldset > input[name="t"]`
      ).value
    };

    for (const post of document.querySelectorAll(".post")) {
      // Lop off the prefix "p"
      let postId = post.id.slice(1);

      let codeboxes = [...post.querySelectorAll(".codebox")];
      for (const codebox of codeboxes) {
        if (codebox.hasAttribute("data-userscript-blob")) {
          continue;
        }
        // Check if parent element has the class "content"
        // If it doesnt, then this codebox is in a quoted context
        if ([...codebox.parentElement.classList].indexOf("content") == -1) {
          // We're in a quoted context

          let closestCitedBlockQuote = codebox.closest(
            "blockquote:not(.uncited)"
          );

          if (closestCitedBlockQuote) {
            postId = closestCitedBlockQuote
              .querySelector("cite>a[data-post-id]")
              .getAttribute("data-post-id");
          }
        }

        let postInformation = Object.assign({}, threadInformation, {
          postId
        });

        let downloadLink = [...codebox.querySelectorAll("p>a")].find(
          a => a.textContent === "Download"
        );

        if (!downloadLink) {
          return;
        }

        let extension = null;

        let extMatch = codebox
          .getAttribute("data-filename")
          .match(/^(.+?)\.(.+?)$/);

        let defaultFileName = null;

        if (extMatch) {
          extension = extMatch[2];

          if (extMatch[1] !== "Untitled") {
            defaultFileName = extMatch[1];
          }
        }

        postInformation = Object.assign({}, postInformation, {
          defaultFileName,
          extension
        });

        codebox.setAttribute(
          "data-userscript-blob",
          JSON.stringify(postInformation)
        );

        downloadLink.title = `Download File`;
        downloadLink.removeAttribute("onclick");
        // Fix the hover
        downloadLink.style.cursor = "pointer";

        // Stop moving away from the scroll position when the button is clicked.
        downloadLink.removeAttribute("href");

        let downloadAsLink = document.createElement("a");
        downloadAsLink.title = "Download As";

        downloadAsLink.style.cursor = "pointer";

        downloadAsLink.setAttribute("data-userscript-ask-input", true);

        downloadAsLink.textContent = "Download As";
        downloadAsLink.addEventListener("click", download.bind(downloadAsLink));

        downloadLink.insertAdjacentElement("afterend", downloadAsLink);
        downloadLink.insertAdjacentText("afterend", " - ");

        if (REMOVE_CLASSIC_DOWNLOAD_BUTTON) {
          downloadLink.remove();
        } else {
          downloadLink.addEventListener("click", download.bind(downloadLink));
        }
      }
    }
  }
})();
