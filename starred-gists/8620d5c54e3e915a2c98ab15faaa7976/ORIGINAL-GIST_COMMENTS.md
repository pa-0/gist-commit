### Comments from original gist

I'll eventually go through these and extract the useful code to trim away the excess

#### [qiwihui](https://gist.github.com/qiwihui) commented [on Jul 30, 2017](https://gist.github.com/steinwaywhw/a4cd19cda655b8249d908261a62687f8?permalink_comment_id=2162780#gistcomment-2162780) • edited 

```shell
curl -s https://api.github.com/repos/jgm/pandoc/releases/latest \
| grep "browser_download_url.*deb" \
| cut -d '"' -f 4 \
| wget -qi -
```

#### [aaronnguyen](https://gist.github.com/aaronnguyen) commented [on Aug 9, 2017](https://gist.github.com/steinwaywhw/a4cd19cda655b8249d908261a62687f8?permalink_comment_id=2172418#gistcomment-2172418)

Wildcard didn't work on Docker ubuntu:latest  
But this did. just broke out the greps.

```sh
curl -s https://api.github.com/repos/mozilla/geckodriver/releases/latest \
  | grep browser_download_url \
  | grep linux64 \
  | cut -d '"' -f 4 \
  | wget -qi -
```

#### [ozbillwang](https://gist.github.com/ozbillwang) commented [on Feb 28, 2018](https://gist.github.com/steinwaywhw/a4cd19cda655b8249d908261a62687f8?permalink_comment_id=2365980#gistcomment-2365980)

why some repos supports releases, some not?

```sh
 curl -s https://api.github.com/repos/PyCQA/flake8/releases/latest
{
  "message": "Not Found",
  "documentation_url": "https://developer.github.com/v3/repos/releases/#get-the-latest-release"
}
```

#### [rlewkowicz](https://gist.github.com/rlewkowicz) commented [on Mar 1, 2018](https://gist.github.com/steinwaywhw/a4cd19cda655b8249d908261a62687f8?permalink_comment_id=2366781#gistcomment-2366781)

[@ozbillwang](https://github.com/ozbillwang) I've noticed this when a repo is mirrored vs native to GitHub

#### [w0rd-driven](https://gist.github.com/w0rd-driven) commented [on Apr 18, 2018](https://gist.github.com/steinwaywhw/a4cd19cda655b8249d908261a62687f8?permalink_comment_id=2560312#gistcomment-2560312)

In case anyone else stumbles upon this stupidly useful technique, the one thing that varies between projects is the grep line. `browser_download_url.*deb` looks for files ending in .deb. You likely need to tailor just this line for most repositories.

#### [JedMeister](https://gist.github.com/JedMeister) commented [on May 28, 2018](https://gist.github.com/steinwaywhw/a4cd19cda655b8249d908261a62687f8?permalink_comment_id=2602381#gistcomment-2602381)

This looks really cool, but as noted by [@ozbillwang](https://github.com/ozbillwang) and [@rlewkowicz](https://github.com/rlewkowicz) it's not always reliable. It appears that it depends on how the Dev creates their "releases".

From what I can gather it should always be reliable for projects which provide specific binary file formats (e.g. `.deb` as per the OP). But may not be reliable for repos which just provide a source code tarball/zipball (and even if it is now, may not be in the future).

FWIW it seems that the difference is whether or not the dev explicitly creates a "Release" via GH (which is required to include specific binary formats). Every time a repo is tagged, a new source code bundle will automagically show up on the GH "Releases" page. However, these automagic "releases" will not appear via the API, nor via the `https://github.com/:owner/:repo/releases/latest` URL. They will only be visible via the projects Release webpage and/or via the API under `repos/:owner/:repo/tags`. And unfortunately, it can't be assumed that the tags are in chronological order... 😢

#### [dsifford](https://gist.github.com/dsifford) commented [on Jun 28, 2018](https://gist.github.com/steinwaywhw/a4cd19cda655b8249d908261a62687f8?permalink_comment_id=2632806#gistcomment-2632806) • edited 

Shorter PCRE grep: (just get's the version number)

```shell
curl -s https://api.github.com/repos/USER/REPO/releases/latest | grep -oP '"tag_name": "\K(.*)(?=")'
```

#### [blockloop](https://gist.github.com/blockloop) commented [on Oct 5, 2018](https://gist.github.com/steinwaywhw/a4cd19cda655b8249d908261a62687f8?permalink_comment_id=2724872#gistcomment-2724872)

I use `jq`

```sh
curl -sL https://api.github.com/repos/USER/REPO/releases/latest | jq -r '.assets[].browser_download_url'
```

#### [PizzaLovingNerd](https://gist.github.com/PizzaLovingNerd) commented [on Oct 10, 2018](https://gist.github.com/steinwaywhw/a4cd19cda655b8249d908261a62687f8?permalink_comment_id=2729194#gistcomment-2729194)

Thanks

#### [Arezhik](https://gist.github.com/Arezhik) commented [on Oct 12, 2018](https://gist.github.com/steinwaywhw/a4cd19cda655b8249d908261a62687f8?permalink_comment_id=2731054#gistcomment-2731054) • edited 

`curl -s https://api.github.com/repos/USER/REPO/releases/latest | jq -r ".assets[] | select(.name | contains(\"search param for specific download url\")) | .browser_download_url" | wget -i -`

Then pass into wget also to download it.

#### [TaChao](https://gist.github.com/TaChao) commented [on Oct 18, 2018](https://gist.github.com/steinwaywhw/a4cd19cda655b8249d908261a62687f8?permalink_comment_id=2736901#gistcomment-2736901) • edited 

```shell
curl --silent "https://api.github.com/repos/USER/REPO/releases/latest" | # Get latest release from GitHub api
    grep '"tag_name":' |                                                 # Get tag line
    sed -E 's/.*"([^"]+)".*/\1/' |
    xargs -I {} curl -sOL "https://github.com/USER/REPO/archive/"{}'.tar.gz'
```

#### [zwbetz-gh](https://gist.github.com/zwbetz-gh) commented [on Oct 20, 2018](https://gist.github.com/steinwaywhw/a4cd19cda655b8249d908261a62687f8?permalink_comment_id=2738139#gistcomment-2738139) • edited 

Thanks for this [@steinwaywhw](https://github.com/steinwaywhw). I used it to write a script to install the latest release of the Hugo binary.  
See [https://zwbetz.com/script-to-install-latest-hugo-release-on-linux-and-mac/](https://zwbetz.com/script-to-install-latest-hugo-release-on-linux-and-mac/) for the write-up.

```sh
#!/bin/bash

pushd /tmp/

curl -s https://api.github.com/repos/gohugoio/hugo/releases/latest \
| grep "browser_download_url.*hugo_[^extended].*_Linux-64bit\.tar\.gz" \
| cut -d ":" -f 2,3 \
| tr -d \" \
| wget -qi -

tarball="$(find . -name "*Linux-64bit.tar.gz")"
tar -xzf $tarball

chmod +x hugo

mv hugo /usr/local/bin/

popd

location="$(which hugo)"
echo "Hugo binary location: $location"

version="$(hugo version)"
echo "Hugo binary version: $version"
```

#### [Inkimar](https://gist.github.com/Inkimar) commented [on Oct 23, 2018](https://gist.github.com/steinwaywhw/a4cd19cda655b8249d908261a62687f8?permalink_comment_id=2740318#gistcomment-2740318)

Glad to see the activity here.  
I have a question, which more has to do with releases and 'the latest release'  
Checking the mozilla/geckodriver-repo (thanks [@aaronnguyen](https://github.com/aaronnguyen) ) , [https://github.com/mozilla/geckodriver/releases](https://github.com/mozilla/geckodriver/releases) , which makes the following request possible : [https://api.github.com/repos/mozilla/geckodriver/releases/latest](https://api.github.com/repos/mozilla/geckodriver/releases/latest)  
and comparing it to one of my own projects , [https://github.com/Inkimar/cp_dina-collections/releases](https://github.com/Inkimar/cp_dina-collections/releases) , where I cannot request the latest using [https://api.github.com/repos/inkimar/cp_dina-collections/releases/latest](https://api.github.com/repos/inkimar/cp_dina-collections/releases/latest)  
I can see that the the mozilla/geckodriver-repo has the tag 'latest release' on the left hand side in [https://github.com/mozilla/geckodriver/releases](https://github.com/mozilla/geckodriver/releases) where my repos does not have it [https://github.com/Inkimar/cp_dina-collections/releases](https://github.com/Inkimar/cp_dina-collections/releases) .  
I am pushing to my repo using the following 'git push && git push --tags && rm -rf build/temp ' and I get asked a question on the release ( patch, minor or major) ....  
My Q: how can I get the tag 'latest release' so that I can use the same request as to the mozilla/geckodriver ?

-i

#### [dkebler](https://gist.github.com/dkebler)** commented [on Nov 8, 2018](https://gist.github.com/steinwaywhw/a4cd19cda655b8249d908261a62687f8?permalink_comment_id=2754696#gistcomment-2754696) • edited 

[@zwbetz-gh](https://github.com/zwbetz-gh) thx. Set it up so one can run it without preface of sudo and included a check of current version vs installed first and then proceed on new release. One could do this as a daily cron job and one would always be running the latest release (if that was the goal).

Another improvement would be the check the system architecture and install the correct one (not just the amd 64)

Looks like u already post this to hugo discourse [https://discourse.gohugo.io/t/script-to-install-latest-hugo-release-on-macos-and-ubuntu/14774/8](https://discourse.gohugo.io/t/script-to-install-latest-hugo-release-on-macos-and-ubuntu/14774/8) :-)

```sh
#!/bin/bash

CUR_VERSION="$(hugo version | cut -d'v' -f2 | cut -c 3-5)"
NEW_VERSION="$(curl -s https://api.github.com/repos/gohugoio/hugo/releases/latest | grep tag_name | cut -d'.' -f2 | cut -d'"' -f1)"
echo "Current Version: $CUR_VERSION => New Version: $NEW_VERSION"

if [ "$NEW_VERSION" -ne "$CUR_VERSION" ]; then

  echo "Installing version $NEW_VERSION"

  pushd /tmp/

  curl -s https://api.github.com/repos/gohugoio/hugo/releases/latest \
  | grep "browser_download_url.*hugo_[^extended].*_Linux-64bit\.tar\.gz" \
  | cut -d ":" -f 2,3 \
  | tr -d \" \
  | wget -qi -

  tarball="$(find . -name "*Linux-64bit.tar.gz" 2>/dev/null)"
  tar -xzf $tarball

  chmod +x hugo

  sudo mv hugo /usr/local/bin/

  popd

  location="$(which hugo)"
  echo "Hugo binary location: $location"

  version="$(hugo version)"
  echo "New Hugo binary version installed!: $version"

else
  echo Latest version already installed
fi
```

#### [zwbetz-gh](https://gist.github.com/zwbetz-gh) commented [on Nov 8, 2018](https://gist.github.com/steinwaywhw/a4cd19cda655b8249d908261a62687f8?permalink_comment_id=2754733#gistcomment-2754733)

[@dkebler](https://github.com/dkebler) 👍

#### [drmikecrowe](https://gist.github.com/drmikecrowe) commented [on Nov 13, 2018](https://gist.github.com/steinwaywhw/a4cd19cda655b8249d908261a62687f8?permalink_comment_id=2758561#gistcomment-2758561) • edited 

Thanks to [@blockloop](https://github.com/blockloop) for the `jq` hint. Here's what I came up with (checks for binary with `linux-amd64` in the name):

```shell
function get_download_url {
	wget -q -nv -O- https://api.github.com/repos/$1/$2/releases/latest 2>/dev/null |  jq -r '.assets[] | select(.browser_download_url | contains("linux-amd64")) | .browser_download_url'
}
```

Usage: `get_download_url 99designs aws-vault`

Followed with:

```shell
function install_binary {
	URL=$(get_download_url $1 $2)
	mkdir -p ~/bin
	BASE=$(basename $URL)
	wget -q -nv -O $BASE $URL 
	if [ ! -f $BASE ]; then
		echo "Didn't download $URL properly.  Where is $BASE?"
		exit 1	
	fi
	mv $BASE ~/bin
	chmod +x ~/bin/$BASE
}
```

Usage: `install_binary 99designs aws-vault`

#### [evankanderson](https://gist.github.com/evankanderson) commented [on Jan 7, 2019](https://gist.github.com/steinwaywhw/a4cd19cda655b8249d908261a62687f8?permalink_comment_id=2803497#gistcomment-2803497)

Note that "latest release" will only work if the release is not tagged as a "draft" or "prerelease". For repos which are still under development, you might want to fetch `/releases` and then use the most recent one:

```shell
curl -s https://api.github.com/repos/$1/$2/releases | \
  jq ".[0].assets | map(select(.name == \"$3\")) | .[0].browser_download_url"
```

#### [oddlots](https://gist.github.com/oddlots) commented [on Jan 9, 2019](https://gist.github.com/steinwaywhw/a4cd19cda655b8249d908261a62687f8?permalink_comment_id=2804727#gistcomment-2804727) • edited 

Thanks [@TaChao](https://github.com/TaChao)

It's a little beyond the scope of this but I have also added a `| tar -xz --strip-components=1 -C target/dir` in order to facilitate a one liner update of a library.

#### [agustif](https://gist.github.com/agustif) commented [on Feb 9, 2019](https://gist.github.com/steinwaywhw/a4cd19cda655b8249d908261a62687f8?permalink_comment_id=2832656#gistcomment-2832656)

```sh
curl -s [https://api.github.com/repos/user/repo/releases/latest](https://api.github.com/repos/user/repo/releases/latest) |  
grep "browser_download_url.*zip" | cut -d : -f 2,3 | tr -d '"' | wget -qi -
```

#### [ghost](https://gist.github.com/ghost)** commented [on Feb 21, 2019](https://gist.github.com/steinwaywhw/a4cd19cda655b8249d908261a62687f8?permalink_comment_id=2843657#gistcomment-2843657) • edited by ghost 
```sh
curl -s https://api.github.com/repos/user/repo/releases | jq ".[0].assets | .[].browser_download_url" | grep (𝑙𝑠𝑏𝑟𝑒𝑙𝑒𝑎𝑠𝑒−𝑐𝑠)|𝑔𝑟𝑒𝑝([[ $(arch) == x86_64 ]] && echo amd64 || echo i386) | sed 's/"//g'
```
_note:_ trying to find better solution for arch.

#### [josh](https://gist.github.com/josh) commented [on Feb 22, 2019](https://gist.github.com/steinwaywhw/a4cd19cda655b8249d908261a62687f8?permalink_comment_id=2845270#gistcomment-2845270)

Heh, this was bugging me how tricky it was to do as well. I just added a new redirect so `https://github.com/user/repo/releases/latest/download/foo.zip` redirects to the latest tagged asset. Hope it's handy!

#### [derekbekoe](https://gist.github.com/derekbekoe) commented [on Feb 23, 2019](https://gist.github.com/steinwaywhw/a4cd19cda655b8249d908261a62687f8?permalink_comment_id=2845898#gistcomment-2845898)

Thanks [@josh](https://github.com/josh)!

#### [aaronliu0130](https://gist.github.com/aaronliu0130) commented [on Mar 9, 2019](https://gist.github.com/steinwaywhw/a4cd19cda655b8249d908261a62687f8?permalink_comment_id=2858183#gistcomment-2858183)

how do I find a specific link when there are multiple releases?

#### [bgokden](https://gist.github.com/bgokden) commented [on Mar 13, 2019](https://gist.github.com/steinwaywhw/a4cd19cda655b8249d908261a62687f8?permalink_comment_id=2860947#gistcomment-2860947) • edited 

> Heh, this was bugging me how tricky it was to do as well. I just added a new redirect so `https://github.com/user/repo/releases/latest/download/foo.zip` redirects to the latest tagged asset. Hope it's handy!

This works for us. I wrote a small script to install binary locally:

```shell
base=https://github.com/magneticio/forklift/releases/latest/download &&
  curl -L $base/forklift-$(uname -s)-$(uname -m) >/usr/local/bin/forklift &&
  chmod +x /usr/local/bin/forklift
```

#### [ReSearchITEng](https://gist.github.com/ReSearchITEng) commented [on Mar 15, 2019](https://gist.github.com/steinwaywhw/a4cd19cda655b8249d908261a62687f8?permalink_comment_id=2863652#gistcomment-2863652)

For anyone interested how to do that with ansible, see below.

```sh
  vars:
    k8s_ver: "v1.13.1"
  tasks:
    - name: limit k8s_ver to vMajor.Minor
      set_fact:
        k8s_ver_major_minor: "{{k8s_ver | regex_replace('^v([0-9])\\.([0-9]*).*', 'v\\1.\\2') }}"

    - name: get all releases as json file
      get_url:
        url: "https://api.github.com/repos/ReSearchITEng/kubeadm-playbook/releases"
        dest: /tmp/all.releases.json
        force: yes

    - name: parse releases json
      command: cat /tmp/all.releases.json
      register: allreleases

    - name: download the targz
      get_url:
        url: '{{allreleases.stdout_lines[0] | from_json | json_query(query) | join ("") }}'
        dest: /tmp/sourcesofthedesiredrelease.tar.gz
        force: yes
      vars:
        query: "[?name=='{{k8s_ver_major_minor}}'].tarball_url"
```

For getting the tar.gz of the latest release, the above would become more simple.

#### [mweibel](https://gist.github.com/mweibel) commented [on Mar 19, 2019](https://gist.github.com/steinwaywhw/a4cd19cda655b8249d908261a62687f8?permalink_comment_id=2866225#gistcomment-2866225)

I just released [https://gitreleases.dev/](https://gitreleases.dev/) which solves this issue with a simple URL.

#### [rpdelaney](https://gist.github.com/rpdelaney) commented [on Mar 25, 2019](https://gist.github.com/steinwaywhw/a4cd19cda655b8249d908261a62687f8?permalink_comment_id=2871615#gistcomment-2871615)

[@mweibel](https://github.com/mweibel) Very cool, but what if the release asset has an unpredictable name? For instance, have a look at [https://github.com/funtoo/keychain/releases/latest](https://github.com/funtoo/keychain/releases/latest)

#### [coocheenin](https://gist.github.com/coocheenin) commented [on Mar 27, 2019](https://gist.github.com/steinwaywhw/a4cd19cda655b8249d908261a62687f8?permalink_comment_id=2873288#gistcomment-2873288)

> Everytime a repo is tagged, a new source code bundle will automagically show up on the GH "Releases" page. However, these automagic "releases" will not appear via the API

[@JedMeister](https://github.com/JedMeister) I can confirm this. Sad, but true.

#### [mweibel](https://gist.github.com/mweibel) commented [on Mar 28, 2019](https://gist.github.com/steinwaywhw/a4cd19cda655b8249d908261a62687f8?permalink_comment_id=2874009#gistcomment-2874009)

[@rpdelaney](https://github.com/rpdelaney) (sorry, somehow I didn't get a notification for this comment?)

> [@mweibel](https://github.com/mweibel) Very cool, but what if the release asset has an unpredictable name? For instance, have a look at [https://github.com/funtoo/keychain/releases/latest](https://github.com/funtoo/keychain/releases/latest)

There are two possible things here:  
a) Release doesn't contain a release asset but only the automatically generated one by GitHub (tarball, zipball)  
b) Release contains a release asset which contains the version in the filename again (e.g. in the linked example a possibility would be `keychain_2.8.5.zip`)

Both are currently not well supported by gitreleases, but I plan to support them: [mweibel/gitreleases#2](https://github.com/mweibel/gitreleases/issues/2) and [mweibel/gitreleases#3](https://github.com/mweibel/gitreleases/issues/3).  
Feel free to comment on those issues or open new issues 👍

#### [jhuckaby](https://gist.github.com/jhuckaby) commented [on Apr 17, 2019](https://gist.github.com/steinwaywhw/a4cd19cda655b8249d908261a62687f8?permalink_comment_id=2891803#gistcomment-2891803)

For those that may have missed it above, [@josh](https://github.com/josh) from GitHub released an official fix for this:

[https://gist.github.com/steinwaywhw/a4cd19cda655b8249d908261a62687f8#gistcomment-2845270](https://gist.github.com/steinwaywhw/a4cd19cda655b8249d908261a62687f8#gistcomment-2845270)

> Heh, this was bugging me how tricky it was to do as well. I just added a new redirect so `https://github.com/USER/REPO/releases/latest/download/FILENAME.zip` redirects to the latest tagged asset. Hope it's handy!

This works perfectly for me. Just replace `USER`, `REPO` and `FILENAME` with your own stuff.

#### [loganmarchione](https://gist.github.com/loganmarchione) commented [on Apr 17, 2019](https://gist.github.com/steinwaywhw/a4cd19cda655b8249d908261a62687f8?permalink_comment_id=2891825#gistcomment-2891825)

[@josh](https://github.com/josh) thank you! This works perfectly!

#### [hartmannr76](https://gist.github.com/hartmannr76) commented [on Apr 18, 2019](https://gist.github.com/steinwaywhw/a4cd19cda655b8249d908261a62687f8?permalink_comment_id=2892510#gistcomment-2892510)

[@josh](https://github.com/josh) Doesn't seem to work if the repo is private. I've tried providing `Basic` and `Token` as an auth header and keep getting a 404. Would love to use this though!!

#### [kurtroberts](https://gist.github.com/kurtroberts) commented [on Apr 30, 2019](https://gist.github.com/steinwaywhw/a4cd19cda655b8249d908261a62687f8?permalink_comment_id=2902097#gistcomment-2902097)

Here's a version that uses python to parse the JSON, in case you don't have jq available (like working with tools installed by default on macOS):

```sh
curl -s https://api.github.com/repos/sheagcraig/yo/releases/latest |  python -c 'import json,sys;obj=json.load(sys.stdin);print obj["assets"][0]["browser_download_url"];'
```

#### [joaovitor](https://gist.github.com/joaovitor) commented [on May 14, 2019](https://gist.github.com/steinwaywhw/a4cd19cda655b8249d908261a62687f8?permalink_comment_id=2917097#gistcomment-2917097)

```shell
curl -sL https://github.com/kubernetes-sigs/aws-iam-authenticator/releases/latest | \
grep "releases/download.*linux_amd64" | \
cut -d \" -f 2 | \
tr -d \" | \
sed -e 's#.*download/v\(.*\)/aws-iam-authenticator.*#\1#g'
```

#### [dvershinin](https://gist.github.com/dvershinin) commented [on May 16, 2019](https://gist.github.com/steinwaywhw/a4cd19cda655b8249d908261a62687f8?permalink_comment_id=2919554#gistcomment-2919554)

This is all too weak you guys. As mentioned by many - GitHub API won't return actual Releases in many cases when releases were not filed formally. Those releases that don't appear are not less releases than the others :)

Thus I have created [lastversion](https://github.com/dvershinin/lastversion) CLI tool.

How about this one liner:

```sh
lastversion user/repo 
```

Will give you the version of latest release even if it's not present in the API response! :)

#### [Contextualist](https://gist.github.com/Contextualist) commented [on May 23, 2019](https://gist.github.com/steinwaywhw/a4cd19cda655b8249d908261a62687f8?permalink_comment_id=2925024#gistcomment-2925024) • edited 

For anyone who don't bother installing extra dependencies or crafting multi-line commands, try my handy service [get latest release](https://github.com/Contextualist/glare):

```sh
curl -fLO https://glare.now.sh/<user>/<repo>/<asset_regex>
```

e.g.

```sh
curl -fLO https://glare.now.sh/jgm/pandoc/deb
```

Why?

-   Succinct and maintainable
-   Match asset names containing version numbers with regex

#### [vojtech2](https://gist.github.com/vojtech2)** commented [on May 27, 2019](https://gist.github.com/steinwaywhw/a4cd19cda655b8249d908261a62687f8?permalink_comment_id=2928051#gistcomment-2928051)

Possibly also an option:

```sh
git ls-remote --tags https://github.com/jgm/pandoc.git | sed -nE 's#.*refs/tags/(v?[0-9]+(\.[0-9]+)*)$#\1#p' | sort -Vr | head -n 1
```

See [https://stackoverflow.com/questions/10649814/get-last-git-tag-from-a-remote-repo-without-cloning](https://stackoverflow.com/questions/10649814/get-last-git-tag-from-a-remote-repo-without-cloning)

#### [Puvipavan](https://gist.github.com/Puvipavan)** commented [on Jul 10, 2019](https://gist.github.com/steinwaywhw/a4cd19cda655b8249d908261a62687f8?permalink_comment_id=2966300#gistcomment-2966300)

```sh
curl -s https://api.github.com/repos/cloud-custodian/cloud-custodian/releases/latest | sed -n 's/.*tag_name":\s"\(.*\)".*/\1/p' | head -1
```


#### [steinwaywhw](https://gist.github.com/steinwaywhw)** commented [on Jul 10, 2019](https://gist.github.com/steinwaywhw/a4cd19cda655b8249d908261a62687f8?permalink_comment_id=2966665#gistcomment-2966665)

Wow, thank you so much for all the comments/tips/improvements. I didn't even notice until today. You're awesome ❤️


#### [evandrix](https://gist.github.com/evandrix)** commented [on Jul 13, 2019](https://gist.github.com/steinwaywhw/a4cd19cda655b8249d908261a62687f8?permalink_comment_id=2969666#gistcomment-2969666) • edited 

```sh
wget -c $(curl -ksL "https://api.github.com/repos/x64dbg/x64dbg/releases/latest" | jq -r ".assets[0].browser_download_url")
```


#### [fakuivan](https://gist.github.com/fakuivan)** commented [on Aug 2, 2019](https://gist.github.com/steinwaywhw/a4cd19cda655b8249d908261a62687f8?permalink_comment_id=2987801#gistcomment-2987801)

Expanding on [@evandrix](https://github.com/evandrix)'s answer

```shell
curl -s https://api.github.com/repos/pyrovski/wrtbwmon/releases | \
  jq -r '[[.[] |
    select(.draft != true) |
    select(.prerelease != true)][0] |
    .assets |
    .[] |
    select(.name | endswith(".ipk")) |
    .browser_download_url][0]'
```

#### [xeruf](https://gist.github.com/xeruf)** commented [on Aug 4, 2019](https://gist.github.com/steinwaywhw/a4cd19cda655b8249d908261a62687f8?permalink_comment_id=2989645#gistcomment-2989645)

Much simpler: 
```sh
curl -s https://api.github.com/repos/user/repo/releases/latest | grep -o "http.*deb"
```

Now in my `.zshrc` (works just as well with bash):

```shell
# Gets the download url for the latest release of a package provided via GitHub Releases
# Usage: ghrelease USER REPO [PATTERN]
ghrelease() {
	curl -s "https://api.github.com/repos/$1/$2/releases/latest" | grep -o "http.*${3:-deb}"
}
```

Perfect pair with:

```shell
# Installs a local or remote(http/https) deb package and removes it after installation
installdeb() {
	set -e
	loc="/tmp/install.deb"
	case $1 in 
	http*) sudo wget -O "$loc" $1;;
	*) loc="$1"
	esac
	sudo dpkg -i "$loc"
	sudo apt -f install
	sudo rm -f "$loc"
}
```

Example use: 

```sh
installdeb $(ghrelease sharkdp bat "bat_.*_amd64.deb")
```
Perfect 👌

#### [koddsson](https://gist.github.com/koddsson) commented [on Aug 28, 2019](https://gist.github.com/steinwaywhw/a4cd19cda655b8249d908261a62687f8?permalink_comment_id=3010705#gistcomment-3010705)

Hey hey!

This feature has been added to github, see [https://help.github.com/en/articles/linking-to-releases#linking-to-the-latest-release](https://help.github.com/en/articles/linking-to-releases#linking-to-the-latest-release)

> If you'd like to link directly to a download of your latest release asset you can link to /owner/name/releases/latest/download/asset-name.zip.

Example: `curl -L https://github.com/primer/octicons/releases/latest/download/svg.zip`

#### [archf](https://gist.github.com/archf) commented [on Oct 8, 2019](https://gist.github.com/steinwaywhw/a4cd19cda655b8249d908261a62687f8?permalink_comment_id=3049030#gistcomment-3049030)

My attempt to solve this: [ghi](https://github.com/archf/ghi).

It aims to be the reverse operation of [ghr](https://github.com/tcnksm/ghr) CLI tool. More improvements can be done of course. Let me know what you think!

#### [jaekyeom](https://gist.github.com/jaekyeom) commented [on Oct 12, 2019](https://gist.github.com/steinwaywhw/a4cd19cda655b8249d908261a62687f8?permalink_comment_id=3053382#gistcomment-3053382)

> Hey hey!
> 
> This feature has been added to github, see [https://help.github.com/en/articles/linking-to-releases#linking-to-the-latest-release](https://help.github.com/en/articles/linking-to-releases#linking-to-the-latest-release)
> 
> > If you'd like to link directly to a download of your latest release asset you can link to /owner/name/releases/latest/download/asset-name.zip.
> 
> Example: `curl -L https://github.com/primer/octicons/releases/latest/download/svg.zip`

That's great, but can we get the link to the tarball/zipball of the latest release, too?

#### [yngvark](https://gist.github.com/yngvark) commented [on Nov 8, 2019](https://gist.github.com/steinwaywhw/a4cd19cda655b8249d908261a62687f8?permalink_comment_id=3077928#gistcomment-3077928) • edited 

```sh
VERSION=$(curl -s https://github.com/Versent/saml2aws/releases/latest/download 2>&1 | grep -Po [0-9]+\.[0-9]+\.[0-9]+)
echo version: $VERSION
wget https://github.com/Versent/saml2aws/releases/latest/download/saml2aws_$VERSION\_linux_amd64.tar.gz
```

#### [oshliaer](https://gist.github.com/oshliaer) commented [on Nov 22, 2019](https://gist.github.com/steinwaywhw/a4cd19cda655b8249d908261a62687f8?permalink_comment_id=3090118#gistcomment-3090118)

##### bazelbuild/bazel `.sh` for `linux`


```shell
curl -s https://api.github.com/repos/bazelbuild/bazel/releases/latest \
| grep "browser_download_url.*linux.*sh\"" \                               
| cut -d : -f 2,3 \                 
| tr -d \" \       
| wget -qi - 
``` 

#### [ghost](https://gist.github.com/ghost) commented [on Mar 1, 2020](https://gist.github.com/steinwaywhw/a4cd19cda655b8249d908261a62687f8?permalink_comment_id=3195347#gistcomment-3195347)

For those who installed fzf, I use this alias every time. It's quick and clear.

```sh
function dlgr() {
	URL=`curl -s "${@}" | grep "browser_download_url" | cut -d '"' -f 4 | fzf`
	curl -O ${URL}
}
```

It's same as this one liner.

```sh
curl -s https://api.github.com/repos/bazelbuild/bazel/releases/latest \
	| grep "browser_download_url" \       
	| cut -d '"' -f 4 \                 
	| fzf \       
	| curl -O
```

#### [gmolveau](https://gist.github.com/gmolveau) commented [on Mar 4, 2020](https://gist.github.com/steinwaywhw/a4cd19cda655b8249d908261a62687f8?permalink_comment_id=3199552#gistcomment-3199552) • edited 

To download the latest `.tar.gz` release using only `curl` :

```sh
curl -s https://api.github.com/repos/<user>/<repo>/releases/latest \
| grep 'browser_download_url.*tar.gz"' \
| cut -d : -f 2,3 \
| tr -d \" \
| xargs -n 1 curl -O -sSL
```

and if you want to download + extract in the current folder :

```sh
curl -s https://api.github.com/repos/<user>/<repo>/releases/latest \
| grep 'browser_download_url.*tar.gz"' \
| cut -d : -f 2,3 \
| tr -d \" \
| xargs -n 1 curl -sSL \
| tar -xz --strip-components=1
```

#### [miguelslemos](https://gist.github.com/miguelslemos) commented [on Mar 9, 2020](https://gist.github.com/steinwaywhw/a4cd19cda655b8249d908261a62687f8?permalink_comment_id=3205975#gistcomment-3205975) • edited 

```sh
curl -s "https://api.github.com/repos/<user>/<repo>/releases/latest?access_token=$GITHUB_TOKEN" \
    | jq '.assets[] | select(.name == "mob-macos.tar.gz") | .url' \
    | xargs -I {} curl -sSL -H 'Accept: application/octet-stream' "{}?access_token=$GITHUB_TOKEN" \
    | tar -xzf -
```

#### [x5engine](https://gist.github.com/x5engine) commented [on Apr 5, 2020](https://gist.github.com/steinwaywhw/a4cd19cda655b8249d908261a62687f8?permalink_comment_id=3241526#gistcomment-3241526)

just send the release to ipfs and download it instead of adding the accesstoken..

#### [skillfr](https://gist.github.com/skillfr) commented [on Apr 19, 2020](https://gist.github.com/steinwaywhw/a4cd19cda655b8249d908261a62687f8?permalink_comment_id=3260937#gistcomment-3260937) • edited 

In case there are multiple files

```shell
v=$(wget -q https://api.github.com/repos/<user>/<repo>/releases/latest -O - | grep -E tag_name | awk -F '[""]' '{print $4}') wget https://github.com/<user>/<repo>/releases/download/$v/file.linuxAMDx64.tar.gz
```

or

```shell
wget https://github.com/<user>/<repo>/releases/download/$v/file.linuxARMx32.tar.gz
```

#### [aslafy-z](https://gist.github.com/aslafy-z) commented [on Apr 23, 2020](https://gist.github.com/steinwaywhw/a4cd19cda655b8249d908261a62687f8?permalink_comment_id=3266931#gistcomment-3266931) • edited 

My 2 cents

```sh
wget -q -O - --header "Authorization: token $GITHUB_TOKEN" "https://api.github.com/repos/<user>/<repo>/releases/latest" \
    | python -c 'import sys, json; print(json.load(sys.stdin)["tarball_url"])' \
    | xargs -I {} wget -q -O - --header "Authorization: token $GITHUB_TOKEN"  "{}" \
    | tar -xz --strip-components=1
```

Comes with a bonus:

```sh
sudo tar --strip=1 --transform "s/original_folder/new_name_folder/" --wildcards -C /usr/local/share/ca-certificates -xzf - "*/original_folder"
# outputs to /usr/local/share/ca-certificates/new_name_folder
```

#### [chris-gillatt](https://gist.github.com/chris-gillatt) commented [on Apr 30, 2020](https://gist.github.com/steinwaywhw/a4cd19cda655b8249d908261a62687f8?permalink_comment_id=3276556#gistcomment-3276556) • edited 

For anyone else who lands on this thread wanting to solve this problem for either this app or others, I've resorted to using a one/two-liner consisting of a simple grep and a not-so-simple (but robust) perl expression to extract semvers. If you really wanted to expand this, you could use positional parameters for the asset type.

```shell
#!/bin/bash -e
LATEST=$(curl -sL --fail https://api.github.com/repos/jgm/pandoc/releases/latest | grep "tag_name" | perl -pe 'if(($_)=/([0-9]+([.][0-9]+)+)/){$_.="\n"}') ; curl -vsL "https://github.com/jgm/pandoc/releases/download/$LATEST/pandoc-$LATEST-macOS.zip" -O
```

#### [Evidlo](https://gist.github.com/Evidlo) commented [on May 1, 2020](https://gist.github.com/steinwaywhw/a4cd19cda655b8249d908261a62687f8?permalink_comment_id=3279451#gistcomment-3279451) • edited 

GitHub has a direct link to the latest release:

```sh
https://github.com/[user]/[repo]/releases/latest/download/[asset-name.zip]
```

[https://help.github.com/en/github/administering-a-repository/linking-to-releases](https://help.github.com/en/github/administering-a-repository/linking-to-releases)

#### [chris-gillatt](https://gist.github.com/chris-gillatt) commented [on May 4, 2020](https://gist.github.com/steinwaywhw/a4cd19cda655b8249d908261a62687f8?permalink_comment_id=3288182#gistcomment-3288182)

[@Evidlo](https://github.com/Evidlo) - Did you actually try following that? It only works if you do it manually. This entire thread is about automating the problem.

#### [Evidlo](https://gist.github.com/Evidlo) commented [on May 6, 2020](https://gist.github.com/steinwaywhw/a4cd19cda655b8249d908261a62687f8?permalink_comment_id=3293170#gistcomment-3293170) • edited 

[@chris-gill](https://github.com/chris-gill)

Yes, it works for me. E.g. [https://github.com/evidlo/remarkable_news/releases/latest/download/release.zip](https://github.com/evidlo/remarkable_news/releases/latest/download/release.zip)

I'm not sure what you mean by 'do it manually'.

Of course it doesn't work if the asset name changes between releases, so I guess it's not useful for Pandoc.

#### [chris-gillatt](https://gist.github.com/chris-gillatt) commented [on May 7, 2020](https://gist.github.com/steinwaywhw/a4cd19cda655b8249d908261a62687f8?permalink_comment_id=3293945#gistcomment-3293945)

[@Evidlo](https://github.com/Evidlo) Ahh - that's the thing then - with many project releases including some of my own, the assets are named with the version in the filename string, meaning that the name changes with each release like can be seen here:  
[https://github.com/jgm/pandoc/releases/](https://github.com/jgm/pandoc/releases/)

The automation problem arises there, meaning we need 1/2 lines of bash to get $latest of those files.  
What I mean by manually, is that you can still do this by following the steps on the page you provided, but only manually through the GUI and clicking the link to the file to download it.

#### [codedge](https://gist.github.com/codedge) commented [on May 26, 2020](https://gist.github.com/steinwaywhw/a4cd19cda655b8249d908261a62687f8?permalink_comment_id=3318771#gistcomment-3318771)

This one works for me:

```sh
curl -LJO https://github.com/[user]/[repo]/tarball/[tag]
```

#### [MaluNoPeleke](https://gist.github.com/MaluNoPeleke) commented [on Jun 5, 2020](https://gist.github.com/steinwaywhw/a4cd19cda655b8249d908261a62687f8?permalink_comment_id=3330913#gistcomment-3330913) • edited 

How to handle cases where the latest release is for an older version (e.g. v2.x maintenance update) but you always want to get latest release of the current version (highest version number).  
One example is this repository (2.38.2 has been released lately but 3.18.1 is the latest): [https://github.com/TryGhost/Ghost/releases](https://github.com/TryGhost/Ghost/releases)

#### [Contextualist](https://gist.github.com/Contextualist) commented [on Jun 5, 2020](https://gist.github.com/steinwaywhw/a4cd19cda655b8249d908261a62687f8?permalink_comment_id=3331168#gistcomment-3331168) • edited 

[@MaluNoPeleke](https://github.com/MaluNoPeleke) Shamelessly promoting my own project [https://github.com/Contextualist/glare](https://github.com/Contextualist/glare) . You can use `semver` matching for releases.

```shell
# To get the latest 3.x:
curl -L https://glare.now.sh/TryGhost/Ghost@3.x/Ghost -o ghost.zip
# To get the latest 2.x:
curl -L https://glare.now.sh/TryGhost/Ghost@2.x/Ghost -o ghost.zip
# Highest version, whatever:
curl -L https://glare.now.sh/TryGhost/Ghost@x/Ghost -o ghost.zip
```

#### [eggbean](https://gist.github.com/eggbean) commented [on Jun 5, 2020](https://gist.github.com/steinwaywhw/a4cd19cda655b8249d908261a62687f8?permalink_comment_id=3331275#gistcomment-3331275) • edited 

> For those who installed `fzf`, I use this alias every time. It's quick and clear.
> 
> ```shell
> function dlgr() {
> 	URL=`curl -s "${@}" | grep "browser_download_url" | cut -d '"' -f 4 | fzf`
> 	curl -O ${URL}
> }
> ```

I like that, but it doesn't download the correct file when I try. It seems you need to add the -L switch, due to redirects. This is what I am using, only requiring USER/REPO.

```sh
dlgr ()
{
    URL=$(curl -s https://api.github.com/repos/"${@}"/releases/latest   | jq -r '.assets[].browser_download_url' | fzf);
    curl -LO ${URL}
}
```

#### [MaluNoPeleke](https://gist.github.com/MaluNoPeleke) commented [on Jun 5, 2020](https://gist.github.com/steinwaywhw/a4cd19cda655b8249d908261a62687f8?permalink_comment_id=3331369#gistcomment-3331369)

[@Contextualist](https://github.com/Contextualist) I would rather use direct features of shell and GitHub instead of relying on another service and if possible have also a generic solution instead of a hard-coded version number but thanks for your quick support.

#### [iofirag](https://gist.github.com/iofirag) commented [on Aug 31, 2020](https://gist.github.com/steinwaywhw/a4cd19cda655b8249d908261a62687f8?permalink_comment_id=3437162#gistcomment-3437162)

```shell
curl -s https://api.github.com/repos/<user-name>/<repo-name>/releases/latest \
    | grep browser_download_url \
    | cut -d '"' -f 4 \
    | wget -qi-
    tarfilename="$(find . -name "*.tar.gz")"
    tar -xzf $tarfilename
    sudo rm $tarfilename
```

#### [jwillikers](https://gist.github.com/jwillikers) commented [on Sep 17, 2020](https://gist.github.com/steinwaywhw/a4cd19cda655b8249d908261a62687f8?permalink_comment_id=3457870#gistcomment-3457870) • edited 

Long live awk! 😉

```shell
$ curl -s https://api.github.com/repos/<user>/<repo>/releases/latest \
    | awk -F': '  '/browser_download_url/ && /\.<extension>/ {gsub(/"/, "", $(NF)); system("curl -LO " $(NF))}'
```

Just substitute in the user or organization name, the project's name, and the desired file extension for the `<user>`, `<repo>`, and `<extension>` fields respectively.  
It's also easy enough to modify the match pattern for the file extension to make it more specific if need be.

#### [unfor19](https://gist.github.com/unfor19) commented [on Sep 19, 2020](https://gist.github.com/steinwaywhw/a4cd19cda655b8249d908261a62687f8?permalink_comment_id=3459923#gistcomment-3459923) • edited 

No dependencies are needed, plain simple Bash and curl

1.  Get the latest version - Assuming the versioning format is - "v0.0.1"  
    If the version format is different from "v0.0.1" then change the `cut -d'v' -f2` section

```shell
ORG_NAME=hashicorp
REPO_NAME=terraform
LATEST_VERSION=$(curl -s https://api.github.com/repos/${ORG_NAME}/${REPO_NAME}/releases/latest | grep "tag_name" | cut -d'v' -f2 | cut -d'"' -f1)

# Output: 0.13.3
```

2.  Download the latest version

```shell
curl -L -o ${REPO_NAME}.tar.gz https://github.com/${ORG_NAME}/${REPO_NAME}/archive/v${LATEST_VERSION}.tar.gz
```

It's not a oneliner, but it's how I use it in a Dockerfile, I hope it helps

#### [maggie44](https://gist.github.com/maggie44) commented [on Sep 27, 2020](https://gist.github.com/steinwaywhw/a4cd19cda655b8249d908261a62687f8?permalink_comment_id=3468950#gistcomment-3468950) • edited 

So many ways to skin a cat.

Retrieving source files:

A shell script, incorporating authentication in order to access private repositories and use tag-name based retrieval to fetch a .tar from the latest release for when browser_download_url isn't available (browser_download_url won't be in the api output if only the standard tar and zip archives are available in your release).

Ensure jq is installed on the system running the script:

```sh
#!/usr/bin/env bash
USER_NAME=your-user-name
REPO_NAME=your-repo-name
TOKEN=your-token # To generate a token see: https://docs.github.com/en/enterprise/2.15/user/articles/creating-a-personal-access-token-for-the-command-line

curl -H "Authorization: token ${TOKEN}" https://api.github.com/repos/${USER_NAME}/${REPO_NAME}/releases/latest | jq -r .tag_name |
xargs -I {} curl -H "Authorization: token ${TOKEN}" -sSL https://github.com/${USER_NAME}/${REPO_NAME}/archive/{}.tar.gz |
tar -xzf - --strip-components=1
```

Retrieve binaries:

A shell script to fetch the latest release when binary files are available, in a private repository.

Ensure jq is installed.

Script may need modification if there is more than one binary file as at the moment it will only fetch the first.

```sh
#!/usr/bin/env bash

USER_NAME=your-user-name
REPO_NAME=your-repo-name
TOKEN=your-token # To generate a token see: https://docs.github.com/en/enterprise/2.15/user/articles/creating-a-personal-access-token-for-the-command-line

ASSET_ID=$(curl -H "Authorization: token ${TOKEN}" https://api.github.com/repos/${USER_NAME}/${REPO_NAME}/releases/latest | jq .assets[0].id); \
curl -H "Authorization: token ${TOKEN}" https://api.github.com/repos/${USER_NAME}/${REPO_NAME}/releases/assets/${ASSET_ID} -LJOH 'Accept: application/octet-stream'
```

#### [sebma](https://gist.github.com/sebma)** commented [on Oct 2, 2020](https://gist.github.com/steinwaywhw/a4cd19cda655b8249d908261a62687f8?permalink_comment_id=3475272#gistcomment-3475272)

[@Ryuta69](https://github.com/Ryuta69) Hi, is fzf the [command-line fuzzy finder](https://github.com/junegunn/fzf) ?

#### [ghost](https://gist.github.com/ghost) commented [on Oct 2, 2020](https://gist.github.com/steinwaywhw/a4cd19cda655b8249d908261a62687f8?permalink_comment_id=3475353#gistcomment-3475353)

[@sebma](https://github.com/sebma)  
yes

#### [hongkongkiwi](https://gist.github.com/hongkongkiwi) commented [on Oct 19, 2020](https://gist.github.com/steinwaywhw/a4cd19cda655b8249d908261a62687f8?permalink_comment_id=3494496#gistcomment-3494496) • edited 

I needed something one liner with no external tools but also cross platform this works:  
```shell
VERSION=$(curl -s "https://github.com/cloudposse/tfmask/releases/latest/download" 2>&1 | sed "s/^.*download\/\([^\"]*\).*/\1/")
```

For those using this in a docker to download files, here's a nice snippet which can handle either setting the version manually via build argument or if blank will auto find the latest version:

```sh
ARG TFMASK_VERSION=
ARG PLATFORM_ARCH=amd64

RUN if [ -z $TFMASK_VERSION ]; then echo "Finding latest TFMask Version..."; TFMASK_VERSION=$(curl -s "https://github.com/cloudposse/tfmask/releases/latest/download" 2>&1 | sed "s/^.*download\/\([^\"]*\).*/\1/"); else echo "TFMask version passed in build argument v${TFMASK_VERSION}"; fi && \
    echo "Downloading TFMask v${TFMASK_VERSION}..." && \
    curl -sLo "/usr/bin/tfmask" "https://github.com/cloudposse/tfmask/releases/download/${TFMASK_VERSION}/tfmask_linux_${PLATFORM_ARCH}"
```

#### [mando7](https://gist.github.com/mando7) commented [on Nov 10, 2020](https://gist.github.com/steinwaywhw/a4cd19cda655b8249d908261a62687f8?permalink_comment_id=3522887#gistcomment-3522887) • edited 

My short one line for latest DBeaver-ce.  
Shorten url [https://api.github.com/repos/dbeaver/dbeaver/releases/latest](https://api.github.com/repos/dbeaver/dbeaver/releases/latest) whith [https://git.io](https://git.io/)  
`curl -Ls` follow a location silently  
`grep -wo` print the exactly  
`wget -qi` download silently

which gives:

`curl -Ls https://git.io/Jkk0N | grep -wo "https.*amd64.deb" | wget -qi -`

#### [pascalandy](https://gist.github.com/pascalandy) commented [on Dec 14, 2020](https://gist.github.com/steinwaywhw/a4cd19cda655b8249d908261a62687f8?permalink_comment_id=3561411#gistcomment-3561411) • edited 

##### script

```sh
_org_name="firepress-org"
_project_name="ghostfire"
_latest_version_is=$(curl -s https://api.github.com/repos/${_org_name}/${_project_name}/releases/latest | grep -oP '"tag_name": "\K(.*)(?=")')
echo ${_latest_version_is}
```

##### output

```sh
3.40.1
```

#### [ghost](https://gist.github.com/ghost)** commented [on Dec 14, 2020](https://gist.github.com/steinwaywhw/a4cd19cda655b8249d908261a62687f8?permalink_comment_id=3561431#gistcomment-3561431)

I changed script a bit from a year ago.

```shell
dlgr() {
    read repo"?type https://api.github.com/repos/{author}/{repo}/releases/latest : ";
    URL=`curl -s "${repo}" | grep "browser_download_url" | cut -d '"' -f 4 | fzf`
    curl -sOL ${URL}
}
```

[![ix2m5us3t6p72fvorbiiv90q4soh](https://user-images.githubusercontent.com/41639488/102137693-90cc6000-3e9e-11eb-9a99-eb5a5afc060b.png)](https://user-images.githubusercontent.com/41639488/102137693-90cc6000-3e9e-11eb-9a99-eb5a5afc060b.png)

If you cursor the target and enter, it downloads.

#### [zero88](https://gist.github.com/zero88)** commented [on Jan 4, 2021](https://gist.github.com/steinwaywhw/a4cd19cda655b8249d908261a62687f8?permalink_comment_id=3581432#gistcomment-3581432)

If anyone interest, give a try: [https://github.com/zero88/gh-release-downloader](https://github.com/zero88/gh-release-downloader)

#### [oshliaer](https://gist.github.com/oshliaer)** commented [on Jan 4, 2021](https://gist.github.com/steinwaywhw/a4cd19cda655b8249d908261a62687f8?permalink_comment_id=3581670#gistcomment-3581670)

> If anyone interest, give a try: [https://github.com/zero88/gh-release-downloader](https://github.com/zero88/gh-release-downloader)

It seems you missed an one line ghrd:latest download cmd 😼

#### [crazy-matt](https://gist.github.com/crazy-matt)** commented [on Feb 18, 2021](https://gist.github.com/steinwaywhw/a4cd19cda655b8249d908261a62687f8?permalink_comment_id=3636642#gistcomment-3636642) • edited 

> This looks really cool, but as noted by [@ozbillwang](https://github.com/ozbillwang) and [@rlewkowicz](https://github.com/rlewkowicz) it's not always reliable. It appears that it depends on how the Dev creates their "releases".
> 
> From what I can gather it should always be reliable for projects which provide specific binary file formats (e.g. `.deb` as per the OP). But may not be reliable for repos which just provide a source code tarball/zipball (and even if it is now, may not be in the future).
> 
> FWIW it seems that the difference is whether or not the dev explicitly creates a "Release" via GH (which is required to include specific binary formats). Everytime a repo is tagged, a new source code bundle will automagically show up on the GH "Releases" page. However, these automagic "releases" will not appear via the API, nor via the `https://github.com/:owner/:repo/releases/latest` URL. They will only be visible via the projects Release webpage and/or via the API under `repos/:owner/:repo/tags`. And unfortunately, it can't be assumed that the tags are in chronological order... 😢

Solving this problem:

```sh
_latest_version="$(curl --silent "https://api.github.com/repos/${USER}/${REPO}/releases/latest" | grep "tag_name" | cut -d '"' -f4)"
if [[ -z "${_version}" ]]; then
  local _latest_version="$(curl --silent "https://api.github.com/repos/${USER}/${REPO}/tags" | grep "name" | grep -v "rc" | cut -d '"' -f4 | sort -rV | head -n 1)"
                                                    # not reliable but trying to exclude the release candidate tags --^^
fi
```

#### [crazy-matt](https://gist.github.com/crazy-matt)** commented [on Feb 18, 2021](https://gist.github.com/steinwaywhw/a4cd19cda655b8249d908261a62687f8?permalink_comment_id=3636645#gistcomment-3636645)

> I changed script a bit from a year ago.
> 
> ```shell
> dlgr() {
>     read repo"?type https://api.github.com/repos/{author}/{repo}/releases/latest : ";
>     URL=`curl -s "${repo}" | grep "browser_download_url" | cut -d '"' -f 4 | fzf`
>     curl -sOL ${URL}
> }
> ```
> 
> If you cursor the target and enter, it downloads.

Sweeet, thanks for that one

#### [philthynz](https://gist.github.com/philthynz)** commented [on Mar 2, 2021](https://gist.github.com/steinwaywhw/a4cd19cda655b8249d908261a62687f8?permalink_comment_id=3651696#gistcomment-3651696)

Here's what I did to get the latest azure pipeline agent:

```sh
curl -s https://api.github.com/repos/microsoft/azure-pipelines-agent/releases/latest | grep -hnr "https://vstsagentpackage.azureedge.net/agent/2.182.1/pipelines-agent-linux-x64-" | cut -d '"' -f 4 | xargs wget -qO pipeline-agent.tar.gz
```

#### [graphik55](https://gist.github.com/graphik55)** commented [on Mar 17, 2021](https://gist.github.com/steinwaywhw/a4cd19cda655b8249d908261a62687f8?permalink_comment_id=3668287#gistcomment-3668287)

If someone needs a PowerShell only version (example for Microsofts vsts agent):

```sh
$githubLatestReleases = "https://api.github.com/repos/microsoft/azure-pipelines-agent/releases/latest"   
$githubLatestReleasesJson = ((Invoke-WebRequest $gitHubLatestReleases) | ConvertFrom-Json).assets.browser_download_url  
$Uri = (((Invoke-WebRequest $githubLatestReleasesJson | ConvertFrom-Json).downloadUrl) | Select-String "vsts-agent-win-x64").ToString()  
```  

#### [MostHated](https://gist.github.com/MostHated)** commented [on Apr 8, 2021](https://gist.github.com/steinwaywhw/a4cd19cda655b8249d908261a62687f8?permalink_comment_id=3698998#gistcomment-3698998) • edited 

> If someone needs a PowerShell only version (example for Microsofts vsts agent):

Exactly what I was hoping to find. 👍I made a slight adjustment to it for my needs.

```powershell
$githubLatestReleases = 'https://api.github.com/repos/microsoft/winget-cli/releases/latest'   
$githubLatestRelease = (((Invoke-WebRequest $gitHubLatestReleases) | ConvertFrom-Json).assets.browser_download_url | select-string -Pattern 'appxbundle').Line
Invoke-WebRequest $githubLatestRelease -OutFile 'Microsoft.DesktopAppInstaller.appxbundle'
```

#### [alerque](https://gist.github.com/alerque)** commented [on Apr 14, 2021](https://gist.github.com/steinwaywhw/a4cd19cda655b8249d908261a62687f8?permalink_comment_id=3705619#gistcomment-3705619) • edited 

The `cut`/`tr` shenanigans in the original post dodging the colon in the URL drives me crazy. This snippet has propogated everywhere, very few people that copy / paste it know how it works, and it leaves so much room for improvement. [@dsifford](https://github.com/dsifford) was on the [same track](https://gist.github.com/steinwaywhw/a4cd19cda655b8249d908261a62687f8#gistcomment-2632806) but stopped short of passing the result to the final download. (**Edit** At first pass I missed [@mando7](https://github.com/mando7)'s [similar solution](https://gist.github.com/steinwaywhw/a4cd19cda655b8249d908261a62687f8#gistcomment-3522887), the extra `grep -w` flag is a nice touch but not required.)

Lets start with swapping `grep | cut | tr` for [`grep -o`](https://explainshell.com/explain?cmd=grep%20-o). If you're already searching for a string, why not just print the bit that matches your search instead of searching for it with context then stripping away the context? No good reason. Since the ".deb" from the original post happens to be ambiguous for this project now I'm including a match.

Also, why use two tools `curl` then `wget` when `curl` is arguably more capable than the latter for both jobs. `wget -` can be [`curl -fsSLJO`](https://explainshell.com/explain?cmd=curl+-fsSLJO).

```sh
curl -s https://api.github.com/repos/jgm/pandoc/releases/latest |
	grep -o "https://.*\.amd64\.deb" |
	xargs curl -fsLJO
```

If the `grep` doesn't suit you and you have `jq` handy you can swap in the equivalent:

```sh
curl -s https://api.github.com/repos/jgm/pandoc/releases/latest |
	jq -r '.assets[].browser_download_url | select(test("arm64.deb"))' |
	xargs curl -fsLJO
```

#### [flightlesstux](https://gist.github.com/flightlesstux) commented [on May 5, 2021](https://gist.github.com/steinwaywhw/a4cd19cda655b8249d908261a62687f8?permalink_comment_id=3732887#gistcomment-3732887) • edited 

I don't understand why there are so many comments here. It's really easy with bash. Here is the example, I did it for you.

```sh
if [ "${OSTYPE}" = "x86_64" ]; then
    BIN="amd64"
else
    BIN="arm64"
fi

LATEST=$(curl -s https://api.github.com/repos/prometheus/node_exporter/releases/latest | grep "linux-${BIN}.tar.gz" | cut -d '"' -f 4 | tail -1)

cd /tmp/
curl -s -LJO $LATEST
```

#### [Sy3Omda](https://gist.github.com/Sy3Omda) commented [on May 7, 2021](https://gist.github.com/steinwaywhw/a4cd19cda655b8249d908261a62687f8?permalink_comment_id=3735025#gistcomment-3735025)

easy and fast  
```shell
curl -s https://api.github.com/repos/user/reponame/releases/latest | grep -E 'browser_download_url' | grep linux_amd64 | cut -d '"' -f 4 | wget -qi -
```

#### [Frikster](https://gist.github.com/Frikster) commented [on May 18, 2021](https://gist.github.com/steinwaywhw/a4cd19cda655b8249d908261a62687f8?permalink_comment_id=3747836#gistcomment-3747836) • edited 

To download the latest tarball for a repo I was able to just do this:

```shell
curl https://api.github.com/repos/user/reponame/releases/latest | grep "browser_download_url" | grep -Eo 'https://[^\"]*' | xargs wget
```

I think if you are on Windows you have to change it to:

```shell
curl https://api.github.com/repos/user/reponame/releases/latest | grep "browser_download_url" | grep -Eo 'https://[^/"]*' | xargs wget
```

If you want to download the latest tar and immediately extract what was downloaded:

```shell
curl https://api.github.com/repos/user/reponame/releases/latest | grep "browser_download_url" | grep -Eo 'https://[^\"]*' | xargs wget -O - | tar -xz
```

#### [vithalreddy](https://gist.github.com/vithalreddy)** commented [on May 23, 2021](https://gist.github.com/steinwaywhw/a4cd19cda655b8249d908261a62687f8?permalink_comment_id=3753693#gistcomment-3753693)

i have developed a small bash function which will take git repo as fn argument and has an option to define install methods. and cleans the data after instalation is complete.

```shell
ghInstall author/repo
```

```shell
function ghInstall(){
    local loc="/tmp/gh-downloads/$1"
    local repo="https://api.github.com/repos/$1/releases/latest"
    local URL=`curl -s "${repo}" | grep "browser_download_url" | cut -d '"' -f 4 | fzf`
    echo "Repo: $repo Temp Dir: $loc"

    mkdir -p $loc
    curl -sOL --output-dir $loc  ${URL}
    local tarfilename="$(find $loc  -name "*.tar.gz")"
    tar xvzf $tarfilename -C $loc
    ls $loc -al

    local PS3='Please choose the Installing Method: '
    local gh_options=("Move to Bin Dir" "Make install" "Quit")
    select opt in "${gh_options[@]}"
    do
        case $opt in
            "Move to Bin Dir")
                rm -rf $tarfilename
                sudo mv $loc/* /usr/local/bin/
                break
                ;;
            "Make install")
                make install
                break
                ;;
            "Quit")
                break
                ;;
            *) echo "invalid option $REPLY";;
        esac
    done

    rm -rf $loc
}
```

#### [SuperJC710e](https://gist.github.com/SuperJC710e)** commented [on May 27, 2021](https://gist.github.com/steinwaywhw/a4cd19cda655b8249d908261a62687f8?permalink_comment_id=3759604#gistcomment-3759604)

> If someone needs a PowerShell only version (example for Microsofts vsts agent):
> 
> ```shell
> $githubLatestReleases = "https://api.github.com/repos/microsoft/azure-pipelines-agent/releases/latest"   
> $githubLatestReleasesJson = ((Invoke-WebRequest $gitHubLatestReleases) | ConvertFrom-Json).assets.browser_download_url  
> $Uri = (((Invoke-WebRequest $githubLatestReleasesJson | ConvertFrom-Json).downloadUrl) | Select-String "vsts-agent-win-x64").ToString()  
> ```

Perfect! Thank you!

#### [majick777](https://gist.github.com/majick777)** commented [on May 30, 2021](https://gist.github.com/steinwaywhw/a4cd19cda655b8249d908261a62687f8?permalink_comment_id=3763081#gistcomment-3763081)

"To link directly to a download of your latest release asset, link to /owner/name/releases/latest/download/asset-name.zip."  
Source: [https://docs.github.com/en/github/administering-a-repository/releasing-projects-on-github/linking-to-releases](https://docs.github.com/en/github/administering-a-repository/releasing-projects-on-github/linking-to-releases)

This means you can just download the asset URL directly without the API?  
So I'm not sure why this is still a thing? (Tho my guess is maybe this redirect was added in 2019 but this thread started in 2017.)

#### [alerque](https://gist.github.com/alerque) commented [on May 31, 2021](https://gist.github.com/steinwaywhw/a4cd19cda655b8249d908261a62687f8?permalink_comment_id=3763337#gistcomment-3763337) • edited 

[@majick777](https://github.com/majick777) That only works for projects that post assets with simple filenames that don't have any changing version data in the asset name itself. Some projects do that, but not all can be downloaded that way and while it makes this easy doing that makes other things hard (like keeping multiple versions of something in a directory). Hence these solutions are still useful in 2021. If the project you are downloading from doesn't have version info in the asset name by all means use those "latest" links.

***

As for the proliferation of comments here:

1.  The majority of people posting clearly aren't proficient shell coders. There are a number of gems above, but many of the solutions are overly complex, spawn more processes than necessary, make shell quoting blunders, etc. Some claim to be "bash" but are actually "sh" and vise versa. Many of the examples here using 2 `grep`s and a `cut` could be simplified to a single `grep` if you pay attention to the URL scheme to match. Many examples above make the mistake of using `xargs`, then only handling one possible output. These will fail badly if more than one match is found.
2.  Half the comments seem to be unaware that the exact syntax will need to be adjusted based on the upstream project's asset naming schemes. There is no 1-size-fits-all command for this because almost all of these rely on some form of pattern matching or assumptions about the naming scheme. **We don't need 20 more "this is the one that works" posts!** Sure you had to adjust your syntax for the project you were downloading from, but that doesn't mean it will work best for everyone.
3.  Different tools are used and some situations might call for that. [I posted examples](https://gist.github.com/steinwaywhw/a4cd19cda655b8249d908261a62687f8#gistcomment-3705619) with `jq` and with `grep` above to illustrate how different tooling could be used to advantage. Likewise swapping `wget -qi` and `curl -fsLJO` can be a matter of system tooling choice.
4.  Some of these are better for scripting, some are better for interactive use.

***

Before posting more, please seriously consider whether your solution offers something more in the way of a better implementation or more explanation than existing options. If you just copied and tweaked an existing one to match some other project URL scheme, please refrain since that won't _add_ anything.

#### [yaneony](https://gist.github.com/yaneony)** commented [on Jun 17, 2021](https://gist.github.com/steinwaywhw/a4cd19cda655b8249d908261a62687f8?permalink_comment_id=3783983#gistcomment-3783983)

Shameless self-promotion, but i did that for community as well. [https://ghd.one](https://ghd.one/)  
Enter repository URL, filter down the list to only one single file, get your permanent link for download.

Example for Gitea repository: [https://ghd.one/go-gitea/gitea](https://ghd.one/go-gitea/gitea)  
Filtered to Linux binary 64bit without extension: [https://ghd.one/go-gitea/gitea?includes=linux+amd64&excludes=amd64](https://ghd.one/go-gitea/gitea?includes=linux+amd64&excludes=amd64).  
Filtered to Windows 64bit executable file: [https://ghd.one/go-gitea/gitea?includes=windows+amd64&excludes=gogit+.exe](https://ghd.one/go-gitea/gitea?includes=windows+amd64&excludes=gogit+.exe).

More about it on reddit: [https://www.reddit.com/r/programming/comments/o1yit0/ghd_get_github_direct_links_without_pain_wip/](https://www.reddit.com/r/programming/comments/o1yit0/ghd_get_github_direct_links_without_pain_wip/)

#### [alerque](https://gist.github.com/alerque)** commented [on Jun 17, 2021](https://gist.github.com/steinwaywhw/a4cd19cda655b8249d908261a62687f8?permalink_comment_id=3784005#gistcomment-3784005)

[@yaneony](https://github.com/yaneony) That’s kinda spiffy to help people that can't write match expressions for `grep` come up with something useful, but it would be cooler if the UI gave out a shell command with the appropriate way to get the original URL rather than bouncing everybody’s downloads through a 3rd party service!

#### [yaneony](https://gist.github.com/yaneony)** commented [on Jun 17, 2021](https://gist.github.com/steinwaywhw/a4cd19cda655b8249d908261a62687f8?permalink_comment_id=3784016#gistcomment-3784016)

[@alerque](https://github.com/alerque) you've right, the only problem is: different platforms - different methods.  
Some people using bash, some wget, other nodejs or even php... I went thru all of them. It did a lot of pain changing regular expressions every time developer change naming pattern. That's how i came to idea of making that website.

#### [psychowood](https://gist.github.com/psychowood)** commented [on Jul 14, 2021](https://gist.github.com/steinwaywhw/a4cd19cda655b8249d908261a62687f8?permalink_comment_id=3813080#gistcomment-3813080)

Just in case this could be useful for anyone, I'm using this oneliner from an alpine docker image, to pull the latest tarball from a github release and extract it in the current folder, skipping the original root folder:

`curl -s https://api.github.com/repos/ghostfolio/ghostfolio/releases/latest | sed -n 's/.*"tarball_url": "\(.*\)",.*/\1/p' | xargs -n1 wget -O - -q | tar -xz --strip-components=1`

#### [minlaxz](https://gist.github.com/minlaxz)** commented [on Aug 1, 2021](https://gist.github.com/steinwaywhw/a4cd19cda655b8249d908261a62687f8?permalink_comment_id=3839082#gistcomment-3839082)

How I do in bash,

```sh
tarballLink=$(curl -s https://api.github.com/repos/minlaxz/cra-by-noob/releases/latest \
| grep "browser_download_url.*tar.xz"  \
| cut -d : -f 2,3 \
| tr -d \" \
| xargs)
```

#### [pogossian](https://gist.github.com/pogossian)** commented [on Aug 18, 2021](https://gist.github.com/steinwaywhw/a4cd19cda655b8249d908261a62687f8?permalink_comment_id=3864752#gistcomment-3864752)

To link directly to a download of your latest release asset, link to /owner/name/releases/latest/download/asset-name.zip.

[https://docs.github.com/en/github/administering-a-repository/releasing-projects-on-github/linking-to-releases](https://docs.github.com/en/github/administering-a-repository/releasing-projects-on-github/linking-to-releases)

#### [minlaxz](https://gist.github.com/minlaxz)** commented [on Aug 19, 2021](https://gist.github.com/steinwaywhw/a4cd19cda655b8249d908261a62687f8?permalink_comment_id=3865662#gistcomment-3865662) • edited 

[@pogossian](https://github.com/pogossian) thanks.  
Now I can simply `curl` it

```sh
curl -fsSL github.com/{owner}/{repo}/releases/latest/download/{asset-name.zip} -O
```

#### [knadh](https://gist.github.com/knadh)** commented [on Aug 22, 2021](https://gist.github.com/steinwaywhw/a4cd19cda655b8249d908261a62687f8?permalink_comment_id=3868412#gistcomment-3868412)

Download the latest release where the release filename is dynamic, for example, with version strings.

```shell
# Get the URL of the latest release.
# Leave https://(.*) as is and adjust the second (.*) in the URL to match the dynamic bits in the project filename.
URL=$(curl -L -s https://api.github.com/repos/username/projectname/releases/latest | grep -o -E "https://(.*)projectname_(.*)_linux_amd64.tar.gz")

# Download and extract the release to the build dir.
curl -L -s $URL | tar xvz -C ./extract-dir
```

#### [yaneony](https://gist.github.com/yaneony)** commented [on Aug 23, 2021](https://gist.github.com/steinwaywhw/a4cd19cda655b8249d908261a62687f8?permalink_comment_id=3869732#gistcomment-3869732)

The only problem by the code you're sharing here is, you can only get the release source code, but not the released asset which name might change from version to version. And that is why i did that here: [https://gist.github.com/steinwaywhw/a4cd19cda655b8249d908261a62687f8#gistcomment-3783983](https://gist.github.com/steinwaywhw/a4cd19cda655b8249d908261a62687f8#gistcomment-3783983)

#### [SOOS-Pchen](https://gist.github.com/SOOS-Pchen)** commented [on Sep 2, 2021](https://gist.github.com/steinwaywhw/a4cd19cda655b8249d908261a62687f8?permalink_comment_id=3880468#gistcomment-3880468)

[@yaneony](https://github.com/yaneony) when i try it, the assets show up but when hovering over the download button it says "not available".

#### [yaneony](https://gist.github.com/yaneony)** commented [on Sep 3, 2021](https://gist.github.com/steinwaywhw/a4cd19cda655b8249d908261a62687f8?permalink_comment_id=3881114#gistcomment-3881114)

[@SOOS-Pchen](https://github.com/SOOS-Pchen) which repository?

#### [redraw](https://gist.github.com/redraw)** commented [on Sep 21, 2021](https://gist.github.com/steinwaywhw/a4cd19cda655b8249d908261a62687f8?permalink_comment_id=3900967#gistcomment-3900967)

I've written a snippet that usually works [https://gist.github.com/redraw/13ff169741d502b6616dd05dccaa5554](https://gist.github.com/redraw/13ff169741d502b6616dd05dccaa5554)

#### [XedinUnknown](https://gist.github.com/XedinUnknown)** commented [on Sep 29, 2021](https://gist.github.com/steinwaywhw/a4cd19cda655b8249d908261a62687f8?permalink_comment_id=3911206#gistcomment-3911206)

> To link directly to a download of your latest release asset, link to /owner/name/releases/latest/download/asset-name.zip.
> 
> [docs.github.com/en/github/administering-a-repository/releasing-projects-on-github/linking-to-releases](https://docs.github.com/en/github/administering-a-repository/releasing-projects-on-github/linking-to-releases)

[@pogossian](https://github.com/pogossian), the point of this whole thread seems to be that the `asset-name.zip` part is different for automatic source tarballs. Have you found a convenient way to go around this?

#### [yaneony](https://gist.github.com/yaneony)** commented [on Sep 29, 2021](https://gist.github.com/steinwaywhw/a4cd19cda655b8249d908261a62687f8?permalink_comment_id=3911367#gistcomment-3911367)

> > To link directly to a download of your latest release asset, link to /owner/name/releases/latest/download/asset-name.zip.  
> > [docs.github.com/en/github/administering-a-repository/releasing-projects-on-github/linking-to-releases](https://docs.github.com/en/github/administering-a-repository/releasing-projects-on-github/linking-to-releases)
> 
> [@pogossian](https://github.com/pogossian), the point of this whole thread seems to be that the `asset-name.zip` part is different for automatic source tarballs. Have you found a convenient way to go around this?

There is no easy way to do that. If you use only few repos you can handle the whole with some regular expressions. The thing can get ugly if released assets get different names from version to version, like codename in file name or other things. Handling different repos is really hard, since you also have rate limits. I've solved that by my website, but you have to rely on third party service. It's just doing redirect in background.

#### [Strykar](https://gist.github.com/Strykar)** commented [on Sep 30, 2021](https://gist.github.com/steinwaywhw/a4cd19cda655b8249d908261a62687f8?permalink_comment_id=3912050#gistcomment-3912050)

My solution, multi-arch - [https://gist.github.com/Strykar/389e1a1ed2e2ecf4068cafd584d735e0](https://gist.github.com/Strykar/389e1a1ed2e2ecf4068cafd584d735e0)

#### [Karmakstylez](https://gist.github.com/Karmakstylez)** commented [on Oct 12, 2021](https://gist.github.com/steinwaywhw/a4cd19cda655b8249d908261a62687f8?permalink_comment_id=3924479#gistcomment-3924479) • edited 

`URL=$(curl -v https://api.github.com/repos/user/repo/releases/latest 2>&1 | grep -v ant | grep browser_download_url | grep -v .asc | cut -d '"' -f 4) && wget $URL && ZIP="$(find . -maxdepth 1 -name "namebefore-*-release.zip")" && unzip -qq $ZIP`

Dockerfile tested and works perfectly. In case there are multiple files you can try with WSL to see which file you need and do multiple grep pipelines to get the file you need. Such as .asc files. If there are none you can simply ignore that.

#### [jasonbrianhall](https://gist.github.com/jasonbrianhall)** commented [on Oct 21, 2021](https://gist.github.com/steinwaywhw/a4cd19cda655b8249d908261a62687f8?permalink_comment_id=3935122#gistcomment-3935122)

```shell
#!/bin/bash

export HTTPS_PROXY=servername:port

for x in `curl -s https://api.github.com/repos/aquasecurity/trivy/releases/latest | jq -r '.assets[] | select(.content_type == "application/x-rpm") | {url} | .url'`; do  
RPM=`curl $x | jq -r .browser_download_url`  
curl -L $RPM -O

done
```

#### [ghost](https://gist.github.com/ghost) commented [on Oct 22, 2021](https://gist.github.com/steinwaywhw/a4cd19cda655b8249d908261a62687f8?permalink_comment_id=3936277#gistcomment-3936277)

##### a note (for _your repositories_)

I advise using consistent file-names. I.E. don't include a versioning in the filename.

I know it sounds weird, but bear with me^^[*](https://www.grammarly.com/blog/bear-with-me/)^^ for a second.

You know the `.../releases/latest` syntax right?  
did you know you can also use it to download files as well? (and not just to redirect to the latest release on GitHub?)

Here, try this URL for example:  
[](https://github.com/ytdl-org/youtube-dl/releases/latest/download/youtube-dl.exe)[https://github.com/ytdl-org/youtube-dl/releases/latest/download/youtube-dl.exe](https://github.com/ytdl-org/youtube-dl/releases/latest/download/youtube-dl.exe).

this reduces the need to walk through GitHub-[Releases API](https://docs.github.com/en/rest/reference/repos#releases) entirely! and simplify stuff for users and also web-services that crawls your repository (in-case you have a somewhat popular product :] ).  
You don't to maintain any kind of backend or domain at all and relink to to the latest binaries (for example: [](http://youtube-dl.org/downloads/latest/youtube-dl.exe)[http://youtube-dl.org/downloads/latest/youtube-dl.exe](http://youtube-dl.org/downloads/latest/youtube-dl.exe)). it is handled by GitHub releases!

you can always include the version in a file named `version.txt`,  
or any meta-data, really. keep a consistent file-name here too.

got the idea from [https://github.com/yt-dlp/yt-dlp#update](https://github.com/yt-dlp/yt-dlp#update)

#### [yucongo](https://gist.github.com/yucongo)** commented [on Oct 24, 2021](https://gist.github.com/steinwaywhw/a4cd19cda655b8249d908261a62687f8?permalink_comment_id=3937644#gistcomment-3937644)

```shell
curl --silent "https://api.github.com/repos/USER/REPO/releases/latest" | jq ".. .tag_name? // empty"
```

delivers the latest release string, e.g., `"v1.0.0-beta7-fix2"`, provided tag_name is so set I suppose.

#### [blafasel42](https://gist.github.com/blafasel42)** commented [on Oct 25, 2021](https://gist.github.com/steinwaywhw/a4cd19cda655b8249d908261a62687f8?permalink_comment_id=3938550#gistcomment-3938550) • edited 

```shell
curl -o filename.tgz -L `curl -s [https://api.github.com/repos/USER/REPO/releases/latest](https://api.github.com/repos/USER/REPO/releases/latest) | grep -oP '"tarball_url": "\K(.*)(?=")'
```

there will be a container directory inside this. You can find its name like:

```shell
export hash=`curl -s [https://api.github.com/repos/ImageMagick/ImageMagick/releases/latest](https://api.github.com/repos/ImageMagick/ImageMagick/releases/latest) | grep -oP '"target_commitish": "\K(.*)(?=")'`  
export dir = USER-REPO-${hash::7}
```

so if you `tar -zxf filename.tgz` after the first curl, you can then `cd $dir` and then work with the files...

#### [maelstrom256](https://gist.github.com/maelstrom256)** commented [on Dec 9, 2021](https://gist.github.com/steinwaywhw/a4cd19cda655b8249d908261a62687f8?permalink_comment_id=3989670#gistcomment-3989670)

Not a oneliner, but…  
Sample for VictoriaMetrics vmutils package

```shell
REPO=VictoriaMetrics/VictoriaMetrics
IMASK='vmutils.*amd64.*gz'
EMASK='(enterprise|windows)'
curl --silent https://api.github.com/repos/${REPO}/releases | \
jq -r "sort_by(.tag_name) | [ .[] | select(.draft | not) | select(.prerelease | not) ] | .[-1].assets[].browser_download_url | select(test(\".*${IMASK}.*\")) | select(test(\"${EMASK}\") | not)"
```

#### [maxadamo](https://gist.github.com/maxadamo)** commented [on Dec 13, 2021](https://gist.github.com/steinwaywhw/a4cd19cda655b8249d908261a62687f8?permalink_comment_id=3994492#gistcomment-3994492) • edited 

it can be done using AWK. In this case I'm matching against a `deb` package:

```sh
REPO='jgraph/drawio-desktop'
curl -s https://api.github.com/repos/${REPO}/releases/latest | awk -F\" '/browser_download_url.*.deb/{print $(NF-1)}'
```

#### [redraw](https://gist.github.com/redraw)** commented [on Dec 15, 2021](https://gist.github.com/steinwaywhw/a4cd19cda655b8249d908261a62687f8?permalink_comment_id=3997427#gistcomment-3997427)

I've made a Github extension

Installation: `gh extension install redraw/gh-install`

Usage: `gh install <user>/<repo>`

#### [sebma](https://gist.github.com/sebma)** commented [on Dec 15, 2021](https://gist.github.com/steinwaywhw/a4cd19cda655b8249d908261a62687f8?permalink_comment_id=3997433#gistcomment-3997433)

👍

#### [b2az](https://gist.github.com/b2az)** commented [on Feb 22, 2022](https://gist.github.com/steinwaywhw/a4cd19cda655b8249d908261a62687f8?permalink_comment_id=4074346#gistcomment-4074346)

[@yucongo](https://github.com/yucongo) i had to laugh so much - as i found this searching for a way to download the latest release of the jq tool itself 🧨


#### [xaratustrah](https://gist.github.com/xaratustrah)** commented [on Mar 3, 2022](https://gist.github.com/steinwaywhw/a4cd19cda655b8249d908261a62687f8?permalink_comment_id=4084140#gistcomment-4084140) • edited 

thanks [@Frikster](https://github.com/Frikster) ! here is a modified version for getting the newest tag from a repository and unpack it immediately:

```shell
curl https://api.github.com/repos/<USER>/<REPO>/tags | grep "tarball_url" | grep -Eo 'https://[^\"]*' | sed -n '1p' | xargs wget -O - | tar -xz
```

#### [NotoriousPyro](https://gist.github.com/NotoriousPyro)** commented [on Apr 20, 2022](https://gist.github.com/steinwaywhw/a4cd19cda655b8249d908261a62687f8?permalink_comment_id=4138961#gistcomment-4138961)

I prefer to use jq to parse the output (e.g. for Vale)

```sh
    package=$(curl -s https://api.github.com/repos/errata-ai/vale/releases/latest \
    | jq -r ' .assets[] | select(.name | contains("Linux"))'); output=$(mktemp -d); \
    echo $package | jq -r '.browser_download_url' | xargs curl -L --output-dir $output -O; \
    echo $package | jq -r '.name' | sed -r "s#(.*)#$output/\1#g" | xargs cat \
    | tar xzf - -C $output; cp $output/vale $HOME/bin
```

#### [necros2k7](https://gist.github.com/necros2k7)** commented [on Apr 23, 2022](https://gist.github.com/steinwaywhw/a4cd19cda655b8249d908261a62687f8?permalink_comment_id=4142985#gistcomment-4142985)

Can we get latest release from Windows? What would command line look like?


#### [oshliaer](https://gist.github.com/oshliaer)** commented [on Apr 23, 2022](https://gist.github.com/steinwaywhw/a4cd19cda655b8249d908261a62687f8?permalink_comment_id=4143015#gistcomment-4143015)

[@necros2k7](https://github.com/necros2k7), you have to learn the cmd of your OS.


#### [graphik55](https://gist.github.com/graphik55)** commented [on Apr 24, 2022](https://gist.github.com/steinwaywhw/a4cd19cda655b8249d908261a62687f8?permalink_comment_id=4143067#gistcomment-4143067)

> Can we get latest release from Windows? What would command line look like?

[@necros2k7](https://github.com/necros2k7)  
Checkout my previous answer:  
[https://gist.github.com/steinwaywhw/a4cd19cda655b8249d908261a62687f8?permalink_comment_id=3668287#gistcomment-3668287](https://gist.github.com/steinwaywhw/a4cd19cda655b8249d908261a62687f8?permalink_comment_id=3668287#gistcomment-3668287)


#### [XedinUnknown](https://gist.github.com/XedinUnknown)** commented [on May 7, 2022](https://gist.github.com/steinwaywhw/a4cd19cda655b8249d908261a62687f8?permalink_comment_id=4159122#gistcomment-4159122)

[@necros2k7](https://github.com/necros2k7), why not WSL2?

[@redraw](https://github.com/redraw), thanks, looks really good!


#### [Ritesh007](https://gist.github.com/Ritesh007)** commented [on May 19, 2022](https://gist.github.com/steinwaywhw/a4cd19cda655b8249d908261a62687f8?permalink_comment_id=4172479#gistcomment-4172479) • edited 

-   for the latest package download -
    ```shell
    curl -fsSL github.com/<user>/<repo>/releases/latest/download/<asset_name> -O
    ```
-   for a specific tagged release package download -  
    ```shell
    curl -fsSL github.com/<user>/<repo>/releases/download/<tag_name>/<asset_name> -O
    ```

#### [joaovitor](https://gist.github.com/joaovitor)** commented [on May 19, 2022](https://gist.github.com/steinwaywhw/a4cd19cda655b8249d908261a62687f8?permalink_comment_id=4172485#gistcomment-4172485)

Try simplifying it using [https://cli.github.com/manual/gh_release_download](https://cli.github.com/manual/gh_release_download)

#### [sebma](https://gist.github.com/sebma)** commented [on May 19, 2022](https://gist.github.com/steinwaywhw/a4cd19cda655b8249d908261a62687f8?permalink_comment_id=4172710#gistcomment-4172710)

[@joaovitor](https://github.com/joaovitor) 👍

#### [wmacevoy](https://gist.github.com/wmacevoy)** commented [on May 20, 2022](https://gist.github.com/steinwaywhw/a4cd19cda655b8249d908261a62687f8?permalink_comment_id=4173036#gistcomment-4173036) • edited 

Python3 instead of jq (grep is bad because it assumes json will be formatted in certain ways)

```shell
curl -LJO `curl -s https://api.github.com/repos/wmacevoy/facts/releases/latest | python3  -c 'import sys, json; print(json.load(sys.stdin)["tarball_url"])'`
```

You can extract the latest into the current directory with:

```shell
curl -LJ `curl -s https://api.github.com/repos/wmacevoy/facts/releases/latest | python3  -c 'import sys, json; print(json.load(sys.stdin)["tarball_url"])'` | tar zxf - --strip=1
```

In either case, if you have jq, then you can replace

```shell
python3  -c 'import sys, json; print(json.load(sys.stdin)["tarball_url"])'
```

with

```shell
jq -r .tarball_url
```

#### [jreybert](https://gist.github.com/jreybert) commented [on May 31, 2022](https://gist.github.com/steinwaywhw/a4cd19cda655b8249d908261a62687f8?permalink_comment_id=4184757#gistcomment-4184757) • edited 

To select an asset based on a regex on the asset name, for example `.*linux_amd64.tar.gz`, and get the donwload url:

```sh
curl -s https://api.github.com/repos/username/projectname/releases/latest | jq '.assets[] | select(.name|match("linux_amd64.tar.gz$")) | .browser_download_url'
```

#### [jreisinger](https://gist.github.com/jreisinger) commented [on Jun 4, 2022](https://gist.github.com/steinwaywhw/a4cd19cda655b8249d908261a62687f8?permalink_comment_id=4189494#gistcomment-4189494) • edited 

I wrote a CLI tool in Go named [ghrel](https://github.com/jreisinger/ghrel) to list, concurrently download and verify assets of the latest release.

#### [liudonghua123](https://gist.github.com/liudonghua123) commented [on Jun 19, 2022](https://gist.github.com/steinwaywhw/a4cd19cda655b8249d908261a62687f8?permalink_comment_id=4206170#gistcomment-4206170)

> ### a note (for _your repositories_)
> 
> I advise using consistent file-names. I.E. don't include a versioning in the filename.  
> I know it sounds weird, but bear with me[*](https://www.grammarly.com/blog/bear-with-me/) for a second.
> 
> You know the `.../releases/latest` syntax right? did you know you can also use it to download files as well? (and not just to redirect to the latest release on Github?)
> 
> Here, try this URL for example: [https://github.com/ytdl-org/youtube-dl/releases/latest/download/youtube-dl.exe](https://github.com/ytdl-org/youtube-dl/releases/latest/download/youtube-dl.exe).
> 
> this reduces the need to walk through GitHub-[Releases API](https://docs.github.com/en/rest/reference/repos#releases) entirely! and simplify stuff for users and also web-services that crawls your repository (in-case you have a somewhat popular product :] ). You don't to maintain any kind of backend or domain at all and relink to to the latest binaries (for example: [http://youtube-dl.org/downloads/latest/youtube-dl.exe](http://youtube-dl.org/downloads/latest/youtube-dl.exe)). it is handled by github releases!
> 
> you can always include the version in a file named `version.txt`, or any meta-data, really. keep a consistent file-name here too.
> 
> got the idea from [https://github.com/yt-dlp/yt-dlp#update](https://github.com/yt-dlp/yt-dlp#update)

COOL! 👍

#### [robertpatrick](https://gist.github.com/robertpatrick)** commented [on Sep 15, 2022](https://gist.github.com/steinwaywhw/a4cd19cda655b8249d908261a62687f8?permalink_comment_id=4302888#gistcomment-4302888) • edited 

Hmm... 
```
https://github.com/<org-name>/<repo-name>/releases/latest/download/<artifact-file-name>
```
should work without having to rely on the GitHub REST API, no?

#### [derekm](https://gist.github.com/derekm)** commented [on Sep 15, 2022](https://gist.github.com/steinwaywhw/a4cd19cda655b8249d908261a62687f8?permalink_comment_id=4303846#gistcomment-4303846) • edited 

Download all assets in the latest release:

```shell
#!/bin/bash
IFS=$' \t\r\n'

assets=$(curl https://api.github.com/repos/$ORG/$REPO/releases | jq -r '.[0].assets[].browser_download_url')

for asset in $assets; do
    curl -OL $asset
done
```

**... or ...**

Download all assets in a specific release:

```shell
#!/bin/bash
IFS=$' \t\r\n'

assets=$(curl https://api.github.com/repos/$ORG/$REPO/releases | jq -r ".[] | select(.tag_name == \"$TAG\") | .assets[].browser_download_url")

for asset in $assets; do
    curl -OL $asset
done
```

#### [nicman23](https://gist.github.com/nicman23)** commented [on Sep 28, 2022](https://gist.github.com/steinwaywhw/a4cd19cda655b8249d908261a62687f8?permalink_comment_id=4317916#gistcomment-4317916) • edited 

```sh
curl -sL https://github.com/revanced/revanced-integrations/releases/ | 
   xmllint -html -xpath '//a[contains(@href, "releases")]/text()' - 2> /dev/null | 
   grep -P '^v' | head -n1
```

#### [cobalt2727](https://gist.github.com/cobalt2727)** commented [on Oct 18, 2022](https://gist.github.com/steinwaywhw/a4cd19cda655b8249d908261a62687f8?permalink_comment_id=4340582#gistcomment-4340582)

Hello! Every now and then this function fails seemingly at random, and I haven't been able to successfully determine why.

From a [script](https://github.com/cobalt2727/L4T-Megascript/blob/master/scripts/discord.sh) to automatically update WebCord:

```
Downloading the most recent .deb from SpacingBat3 repository...
--2022-10-18 19:51:55--  https://api.github.com/repos/SpacingBat3/WebCord/releases/79464711,assets_url
Resolving api.github.com (api.github.com)... 140.82.113.5
Connecting to api.github.com (api.github.com)|140.82.113.5|:443... connected.
HTTP request sent, awaiting response... 200 OK
Length: unspecified [application/json]
Saving to: ‘79464711,assets_url’

     0K .......... .......... .......                          1.35M=0.02s

2022-10-18 19:51:55 (1.35 MB/s) - ‘79464711,assets_url’ saved [28644]

FINISHED --2022-10-18 19:51:55--
Total wall clock time: 0.3s
Downloaded: 1 files, 28K in 0.02s (1.35 MB/s)
Done! Installing the package...
Waiting until APT locks are released... 

WARNING: apt does not have a stable CLI interface. Use with caution in scripts.

Reading package lists...
E: Unsupported file /tmp/*arm64.deb given on commandline
Webcord install failed
```

Would anyone be able to help me debug this and figure out why I'm getting whatever `79464711,assets_url` is supposed to be instead of the release file?  
The exact commands I'm running are

```shell
cd /tmp
curl -s https://api.github.com/repos/SpacingBat3/WebCord/releases/latest |
  grep "browser_download_url.*arm64.deb" |
  cut -d : -f 2,3 |
  tr -d \" |
  wget -i -

echo "Done! Installing the package..."
sudo apt install -y /tmp/*arm64.deb || error "Webcord install failed"
```

#### [antofthy](https://gist.github.com/antofthy)** commented [on Oct 20, 2022](https://gist.github.com/steinwaywhw/a4cd19cda655b8249d908261a62687f8?permalink_comment_id=4343227#gistcomment-4343227) • edited 

While all this USED to be easy... I am now finding the returned URL for the project I am interested in has a return of  
`"message": "Moved Permanently"`  
But without a HTTP redirection, which curl could handle transparently.

Seems the owner of the project had changed on me!

As such you may have to check for this condition and adjust accordingly!

"The pain. The pain!" -- Doctor Smith, "Lost in Space"

#### [surfzoid](https://gist.github.com/surfzoid)** commented [on Nov 8, 2022](https://gist.github.com/steinwaywhw/a4cd19cda655b8249d908261a62687f8?permalink_comment_id=4362025#gistcomment-4362025)

Hi, you should add point betwen * and deb , because, as you can see curl -s [https://api.github.com/repos/surfzoid/QtVsPlayer/releases/latest](https://api.github.com/repos/surfzoid/QtVsPlayer/releases/latest)  
| grep "browser_download_url.*deb"

By the way, i thank you for time win


#### [surfzoid](https://gist.github.com/surfzoid)** commented [on Nov 8, 2022](https://gist.github.com/steinwaywhw/a4cd19cda655b8249d908261a62687f8?permalink_comment_id=4362038#gistcomment-4362038)

unlucky it is not enough, why curl/grep catch debuginfo as .deb?


#### [NotoriousPyro](https://gist.github.com/NotoriousPyro)** commented [on Nov 8, 2022](https://gist.github.com/steinwaywhw/a4cd19cda655b8249d908261a62687f8?permalink_comment_id=4362042#gistcomment-4362042)

> Hello! Every now and then this function fails seemingly at random, and I haven't been able to successfully determine why.
> 
> From a [script](https://github.com/cobalt2727/L4T-Megascript/blob/master/scripts/discord.sh) to automatically update WebCord:
> 
> ```shell
> Downloading the most recent .deb from SpacingBat3 repository...
> --2022-10-18 19:51:55--  https://api.github.com/repos/SpacingBat3/WebCord/releases/79464711,assets_url
> Resolving api.github.com (api.github.com)... 140.82.113.5
> Connecting to api.github.com (api.github.com)|140.82.113.5|:443... connected.
> HTTP request sent, awaiting response... 200 OK
> Length: unspecified [application/json]
> Saving to: ‘79464711,assets_url’
> 
>      0K .......... .......... .......                          1.35M=0.02s
> 
> 2022-10-18 19:51:55 (1.35 MB/s) - ‘79464711,assets_url’ saved [28644]
> 
> FINISHED --2022-10-18 19:51:55--
> Total wall clock time: 0.3s
> Downloaded: 1 files, 28K in 0.02s (1.35 MB/s)
> Done! Installing the package...
> Waiting until APT locks are released... 
> 
> WARNING: apt does not have a stable CLI interface. Use with caution in scripts.
> 
> Reading package lists...
> E: Unsupported file /tmp/*arm64.deb given on commandline
> Webcord install failed
> ```
> 
> Would anyone be able to help me debug this and figure out why I'm getting whatever `79464711,assets_url` is supposed to be instead of the release file? The exact commands I'm running are
> 
> ```shell
> cd /tmp
> curl -s https://api.github.com/repos/SpacingBat3/WebCord/releases/latest |
>   grep "browser_download_url.*arm64.deb" |
>   cut -d : -f 2,3 |
>   tr -d \" |
>   wget -i -
> 
> echo "Done! Installing the package..."
> sudo apt install -y /tmp/*arm64.deb || error "Webcord install failed"
> ```

The problem is you're trying to use grep, cut and trim on json. None of which are designed for handing json in a reliable way. Use jq for reliability, as per my example above.

#### [NotoriousPyro](https://gist.github.com/NotoriousPyro)** commented [on Nov 8, 2022](https://gist.github.com/steinwaywhw/a4cd19cda655b8249d908261a62687f8?permalink_comment_id=4362046#gistcomment-4362046)

> While all this USED to be easy... I am now finding the returned URL for the project I am interested in has a return of `"message": "Moved Permanently"` But without a HTTP redirection, which curl could handle transparently.
> 
> Seems the owner of the project had changed on me!
> 
> As such you may have to check for this condition and adjust accordingly!
> 
> "The pain. The pain!" -- Doctor Smith, "Lost in Space"

You can use -L with curl to make it follow redirects.

#### [dvershinin](https://gist.github.com/dvershinin)** commented [on Nov 8, 2022](https://gist.github.com/steinwaywhw/a4cd19cda655b8249d908261a62687f8?permalink_comment_id=4362587#gistcomment-4362587)

> Would anyone be able to help me debug this and figure out why I'm getting whatever 79464711,assets_url is supposed to be instead of the release file?

Just use [`lastversion`](https://github.com/dvershinin/lastversion). It's pretty powerful:

```shell
lastversion --assets --filter arm64.deb download https://github.com/SpacingBat3/WebCord
```

> Downloaded webcord_3.9.2_arm64.deb: : 72872.0KB [00:18, 3860.60KB/s]

#### [antofthy](https://gist.github.com/antofthy)** commented [on Nov 8, 2022](https://gist.github.com/steinwaywhw/a4cd19cda655b8249d908261a62687f8?permalink_comment_id=4362929#gistcomment-4362929)

> > While all this USED to be easy... I am now finding the returned URL for the project I am interested in has a return of `"message": "Moved Permanently"` But without a HTTP redirection, which curl could handle transparently.  
> > Seems the owner of the project had changed on me!  
> > As such you may have to check for this condition and adjust accordingly!  
> > "The pain. The pain!" -- Doctor Smith, "Lost in Space"
> 
> You can use -L with curl to make it follow redirects.

That was the point... there were no redirects! Not in the HTTP protocol header, only in the JSON data returned.

#### [solbu](https://gist.github.com/solbu)** commented [on Nov 20, 2022](https://gist.github.com/steinwaywhw/a4cd19cda655b8249d908261a62687f8?permalink_comment_id=4375618#gistcomment-4375618)

Just remember that this only works for repos that do a Release.  
Many projects only use Tags as the release mechanism. I am one of them. :-)

#### [NotoriousPyro](https://gist.github.com/NotoriousPyro)** commented [on Nov 20, 2022](https://gist.github.com/steinwaywhw/a4cd19cda655b8249d908261a62687f8?permalink_comment_id=4375627#gistcomment-4375627)

Well then it's not a release and those repos are not releasing anything.

#### [NotoriousPyro](https://gist.github.com/NotoriousPyro)** commented [on Nov 20, 2022](https://gist.github.com/steinwaywhw/a4cd19cda655b8249d908261a62687f8?permalink_comment_id=4375629#gistcomment-4375629)

Tags are not releases, but releases reference a tag.

#### [dvershinin](https://gist.github.com/dvershinin)** commented [on Nov 20, 2022](https://gist.github.com/steinwaywhw/a4cd19cda655b8249d908261a62687f8?permalink_comment_id=4375637#gistcomment-4375637)

Tags are not releases. But the tags that resemble version numbers in all likelihood are releases 🫡

#### [NotoriousPyro](https://gist.github.com/NotoriousPyro)** commented [on Nov 20, 2022](https://gist.github.com/steinwaywhw/a4cd19cda655b8249d908261a62687f8?permalink_comment_id=4375640#gistcomment-4375640)

True, but then it creates the problem you mention. Using a repo in this way creates the limitation of not being able to grab the releases... Without doing some grepping and whatnot on the tag name.

#### [solbu](https://gist.github.com/solbu)** commented [on Nov 20, 2022](https://gist.github.com/steinwaywhw/a4cd19cda655b8249d908261a62687f8?permalink_comment_id=4375650#gistcomment-4375650)

My reason for Not doing a Release on GitHub (in the /username/foo-bar/releases/ page) is that I have to interact with the web gui, as in I have to login to GitHub in a browser, upload whatever is part of the release and so on – just to do a release,  whereas on SourceForge I only have to do an `rsync` command in the terminal to do a Release, which is often automated in a script or a target in a `Makefile`.

#### [robertpatrick](https://gist.github.com/robertpatrick)** commented [on Nov 20, 2022](https://gist.github.com/steinwaywhw/a4cd19cda655b8249d908261a62687f8?permalink_comment_id=4375740#gistcomment-4375740)

[@solbu](https://github.com/solbu) well…. There are mechanisms to create releases via the REST API. I wrote a little GitHub-maven-plug-in that currently supports creating draft releases, uploading any binaries needed, and pushing release notes. It could easily be extended to publish the release…

#### [cobalt2727](https://gist.github.com/cobalt2727)** commented [on Nov 20, 2022](https://gist.github.com/steinwaywhw/a4cd19cda655b8249d908261a62687f8?permalink_comment_id=4375921#gistcomment-4375921)

> > Would anyone be able to help me debug this and figure out why I'm getting whatever 79464711,assets_url is supposed to be instead of the release file?
> 
> Just use [`lastversion`](https://github.com/dvershinin/lastversion). It's pretty powerful:
> 
> ```
> lastversion --assets --filter arm64.deb download https://github.com/SpacingBat3/WebCord
> ```
> 
> > Downloaded webcord_3.9.2_arm64.deb: : 72872.0KB [00:18, 3860.60KB/s]

I'll definitely look into this, thank you!

#### [eortegaz](https://gist.github.com/eortegaz)** commented [on Dec 9, 2022](https://gist.github.com/steinwaywhw/a4cd19cda655b8249d908261a62687f8?permalink_comment_id=4397720#gistcomment-4397720) • edited 

**Love a good one-liner.**

If you must use `wget`, to make your life easier you should search for your architecture by matching `uname -m` from the JSON response. Don't forget to add `head -1` though, otherwise you're (silently) downloading packages for all available archs.

Totally up to you, but you may want to show progress too (albeit omitting everything else) with `-q --show-progress` instead of suppressing all output.

The one-liner would look something like this:

```shell
    REPO="jgm/pandoc"; \
    curl -s https://api.github.com/repos/${REPO}/releases/latest | grep "browser_download_url.*$(uname -m).deb" \
    | head -1 \
    | cut -d : -f 2,3 \
    | tr -d \" \
    | wget --show-progress -qi - \
    || echo "-> Could not download the latest version of '${REPO}' for your architecture." # if you're polite
```

Note: Setting a variable with the user/repo should decrease the risk of messing up the url :)

#### [fanuch](https://gist.github.com/fanuch)** commented [on Dec 23, 2022](https://gist.github.com/steinwaywhw/a4cd19cda655b8249d908261a62687f8?permalink_comment_id=4411890#gistcomment-4411890)

My hat in the ring.

```shell
VER=$(curl --silent -qI https://github.com/bakito/adguardhome-sync/releases/latest | awk -F '/' '/^location/ {print  substr($NF, 1, length($NF)-1)}'); \
wget https://github.com/bakito/adguardhome-sync/releases/download/$VER/adguardhome-sync_${VER#v}_linux_x86_64.tar.gz 
```

Technically two lines because I needed to use the version number both in the URL path and in the filename

##### Retrieve latest version using `curl`

```sh
curl -I https://github.com/bakito/adguardhome-sync/releases/latest
```

returns

```sh
HTTP/2 302 
...
location: https://github.com/bakito/adguardhome-sync/releases/tag/v0.4.10
...
```

So strip it out (minus the carriage return):

```sh
curl -I https://github.com/bakito/adguardhome-sync/releases/latest | awk -F '/' '/^location/ {print  substr($NF, 1, length($NF)-1)}'
```

returns

```sh
v0.4.10
```

##### Attach to a variable and get annoyed when filename doesn't have a leading 'v'

```sh
${VER#v}
```

This strips the leading `v` from the version number

##### Note

Doesn't handle different architectures but that would be the use of `uname -m` at the least

Thanks for the inspo in this thread - really should be easier than this ...

#### [bluebrown](https://gist.github.com/bluebrown)** commented [on Dec 30, 2022](https://gist.github.com/steinwaywhw/a4cd19cda655b8249d908261a62687f8?permalink_comment_id=4418841#gistcomment-4418841)

[@robertpatrick](https://github.com/robertpatrick)

> Hmm... [https://github.com/](https://github.com/)//releases/latest/download/ should work without having to rely on the GitHub REST API, no?

That works only if the publisher doesn't put the version in the artifact file name, which is more often than not the case. The api.github.com, tells you the version and download URL in the response.

#### [bluebrown](https://gist.github.com/bluebrown)** commented [on Dec 30, 2022](https://gist.github.com/steinwaywhw/a4cd19cda655b8249d908261a62687f8?permalink_comment_id=4418842#gistcomment-4418842)

My script looks pretty much like this, but you need to be careful with mono repos that publish different artifacts with different tags. Latest is useless on those.

#### [cinderblock](https://gist.github.com/cinderblock)** commented [on Jan 16, 2023](https://gist.github.com/steinwaywhw/a4cd19cda655b8249d908261a62687f8?permalink_comment_id=4438255#gistcomment-4438255)

One liner to download and pipe it to tar for extraction directly:

```shell
curl -sL $(curl -s https://api.github.com/repos/actions/runner/releases/latest | grep browser_download_url | cut -d\" -f4 | egrep 'linux-arm64-[0-9.]+tar.gz$') | tar zx
```

#### [notorand-it](https://gist.github.com/notorand-it)** commented [on Feb 9, 2023](https://gist.github.com/steinwaywhw/a4cd19cda655b8249d908261a62687f8?permalink_comment_id=4465134#gistcomment-4465134) • edited 

Why on Earth would you use two different tools for the same task and put `curl` and `wget` in the same script/1-liner ?  
Why fiddling with `grep`/`tr`/`cut` when the only reliable JSON parsing tool is `jq` ?

This is from my own stuff (different URL):

```sh
wget -q -O /usr/bin $(wget -q -O - 'https://api.github.com/repos/mikefarah/yq/releases/latest' | jq -r '.assets[] | select(.name=="yq_linux_amd64").browser_download_url'')
```

2 tools is better than 5 IMHO.  
Adapting it to other needs is left to the keen reader. ;-)

#### [joshjohanning](https://gist.github.com/joshjohanning)** commented [on Feb 15, 2023](https://gist.github.com/steinwaywhw/a4cd19cda655b8249d908261a62687f8?permalink_comment_id=4472038#gistcomment-4472038) • edited 

> > ##### a note (for _your repositories_)
> > 
> > I advise using consistent file-names. I.E. don't include a versioning in the filename.  
> > I know it sounds weird, but bear with me[*](https://www.grammarly.com/blog/bear-with-me/) for a second.  
> > You know the `.../releases/latest` syntax right? did you know you can also use it to download files as well? (and not just to redirect to the latest release on Github?)  
> > Here, try this URL for example: [https://github.com/ytdl-org/youtube-dl/releases/latest/download/youtube-dl.exe](https://github.com/ytdl-org/youtube-dl/releases/latest/download/youtube-dl.exe).  
> > this reduces the need to walk through Github-[Releases API](https://docs.github.com/en/rest/reference/repos#releases) entirely! and simplify stuff for users and also web-services that crawls your repository (in-case you have a somewhat popular product :] ). You don't to maintain any kind of backend or domain at all and relink to to the latest binaries (for example: [http://youtube-dl.org/downloads/latest/youtube-dl.exe](http://youtube-dl.org/downloads/latest/youtube-dl.exe)). it is handled by github releases!  
> > you can always include the version in a file named `version.txt`, or any meta-data, really. keep a consistent file-name here too.  
> > got the idea from [https://github.com/yt-dlp/yt-dlp#update](https://github.com/yt-dlp/yt-dlp#update)
> 
> COOL! 👍

This is it

```shell
wget https://github.com/aquasecurity/tfsec/releases/latest/download/tfsec-linux-amd64
```

#### [NLZ](https://gist.github.com/NLZ)** commented [on Apr 4, 2023](https://gist.github.com/steinwaywhw/a4cd19cda655b8249d908261a62687f8?permalink_comment_id=4526688#gistcomment-4526688)

> Exactly what I was hoping to find. 👍
> 
> I made a slight adjustment to it for my needs.
> 
> ```powershell
> $githubLatestReleases = 'https://api.github.com/repos/microsoft/winget-cli/releases/latest'   
> $githubLatestRelease = (((Invoke-WebRequest $gitHubLatestReleases) | ConvertFrom-Json).assets.browser_download_url | select-string -Pattern 'appxbundle').Line
> Invoke-WebRequest $githubLatestRelease -OutFile 'Microsoft.DesktopAppInstaller.appxbundle'
> ```

Powershell can be further simplified with invoke-restmethod's auto-parsing and then exploring the objects in the pipe

```powershell
Invoke-RestMethod 'https://api.github.com/repos/microsoft/winget-cli/releases/latest' | % assets | ? name -like "*.msixbundle" | % { Invoke-WebRequest $_.browser_download_url -OutFile $_.name }
```

#### [bruteforks](https://gist.github.com/bruteforks)** commented [on Apr 19, 2023](https://gist.github.com/steinwaywhw/a4cd19cda655b8249d908261a62687f8?permalink_comment_id=4542209#gistcomment-4542209) • edited 

> Hmm... `https://github.com/<org-name>/<repo-name>/releases/latest/download/<artifact-file-name>` should work without having to rely on the GitHub REST API, no?

literally the easiest way i've found. Thank you! [example](https://github.com/facebook/flipper/releases/latest/download/Flipper-linux.zip)

edit: here's what i ended up with

```sh
echo "Check for watchman"
if ! [ -x "$(command -v watchman)" ]; then
echo "downloading and installing latest github release"
wget $(curl -L -s https://api.github.com/repos/facebook/watchman/releases/latest | grep -o -E "https://(.*)watchman-(.*).rpm") && sudo dnf localinstall watchman-*.rpm
watchman version
else
  echo "watchman exists."	
fi
```

#### [vavavr00m](https://gist.github.com/vavavr00m)** commented [on May 31, 2023](https://gist.github.com/steinwaywhw/a4cd19cda655b8249d908261a62687f8?permalink_comment_id=4585867#gistcomment-4585867)

Nothing for Windows worked for me.

The below [Windows batch script](https://stackoverflow.com/a/69244131/21996598) sort of worked but it's downloading all latest releases. Anyone knows how to modify it to select only the *-x64.exe release?

```sh
  set repo=owner/name
  for /f "tokens=1,* delims=:" %%A in ('curl -ks https://api.github.com/repos/%repo%/releases/latest ^| find "browser_download_url"') do ( curl -kOL %%B )
```

#### [flightlesstux](https://gist.github.com/flightlesstux)** commented [on May 31, 2023](https://gist.github.com/steinwaywhw/a4cd19cda655b8249d908261a62687f8?permalink_comment_id=4585911#gistcomment-4585911) • edited 

> Nothing for Windows worked for me.
> 
> The below [Windows batch script](https://stackoverflow.com/a/69244131/21996598) sort of worked but it's downloading all latest releases. Anyone knows how to modify it to select only the *-x64.exe release?
> 
> ```shell
>   set repo=owner/name
>   for /f "tokens=1,* delims=:" %%A in ('curl -ks https://api.github.com/repos/%repo%/releases/latest ^| find "browser_download_url"') do ( curl -kOL %%B )
> ```

[@vavavr00m](https://github.com/vavavr00m) could you try this?

```sh
set repo=owner/name
for /f "tokens=1,* delims=:" %%A in ('curl -ks https://api.github.com/repos/%repo%/releases/latest ^| find "browser_download_url"') do (
    set url=%%B
    set "filename=%url:*\=%"
    if "%filename:~-9%"=="-x64.exe" (
        curl -kOL %url%
    )
)
```

#### [vavavr00m](https://gist.github.com/vavavr00m)** commented [on May 31, 2023](https://gist.github.com/steinwaywhw/a4cd19cda655b8249d908261a62687f8?permalink_comment_id=4585928#gistcomment-4585928) • edited 

[@flightlesstux](https://github.com/flightlesstux) Thanks for your response. The %url% stored the -x86.exe release and also the script doesn't also download that file. How do I change it to pick up -x64.exe and download it?

#### [flightlesstux](https://gist.github.com/flightlesstux)** commented [on Jun 1, 2023](https://gist.github.com/steinwaywhw/a4cd19cda655b8249d908261a62687f8?permalink_comment_id=4586099#gistcomment-4586099)

[@vavavr00m](https://github.com/vavavr00m) You're welcome! This script calls a :download subroutine from the loop. The subroutine sets url and filename variables, then checks the filename and downloads the file if it matches -x64.exe.

```bat
@echo off
setlocal enabledelayedexpansion
set repo=owner/name
for /f "tokens=1,* delims=:" %%A in ('curl -ks https://api.github.com/repos/%repo%/releases/latest ^| find "browser_download_url"') do (
    call :download "%%B"
)
goto :eof

:download
set "url=%~1"
for %%i in (%url%) do set "filename=%%~nxi"
if "%filename:~-9%"=="-x64.exe" (
    curl -kOL %url%
)
goto :eof
```

#### [vavavr00m](https://gist.github.com/vavavr00m)** commented [on Jun 1, 2023](https://gist.github.com/steinwaywhw/a4cd19cda655b8249d908261a62687f8?permalink_comment_id=4586474#gistcomment-4586474)

[@flightlesstux](https://github.com/flightlesstux) I tried this on PowerToys. It doesn't download the -x64.exe release(s) for me and %url% output is all the browser_download_url from the PowerToys repo but nothing was downloaded:

[![image](https://user-images.githubusercontent.com/4675132/242622759-4d3a39c8-8323-442f-82cc-c021f9e013bb.png)](https://user-images.githubusercontent.com/4675132/242622759-4d3a39c8-8323-442f-82cc-c021f9e013bb.png)

Would it help to say the .bat is getting the links from a [JSON](https://api.github.com/repos/microsoft/PowerToys/releases/latest)? Should the script echo the URL(s) without the double quotes?

test.bat on W10:

```bat
 @echo off

 setlocal enabledelayedexpansion
 set repo=microsoft/PowerToys
 for /f "tokens=1,* delims=:" %%A in ('curl -ks https://api.github.com/repos/%repo%/releases/latest ^| find "browser_download_url"') do (
      call :download "%%B"
 )
 goto :eof

 :download
 set "url=%~1"
 for %%i in (%url%) do set "filename=%%~nxi"
 if "%filename:~-9%"=="-x64.exe" (
     curl -kOL %url%
)
goto :eof
```

#### [antofthy](https://gist.github.com/antofthy)** commented [on Jun 1, 2023](https://gist.github.com/steinwaywhw/a4cd19cda655b8249d908261a62687f8?permalink_comment_id=4587189#gistcomment-4587189)

The problem is that what to search for VARIES from repo to repo.  
MOST repos seem to use `browser_download_url` but I have also have seen repos that does not have that entry, but use `tarball_url`, `zipball_url` instead.

#### [si618](https://gist.github.com/si618)** commented [on Sep 12, 2023](https://gist.github.com/steinwaywhw/a4cd19cda655b8249d908261a62687f8?permalink_comment_id=4690174#gistcomment-4690174)

[@fanuch](https://github.com/fanuch)

> My hat in the ring.

```shell
VER=$(curl --silent -qI https://github.com/bakito/adguardhome-sync/releases/latest | awk -F '/' '/^location/ {print  substr($NF, 1, length($NF)-1)}'); \
wget https://github.com/bakito/adguardhome-sync/releases/download/$VER/adguardhome-sync_${VER#v}_linux_x86_64.tar.gz 
```

> Thanks for the inspo in this thread - really should be easier than this ...

Agreed, and thanks for putting your hat in the ring; it was very close to what I needed 🙇‍♂️

#### [codelinx](https://gist.github.com/codelinx)** commented [on Sep 21, 2023](https://gist.github.com/steinwaywhw/a4cd19cda655b8249d908261a62687f8?permalink_comment_id=4699831#gistcomment-4699831) • edited 

Using jq, i think this should work with most repos and allow you to saerch different values or fields as needed.

```shell
wget $(curl -s https://api.github.com/repos/bitwarden/clients/releases/latest  | \
 jq -r '.assets[] | select(.name | contains ("deb")) | .browser_download_url')
```

-   `jq -r` _raw search_
-   `select( .name` _select the field to refine your download_
-   `| contains ("deb"))` _search criteria to get the download url_
-   `. browser_download_url'` _return string_

NOTE: `--raw-output/-r` With this option, if the filter's result is a string then it will be written directly to standard output rather than being formatted as a JSON string with quotes.

#### [notorand-it](https://gist.github.com/notorand-it)** commented [on Sep 21, 2023](https://gist.github.com/steinwaywhw/a4cd19cda655b8249d908261a62687f8?permalink_comment_id=4699907#gistcomment-4699907)

But why using wget and curl? Why not just wget or curl?

#### [codelinx](https://gist.github.com/codelinx)** commented [on Sep 21, 2023](https://gist.github.com/steinwaywhw/a4cd19cda655b8249d908261a62687f8?permalink_comment_id=4700042#gistcomment-4700042)

> But why using wget and curl? Why not just wget or curl?

This is a programmatic discussion for downloading the file(s). You cant wget/curl get the file because of links and internet things. Other issues are that the file name may change, the version, or the file you may need for your OS may change etc.

#### [codelinx](https://gist.github.com/codelinx)** commented [on Sep 21, 2023](https://gist.github.com/steinwaywhw/a4cd19cda655b8249d908261a62687f8?permalink_comment_id=4700044#gistcomment-4700044)

> But why using wget and curl? Why not just wget or curl?

you are just trolling.

#### [notorand-it](https://gist.github.com/notorand-it)** commented [on Sep 22, 2023](https://gist.github.com/steinwaywhw/a4cd19cda655b8249d908261a62687f8?permalink_comment_id=4700373#gistcomment-4700373) • edited 

```shell
wget $(wget -q -O - https://api.github.com/repos/bitwarden/clients/releases/latest | jq -r '.assets[] | select(.name | contains ("deb")) | .browser_download_url')
```

I would say this is NOT trolling.  
Just like [this](https://gist.github.com/steinwaywhw/a4cd19cda655b8249d908261a62687f8?permalink_comment_id=4465134#gistcomment-4465134), IMHO.

#### [jrichardsz](https://gist.github.com/jrichardsz)** commented [on Oct 11, 2023](https://gist.github.com/steinwaywhw/a4cd19cda655b8249d908261a62687f8?permalink_comment_id=4722024#gistcomment-4722024)

It worked at first attempt :)  
Thank you so much !!

#### [NiceGuyIT](https://gist.github.com/NiceGuyIT)** commented [on Oct 14, 2023](https://gist.github.com/steinwaywhw/a4cd19cda655b8249d908261a62687f8?permalink_comment_id=4725425#gistcomment-4725425)

[dra](https://github.com/devmatteini/dra) is making huge strides in simplifying the download process.

> dra helps you download release assets more easily:
> 
> -   no authentication for public repository (you cannot use gh without authentication)
> -   [Built-in generation of pattern](https://github.com/devmatteini/dra#non-interactive) to select an asset to download (with gh you need to provide [glob pattern](https://cli.github.com/manual/gh_release_download) that you need to create manually).

#### [panscher](https://gist.github.com/panscher)** commented [on Oct 21, 2023](https://gist.github.com/steinwaywhw/a4cd19cda655b8249d908261a62687f8?permalink_comment_id=4734235#gistcomment-4734235)

[@flightlesstux](https://github.com/flightlesstux)

The download with NotpadPlus **x64.exe** does not work.

```bat
@echo off

setlocal enabledelayedexpansion  
set repo=notepad-plus-plus/notepad-plus-plus  
for /f "tokens=1,* delims=:" %%A in ('curl -ks [https://api.github.com/repos/%repo%/releases/latest](https://api.github.com/repos/%repo%/releases/latest) ^| find "browser_download_url"') do (  
call :download "%%B"  
)  
goto :eof

:download  
set "url=%~1"  
for %%i in (%url%) do set "filename=%%~~nxi"  
if "%filename:~~-9%"==".x64.exe" (  
curl -kOL %url%  
)  
goto :eof  
```


#### [TheRealMrWicked](https://gist.github.com/TheRealMrWicked)** commented [on Dec 16, 2023](https://gist.github.com/steinwaywhw/a4cd19cda655b8249d908261a62687f8?permalink_comment_id=4795468#gistcomment-4795468)

Here is a solution for Windows, you need to put the repo owner and name, as well as a string to identify the download, the generic version of the command is below.

```shell
for /f "tokens=1,* delims=:" %a in ('curl -s https://api.github.com/repos/<Put repo owner and repo name here>/releases/latest ^| findstr "browser_download_url" ^| findstr "<Put identifying string here>"') do (curl -kOL %b)
```

Example  
Putting the repo as **notepad-plus-plus/notepad-plus-plus** and the identifying string as **.x64.exe** we get this command:

```shell
for /f "tokens=1,* delims=:" %a in ('curl -s https://api.github.com/repos/notepad-plus-plus/notepad-plus-plus/releases/latest ^| findstr "browser_download_url" ^| findstr ".x64.exe"') do (curl -kOL %b)
```

Which downloads the latest x64 installer of Notepad++ to the current directory.

#### [Chuckame](https://gist.github.com/Chuckame)** commented [on Jan 22](https://gist.github.com/steinwaywhw/a4cd19cda655b8249d908261a62687f8?permalink_comment_id=4843419#gistcomment-4843419) • edited 

Here is the simplest way of getting the latest version with only `curl` and `basename`: Using the Forwarded url by github when accessing `/latest`:

```shell
basename $(curl -Ls -o /dev/null -w %{url_effective} https://github.com/<user>/<repo>/releases/latest)
```

Here another variant of it with only `curl` and a pure bash feature:

```shell
version=$(curl -Ls -o /dev/null -w %{url_effective} https://github.com/<user>/<repo>/releases/latest)
version=${version##*/}
```

#### [ivomarino](https://gist.github.com/ivomarino)** commented [on Feb 23](https://gist.github.com/steinwaywhw/a4cd19cda655b8249d908261a62687f8?permalink_comment_id=4932652#gistcomment-4932652)

> Here is the simplest way of getting the latest version with only `curl` and `basename`: Using the Forwarded url by github when accessing `/latest`:
> 
> ```shell
> basename $(curl -Ls -o /dev/null -w %{url_effective} https://github.com/<user>/<repo>/releases/latest)
> ```
> 
> Here another variant of it with only `curl` and a pure bash feature:
> 
> ```shell
> version=$(curl -Ls -o /dev/null -w %{url_effective} https://github.com/<user>/<repo>/releases/latest)
> version=${version##*/}
> ```

works great

#### [jessp01](https://gist.github.com/jessp01)** commented [on Mar 12](https://gist.github.com/steinwaywhw/a4cd19cda655b8249d908261a62687f8?permalink_comment_id=4984006#gistcomment-4984006) • edited 

Using `jq` to match a release file pattern (`modsecurity-v.*.tar.gz$` in this example):

```shell
curl -sL https://api.github.com/repos/owasp-modsecurity/ModSecurity/releases/latest| \
jq -r '.assets[] | select(.name? | match("modsecurity-v.*.tar.gz$")) | .browser_download_url'
```

#### [healBvdb](https://gist.github.com/healBvdb)** commented [on Mar 18](https://gist.github.com/steinwaywhw/a4cd19cda655b8249d908261a62687f8?permalink_comment_id=4991974#gistcomment-4991974)

Another simple command using the fantastic [Nushell](https://www.nushell.sh/)  
`http get https://api.github.com/repos/<user>/<repo>/releases/latest | get tag_name`

#### [JonnieCache](https://gist.github.com/JonnieCache)** commented [on May 22](https://gist.github.com/steinwaywhw/a4cd19cda655b8249d908261a62687f8?permalink_comment_id=5065212#gistcomment-5065212) • edited 

here's one for getting the tag name of the latest release:

```shell
curl -s https://api.github.com/repos/<REPO>/releases/latest | jq -r '.tag_name'
```

this is useful for cloning the latest release, eg. with asdf:

```shell
local asdf_version=$(curl -s https://api.github.com/repos/asdf-vm/asdf/releases/latest | jq -r '.tag_name')
git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch $asdf_version
```

#### [spvkgn](https://gist.github.com/spvkgn)** commented [on Jun 1](https://gist.github.com/steinwaywhw/a4cd19cda655b8249d908261a62687f8?permalink_comment_id=5075482#gistcomment-5075482) • edited 

wget one-liner to get release tarball and extract its contents:

```sh
wget -qO- 'https://api.github.com/repos/<REPO>/releases/latest' | jq -r '.assets[] | select(.name | match("tar.(gz|xz)")) | .browser_download_url' | xargs wget -qO- | bsdtar -xf -
```

#### [Samueru-sama](https://gist.github.com/Samueru-sama)** commented [on Jun 2](https://gist.github.com/steinwaywhw/a4cd19cda655b8249d908261a62687f8?permalink_comment_id=5076104#gistcomment-5076104)

Better alternative that will work even if the JSON is pretty or not:

```sh
curl -s https://api.github.com/repos/jgm/pandoc/releases/latest | sed 's/[()",{}]/ /g; s/ /\n/g' | grep "https.*releases/download.*deb"
```

Using `jq -c` to turn the JSON compact and this is what happens:

Old:

```sh
curl -s https://api.github.com/repos/jgm/pandoc/releases/latest \
| grep "browser_download_url.*deb" \
| cut -d : -f 2,3 \
| tr -d \"
 https://github.com/jgm/pandoc/releases/download/3.2/pandoc-3.2-1-amd64.deb
 https://github.com/jgm/pandoc/releases/download/3.2/pandoc-3.2-1-arm64.deb


curl -s https://api.github.com/repos/jgm/pandoc/releases/latest | jq -c \
| grep "browser_download_url.*deb" \
| cut -d : -f 2,3 \
| tr -d \"
https://api.github.com/repos/jgm/pandoc/releases/155373146,assets_url
```

Alternative:

```sh
curl -s https://api.github.com/repos/jgm/pandoc/releases/latest | sed 's/[()",{}]/ /g; s/ /\n/g' | grep "https.*releases/download.*deb"         
https://github.com/jgm/pandoc/releases/download/3.2/pandoc-3.2-1-amd64.deb
https://github.com/jgm/pandoc/releases/download/3.2/pandoc-3.2-1-arm64.deb

curl -s https://api.github.com/repos/jgm/pandoc/releases/latest | jq -c | sed 's/[()",{}]/ /g; s/ /\n/g' | grep "https.*releases/download.*deb"
https://github.com/jgm/pandoc/releases/download/3.2/pandoc-3.2-1-amd64.deb
https://github.com/jgm/pandoc/releases/download/3.2/pandoc-3.2-1-arm64.deb
```

Fedora 40 recently changed wget for wget2, and this causes github the send the json compact breaking scripts that were parsing it with grep.

I use gron when it is available, otherwise the sed tricks should work most of the time.

#### [motdotla](https://gist.github.com/motdotla)** commented [on Jun 19](https://gist.github.com/steinwaywhw/a4cd19cda655b8249d908261a62687f8?permalink_comment_id=5094164#gistcomment-5094164)

> This is it
> 
> ```shell
> wget https://github.com/aquasecurity/tfsec/releases/latest/download/tfsec-linux-amd64
> ```

this is the best solution. thank you [@joshjohanning](https://github.com/joshjohanning). everything else is unnecessarily complicated for users and could trip them up because of different shell versions and lack of installed libs like `jq`.

add in a bit of `uname` magic and all your users are good to go.

```sh
curl -L -o dotenvx.tar.gz "https://github.com/dotenvx/dotenvx/releases/latest/download/dotenvx-$(uname -s)-$(uname -m).tar.gz"
tar -xzf dotenvx.tar.gz
./dotenvx help
```

#### [bruteforks](https://gist.github.com/bruteforks)** commented [on Jun 22](https://gist.github.com/steinwaywhw/a4cd19cda655b8249d908261a62687f8?permalink_comment_id=5097031#gistcomment-5097031)

Since this gist is still very active, here's one I've made recently:

```sh
#!/usr/bin/env bash

# Fetch the latest release version
latest_version=$(curl -s https://api.github.com/repos/microsoft/vscode-js-debug/releases/latest | grep -oP '"tag_name": "\K(.*)(?=")')

# Remove the 'v' prefix from the version number
version=${latest_version#v}

# Construct the download URL
download_url="https://github.com/microsoft/vscode-js-debug/releases/download/${latest_version}/js-debug-dap-${latest_version}.tar.gz"

# Download the tar.gz file
curl -L -o "js-debug-dap-${version}.tar.gz" "$download_url"
```

#### [initiateit](https://gist.github.com/initiateit)** commented [last week](https://gist.github.com/steinwaywhw/a4cd19cda655b8249d908261a62687f8?permalink_comment_id=5124113#gistcomment-5124113) • edited 

Just curl and grep:

```sh
curl -s https://api.github.com/repos/caddyserver/xcaddy/releases/latest | grep '"browser_download_url":' | grep 'amd64.deb' | grep -vE '(\.pem|\.sig)' | grep -o 'https://[^"]*'
```

[https://github.com/caddyserver/xcaddy/releases/download/v0.4.2/xcaddy_0.4.2_linux_amd64.deb](https://github.com/caddyserver/xcaddy/releases/download/v0.4.2/xcaddy_0.4.2_linux_amd64.deb)

```sh
curl -s https://api.github.com/repos/aptly-dev/aptly/releases/latest | grep '"browser_download_url":' | grep 'amd64.deb' | grep -o 'https://[^"]*'
```

[https://github.com/aptly-dev/aptly/releases/download/v1.5.0/aptly_1.5.0_amd64.deb](https://github.com/aptly-dev/aptly/releases/download/v1.5.0/aptly_1.5.0_amd64.deb)

My apologies if it borrows from other answers.

#### [adriangalilea](https://gist.github.com/adriangalilea)** commented [3 days ago](https://gist.github.com/steinwaywhw/a4cd19cda655b8249d908261a62687f8?permalink_comment_id=5127228#gistcomment-5127228)

> [dra](https://github.com/devmatteini/dra) is making huge strides in simplifying the download process.

[@NiceGuyIT](https://github.com/NiceGuyIT) thanks for bringing it up.