Kw to help searching: 成对符号 成对 居中光标 居中 符号

Since I didn't use Windows and then AHK much, here I keep comments and reference links to help those similar to me.

Originally, I [followed this issue link](https://github.com/hchunhui/librime-lua/issues/84#issuecomment-1124694033) which is referred to in rime-fast-xhup. 

Firstly, I use pure lua to implement this, but [the `Left` key seems to be not manipulated in librime](https://github.com/hchunhui/librime-lua/issues/84#issuecomment-2044285312).

---

Secondly I tried use `os.execute`, but it will always pop one cmd window. Although we can avoid by [using `wscript.shell`](https://stackoverflow.com/a/20505107/21294350) 

Notice `wscript.shell` in lua needs `luacom` which is not maintained for a long time. See [this](https://github.com/davidm/luacom/issues/18#issuecomment-315681756) and [this luarocks for x86](https://luarocks.org/modules/sci-42ver/luacom_x86) for how to install it. 
- Here I use weasel 0.15.0 which is x86 and compatible with my installed win11. Weasel lastest x64 will crash on my computer. I didn't digest to find the reasons. So I installed x86 luacom and also obviously x86 lua54. (You can use namke or msys2 related packages which is used by librime workflow to compile.)

Then I use [one powershell script](https://superuser.com/a/1462429/1658455) to send keys. But actually they are much slower than AHK. I  didn't recommend using lua to create such one sequence of calls just for sending one key sequence. This is same as [the recommendation by shewer](https://github.com/hchunhui/librime-lua/issues/84#issuecomment-756073730) who is one really helpful man (Thanks for your very enthusiastic help in librime-lua).

---

The similar AHK script can be also seen in [this issue comment](https://github.com/rime/home/issues/485#issuecomment-653695296). This issue is not searched until I finished the above AHK script, tried sharing my method to help others and searched the reference issue link. Whoo, time wasted unnecessarily ...