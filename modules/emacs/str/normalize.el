;;; emacs/str/string.el -*- lexical-binding: t; -*-


;;------------------------------------------------------------------------------
;; Normalize something else into a string  strings.
;;------------------------------------------------------------------------------

(defun str:normalize:symbol->string (symbol)
  "Converts a symbol/keyword name to a string. Removes \":\" from keyword symbols."
  (replace-regexp-in-string ":" ""
                            (symbol-name symbol)))
;; (str:normalize.symbol 'jeff)
;; (str:normalize.symbol :jeff)
;; (let ((x 'jeff)) (str:normalize.symbol x))
;; (let* ((jeff "geoff") (x 'jeff)) (str:normalize.symbol x))


(defun str:normalize:name->list (&rest inputs)
  "For each item in INPUTS:
  - If it's a string, use as-is.
  - If it's a symbol (or function), use the symbol's name via
    `str:normalize:symbol->string'.

Returns a list of strings."
  (let ((output nil))
    (dolist (item inputs output)
      ;; String? Direct to output.
      (cond ((stringp item)
             (push item output))

            ;; Symbol (or function)? Use its name.
            ((symbolp item)
             (push (str:normalize:symbol->string item) output))))
    ;; `push' pushes to the front of the list, so reverse it for result.
    (nreverse output)))
;; (str:normalize.name "Test/ing" 'jeff :jeff)


(defun str:normalize:name (input)
  "Normalize INPUT to a string.
  - If it's a string, use as-is.
  - If it's a symbol (or function), use its name via
    `str:normalize:symbol->string'.

Returns a string."
  ;; Just reuse `str:normalize:name->list'.
  (nth 0 (str:normalize:name->list input)))


(defun str:normalize:value->list (&rest inputs)
  "For each item in INPUTS:
  - If it's a string, use the string.
  - If it's a symbol, use the symbol's value.
  - If it's a function, call it with no parameters and use the output string.

Returns a list of strings."
  (let ((func.name "str:normalize:value->list")
        (output nil))
    (dolist (item inputs output)
      ;; String? Direct to output.
      (cond ((stringp item)
             (push item output))

            ;; Function? Assume it will give us our string.
            ((or (fboundp item)
                 (functionp item))
             (condition-case-unless-debug err
                 (let ((result (funcall item)))
                   (if (stringp result)
                       (push result output)
                     (error "%s: Function did not return a string: %S -> %S"
                            func.name
                            item
                            result)))
               (error (error "%s: Failed calling %S: %S"
                             func.name
                             item
                             err))))

            ;; Symbol? Use its value.
            ((symbolp item)
             (condition-case-unless-debug err
                 (let ((result (symbol-value item)))
                   (if (stringp result)
                       (push result output)
                     (error "%s: Symbol '%S' does not contain a string value: %S"
                            func.name
                            item
                            result)))
               (error (error "%s: Failed while trying to get symbol value of %S: %S"
                             func.name
                             item
                             err))))

            (t
             (error "%s: Don't know what to do with INPUT. Reason: '%s' Input: '%s'"
                    func.name
                    "Not a string, function, or symbol?"
                    input))))
    ;; `push' pushes to the front of the list, so reverse it for result.
    (nreverse output)))
;; bad: func doesn't return str
;;   (str:normalize:value->list "Test/ing" 'ignore :jeff)
;; bad: keywords can't have string values
;;   (str:normalize:value->list "Test/ing" 'test:test :jeff)
;; good:
;;   (let* ((name "jeff") (name-symbol 'name)) (str:normalize:value->list "Test/ing" 'test:test name-symbol))
;;   (let* ((name "jeff")) (str:normalize:value->list "Test/ing" 'test:test 'name))


(defun str:normalize:value (input)
  "Normalize INPUT to a string.
  - If it's a string, use as-is.
  - If it's a symbol, use the symbol's value.
  - If it's a function, call it with no parameters and use the output string.

Returns a list of strings."
  ;; Just reuse `str:normalize:value->list'.
  (nth 0 (str:normalize:value->list input)))


;;------------------------------------------------------------------------------
;; Normalize something into a keyword.
;;------------------------------------------------------------------------------

(defun str:normalize:name->keyword (input)
  "Convert INPUT to a keyword.

If INPUT is nil, return nil.
If INPUT is already a keyword, return as-is.
If INPUT is a function, call it with no args and convert its string output
to a keyword.
If INPUT is a symbol, get its `symbol-name', and convert to a keyword.
If INPUT is a string (leading ':' is optional), convert to a keyword."
  (let ((func.name "str:normalize:name->keyword"))
    (cond ((null input)
           nil)

          ((keywordp input)
           input)

          ;; Function? Assume it will give us our string.
          ((or (fboundp item)
               (functionp item))
           (condition-case-unless-debug err
               (let ((result (funcall item)))
                 (if (stringp result)
                     result
                   (error "%s: Function did not return a string: %S -> %S"
                          func.name
                          item
                          result)))
             (error (error "%s: Failed calling %S: %S"
                           func.name
                           item
                           err))))

          ((or (stringp input)
               (symbolp input))
           (intern
            ;; INPUT only optionally has a ":", so ensure a ":" by:
            ;;   1) Removing the leading ":" if it exists.
            ;;   2) Always prefixing a new ":".
            (concat ":"
                    ;; Remove keyword's leading ":"?
                    (string-remove-prefix
                     ":"
                     ;; Make sure we have a string.
                     (if (stringp input)
                         input
                       (symbol-name input))))))
          (t
           (error "%s: Unsupported INPUT type of '%S': %S"
                  func.name
                  (type-of input)
                  input)))))


;;------------------------------------------------------------------------------
;; The End.
;;------------------------------------------------------------------------------
(imp:provide :str 'normalize)
