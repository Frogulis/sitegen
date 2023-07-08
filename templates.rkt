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
    (cond
      [(not (page? p)) (optional #f "Provided page definition is invalid")]
      [else
       (optional
        #t
        `(html ((lang "en"))
               (head (meta ((name "viewport") (content "width=device-width, initial-scale=1")))
                     (title (unquote (page-title p)))
                     (unquote-splicing (css-links (page-css-paths p))))
               (body (header (a ((href "/")) (img ((src "/favicon.ico") (alt "Return home"))))
                             (h1 (unquote (page-title p))))
                     (main (unquote-splicing content)
                           (object ((type "image/png")
                                    (data (unquote (statsbild-path (page-key p))))))))))])))
