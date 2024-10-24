How to create a portable windows application without an installer from an electron project:

1. Clone the electron-quick-start repo:
```bash
git clone https://github.com/electron/electron-quick-start
``` 
2. yarn
3. Make your application - probably edit main.js to navigate to some URL
4. yarn add electron-packager
3. Edit package.json - update the 'name' and add a new script 'packager':
```javascript
{
  "name": "my-app-name",
  ...
  "scripts": {
	"start": "electron .",
    "packager": "electron-packager ./ --platform=win32"
  }
}
```

4. 'npm start' will bring up the application
5. 'npm run packager' will package the app for windows. You will see a new directory 'my-app-name-win32-x64' in the top directory of the project, with a my-app-name.exe