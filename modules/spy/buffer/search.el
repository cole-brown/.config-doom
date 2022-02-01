;;; spy/buffer/search.el -*- lexical-binding: t; -*-

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
  (interactive "sSearch for: ")
  (let ((max-chars (or max-chars
                       sss:buffer/search.header/boundry))
         found-at-point)
    (save-mark-and-excursion
      (org-with-wide-buffer
       (goto-char (point-min))
       (setq found-at-point
             (search-forward
              ;; search string
              string

              ;; search boundry (characters/buffer position)
              max-chars

              ;; NOERROR:
              ;; - nil/default: fail w/ error msg
              ;; -           t: fail w/ nil return value
              ;; -       other: fail w/ nil & move point to boundry/end
              t))))

    ;; Return whatever we found, and if called interactively, also message it.
    (when (called-interactively-p)
        (if found-at-point
            (message "Found \"%s\" at buffer position: %d"
                     string found-at-point)
          (message "No \"%s\" in buffer's first %d chars."
                   string max-chars)))
    found-at-point))


;;------------------------------------------------------------------------------
;; The End.
;;------------------------------------------------------------------------------
(imp:provide :modules 'spy 'buffer 'search)
