#lang racket
(provide default-template)

(require "shared.rkt")

(define (statsbild-path s)
  (string-append "/statsbild/" s))

(define (css-links css-paths)
  (map (lambda (css-path) `(link ((rel "stylesheet") (href (unquote css-path)) (type "text/css"))))
       css-paths))

(define (default-template page-with-content)
  (let ([p (car page-with-content)] [content (cdr page-with-content)])
    (optional #t
              `(html ((lang "en"))
                     (head (meta ((name "viewport") (content "width=device-width, initial-scale=1")))
                           (title (unquote (hash-ref p 'title)))
                           (unquote-splicing (css-links (hash-ref p 'css-files)))
                           (link ((rel "alternate") (type "application/atom+xml") (href "feed.xml"))))
                     (body (header (a ((href "/")) (img ((src "/favicon.ico") (alt "Return home"))))
                                   (h1 (unquote (hash-ref p 'title))))
                           (main (unquote-splicing content)
                                 (object ((type "image/png")
                                          (data (unquote (statsbild-path (hash-ref p 'path))))))))))))
