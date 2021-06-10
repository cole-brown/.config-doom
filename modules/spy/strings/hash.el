;;; spy/strings/hash.el -*- lexical-binding: t; -*-


;;------------------------------------------------------------------------------
;; Constants & Variables
;;------------------------------------------------------------------------------

(defconst spy:hash/default 'sha512
  "Default hashing function to use for spy:hash-input.")

(defconst spy:hash/slice 6
  "Default hashing slice size to use for `spy:hash/pretty'.")

(defconst spy:hash/join/slices "-"
  "Default slice join string for `spy:hash/pretty'.")

(defconst spy:hash/join/prefixes "/"
  "Default join string to use for joining prefixes together in `spy:hash'.")

(defconst spy:hash/join/prepend "::"
  "Default join string to use for joining prefixes to hash in `spy:hash'.")


;;------------------------------------------------------------------------------
;; Hashes
;;------------------------------------------------------------------------------

(defun sss:hash/input->str (input)
  "Converts a single INPUT (string or symbol) into a string."
  (cond ((null input)
         (error "%s: Cannot hash 'nil' INPUT. %s Input: %s"
                "sss:hash/input->str"
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
                 "sss:hash/input->str"
                 "Not a string, symbol, or list of strings/symbols?"
                 input))))
;; (sss:hash/input->str "jeff")
;; (sss:hash/input->str 'jeff)


(defun spy:hash/full (input &optional hash)
  "Returns the full hash string of INPUT (can be string, symbol or list of
strings/symbols). Uses HASH algorithm (see `(secure-hash-algorithms)' for
available algorithms.

If HASH is nil, this will use the default defined in `spy:hash/default'."
  ;; Set hash to default if unspecified.
  (let ((hash (or hash spy:hash/default))
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
           (setq input-string (sss:hash/input->str input)))

          ;; A list? Stringify and concat together.
          ((listp input)
           (setq input-string (mapconcat #'sss:hash/input->str input " ")))

          ;; Fallthrough: Bad Input.
          (t
           (error "Don't know what to do with INPUT. %s Input: %s"
                  "Not a string, symbol, or list of strings/symbols?"
                  input)))

    (secure-hash hash input-string)))
;; (spy:hash/full "jeff")
;; (spy:hash/full 'jeff)
;; (spy:hash/full '(jeff jeff))
;; (spy:hash/full nil)


(defun spy:hash/pretty (input &optional hash slice join)
  "Hash INPUT (can be string, symbol or list of strings/symbols).

If HASH is non-nil, will use that HASH algorithm (see `(secure-hash-algorithms)'
for available algorithms. Otherwise uses `spy:hash/default'.

If SLICE is non-nil, will use that (integer) to break the hash up into slices.
Otherwise uses `spy:hash/slice'. The slices it uses are the first SLICE
characters and the last SLICE characters.

If JOIN is non-nil, will use that (string) to join back together the hash
slices. Otherwise uses `spy:hash/join/slices'."
  (let* ((hash-full (spy:hash/full input hash))
         (slice (or slice spy:hash/slice))
         (join (or join spy:hash/join/slices)))

    (concat (substring hash-full 0 slice)
            join
            (substring hash-full (- slice) nil))))
;; (spy:hash/pretty "jeff")


(defun spy:hash (prefixes inputs)
  "PREFIXES and INPUTS should be: string, symbol, or list of strings/symbols.

This joins all PREFIXES together into a string separated with
`spy:hash/join/prefixes'.

Then it hash INPUTS using `spy:hash/pretty' function.

Finally, it join prefixes string and inputs hash string with
`spy:hash/join/prepend'."
  ;; Create prepend string from prefixes...
  (concat (apply #'spy:string/concat spy:hash/join/prefixes prefixes)
          ;; ...add prepend separator...
          spy:hash/join/prepend
          ;; ...and finish with the pretty hash.
          (spy:hash/pretty inputs)))
;; (spy:hash '(jeff compy) 'laptop-2020)


;;------------------------------------------------------------------------------
;; The End.
;;------------------------------------------------------------------------------
(imp:provide :modules 'spy 'strings 'hash)
