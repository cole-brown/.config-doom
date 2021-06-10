;;; spy/strings/normalize.el -*- lexical-binding: t; -*-

;;------------------------------------------------------------------------------
;; Symbols
;;------------------------------------------------------------------------------

(defun spy:string/normalize.symbol (symbol)
  "Converts a symbol name to a string. Removes \":\" from keyword symbols."
  (replace-regexp-in-string ":" ""
                            (symbol-name symbol)))
;; (spy:string/normalize.symbol 'jeff)
;; (spy:string/normalize.symbol :jeff)
;; (let ((x 'jeff)) (spy:string/normalize.symbol x))
;; (let* ((jeff "geoff") (x 'jeff)) (spy:string/normalize.symbol x))


(defun spy:string/normalize.name (&rest inputs)
  "For each item in INPUTS:
  - If it's a strings, use the string.
  - If it's a symbol, use the symbol's name via `spy:string/normalize.symbol'.

Returns a list of strings."
  (let ((output nil))
    (dolist (item inputs output)
      ;; String? Direct to output.
      (cond ((stringp item)
             (push item output))

            ;; Symbol (or function)? Use its name.
            ((symbolp item)
             (push (spy:string/normalize.symbol item) output))))
    ;; `push' pushes to the front of the list, so reverse it for result.
    (nreverse output)))
;; (spy:string/normalize.name "Test/ing" 'jeff :jeff)


(defun spy:string/normalize.value (&rest inputs)
  "For each item in INPUTS:
  - If it's a strings, use the string.
  - If it's a symbol, use the symbol's name via `spy:string/normalize.symbol'.

Returns a list of strings."
  (let ((output nil))
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
                     (error "Function did not return a string: %S -> %S"
                            item
                            result)))
               (error (error "Failed calling %S: %S"
                             item
                             err))))

            ;; Symbol? Use its value.
            ((symbolp item)
             (condition-case-unless-debug err
                 (let ((result (symbol-value item)))
                   (if (stringp result)
                       (push result output)
                     (error "Symbol '%S' does not contain a string value: %S"
                            item
                            result)))
               (error (error "Failed while trying to get symbol value of %S: %S"
                             item
                             err))))))
    ;; `push' pushes to the front of the list, so reverse it for result.
    (nreverse output)))
;; bad: func doesn't return str
;;   (spy:string/normalize.value "Test/ing" 'ignore :jeff)
;; bad: keywords can't have string values
;;   (spy:string/normalize.value "Test/ing" 'spy:test :jeff)
;; good:
;;   (let* ((name "jeff") (name-symbol 'name)) (spy:string/normalize.value "Test/ing" 'spy:test name-symbol))
;;   (let* ((name "jeff")) (spy:string/normalize.value "Test/ing" 'spy:test 'name))


;;------------------------------------------------------------------------------
;; The End.
;;------------------------------------------------------------------------------
(imp:provide :modules 'spy 'strings 'normalize)
