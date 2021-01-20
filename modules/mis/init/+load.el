;;; mis/helpers/load.el -*- lexical-binding: t; -*-

(require 'dash)

;;------------------------------------------------------------------------------
;; Constants & Variables
;;------------------------------------------------------------------------------

(defconst -m//path/root ".."
  "The root of mis' elisp should be a directory up.")

(defvar -m//load/features '()
  "Mis (internal) features that have been loaded by `-m//load'.")


;;------------------------------------------------------------------------------
;; Path Helpers
;;------------------------------------------------------------------------------

(defun -m//string/normalize (&rest inputs)
  "For each item in INPUTS:
  - If it's a strings, use the string.
  - If it's a symbol, use the symbol's name via `-m//string/symbol->str'.

Returns a list of strings.
"
  (let ((output nil))
    (dolist (item inputs output)
      ;; String? Direct to output.
      (cond ((stringp item)
             (push item output))

            ;; Funcs are annoying. E.g.:
            ;;   (-m//string/symbol/normalize 'org-mode)
            ;; I wanted it to stringify the symbol but turns out that's
            ;; a function. Removing the function calls for now.
            ;; ;; Bound func or lambda? Call it for string.
            ;; ((or (fboundp item)
            ;;      (functionp item))
            ;;  (push (funcall item) output))

            ;; Symbol? Use its name.
            ((symbolp item)
             ;; Ignore colons (don't want them from keywords).
             (push (replace-regexp-in-string ":" ""
                                             (symbol-name symbol))
                   output))))
    ;; `push' pushes to the front of the list, so reverse it for result.
    (nreverse output)))
;; (-m//string/symbol/normalize "Test/ing" 'jeff :jeff)

(defun -m//path/append (parent next)
  "Append NEXT element as-is to PARENT, adding dir separator between them if
needed.

NEXT and PARENT are expected to be strings.
"
  (let ((next (car (-m//string/symbol/normalize next))))
    (if (null parent)
        next
      (concat (file-name-as-directory parent) next))))


(defun -m//path/join (&rest path)
  "Combines PATH elements together into a path platform-agnostically.

(-m//path/join \"jeff\" \"jill.el\")
  ->\"jeff/jill.el\"
"
  (-reduce #'-m//path/append (-flatten path)))


(defun -m//path/get (&rest symbols)
  "Convert list of symbol names to a load path string.
"
   (apply #'-m//path/join
          ;; Starts at -m//path/root...
          (expand-file-name "" -m//path/root)
          ;; Include the path symbols as strings.
          (-map (lambda (sym)
                  "Convert symbol to string and remove ':'."
                  (replace-regexp-in-string "[:+]" ""
                                            (symbol-name sym)))
                (-flatten symbols))))
;; (-m//path/get 'jeff 'jill)


;;------------------------------------------------------------------------------
;; Load Name -> String
;;------------------------------------------------------------------------------

(defun -m//load/name (&rest name)
  "Convert symbols into a mis load name string."
  (-m//path/join (-map
                  (lambda (sym)
                    "Convert symbol to string and remove ':'."
                    (replace-regexp-in-string ":" ""
                                              (symbol-name sym)))
                  (-flatten name))))
;; (-m//load/name 'jeff 'jill :home)


;;------------------------------------------------------------------------------
;; Load, Require, Provide
;;------------------------------------------------------------------------------

(defun -m//provided? (&rest name)
  "Checks for NAME in `-m//load/features'."
  (when-let ((feature (-m//load/name name)))
    ;; Check for the feature in our loaded features and convert to
    ;; a boolean (t/nil).
    (not (null (assoc-string feature -m//load/features)))))
;; (-m//provided? 'internal 'load)


(defun -m//provide (&rest name)
  "Record NAME as having been provided."
  (unless (-m//provided? name)
    (push (-m//load/name name) -m//load/features)))


(defun -m//require (&rest name)
  "Loads NAME if not already loaded.
"
  (unless (-m//provided? name)
    (-m//load name)))


(defmacro -m//load (&rest name)
  "Load a file relative to `-m//path/root' based on NAME symbols.

For example, to load \"mis/code/comment.el[c]\":
   (-m//load 'code 'comment)

This is for loading done internally in mis.
"
  ;; TODO: keep a 'feature list' of loaded mis stuff?
  (let ((path (apply #'-m//path/get name)))
    `(condition-case-unless-debug e
         (let (file-name-handler-alist)
           (load ,path nil 'nomessage)
       (error "mis fail loading: %s (%S)" path name)))))


;;------------------------------------------------------------------------------
;; The End.
;;------------------------------------------------------------------------------
(-m//provide 'internal 'load)
