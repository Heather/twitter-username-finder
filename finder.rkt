#lang racket/gui

(require net/url srfi/13
         net/http-client
         json)

(define-values (status header response) (http-sendrecv "httpbin.org" "/ip" #:ssl? 'tls))
(define ip (hash-ref (read-json response) 'origin))
(define (urlopen url)
  (let* ((input (get-pure-port (string->url url) #:redirections 5))
         (response (port->string input)))
    (close-input-port input)
    response))
(define append-only-text%
  (class text%
    (inherit last-position)
    (define/augment (can-insert? s l) (= s (last-position)))
    (define/augment (can-delete? s l) #f)
    (super-new)))

(define main (new (class frame% (super-new)
                    (define/augment (on-close)
                      (displayln "Bye")))
                  [label ip] [min-width 300]))

(define c (new editor-canvas% [parent main]
        [min-width 100] [min-height 300]))
(define t (new append-only-text%))
(send c set-editor t)

(let* ([twitterCheck "https://twitter.com/users/username_available?username="]
       [editBox (new text-field%
                     [label "Want"]
                     [parent main]
                     [init-value ""])]

       [twitter-search
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
            (send t insert msg) available))]
       
       [cycle 0]
       [trytime 0]
       [smart-twitter-search
        (λ (username)
          (define timer-counter 0)
          (unless (twitter-search username)
            (letrec ((recursive-twitter-search
                      (λ (username tch)
                        ;Logics:
                        (let* (;[strlen (string-length username)]
                               [test (match cycle
                                       [0 (let* ([username- (string-drop-right username 1)])
                                            (format "~a~a" username- tch)
                                           )]
                                       [_ (format "~a~a" username tch)]
                                       )]
                               [tchx (integer->char (+ 1 (char->integer tch)))])
                          (set! trytime (+ 1 trytime))
                          (cond
                            [(= trytime 5) (set! cycle 1)]
                            [(= trytime 10) (set! cycle 2)])
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
       
       [p (new horizontal-panel%
               [parent main]
               [alignment '(right top)])]
       
       [twitter (new button%
                    [parent p]
                    [label "Analyse"]
                    [callback (λ (btn evt)
           (smart-twitter-search (send editBox get-value)))])])

(send main show #t))
