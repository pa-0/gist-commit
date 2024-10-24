// ==UserScript==
// @name         Git Archive
// @namespace    http://wingysam.xyz/
// @version      2.4
// @description  Mirror every git repo you look at to gitea
// @author       Wingy <git@wingysam.xyz>
// @include      *
// @grant        GM_xmlhttpRequest
// @grant        GM_notification
// @grant        GM_openInTab
// ==/UserScript==

(async function() {
    'use strict';

    const GITEA_TOKEN = 'token xyz'
    const GITEA_URL = ''
    const GITEA_REPO_OWNER = ''
    const GIT_LS_REMOTE = ''

    function http(url, opts) {
        return new Promise((resolve, reject) => {
            GM_xmlhttpRequest({
                url,
                ...opts,
                onload: resolve,
                onerrror: reject
            })
        })
    }

    function safeify(string) {
        return Array.from(string).map(char => 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789./'.includes(char) ? char : '_').join('').split('/').join('-').split('.git').join('_git')
    }

    async function mirror(url, id) {
        const gitea = await http(GITEA_URL + '/api/v1/repos/migrate', {
            method: 'POST',
            headers: {
                'Authorization': GITEA_TOKEN,
                'Content-Type': 'application/json'
            },
            data: JSON.stringify({
                clone_addr: url,
                description: '',
                issues: true,
                labels: true,
                milestones: true,
                mirror: true,
                private: true,
                pull_requests: true,
                releases: true,
                repo_name: id,
                repo_owner: GITEA_REPO_OWNER,
                service: "git",
                uid: 0,
                wiki: true
            })
        })

        console.log('Gitea responded, result:', gitea)
        if (gitea.statusText !== 'Created') return
        const json = JSON.parse(gitea.responseText)
        GM_notification({
            title: 'Git Archiver',
            text: `Archived ${id}`,
            timeout: 5000,
            onclick: () => GM_openInTab(json.html_url, {
                active: true,
                insert: true,
                setParent: true
            })
        })
    }

    (async () => {
        const url = document.location.origin + document.location.pathname
        const id = safeify(url.split('//').reverse()[0])

        console.log('Checking if this is a git repo...')
        const lsRemote = await http(GIT_LS_REMOTE + '?url=' + encodeURIComponent(url))
        console.log({lsRemote})

        const { empty } = JSON.parse(lsRemote.responseText)
        if (empty) return console.log('Appears to not be a git repo.')
        console.log('Appears to be a git repo, attempting mirror.')

        await mirror(url, id)
    })()
})();