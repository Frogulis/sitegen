#lang racket

(require xml)

(provide render-feed
         feed-outer
         feed-entry)

; (define (render-feed entries)
;   (apply string-append
;          (flatten (list '("<?xml version=\"1.0\" encoding=\"utf-8\"?>"
;                           "<feed xmlns=\"http://www.w3.org/2005/Atom\">"
;                           "<title>Frogulis</title>"
;                           "<link href=\"xxx\" />"
;                           "<author><name>Jamie Hoffmann</name></author>")
;                         (map (lambda (entry)
;                                (string-append
;                                 "<entry>"
;                                 (string-append "<id>" (hash-ref entry 'feed-id) "</id>")
;                                 (string-append "<title>" (hash-ref entry 'title) "</title>")
;                                 "</entry>"))
;                              entries)
;                         '("</feed>")))))

(define (render-feed doc)
  (define out (open-output-string))
  (display-xml/content (xexpr->xml doc) out)
  (string-append "<?xml version=\"1.0\" encoding=\"UTF-8\"?>" (get-output-string out)))

(define (feed-outer metadata entries)
  `(feed ([xmlns "http://www.w3.org/2005/Atom"])
         (title "Frogulis")
         (link ([href ,(hash-ref metadata 'domain)]))
         (author ,(hash-ref metadata 'author))
         (unquote-splicing entries)))

(define (feed-entry metadata datum)
  `(entry (title ,(hash-ref datum 'title))
          (id ,(hash-ref datum 'feed-id))
          (updated ,(hash-ref datum 'updated))
          ;; excluding content for now... not sure if it works, not sure if i want it
          ;   (unquote-splicing
          ;    (if (hash-has-key? datum 'content)
          ;        (list `(content ((type "html")) ,(xml-attribute-encode (hash-ref datum 'content))))
          ;        '()))
          (link ([rel "alternate"]
                 [href ,(string-append (hash-ref metadata 'domain) (hash-ref datum 'path))]))))
