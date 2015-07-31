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
                  [label ip] [min-width 300]
                  [stretchable-width #f]
                  [stretchable-height #f]))

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
       
       [trytime 0]
       
       ;Add character method (last cycle)
       [addMethod
        (λ (username tch)
          (format "~a~a" username tch)
          )]
       
       ;Replace character method (cycle 0)
       [replaceDepth 1]
       [replaceMethod
        (λ (username tch)
          (define strlen (string-length username))
          (when (= trytime 26)
            (set! replaceDepth 2))
          (let* ([username- (string-drop-right username replaceDepth)])
            (format "~a~a" username- tch))
          )]
       
       ;Main processor
       [smart-twitter-search
        (λ (username)
          (define timer-counter 0)
          (define lchars (integer->char (- (char->integer #\a) 1)))
          (unless (twitter-search username)
            (letrec 
                ((recursive-twitter-search
                  (λ (username tch cycle)
                    ;Logics:
                    (let* (;[strlen (string-length username)]
                           [test ((match cycle
                                    [0 replaceMethod]
                                    [_ addMethod]
                                    ) username tch)]
                           [tchx (integer->char (+ 1 (char->integer tch)))])
                      (set! trytime (+ 1 trytime))
                      (unless (or (twitter-search test)                           
                                  (cond
                                    [(or (= trytime 26)
                                         (= trytime (* 2 26))) 
                                     (recursive-twitter-search username #\a 1) #t]
                                    [(and (>= trytime (* 3 26))
                                          (<= trytime (* (+ 3 26) 26))
                                          (= (modulo trytime 26) 0))
                                     (define username- 
                                       (cond 
                                         [(= trytime (* 3 26)) username]
                                         [else (string-drop-right username 1)]))
                                     (set! lchars (integer->char (+ 1 (char->integer lchars))))
                                     (define u (addMethod username- lchars))
                                     (recursive-twitter-search u #\a 1) #t]
                                    [(= trytime (* (+ 4 26) 26)) #t]; End
                                    [else #f]))
                        (define timer
                          (new timer%
                               (notify-callback
                                (lambda ()
                                  (cond [(< timer-counter 1)
                                         (set! timer-counter (add1 timer-counter))]
                                        [else
                                         (send timer stop)
                                         (set! timer-counter 0)
                                         (recursive-twitter-search username tchx cycle)
                                         ])))))
                        (send timer start 100))))))
              (recursive-twitter-search username #\a 0))))]
       
       [p (new horizontal-panel%
               [parent main]
               [alignment '(right top)])]
       
       [twitter (new button%
                     [parent p]
                     [label "Analyse"]
                     [callback (λ (btn evt)
                                 (smart-twitter-search (send editBox get-value)))])])
  
  (send main show #t))
