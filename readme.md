# sitegen
This is the site generator I built for [https://frogulis.net](https://frogulis.net).

I wouldn't recommend it for anything important!

How to use:
1. Install Racket (duh)
2. Put a `definitions.rkt` in your source directory
3. Navigate to the directory with `definitions.rkt`
4. Run `racket [...]/sitegen.rkt`

The output will be put in `[working dir]/output/`.

Here's an example `definitions.rkt`:
```racket
#lang racket

; the important part - these will be imported by sitegen and used to build the site
(provide page-definitions metadata)

(define metadata (hash 'author "John Doe" 'domain "https://example.net/"))

; just a plain old variable
(define css-files (list "/styles/my.css"))

; a list of directives
; gen (path, title, css-file-paths) -> generate HTML from [path].md
; copy-dir -> copy specified directory directly from source to output
; copy -> copy specified file from source to output
(define page-definitions
  (list (hash 'type 'path "index" 'title "Home" 'css-files ,css-files)
        ; if title, feed-id, and updated are all included, this file will be included in the generated atom `feed.xml`
        (hash 'type 'gen 'path "writing/opinions" 'title "I'm full of opinions!" 'css-files ,css-files 'feed-id "perma-id1234" 'updated "2026-01-12T21:34:20")
        (hash 'type 'copy-dir 'path "writing/images/" feed-id "perma-id5678" 'updated "1999-12-31T23:59:59")
        (hash 'type 'copy 'path "favicon.ico")
        (hash 'type 'copy-dir 'path "styles/")))
```