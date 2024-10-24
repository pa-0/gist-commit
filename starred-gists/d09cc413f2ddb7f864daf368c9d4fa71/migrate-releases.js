const { Octokit } = require('@octokit/rest');
const semver = require('semver');
require('dotenv').config();

const fileSizeSI = (bytes) => {
  const size = (Math.log(bytes) / Math.log(1024)) | 0;

  return (
    (bytes / Math.pow(1024, size)).toFixed(2) +
    ' ' +
    (size ? 'KMGTPEZY'[size - 1] + 'iB' : 'Bytes')
  );
};

const octokit = new Octokit({
  auth: process.env.GH_AUTH_TOKEN,
});

const { SOURCE_REPO, DESTINATION_REPO, TAG_SHA } = process.env;

const parseRepo = (repo) => ({
  owner: repo.split('/')[0],
  repo: repo.split('/')[1],
});

const oldRepo = parseRepo(SOURCE_REPO);
const newRepo = parseRepo(DESTINATION_REPO);

(async () => {
  console.log(`Fetching all Releases from "${SOURCE_REPO}"...`);

  const oldReleases = await octokit.rest.repos.listReleases({
    ...oldRepo,
  });

  console.log(`  Found ${oldReleases.data.length} releases`);

  for (const oldRelease of oldReleases.data.sort((a, b) =>
    semver.compare(a.tag_name, b.tag_name)
  )) {
    console.log(`  Creating "${oldRelease.name}"`);

    const newRelease = await octokit.rest.repos.createRelease({
      ...newRepo,
      tag_name: oldRelease.tag_name,
      target_commitish: TAG_SHA,
      name: oldRelease.name,
      body: oldRelease.body,
    });

    console.log(`    Processing Assets`);

    for (const [i, asset] of Object.entries(oldRelease.assets)) {
      console.log(
        `     - Asset ${+i + 1} of ${oldRelease.assets.length} ("${
          asset.name
        }")`
      );
      console.log(`       Downloading asset (${fileSizeSI(asset.size)})...`);

      const oldAsset = await octokit.rest.repos.getReleaseAsset({
        ...oldRepo,
        asset_id: asset.id,
        headers: {
          Accept: 'application/octet-stream',
        },
      });

      console.log(`       Uploading asset...`);
      await octokit.rest.repos.uploadReleaseAsset({
        ...newRepo,
        release_id: newRelease.data.id,
        name: asset.name,
        headers: {
          'Content-Type': asset.content_type,
        },
        data: oldAsset.data,
      });

      console.log(`       Done`);
    }

    console.log(`    Successfully created Release "${oldRelease.name}"`);
  }
})();
