;;; spy/buffer/+search.el -*- lexical-binding: t; -*-

;;------------------------------------------------------------------------------
;; Constants
;;------------------------------------------------------------------------------

(defconst sss:buffer/search.header/boundry 1000
  "Buffer position boundry for `spy:cmd:buffer/search.header'.")

;;------------------------------------------------------------------------------
;; Buffer Searching Functions
;;------------------------------------------------------------------------------

(defun spy:cmd:buffer/search.header (string &optional max-chars)
  "Searches for STRING in the first MAX-CHARS of the buffer.

If MAX-CHARS is nil, use `sss:buffer/search.header/boundry'.
"
  (interactive "s")
  (search-forward
     ;; search string
     string

     ;; search boundry (characters/buffer position)
     (or max-chars
         sss:buffer/search.header/boundry)

     ;; NOERROR:
     ;; - nil/default: fail w/ error msg
     ;; -           t: fail w/ nil return value
     ;; -       other: fail w/ nil & move point to boundry/end
     t))


;;------------------------------------------------------------------------------
;; The End.
;;------------------------------------------------------------------------------
(imp:provide :modules 'spy 'buffer 'search)
