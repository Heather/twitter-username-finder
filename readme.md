Work in progress
----------------

[![Build Status](https://travis-ci.org/Heather/twitter-username-finder.png?branch=master)](https://travis-ci.org/Heather/twitter-username-finder)

![](http://fc04.deviantart.net/fs70/f/2012/022/5/9/twin_render_by_kaminaridecode-d4nb45q.png)

``` racket
(λ (username)
  (let* ([url (string-append twitterCheck username)]
         [resp (urlopen url)]
         [fromJson (string->jsexpr resp)]
         [strReason (hash-ref fromJson 'reason)]
         [available (string=? strReason "available")]
         [msg (format "~a -> ~a\n" username strReason)])
    (send t change-style 
      (make-object style-delta% 'change-weight
        (if available
            'bold
            'normal)))
    (send t insert msg) available))
```


