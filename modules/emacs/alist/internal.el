;;; alist/internal.el -*- lexical-binding: t; -*-

;;                                 ──────────                                 ;;
;; ╔════════════════════════════════════════════════════════════════════════╗ ;;
;; ║                          Simple-ish Erroring                           ║ ;;
;; ╚════════════════════════════════════════════════════════════════════════╝ ;;
;;                                   ──────                                   ;;
;;         Bit of Formatting                                                  ;;
;;           - `dd` never hurt anyone...                                      ;;
;;         Simple-ish Erroring                                                ;;
;;           - I want better errors than "something went wrong"...            ;;
;;                                 ──────────                                 ;;


;;------------------------------------------------------------------------------
;; Formatting
;;------------------------------------------------------------------------------

(defun int<alist>:string:format (&rest msg)
  "Format MSG into a message formatting string.

MSG should be:
  - string(s)
  - a keyword followed by string(s)

The acceptable keywords are:
  - :newline
    + Alias for `:newlines'.
  - :newlines
    + Concatenate all strings with newlines separator."
  ;;------------------------------
  ;; Formatted message based on what we got passed in.
  ;;------------------------------
  (cond ((null msg)
         "")

        ;; 1) Newline concat? `:newline' or `:newlines' first, then strings.
        ((and (memq (car msg) '(:newline :newlines))
              (seq-reduce (lambda (reduction element)
                            "Require all strings."
                            (and reduction
                                 (stringp element)))
                          (cdr msg)
                          t))
         ;; Concat strings w/ newline separator.
         (mapconcat #'identity
                    (cdr msg)
                    "\n"))

        ;; 2) String concat (no separator).
        ((seq-reduce (lambda (reduction element)
                       "Require all strings."
                       (and reduction
                            (stringp element)))
                     msg
                     t)
         ;; Glue all the strings together.
         (apply #'concat msg))

        ;;---
        ;; Error: invalid MSG.
        ;;---
        (t
         (error "int<alist>:string:format: Don't know how to format: %S"
                msg))))
;; (int<alist>:string:format nil)
;; (int<alist>:string:format "hello there")
;; (int<alist>:string:format "hello, " "there")
;; (int<alist>:string:format :newlines "Hi." "  -> Line 2")


(defun int<alist>:callers:format (this callers)
  "Build a 'caller' string.

Builds from THIS (string) and CALLERS (string or nil).

Returns a string."
  ;;------------------------------
  ;; Error Checks:
  ;;------------------------------
  ;; THIS must be a string.
  (cond ((not (stringp this))
         (int<alist>:error "int<alist>:callers:format"
                         "Invalid THIS param. Expected a string; got: this: %S, callers: %S"
                         this callers))
        ;; CALLERS must be a string if not nil.
        ((and callers
              (not (stringp callers)))
         (int<alist>:error "int<alist>:callers:format"
                         "Invalid CALLER param. Expected a string; got: callers: %S, this: %S"
                         callers this))

        ;;------------------------------
        ;; Valid: Concat this w/ callers.
        ;;------------------------------
        (t
         (if callers
             (concat this " <-via- " callers)
           this))))
;; (int<alist>:callers:format "bob" nil)
;; (int<alist>:callers:format "bob" "alice")
;; (int<alist>:callers:format "C" (int<alist>:callers:format "B" "A"))
;; (int<alist>:callers:format nil nil)


;;------------------------------------------------------------------------------
;; Errors
;;------------------------------------------------------------------------------
;; alist can't use `alist:output', unless you're after 'output.el' in the load
;; ordering, like 'debug.el'...
;;
;; So here's an error function for our error library.

(defun int<alist>:error (caller msg &rest args)
  "Format an error message for CALLER and signal an error.

CALLER should be a string.

MSG should be:
  - a string
  - a list of strings to `concat'
  - a cons of: '(:newlines . (string-00 ...))
    + This will concat the list-of-strings with newlines.

ARGS will be passed to `format' with the finalized message string."
  ;; Raise an error after figuring out MSG's formatting.
  (apply #'error (format "%s: %s"
                         caller
                         ;; Formatted message based on what we got passed in.
                         ;; Use `flatten-list' to make MSG a list if it's just a string.
                         ;; It also converts cons to lists, but that's ok here.
                         (apply #'int<alist>:string:format (flatten-list msg)))
         ;; Just pass ARGS directly to error - it will do final format.
         args))
;; (int<alist>:error "test-function-name" "hello there")
;; (int<alist>:error "test-function-name" '("hello, " "there"))
;; (int<alist>:error "test-function-name" '(:newlines . ("Hi." "  -> Line 2")))


;;------------------------------------------------------------------------------
;; The End.
;;------------------------------------------------------------------------------
(imp:provide :alist 'internal)
