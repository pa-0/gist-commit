**Update!**

I just found [`rclone`](https://rclone.org/), which seems to do what my script does, and more:
- No need to set up sharing a particular way
- Won't time out, you can just leave it running until it's done
- Seems to run much much faster
- Keeps modified times on files the same

The only drawback is that it takes a bit longer to setup.

Steps:

1. Install `rclone`. On Mac: `brew install rclone`

2. Set up your Google Drive accounts: Type  `rclone config` and follow the instructions. The instructions are long but each step is simple.
   - Add a config for your personal Google Drive called `drive-personal`.
   - Add a config for your school Google Drive called `drive-school`.

3. But then THAT'S IT! You can now run something like:

   ```
   rclone -v copyto --drive-server-side-across-configs --drive-copy-shortcut-content \
         drive-school:'' \
         drive-personal:'Copied from school GDrive via rclone'
   ```
   
   to copy your entire school Drive into a folder in your personal Drive.

If you use `rclone`, you can ignore the rest of this post.

---

My orignal script is still included below in case you have a special use case and still need it:
