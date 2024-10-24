Usually PortableApps installs its packages in X:\PortableApps
and the updater cares them.
You can add any folder into it as well but they are not 
under the control of PortableApps.
This is a tool to detect folders not taken care by PortableApps updater.

# How to use 

```
git clone git@gist.github.com:e01605e8b934eb26ee60b4dbab10d0bd.git check-portableapps
cd check-portableapps
make ROOT=/drive/p/PortableApps
```
