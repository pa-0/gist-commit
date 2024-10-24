# Simple automated GIT Deployment using GIT Hooks

Here are the simple steps needed to create a deployment from your local GIT repository to a server based on [this](https://www.digitalocean.com/community/tutorials/how-to-use-git-hooks-to-automate-development-and-deployment-tasks) in-depth 
tutorial.

## How it works

You are developing in a working-copy on your local machine, lets say on the master branch. Most of the time, people would push code to a remote
server like github.com or gitlab.com and pull or export it to a production server. Or you use a service like [deepl.io](https://deepl.io.noelboss.com) to act upon a Web-Hook that's triggered that service.

But here, we add a "bare" git repository that we create on the production server and pusblish our branch (f.e. master) directly to that
server. This repository acts upon the push event using a 'git-hook' to move the files into a deployment directory on your server. No need for a midle man.

This creates a scenario where there is no middle man, high security with encrypted communication (using ssh keys, only authorized people get access to the server)
and high flexibility tue to the use of .sh scripts for the deployment.

# Prerequisit
1. Know how to use GIT, Terminal etc.
2. Have a local working-working copy ready
2. Have SSH access to your server using private/public key

# Todos
1. Create a folder to deploy to on production server (i.e. your httpds folder)
2. Add a bare repository on the productions server
4. Add the post-receive hook script to the bare repository (and make it executable)
5. Add the remote-repository resided on the production server to your local repository
6. Push to the production server, relax.

## 1. Have a local working-working copy ready
Nuf said. I asume we are working on master – but you could work on any branch.

## 2. Create a folder to deploy to
ssh into your prodctionserver:

    $ ssh user@server.com
    $ mkdir ~/deploy-folder
    
## 3. Add a bare repository on the productions server
Now we create a "bare" repository – one that does not contain the working copy files. It basicaly is the content of the .git repository folder in a normal working copy. Name it whatever you like, you can also ommit the .git part from project.git or leave it to create the repository in an exisiting empty folder:

    $ git init --bare ~/project.git
  
## 4. Add the post-receive hook script
This scrtipt is executed when the push from the local machine has been completed and moves the files into place. It recides in project.git/hooks/ and is named 'post-receive'. You can use vim to edit and create it. The script does check if the correct branch is pushed (not deploying a develop branch for example). You can download a sample [post-receive](#file-post-receive) script below. Also, don't forget to add execute permissions to said script;
    
    chmod +x post-receive

## 5. Add remote-repository localy 
Now we add the this bare repository to your local system as a remote. Where "production" is the name you want to give the remote. This also be called "staging" or "live" or "test" etc if you want to deploy to a different system or multiple systems.
  
    $ cd ~/path/to/working-copy/
    $ git remote add production demo@yourserver.com:project.git
  
Make sure "project.git" coresponds to the name you gave in step 3. If you are using Tower or a similar App, you will see the newly added remote in your sidebar under "Remotes" (make sure it's not collapsed).

## 6. Push to the production server
Now you can push the master branch to the production server:

    $ git push production master
  
If you are using tower, you can drag&drop the master branch onto the new production remote. That's it. Have questions, improvements?

(c) [Noevu Schweizer KMU Webseiten](https://www.noevu.ch/#entwicklung)