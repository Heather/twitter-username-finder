Work in progress
----------------

[![Build Status](https://travis-ci.org/Heather/twitter-username-finder.png?branch=master)](https://travis-ci.org/Heather/twitter-username-finder)

<img align="left" src="http://i.imgur.com/bPwnkD9.jpg">

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
