;;; output/nub/internal.el -*- lexical-binding: t; -*-

;;                                 ──────────                                 ;;
;; ╔════════════════════════════════════════════════════════════════════════╗ ;;
;; ║               What does the error lib use for erroring?                ║ ;;
;; ╚════════════════════════════════════════════════════════════════════════╝ ;;
;;                                   ──────                                   ;;
;;            At least it's only turtles a bit of the way down...             ;;
;;                                 ──────────                                 ;;


;;------------------------------------------------------------------------------
;; Formatting
;;------------------------------------------------------------------------------

(defun int<nub>:format (&rest msg)
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
         (error "int<nub>:format: Don't know how to format: %S"
                msg))))
;; (int<nub>:format nil)
;; (int<nub>:format "hello there")
;; (int<nub>:format "hello, " "there")
;; (int<nub>:format :newlines "Hi." "  -> Line 2")


(defun int<nub>:format:callers (this callers)
  "Build a 'caller' string.

Builds from THIS (string) and CALLERS (string or nil).

Returns a string."
  ;;------------------------------
  ;; Error Checks:
  ;;------------------------------
  ;; THIS must be a string.
  (cond ((not (stringp this))
         (int<nub>:error "int<nub>:format:callers"
                         "Invalid THIS param. Expected a string; got: this: %S, callers: %S"
                         this callers))
        ;; CALLERS must be a string if not nil.
        ((and callers
              (not (stringp callers)))
         (int<nub>:error "int<nub>:format:callers"
                         "Invalid CALLER param. Expected a string; got: callers: %S, this: %S"
                         callers this))

        ;;------------------------------
        ;; Valid: Concat this w/ callers.
        ;;------------------------------
        (t
         (if callers
             (concat this " <-via- " callers)
           this))))
;; (int<nub>:format:callers "bob" nil)
;; (int<nub>:format:callers "bob" "alice")
;; (int<nub>:format:callers "C" (int<nub>:format:callers "B" "A"))
;; (int<nub>:format:callers nil nil)


;;------------------------------------------------------------------------------
;; Errors
;;------------------------------------------------------------------------------
;; nub can't use `nub:output', unless you're after 'output.el' in the load
;; ordering, like 'debug.el'...
;;
;; So here's an error function for our error library.

(defun int<nub>:error (caller msg &rest args)
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
                         (apply #'int<nub>:format (flatten-list msg)))
         ;; Just pass ARGS directly to error - it will do final format.
         args))
;; (int<nub>:error "test-function-name" "hello there")
;; (int<nub>:error "test-function-name" '("hello, " "there"))
;; (int<nub>:error "test-function-name" '(:newlines . ("Hi." "  -> Line 2")))


;;------------------------------------------------------------------------------
;; The End.
;;------------------------------------------------------------------------------
(imp:provide :nub 'internal)
