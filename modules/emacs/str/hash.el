;;; emacs/str/hash.el -*- lexical-binding: t; -*-

(imp:require :str 'normalize)
(imp:require :str 'string)


;;------------------------------------------------------------------------------
;; Constants & Variables
;;------------------------------------------------------------------------------

(defconst str:hash:default 'sha512
  "Default hashing function to use for str:hash-input.")

(defconst str:hash:slice 6
  "Default hashing slice size to use for `str:hash:pretty'.")

(defconst str:hash:join/slices "-"
  "Default slice join string for `str:hash:pretty'.")

(defconst str:hash:join/prefixes "/"
  "Default join string to use for joining prefixes together in `str:hash'.")

(defconst str:hash:join/prepend "::"
  "Default join string to use for joining prefixes to hash in `str:hash'.")


;;------------------------------------------------------------------------------
;; Hashes
;;------------------------------------------------------------------------------

(defun int<str>:hash:input->str (input)
  "Converts a single INPUT (string or symbol) into a string."
  (cond ((null input)
         (error "%s: Cannot hash 'nil' INPUT. %s Input: %s"
                "int<str>:hash:input->str"
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
                 "int<str>:hash:input->str"
                 "Not a string, symbol, or list of strings/symbols?"
                 input))))
;; (int<str>:hash:input->str "jeff")
;; (int<str>:hash:input->str 'jeff)


(defun str:hash:full (input &optional hash)
  "Returns the full hash string of INPUT (can be string, symbol or list of
strings/symbols). Uses HASH algorithm (see `(secure-hash-algorithms)' for
available algorithms.

If HASH is nil, this will use the default defined in `str:hash:default'."
  ;; Set hash to default if unspecified.
  (let ((hash (or hash str:hash:default))
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
           (setq input-string (str:normalize:value->list input)))

          ;; A list? Stringify and concat together.
          ((listp input)
           (setq input-string (mapconcat #'int<str>:hash:input->str input " ")))

          ;; Fallthrough: Bad Input.
          (t
           (error "Don't know what to do with INPUT. %s Input: %s"
                  "Not a string, symbol, or list of strings/symbols?"
                  input)))

    (secure-hash hash input-string)))
;; (str:hash:full "jeff")
;; (str:hash:full 'jeff)
;; (str:hash:full '(jeff jeff))
;; (str:hash:full nil)


(defun str:hash:pretty (input &optional hash slice join)
  "Hash INPUT (can be string, symbol or list of strings/symbols).

If HASH is non-nil, will use that HASH algorithm (see `(secure-hash-algorithms)'
for available algorithms. Otherwise uses `str:hash:default'.

If SLICE is non-nil, will use that (integer) to break the hash up into slices.
Otherwise uses `str:hash:slice'. The slices it uses are the first SLICE
characters and the last SLICE characters.

If JOIN is non-nil, will use that (string) to join back together the hash
slices. Otherwise uses `str:hash:join/slices'."
  (let* ((hash-full (str:hash:full input hash))
         (slice (or slice str:hash:slice))
         (join (or join str:hash:join/slices)))

    (concat (substring hash-full 0 slice)
            join
            (substring hash-full (- slice) nil))))
;; (str:hash:pretty "jeff")


(defun str:hash:recreate (prefixes pretty-hash)
  "Like `str:hash', with PRETTY-HASH instead of a created hash.

PREFIXES should be: string, symbol, or list of strings/symbols.

PRETTY-HASH should be a string like `str:hash:pretty' outputs.

This joins all PREFIXES together into a string separated with
`str:hash:join/prefixes'.

Then it joins the prefix string to the PRETTY-HASH string with
`str:hash:join/prepend'."
  ;; Create prepend string from prefixes...
  (concat (apply #'str:join str:hash:join/prefixes
                 (apply #'str:normalize:value->list prefixes))
          ;; ...add prepend separator...
          str:hash:join/prepend
          ;; ...and finish with the pretty hash.
          pretty-hash))
;; (str:hash:recreate '(jeff compy) "cab3d6-bad38c")


(defun str:hash (prefixes inputs)
  "PREFIXES and INPUTS should be: string, symbol, or list of strings/symbols.

This joins all PREFIXES together into a string separated with
`str:hash:join/prefixes'.

Then it hash INPUTS using `str:hash:pretty' function.

Finally, it join prefixes string and inputs hash string with
`str:hash:join/prepend'."
  ;; Create prepend string from prefixes...
  (concat (apply #'str:join str:hash:join/prefixes
                 (apply #'str:normalize:value->list prefixes))
          ;; ...add prepend separator...
          str:hash:join/prepend
          ;; ...and finish with the pretty hash.
          (str:hash:pretty inputs)))
;; (str:hash '(jeff compy) 'laptop-2020)


(defun str:hash:split (hash:pretty)
  "Split a pretty hash back up into input prefixes and the pretty hash."
  (let ((split (split-string hash:pretty str:hash:join/prepend)))
    ;; Return: '((prefixes ...) hash)
    (list (split-string (nth 0 split) str:hash:join/prefixes)
          (nth 1 split))))
;; (str:hash:split (str:hash '(jeff compy) 'laptop-2020))


;;------------------------------------------------------------------------------
;; The End.
;;------------------------------------------------------------------------------
(imp:provide :str 'hash)
