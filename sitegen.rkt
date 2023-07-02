#lang racket

(require markdown)
(require struct-update)
(require (only-in xml display-xml/content xexpr->xml xexpr?))
(require "shared.rkt")
(require "templates.rkt")
(require "definitions.rkt")

(define-struct-updaters page)

(define (parse-markdown-file file-name)
  (parse-markdown (file->string file-name)))

(define (populate-content p)
  (cond
    [(not (page? p)) (optional #f "Not a valid page")]
    [(string? (page-content p))
     (optional #t (page-content-set p (parse-markdown-file (page-content p))))]
    [else (optional #t p)]))

(define (build-page p)
  (cons (page-key p) (chain-bind-opt p populate-content default-template)))

(define (write-page p)
  (define out (open-output-file (string-append "output/" (car p) ".html") #:exists 'truncate/replace))
  (display-xml/content (xexpr->xml (optional-result (cdr p))) out #:indentation 'peek)
  (close-output-port out))

; main
(define page-pairs (map build-page page-definitions))
(define success-pages
  (filter (lambda (page-response) (optional-success? (cdr page-response))) page-pairs))
(define failed-pages
  (filter (lambda (page-response) (not (optional-success? (cdr page-response)))) page-pairs))

(for-each write-page success-pages)

(displayln "\nError messages:")
(for-each (lambda (failed-page) (displayln (optional-result failed-page))) failed-pages)
