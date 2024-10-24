#!/usr/bin/env python3
from os import mkdir, chdir
from os.path import exists, isdir
from os.path import join as joinpath
import datetime
now = datetime.datetime.now
from github import Github
from git import Repo


def datetimetostr(date):
    return '{:%Y-%m-%d %H-%M}'.format( date )


class GithubBackup():

    def write_log(self, string, level=0, echo=1):
        '''
        Write to logfile in `outputdir`

        Levels
        ======
        0 : info
        1 : warning
        2 : error
        '''

        if echo:
            print(string)
        with open(f'{datetimetostr(self.time)}.log', 'a') as logfile:
            levelstring = ['INFO', 'WARNING', 'ERROR'][level]
            print( f'[{levelstring}]', datetimetostr(now()), string, file=logfile )


    def __init__(self):
        # config
        self.outputdir = 'github-backup'
        self.token = 'TOKEN HERE'

        if exists(self.outputdir):
            if not isdir(self.outputdir):
                self.write_log(
                    'Output directory inaccessible, a file has that name', 2, 0)
                raise Exception(
                    'Output directory inaccessible, a file has that name')
        else:
            mkdir(self.outputdir)
        chdir(self.outputdir)

        self.github = Github(self.token).get_user()

        self.time = now()
        self.write_log(f'Starting GitHub backup for user {self.github.login}')


    def get_repos(self):
        if not exists('repos'):
            mkdir('repos')

        repos = self.github.get_repos()

        for repo in repos :
            self.write_log( f'Cloning repo {repo.full_name}' )
            Repo.clone_from(
                f'https://{self.token}:x-oauth-basic@github.com/{repo.full_name}',
                joinpath('repos', repo.name),
                bare=True
            )

    def get_gists(self):
        if not exists('gists'):
            mkdir('gists')

        gists = self.github.get_gists()

        for gist in gists :
            self.write_log( f'Cloning gist {gist.id}' )
            Repo.clone_from(
                f'https://gist.github.com/{self.github.login}/{gist.id}',
                joinpath('gists', gist.id)
            )



if __name__ == '__main__' :

    githubBackup = GithubBackup()
    githubBackup.get_repos()
    githubBackup.get_gists()
