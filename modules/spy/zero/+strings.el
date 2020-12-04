;;; -*- mode: emacs-lisp; lexical-binding: t -*-


;; TODO: a spy/fan header here



;;------------------------------------------------------------------------------
;; Constants & Variables
;;------------------------------------------------------------------------------

(defconst spy/hash/default 'sha512
  "Default hashing function to use for spy/hash-input.")

(defconst spy/hash/slice 6
  "Default hashing slice size to use for `spy/hash/pretty'.")

(defconst spy/hash/join/slices "-"
  "Default slice join string for `spy/hash/pretty'.")

(defconst spy/hash/join/prefixes "/"
  "Default join string to use for joining prefixes together in `spy/hash'.")

(defconst spy/hash/join/prepend "::"
  "Default join string to use for joining prefixes to hash in `spy/hash'.")


;;------------------------------------------------------------------------------
;; Strings
;;------------------------------------------------------------------------------

;; §-TODO-§ [2020-10-23]: Move to a strings file.
(defun spy/string/concat (separator &rest inputs)
  "Concats INPUTS together with SEPARATOR in between.

INPUTS can be anything that `format' can deal with as a \"%s\" input type.
"
  (mapconcat (function (lambda (x) (format "%s" x)))
             inputs
             separator))


;;------------------------------------------------------------------------------
;; Hashes
;;------------------------------------------------------------------------------

(defun _s//hash/input->str (input)
  "Converts a single INPUT (string or symbol) into a string.
"
  (cond ((null input)
         (error "%s: Cannot hash 'nil' INPUT. %s Input: %s"
                "_s//hash/input->str"
                "Not a string, symbol, or list of strings/symbols."
                input))

        ;; String? Well ok then.
        ((stringp input)
         input)

        ;; A single symbol? Turn it into a string.
        ((symbolp input)
         (symbol-name input))

         ;; Fallthrough: Bad Input.
         (t
          (error "%s: Don't know what to do with INPUT. %s Input: %s"
                 "_s//hash/input->str"
                 "Not a string, symbol, or list of strings/symbols?"
                 input))))
;; (_s//hash/input->str "jeff")
;; (_s//hash/input->str 'jeff)


(defun spy/hash/full (input &optional hash)
  "Returns the full hash string of INPUT (can be string, symbol or list of
strings/symbols). Uses HASH algorithm (see `(secure-hash-algorithms)' for
available algorithms.

If HASH is nil, this will use the default defined in `spy/hash/default'.
"
  ;; Set hash to default if unspecified.
  (let ((hash (or hash spy/hash/default))
        (input-string nil))
    ;; Make sure hash exists as a supported algorithm.
    (unless (member hash (secure-hash-algorithms))
      (error "Unknown hash: %s" hash))

    ;; See if we need to turn our input into a string.
    (cond ((null input)
           (error "Cannot hash 'nil' INPUT. %s Input: %s"
                  "Not a string, symbol, or list of strings/symbols."
                  input))

          ;; String or symbol? Turn it into a string.
          ((or (stringp input)
               (symbolp input))
           (setq input-string (_s//hash/input->str input)))

          ;; A list? Stringify and concat together.
          ((listp input)
           (setq input-string (mapconcat #'_s//hash/input->str input " ")))

          ;; Fallthrough: Bad Input.
          (t
           (error "Don't know what to do with INPUT. %s Input: %s"
                  "Not a string, symbol, or list of strings/symbols?"
                  input)))

    (secure-hash hash input-string)))
;; (spy/hash/full "jeff")
;; (spy/hash/full 'jeff)
;; (spy/hash/full '(jeff jeff))
;; (spy/hash/full nil)


(defun spy/hash/pretty (input &optional hash slice join)
  "Hash INPUT (can be string, symbol or list of strings/symbols).

If HASH is non-nil, will use that HASH algorithm (see `(secure-hash-algorithms)'
for available algorithms. Otherwise uses `spy/hash/default'.

If SLICE is non-nil, will use that (integer) to break the hash up into slices.
Otherwise uses `spy/hash/slice'. The slices it uses are the first SLICE
characters and the last SLICE characters.

If JOIN is non-nil, will use that (string) to join back together the hash
slices. Otherwise uses `spy/hash/join/slices'.
"
  (let* ((hash-full (spy/hash/full input hash))
         (slice (or slice spy/hash/slice))
         (join (or join spy/hash/join/slices)))

    (concat (substring hash-full 0 slice)
            join
            (substring hash-full (- slice) nil))))
;; (spy/hash/pretty "jeff")


(defun spy/hash (prefixes inputs)
  "PREFIXES and INPUTS should be: string, symbol, or list of strings/symbols.

This joins all PREFIXES together into a string separated with
`spy/hash/join/prefixes'.

Then it hash INPUTS using `spy-hash-pretty' function.

Finally, it join prefixes string and inputs hash string with
`spy/hash/join/prepend'.
"
  ;; Create prepend string from prefixes...
  (concat (apply #'spy/string/concat spy/hash/join/prefixes prefixes)
          ;; ...add prepend separator...
          spy/hash/join/prepend
          ;; ...and finish with the pretty hash.
          (spy/hash/pretty inputs)))
;; (spy/hash '(jeff compy) 'laptop-2020)


;;------------------------------------------------------------------------------
;; Symbols
;;------------------------------------------------------------------------------

(defun spy/string/symbol->str (symbol)
  "Converts a symbol name to a string. Removes \":\" from keyword symbols."
  (replace-regexp-in-string ":" ""
                            (symbol-name symbol)))
;; (spy/string/symbol->str 'jeff)
;; (spy/string/symbol->str :jeff)
;; (let ((x 'jeff)) (spy/string/symbol->str x))
;; (let* ((jeff "geoff") (x 'jeff)) (spy/string/symbol->str x))


(defun spy/string/symbol/normalize (&rest inputs)
  "For each item in INPUTS:
  - If it's a strings, use the string.
  - If it's a symbol, use the symbol's name via `spy/string/symbol->str'.

Returns a list of strings.
"
  (let ((output nil))
    (dolist (item inputs output)
      ;; String? Direct to output.
      (cond ((stringp item)
             (push item output))

            ;; Funcs are annoying. E.g.:
            ;;   (spy/string/symbol/normalize 'org-mode)
            ;; I wanted it to stringify the symbol but turns out that's
            ;; a function. Removing the function calls for now.
            ;; ;; Bound func or lambda? Call it for string.
            ;; ((or (fboundp item)
            ;;      (functionp item))
            ;;  (push (funcall item) output))

            ;; Symbol? Use its name.
            ((symbolp item)
             (push (spy/string/symbol->str item) output))))
    ;; `push' pushes to the front of the list, so reverse it for result.
    (nreverse output)))
;; (spy/string/symbol/normalize "Test/ing" 'jeff :jeff)


;;------------------------------------------------------------------------------
;; The End.
;;------------------------------------------------------------------------------
(spy/provide :spy 'zero 'strings)
