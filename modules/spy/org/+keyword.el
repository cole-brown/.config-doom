;;; spy/org/keyword.el -*- lexical-binding: t; -*-

(spy/require :spy 'buffer 'delete)


;; http://kitchingroup.cheme.cmu.edu/blog/2013/05/05/Getting-keyword-options-in-org-files/
(defun -s//org/keywords.get ()
  "Parse the buffer and return a cons list of (property . value)
from lines like:
#+PROPERTY: value
"
  (org-element-map (org-element-parse-buffer 'element) 'keyword
                   (lambda (keyword) (cons (org-element-property :key keyword)
                                           (org-element-property :value keyword)))))
;; (-s//org/keywords.get)


;; http://kitchingroup.cheme.cmu.edu/blog/2013/05/05/Getting-keyword-options-in-org-files/
(defun spy/org/keyword.get (keyword)
  "Get the value of a KEYWORD in the form of #+KEYWORD: value
"
  (cdr (assoc keyword (-s//org/keywords.get))))
;; (spy/org/keyword.get "TICKET-ID")


(defun spy/org/keyword.set (keyword value)
  "Get the value of a KEYWORD in the form of #+KEYWORD: value
"
  ;; Expand to full buffer contents.
  (org-with-wide-buffer
   ;; Start at the beginning, search for keyword elements.
   (goto-char (point-min))
   (re-search-forward (rx-to-string `(sequence "#+"
                                               ,keyword
                                               ":"))
                      1024
                      t)
   (let ((thing (org-thing-at-point)))
     ;; (message "%s: %s" thing
     ;;          (or (not thing)
     ;;              ;; car of thing should be "file-option"
     ;;              (not (car thing))
     ;;              (not (stringp (car thing)))
     ;;              (not (string= (car thing) "file-option"))
     ;;              ;; cdr of thing should be the keyword
     ;;              (not (cdr thing))
     ;;              (not (stringp (cdr thing)))
     ;;              (not (string= (cdr thing) keyword))
     ;;              ))
     (if (or (not thing)
             ;; car of thing should be "file-option"
             (not (car thing))
             (not (stringp (car thing)))
             (not (string= (car thing) "file-option"))
             ;; cdr of thing should be the keyword
             (not (cdr thing))
             (not (stringp (cdr thing)))
             (not (string= (cdr thing) keyword)))
         (error "Keyword not found. Cannot set '%s' to '%s'." keyword value)
       ;; Move past keyword to its value.
       (forward-to-word 1)
       ;; Delete old id and replace with new id.
       (-s//buffer/delete.word 1)
       (insert value)
       ))))


(defun -s//org/todo.keyword (word wrap
                                  &optional
                                  key on-enter on-exit-if)
  "Creates an org-todo-keyword with WORD.
Wraps WORD in (elt WRAP 0) and (elt WRAP 2) (that is, WRAP should be a string /
sequence of chars). Pads WORd inside of wrapping with (elt WRAP 1).

If KEY is a string, creates a keyword with keybind (for `org-todo-keywords'
use).

If ON-ENTER or ON-EXIT-IF are non-nil, they must be:
  - 'timestamp - Add timestamp to state change on enter/exit.
  - 'notes     - Add notes w/ timestamp to state change on enter/exit.

ON-EXIT-IF: The 'if' referes to the next state. So an ON-EXIT-IF
of `notes' will only trigger if the next state doesn't have
notes.
"
  (cond ((not (stringp word))
         ;; Failed validation.
         (error "Invalid parameter. Word ('%S') must be a string."
                word))

      ((or (not (sequencep wrap))
           (not (integerp (elt wrap 0)))
           (not (integerp (elt wrap 1)))
           (not (integerp (elt wrap 2))))
       ;; Failed validation.
       (error "Invalid parameter. Wrap ('%S') must be a sequence of characters. "
              wrap))

      ((and (not (null key))
            (not (stringp key)))
       ;; Failed validation.
       (error "Invalid parameter. Key ('%S') must be a string or nil."
              key))

      ((and (not (null on-enter))
            (not (memq on-enter '(timestamp notes))))
       ;; Failed validation.
       (error "Invalid parameter. On-Enter ('%S') must be: nil, timestamp, or notes."
              on-enter))

      ((and (not (null on-exit-if))
            (not (memq on-exit-if '(timestamp notes))))
       ;; Failed validation.
       (error "Invalid parameter. On-Exit-If ('%S') must be: nil, timestamp, or notes."
              on-exit-if))

      (t
       ;; Create todo keyword string!
       (let ((enter (cond ((eq on-enter 'timestamp)
                           "!")
                          ((eq on-enter 'notes)
                           "@")
                          (t
                           "")))
             (exit (cond ((eq on-exit-if 'timestamp)
                          "/!")
                         ((eq on-exit-if 'notes)
                          "/@")
                         (t
                          "")))
             (format-keyword-extras "(%s%s%s)")
             keyword-string)

         ;;---
         ;; Basic wrapped keyword.
         ;;---
         ;; <wrap><word></wrap>
         (setq keyword-string
               (format "%s%-7s%s"
                       (char-to-string (elt wrap 0))
                       word
                       (char-to-string (elt wrap 2))))
         ;; Had to format it first, now I want to replace the normal spaces with
         ;; non-breaking spaces or something so that whitespace-mode won't
         ;; override the face sytle.
         (setq keyword-string (s-replace " "
                                         (char-to-string (elt wrap 1))
                                         keyword-string))

         ;;---
         ;; Add in key/enter/exit codes?
         ;;---
         (unless (null key)
           ;; <formatted-keyword>(<key><time?><note?>)
           (setq keyword-string
                 (format "%s(%s%s%s)"
                         keyword-string
                         ;; These won't go into non-key'd format
                         key
                         ;; on-enter: notes, timestamp, or nothing.
                         enter
                         ;; on-exit-if: notes, timestamp, or nothing.
                         exit)))
         keyword-string))))
;; (-s//org/todo.keyword "bob" "├─┤")
;; (-s//org/todo.keyword "bob" "[-]"
;; (-s//org/todo.keyword "bob" "[-]" "b")
;; (-s//org/todo.keyword "bob" "[-]" "b" 'timestamp)
;; (-s//org/todo.keyword "bob" "[-]" "b" 'notes)
;; (-s//org/todo.keyword "bob" "[-]" "b" nil 'notes)
;; (-s//org/todo.keyword "bob" "[-]" "b" nil 'timestamp)
;; (-s//org/todo.keyword "bob" "[-]" "b" 'timestamp 'notes)


(defun smd/org/convert.todo (skip-bare)
  "Convert old TODO sequence to new."
  (interactive
   (list (y-or-n-p "Skip bare->wrap? ")))
  (org-with-wide-buffer
   (save-excursion
     ;; Bare->Wrapped ("TODO" -> "[TODO   ]"), for width consistency.
     (unless skip-bare
       (let* ((wrap "[]")
              (replacements
               `(("TODO"      . ,(-s//org/todo.keyword "TODO" wrap))
                 ("STARTED"   . ,(-s//org/todo.keyword "CURRENT" wrap))
                 ("WAITING"   . ,(-s//org/todo.keyword "WAITING" wrap))
                 ("DONE"      . ,(-s//org/todo.keyword "DONE" wrap))
                 ("SUCCESS"   . ,(-s//org/todo.keyword "SUCCESS" wrap))
                 ("FAILURE"   . ,(-s//org/todo.keyword "FAILURE" wrap))
                 ("CANCELLED" . ,(-s//org/todo.keyword "KILLED" wrap)))))
         (dolist (replacement replacements)
           (funcall-interactively #'query-replace
                                  (car replacement) (cdr replacement)
                                  nil
                                  (point-min) (point-max)))))

     ;; "[TODO   ]" -> "├TODO───┤"
     (let* ((wrap "[ ]")
            (replacements/old (list
                               (-s//org/todo.keyword "TODO" wrap)
                               (-s//org/todo.keyword "PROJECT" wrap)
                               (-s//org/todo.keyword "CURRENT" wrap)
                               (-s//org/todo.keyword "WAITING" wrap)
                               (-s//org/todo.keyword "HOLDING" wrap)
                               (-s//org/todo.keyword "DONE" wrap)
                               (-s//org/todo.keyword "SUCCESS" wrap)
                               (-s//org/todo.keyword "FAILURE" wrap)
                               (-s//org/todo.keyword "KILLED" wrap)
                               (-s//org/todo.keyword " " wrap)
                               (-s//org/todo.keyword "▶" wrap)
                               (-s//org/todo.keyword "-" wrap)
                               (-s//org/todo.keyword "?" wrap)
                               (-s//org/todo.keyword "…" wrap)
                               (-s//org/todo.keyword "⁈" wrap)
                               (-s//org/todo.keyword "X" wrap)
                               (-s//org/todo.keyword "X" wrap)
                               (-s//org/todo.keyword "✘" wrap)
                               (-s//org/todo.keyword "÷" wrap))))

       (let* ((wrap "├─┤")
              (replacements/new (list
                                 (-s//org/todo.keyword "TODO" wrap)
                                 (-s//org/todo.keyword "PROJECT" wrap)
                                 (-s//org/todo.keyword "CURRENT" wrap)
                                 (-s//org/todo.keyword "WAITING" wrap)
                                 (-s//org/todo.keyword "HOLDING" wrap)
                                 (-s//org/todo.keyword "DONE" wrap)
                                 (-s//org/todo.keyword "SUCCESS" wrap)
                                 (-s//org/todo.keyword "FAILURE" wrap)
                                 (-s//org/todo.keyword "KILLED" wrap)
                                 (-s//org/todo.keyword "_" wrap)
                                 (-s//org/todo.keyword "▶" wrap)
                                 (-s//org/todo.keyword "-" wrap)
                                 (-s//org/todo.keyword "?" wrap)
                                 (-s//org/todo.keyword "…" wrap)
                                 (-s//org/todo.keyword "⁈" wrap)
                                 (-s//org/todo.keyword "X" wrap)
                                 (-s//org/todo.keyword "X" wrap)
                                 (-s//org/todo.keyword "✘" wrap)
                                 (-s//org/todo.keyword "÷" wrap))))

         ;; And... find/replace 'em.
         (dotimes (index (length replacements/new))
           (let ((old (nth index replacements/old))
                 (new (nth index replacements/new)))
             (unless (string= old new)
               (funcall-interactively #'query-replace
                                      old new
                                      nil
                                      (point-min) (point-max))))))))))


;;------------------------------------------------------------------------------
;; The End.
;;------------------------------------------------------------------------------
(spy/provide :spy 'org 'keyword)
