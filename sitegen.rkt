#lang racket

(require struct-update)
(require "shared.rkt")
(require "templates.rkt")
(require "file-io.rkt")

(define-struct-updaters page)

(define (get-page-with-content p)
  (cond
    [(not (and (page? p) (string? (page-key p)))) (optional #f "Not a valid page")]
    [else (optional #t (cons p (parse-markdown-file (string-append (page-key p) ".md"))))]))

(define (build-page p)
  (cons (page-key p) (chain-bind-opt p get-page-with-content default-template)))

; main
(define page-definitions (dynamic-require "definitions.rkt" 'page-definitions))

(create-required-directories page-definitions)

(define copy-page-definitions
  (filter (lambda (p) (or (equal? 'copy (hash-ref p 'type)) (equal? 'copy-dir (hash-ref p 'type))))
          page-definitions))

(define gen-page-definitions (filter (lambda (p) (equal? 'gen (hash-ref p 'type))) page-definitions))
(define gen-pages (map (lambda (p) (apply page (hash-ref p 'config))) gen-page-definitions))
(define page-pairs (map build-page gen-pages))
(define success-pages (filter (lambda (page-pair) (optional-success? (cdr page-pair))) page-pairs))
(define failed-pages
  (filter (lambda (page-pair) (not (optional-success? (cdr page-pair)))) page-pairs))

(for-each (lambda (p)
            (begin
              (displayln (string-append "Writing generated page with key: " (car p)))
              (write-generated-page p)))
          success-pages)

(for-each (lambda (p)
            (begin
              (displayln (string-append "Copying: " (hash-ref p 'path)))
              (cond
                [(equal? (hash-ref p 'type) 'copy) (copy-page (hash-ref p 'path))]
                [(equal? (hash-ref p 'type) 'copy-dir) (copy-dir (hash-ref p 'path))])))
          copy-page-definitions)

(when (not (empty? failed-pages))
  (begin
    (displayln "\nError messages:")
    (for-each (lambda (failed-page) (displayln (optional-result (cdr failed-page)))) failed-pages)))
