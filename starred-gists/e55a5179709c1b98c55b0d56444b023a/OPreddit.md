# [OP's Reddit Post](https://redd.it/mcjj4s) (revised)
A user yesterday [wanted a specific voice][^1] out of text-to-speech, but he wanted one from a web version and not included in the OS (*ie*, there was the need to scrape the page). Thus...

## WinHttpRequest Wrapper ([v2.0][^2] / [v1.1][^3])

There's no standardized method to make HTTP requests, basically, we have:

* `XMLHTTP`.
* `WinHttpRequest`.
* `UrlDownloadToFile`.
* Complex `DllCall()`s.

`Download()`/`UrlDownloadToFile` are super-limited, unless you ***know*** you need to use it, `XMLHTTP` should be avoided; and `DllCall()` is on the advanced spectrum as is basically what you'll do in C++ with `wininet.dll`/`urlmon.dll`. That leaves us with `WinHttpRequest` for which I didn't find a nice wrapper around the object (years ago, maybe now there is) and most importantly, no 7-bit binary encoding support for multipart when dealing with uploads or big `PATCH`/`POST`/`PUT` requests. So, here's my take.

It will help with services and even for scraping (use the APIs if exist). The highlights or main benefits against other methods:

* Follows redirects.
* Automatic cookie handling.
* It has convenience static methods.
* Can ignore SSL errors, and handles all TLS versions.
* Returns request headers, JSON, status, and text.
  * The JSON representation is lazily-loaded upon request.
* The result of the call can be saved into a file (*ie* download).
* The MIME type (when uploading) is controlled by the `MIME` subclass.
  * Extend it if needed (I've never used anything other than what's there, but YMMV).
* The MIME boundary is 40 chars long, making it compatible with cURL.
  * If you use the appropriate UA length, the request will be the same size as one made by cURL.

### Convenience static methods

Equivalent to JavaScript:

```autohotkey
    WinHttpRequest.EncodeURI(sUri)
    WinHttpRequest.EncodeURIComponent(sComponent)
    WinHttpRequest.DecodeURI(sUri)
    WinHttpRequest.DecodeURIComponent(sComponent)
```
AHK key/pair map (object for v1.1) to URL query (`key1=val1&key2=val2`) and *vice versa*:

```autohotkey
    WinHttpRequest.ObjToQuery(oData)
    WinHttpRequest.QueryToObj(sData)
```
### Calling the object

Creating an instance:

```autohotkey
    http := WinHttpRequest(oOptions)
```

The COM object is exposed via the `.whr` property:

```autohotkey
    MsgBox(http.whr.Option(2), "URL Code Page", 0x40040)
    ; https://learn.microsoft.com/en-us/windows/win32/winhttp/winhttprequestoption
```

Options:

    oOptions := <Map>              ;                Options is a Map (object for v1.1)
    oOptions["Proxy"] := false     ;                Default. Use system settings
                                   ; "DIRECT"       Direct connection
                                   ; "proxy[:port]" Custom-defined proxy, same rules as system proxy
    oOptions["Revocation"] := true ;                Default. Check for certificate revocation
                                   ; false          Do not check
    oOptions["SslError"] := true   ;                Default. Validation of SSL handshake/certificate
                                   ; false          Ignore all SSL warnings/errors
    oOptions["TLS"] := ""          ;                Defaults to TLS 1.2/1.3
                                   ; <Int>          https://support.microsoft.com/en-us/topic/update-to-enable-tls-1-1-and-tls-1-2-as-default-secure-protocols-in-winhttp-in-windows-c4bd73d2-31d7-761e-0178-11268bb10392
    oOptions["UA"] := ""           ;                If defined, uses a custom User-Agent string

**Returns:**

```autohotkey
    response := http.VERB(...) ; Object
    response.Headers := <Map>  ; Key/value Map (object for v1.1)
    response.Json := <Json>    ; JSON object
    response.Status := <Int>   ; HTTP status code
    response.Text := ""        ; Plain text response
```

<details>
  <summary>
   Methods
  </summary>

### HTTP verbs as public methods

```autohotkey
    http.DELETE()
    http.GET()
    http.HEAD()
    http.OPTIONS()
    http.PATCH()
    http.POST()
    http.PUT()
    http.TRACE()
```
 
All the HTTP verbs use the same parameters:

    sUrl     = Required, string.
    mBody    = Optional, mixed. String or key/value map (object for v1.1).
    oHeaders = Optional, key/value map (object for v1.1). HTTP headers and their values.
    oOptions = Optional. key/value map (object for v1.1) as specified below:

    oOptions["Encoding"] := ""     ;       Defaults to `UTF-8`.
    oOptions["Multipart"] := false ;       Default. Uses `application/x-www-form-urlencoded` for POST.
                                   ; true  Force usage of `multipart/form-data` for POST.
    oOptions["Save"] := ""         ;       A file path to store the response of the call.
                                   ;       (Prepend an asterisk to save even non-200 status codes)

</details>
  
<details>
  <summary>
    Examples
  </summary>
  
**GET:**

```autohotkey
    endpoint := "http://httpbin.org/get?key1=val1&key2=val2"
    response := http.GET(endpoint)
    MsgBox(response.Text, "GET", 0x40040)
```
 
    ; or

```autohotkey
    endpoint := "http://httpbin.org/get"
    body := "key1=val1&key2=val2"
    response := http.GET(endpoint, body)
    MsgBox(response.Text, "GET", 0x40040)
```
 
    ; or

```autohotkey
    endpoint := "http://httpbin.org/get"
    body := Map()
    body["key1"] := "val1"
    body["key2"] := "val2"
    response := http.GET(endpoint, body)
    MsgBox(response.Text, "GET", 0x40040)
```
 
**POST**, regular:

```autohotkey
    endpoint := "http://httpbin.org/post"
    body := Map("key1", "val1", "key2", "val2")
    response := http.POST(endpoint, body)
    MsgBox(response.Text, "POST", 0x40040)
```
 
**POST**, force multipart (for big payloads):

```autohotkey
    endpoint := "http://httpbin.org/post"
    body := Map()
    body["key1"] := "val1"
    body["key2"] := "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."
    options := {Multipart:true}
    response := http.POST(endpoint, body, , options)
    MsgBox(response.Text, "POST", 0x40040)
```
 
**HEAD**, retrieve a specific header:

```autohotkey
    endpoint := "https://github.com/"
    response := http.HEAD(endpoint)
    MsgBox(response.Headers["X-GitHub-Request-Id"], "HEAD", 0x40040)
```
 
**Download** the response (it handles binary data):

```autohotkey
    endpoint := "https://www.google.com/favicon.ico"
    options := Map("Save", A_Temp "\google.ico")
    http.GET(endpoint, , , options)
    RunWait(A_Temp "\google.ico")
    FileDelete(A_Temp "\google.ico")
```
 
To **upload** files, put the paths inside an array:

```autohotkey
    ; Image credit: http://probablyprogramming.com/2009/03/15/the-tiniest-gif-ever
    Download("http://probablyprogramming.com/wp-content/uploads/2009/03/handtinyblack.gif", A_Temp "\1x1.gif")

    endpoint := "http://httpbun.org/anything"
    ; Single file
    body := Map("test", 123, "my_image", [A_Temp "\1x1.gif"])
    ; Multiple files (PHP server style)
    ; body := Map("test", 123, "my_image[]", [A_Temp "\1x1.gif", A_Temp "\1x1.gif"])
    headers := Map()
    headers["Accept"] := "application/json"
    response := http.POST(endpoint, body, headers)
    MsgBox(response.Json.files.my_image, "Upload", 0x40040)
```
 
</details>

<details>
  <summary>Notes</summary>

1\. Use G33kDude's [cJson.ahk][^4] as the JSON library because it has boolean/`null` support, however others can be used.

2\. Even if I said that `DllCall()` was on the advanced side of things, is better suited to download big files. Regardless if the wrapper supports saving a file, doesn't mean is meant to act as a downloader because the memory usage is considerable (the size of the file needs to be allocated in memory, so a 1 GiB file will need the same amount of memory).

3\. [Joe Glines](https://www.reddit.com/u/joetazz) did a [talk on the subject][^5], if you want a high-level overview about it.

4\. You just need to drop it in [a library][^6] and start using it.
</details>

[^1]: https://redd.it/mbpwf7
[^2]: https://gist.github.com/anonymous1184/e6062286ac7f4c35b612d3a53535cc2a/raw/WinHttpRequest.ahk
[^3]: https://gist.github.com/anonymous1184/e6062286ac7f4c35b612d3a53535cc2a/raw/WinHttpRequest-deprecated.ahk
[^4]: https://github.com/G33kDude/cJson.ahk
[^5]: https://youtu.be/fzfJCLeEWfQ
[^6]: https://www.autohotkey.com/docs/Functions.htm#lib