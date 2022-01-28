;;; spy/org/keyword.el -*- lexical-binding: t; -*-

(imp:require :modules 'spy 'buffer 'delete)


;; http://kitchingroup.cheme.cmu.edu/blog/2013/05/05/Getting-keyword-options-in-org-files/
(defun sss:org/keywords.get ()
  "Parse the buffer and return a cons list of (property . value)
from lines like:
#+PROPERTY: value
"
  (org-element-map (org-element-parse-buffer 'element) 'keyword
    (lambda (keyword) (cons (org-element-property :key keyword)
                            (org-element-property :value keyword)))))
;; (sss:org/keywords.get)


;; http://kitchingroup.cheme.cmu.edu/blog/2013/05/05/Getting-keyword-options-in-org-files/
(defun spy:org/keyword.get (keyword)
  "Get the value of a KEYWORD in the form of #+KEYWORD: value
"
  (cdr (assoc keyword (sss:org/keywords.get))))
;; (spy:org/keyword.get "TICKET-ID")


(defun spy:org/keyword.set (keyword value)
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
       (sss:buffer/delete.word 1)
       (insert value)
       ))))


(defun sss:org/todo.keyword (word wrap
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
;; (sss:org/todo.keyword "bob" "├─┤")
;; (sss:org/todo.keyword "bob" "[-]"
;; (sss:org/todo.keyword "bob" "[-]" "b")
;; (sss:org/todo.keyword "bob" "[-]" "b" 'timestamp)
;; (sss:org/todo.keyword "bob" "[-]" "b" 'notes)
;; (sss:org/todo.keyword "bob" "[-]" "b" nil 'notes)
;; (sss:org/todo.keyword "bob" "[-]" "b" nil 'timestamp)
;; (sss:org/todo.keyword "bob" "[-]" "b" 'timestamp 'notes)


(defun spy:cmd:org/convert.todo (skip-bare)
  "Convert old TODO sequence to new."
  (interactive
   (list (y-or-n-p "Skip bare->wrap? ")))
  (org-with-wide-buffer
   (save-excursion
     ;; Bare->Wrapped ("TODO" -> "[TODO   ]"), for width consistency.
     (unless skip-bare
       (message "'TODO' -> '[TODO   ]'")
       (let* ((wrap "[ ]")
              (replacements
               `(("TODO"      . ,(sss:org/todo.keyword "TODO" wrap))
                 ("STARTED"   . ,(sss:org/todo.keyword "CURRENT" wrap))
                 ("WAITING"   . ,(sss:org/todo.keyword "WAITING" wrap))
                 ("DONE"      . ,(sss:org/todo.keyword "DONE" wrap))
                 ("SUCCESS"   . ,(sss:org/todo.keyword "SUCCESS" wrap))
                 ("FAILURE"   . ,(sss:org/todo.keyword "FAILURE" wrap))
                 ("CANCELLED" . ,(sss:org/todo.keyword "KILLED" wrap)))))
         (dolist (replacement replacements)
           (funcall-interactively #'query-replace
                                  (car replacement) (cdr replacement)
                                  nil
                                  (point-min) (point-max)))))

     ;; "[TODO   ]" -> "├TODO───┤"
     (let* ((wrap "[ ]")
            (replacements/old (list
                               (sss:org/todo.keyword "TODO" wrap)
                               (sss:org/todo.keyword "PROJECT" wrap)
                               (sss:org/todo.keyword "CURRENT" wrap)
                               (sss:org/todo.keyword "WAITING" wrap)
                               (sss:org/todo.keyword "HOLDING" wrap)
                               (sss:org/todo.keyword "DONE" wrap)
                               (sss:org/todo.keyword "SUCCESS" wrap)
                               (sss:org/todo.keyword "FAILURE" wrap)
                               (sss:org/todo.keyword "KILLED" wrap)
                               (sss:org/todo.keyword " " wrap)
                               (sss:org/todo.keyword "▶" wrap)
                               (sss:org/todo.keyword "-" wrap)
                               (sss:org/todo.keyword "?" wrap)
                               (sss:org/todo.keyword "…" wrap)
                               (sss:org/todo.keyword "⁈" wrap)
                               (sss:org/todo.keyword "X" wrap)
                               (sss:org/todo.keyword "X" wrap)
                               (sss:org/todo.keyword "✘" wrap)
                               (sss:org/todo.keyword "÷" wrap))))

       (let* ((wrap "├─┤")
              (replacements/new (list
                                 (sss:org/todo.keyword "TODO" wrap)
                                 (sss:org/todo.keyword "PROJECT" wrap)
                                 (sss:org/todo.keyword "CURRENT" wrap)
                                 (sss:org/todo.keyword "WAITING" wrap)
                                 (sss:org/todo.keyword "HOLDING" wrap)
                                 (sss:org/todo.keyword "DONE" wrap)
                                 (sss:org/todo.keyword "SUCCESS" wrap)
                                 (sss:org/todo.keyword "FAILURE" wrap)
                                 (sss:org/todo.keyword "KILLED" wrap)
                                 (sss:org/todo.keyword "_" wrap)
                                 (sss:org/todo.keyword "▶" wrap)
                                 (sss:org/todo.keyword "-" wrap)
                                 (sss:org/todo.keyword "?" wrap)
                                 (sss:org/todo.keyword "…" wrap)
                                 (sss:org/todo.keyword "⁈" wrap)
                                 (sss:org/todo.keyword "X" wrap)
                                 (sss:org/todo.keyword "X" wrap)
                                 (sss:org/todo.keyword "✘" wrap)
                                 (sss:org/todo.keyword "÷" wrap))))

         ;; "[TODO   ]" -> "├TODO───┤"
         (message "'[TODO   ]' -> '├TODO───┤'")

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
;; Per File Org-Keywords
;;------------------------------------------------------------------------------

(defun spy:cmd:org/file.keywords (todo-sequence)
  "Create 'per-file' keyword lines using TODO-SEQUENCE (or the prompt input).

See here for acceptable inputs:
  - https://orgmode.org/manual/Per_002dfile-keywords.html
  - e.g. TODO FEEDBACK VERIFY | DONE CANCELED

Replaces a \"#+TODO\" keyword if found.

Outputs 2 lines:
  - \"#+TODO: [...]\"
  - \"-*- org-todo-keyword-faces: ([...]) -*-\"

The `org-todo-keyword-faces' line must be at the top of the file to work."
  (interactive "sTODO Sequence: ")

  ;;------------------------------
  ;; TODO Sequence Keyword
  ;;------------------------------
  (let* ((keyword/todo "TODO")
         (keyword/face-var "org-todo-keyword-faces")
         (todo/wrap "├─┤")
         (todo/existing (spy:org/keyword.get keyword/todo))
         todo/new.list
         todo/new.str
         keywords-set)

    ;; Need to wrap the keywords!
    (dolist (keyword (nreverse (split-string todo-sequence)))
      (if (string= keyword "|")
          ;; Leave as-is - it's the todo/done separator.
          (push keyword todo/new.list)
        ;; Wrap it.
        (push (sss:org/todo.keyword keyword todo/wrap) todo/new.list)))

    ;; Convert the wrapped list into a wrapped string.
    (setq todo/new.str (mapconcat #'identity
                                  todo/new.list
                                  " "))

    ;; Insert into the buffer.
    (if todo/existing
        ;; Find `TODO' keyword in file, change it.
        (if (not (yes-or-no-p (format "Found existing 'TODO' keyword. Replace? Existing: \"%s\", New: \"%s\""
                                      todo/existing todo/new.str)))
            (message "Ok; changed nothing.")

          (spy:org/keyword.set keyword/todo todo/new.str)
          (message "Updated keywords to: \"%S\"" todo/new.str)
          (setq keywords-set t))

      ;; No existing; create new one.
      ;; I'm not going to bother with placing this somewhere smart, for now.
      (org-with-wide-buffer
       (beginning-of-line)
       (insert (format "\n#+%s: %s\n" keyword/todo todo/new.str))
       (message "Created keywords: \"%S\"" todo/new.str))
      (setq keywords-set t))

    ;;------------------------------
    ;; Faces Local Variable
    ;;------------------------------
    (when (and keywords-set
               (yes-or-no-p "Create alist for applying faces to the keywords?"))
      (org-with-wide-buffer
       (let ((faces/alist))
         (dolist (keyword todo/new.list)
           (unless (string= keyword "|")
             (push (cons keyword 'spy:theme.face/org.todo.keyword/todo) faces/alist)))
         (setq faces/alist (nreverse faces/alist))

         ;; Put it before the keywords?
         (beginning-of-line)
         (insert "\n")

         ;; Just make the line for user to fiddle with.
         (insert (format "\n# -*- %s: %S -*-"
                         keyword/face-var
                         faces/alist))
         (insert (mapconcat #'identity
                            '(""
                              "# The above line must be at the top of the file, possibly combining with/replacing whatever already exists there."
                              "# For faces to use, see:"
                              "# - command: `M-x list-faces-display'"
                              "# - variables: `spy:theme.face/org.todo.[...]'"
                              "# - variables: `+org-todo-[...]'"
                              "# - file: ~/.doom.d/config/org-mode.el")
                            "\n"))
         (insert "\n"))))

    ;;------------------------------
    ;; Done.
    ;;------------------------------
    (org-with-wide-buffer
     (insert (mapconcat #'identity
                        '("Done; you may need to move the inserted lines up to/near the top of the file."
                          "To finalize:"
                          "  1. Complete faces alist (if generated)."
                          "  2. Move faces line to top of file."
                          "  3. Move keyword line to near top of file."
                          "  4. Save the file."
                          "  5. Revisit the file.")
                        "\n")))))


;;------------------------------------------------------------------------------
;; The End.
;;------------------------------------------------------------------------------
(imp:provide :modules 'spy 'org 'keyword)
