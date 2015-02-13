#lang racket/gui

(require net/url
         net/http-client
         json)

(define-values (status header response) (http-sendrecv "httpbin.org" "/ip" #:ssl? 'tls))
(define ip (hash-ref (read-json response) 'origin))
(define (urlopen url)
  (let* ((input (get-pure-port (string->url url) #:redirections 5))
         (response (port->string input)))
    (close-input-port input)
    response))

(let* ([twitterCheck "https://twitter.com/users/username_available?username="]
       [main (new (class frame% (super-new)
                 (define/augment (on-close)
                   (displayln "Bye")))
               [label ip] [min-width 300])]
       
       [editBox (new text-field%
                     [label "Want"]
                     [parent main]
                     [init-value ""])]
       
       [group-box-panel (new group-box-panel%
                             [parent main] [label "Log:"]
                             [min-width 100] [min-height 300])]
       
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
       
       [trytime 0]
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
       
       ;TODO: replace it with something alike console maybe
       [p (new horizontal-panel%
               [parent main]
               [alignment '(right top)])]
       
       [twitter (new button%
                    [parent p]
                    [label "Analyse"]
                    [callback (λ (btn evt)
           (smart-twitter-search (send editBox get-value)))])])

(send main show #t))
