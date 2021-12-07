;;; output/nub/internal.el -*- lexical-binding: t; -*-

;;                                 ──────────                                 ;;
;; ╔════════════════════════════════════════════════════════════════════════╗ ;;
;; ║               What does the error lib use for erroring?                ║ ;;
;; ╚════════════════════════════════════════════════════════════════════════╝ ;;
;;                                   ──────                                   ;;
;;            At least it's only turtles a bit of the way down...             ;;
;;                                 ──────────                                 ;;


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
  ;;------------------------------
  ;; Raise an error after figuring out MSG's formatting.
  ;;------------------------------
  (error (format "%s: %s"
                 caller

                 ;;------------------------------
                 ;; Formatted message based on what we got passed in.
                 ;;------------------------------
                 ;; 1) A String is just a string.
                 (cond ((stringp msg)
                        msg)
                       ;; 2) Newline concat: '(:newline . (string-00 ...))
                       ((and (consp msg)
                             (memq (car msg) '(:newline :newlines))
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
                       ;; 3) String concat: '(string-00 ...)
                       ((and (listp msg)
                             (seq-reduce (lambda (reduction element)
                                           "Require all strings."
                                           (and reduction
                                                (stringp element)))
                                         msg
                                         t))
                        ;; Glue all the strings together.
                        (apply #'concat msg))))

         ;;------------------------------
         ;; Just pass ARGS directly to error - it will do final format.
         ;;------------------------------
         args))
;; (int<nub>:error "test-function-name" "hello there")
;; (int<nub>:error "test-function-name" '("hello, " "there"))
;; (int<nub>:error "test-function-name" '(:newlines . ("Hi." "  -> Line 2")))


;;------------------------------------------------------------------------------
;; The End.
;;------------------------------------------------------------------------------
(imp:provide :nub 'internal)
