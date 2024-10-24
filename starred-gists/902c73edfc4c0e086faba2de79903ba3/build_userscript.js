#!/usr/bin/env node

const defaultConfig = require("./default.config");
const userConfig = require("./user.config");
const md5Config = require("./md5.config");
const fs = require("fs");
const path = require("path");

const FILE_NAME = __dirname + "/titled.template.js";

const OUTPUT = "titled.user.js";

const OUTPUT_MD5 = "titled_md5.user.js";

const CONFIG_INDENT = "  ";

let fileData = fs.readFileSync(FILE_NAME, "utf8");

// Cheap way to version bump
if (process.argv[2] == "bump") {
  console.log("bumping version");
  let fileLines = fileData.split(/\n/);

  let index = fileLines.findIndex(line => line.match(/^\s*\/\/\s*@version/));

  if (index == -1) {
    console.error("no version line was found");
    process.exit(1);
  }

  let foundLine = fileLines[index];
  let match = foundLine.match(/\s*\/\/\s*@version(\s{1,})(\d+(\.\d+)*)/);
  if (!match) {
    console.error(`no valid version string was found on line ${index}`);
    process.exit(1);
  }
  let version = match[2];
  console.log(`current version is: ${version}`);
  version = version.split(".").map(versionPart => parseInt(versionPart, 10));

  // bump
  version[version.length - 1]++;

  console.log(`new version is: ${version.join(".")}`);

  fileLines[index] = `// @version${match[1]}${version.join(".")}`;

  fs.writeFileSync(FILE_NAME, fileLines.join("\n"));
  fileData = fileLines.join("\n");
}

function cloneConfig(config) {
  return {
    config: { ...config.config },
    documentation: { ...config.documentation },
    requires: [...config.requires]
  };
}

function mergeConfig(a, b) {
  Object.assign(a.config, b.config);
  Object.assign(a.documentation, b.documentation);
  a.requires = [...a.requires, ...b.requires];
}

function stringifyConfig(config) {
  let configStr = "";

  for (const [key, value] of Object.entries(config.config)) {
    let documentation = config.documentation[key];

    if (documentation) {
      configStr +=
        documentation
          .trim()
          .split("\n")
          .map(line => CONFIG_INDENT + "// " + line)
          .join("\n") + "\n";
    }

    configStr +=
      CONFIG_INDENT + `const ${key} = ${JSON.stringify(value)};` + "\n\n";
  }
  return configStr;
}

let baseConfig = cloneConfig(defaultConfig);

mergeConfig(baseConfig, userConfig);

function applyConfig(contents, config, filePath) {
  return contents
    .replace(
      /\n[ \t]+\/\* --START-REMOVING--HERE-- \*\/([\s\S]+?)\/\* --STOP-REMOVING--HERE-- \*\//,
      "\n" + stringifyConfig(config)
    )
    .replace(/\$\$FILE_PATH\$\$/g, filePath)
    .replace(
      /\n[ \t]*\/\* --INSERT-REQUIRES--HERE-- \*\//,
      config.requires.length === 0
        ? ""
        : "\n" +
            config.requires
              .map(require => `// @require      ${require}`)
              .join("\n")
    );
}

let baseScript = applyConfig(fileData, baseConfig, OUTPUT);

fs.writeFileSync(__dirname + "/" + OUTPUT, baseScript);

let md5ConfigFinal = cloneConfig(baseConfig);

mergeConfig(md5ConfigFinal, md5Config);

let md5Script = applyConfig(fileData, md5ConfigFinal, OUTPUT_MD5);

fs.writeFileSync(__dirname + "/" + OUTPUT_MD5, md5Script);
