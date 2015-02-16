Work in progress
----------------

[![Build Status](https://travis-ci.org/Heather/twitter-username-finder.png?branch=master)](https://travis-ci.org/Heather/twitter-username-finder)

``` racket
[twitter-search
(λ (username)
  (let* ([url (string-append twitterCheck username)]
         [resp (urlopen url)]
         [fromJson (string->jsexpr resp)]
         [strReason (hash-ref fromJson 'reason)]
         [msg (format "~a -> ~a" username strReason)]
         [zp (new horizontal-panel%
                  [parent group-box-panel]
                  [alignment '(left top)]
                  )])
    (make-object message% msg zp)
    (string=? strReason "available")))]
```
