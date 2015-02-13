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
[smart-twitter-search
(λ (username)
  (define timer-counter 0)
  (unless (twitter-search username)
    (letrec ((recursive-twitter-search
              (λ (username tch)
                ;Logics:
                ; - Add characters
                ; - Replace characters
                ; - ...
                (let* ([test (format "~a~a" username tch)]
                       [tchx (integer->char (+ 1 (char->integer tch)))])
                  (set! trytime (+ 1 trytime))
                  (unless (or (twitter-search test) (> trytime 10))
                    (define timer
                      (new timer%
                           (notify-callback
                            (lambda ()
                              (cond [(< timer-counter 5)
                                     (set! timer-counter (add1 timer-counter))]
                                    [else
                                     (send timer stop)
                                     (set! timer-counter 0)
                                     (recursive-twitter-search username tchx)
                                     ])))))
                    (send timer start 100))))))
      (recursive-twitter-search username #\a))))]
```
