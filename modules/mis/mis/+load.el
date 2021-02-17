;;; mis/helpers/load.el -*- lexical-binding: t; -*-

(require 'dash)

;;------------------------------------------------------------------------------
;; Constants & Variables
;;------------------------------------------------------------------------------

(defconst -m//path/root
  ;; Our parent directory.
  (file-name-directory
   ;; Strip slash out so we can go up a dir...
   (directory-file-name
    ;; Start with the directory of this file.
    (file-name-directory load-file-name)))
  "The root of mis' elisp should be a directory up.")


(defvar -m//load/features '()
  "Mis (internal) features that have been loaded by `-m//load'.")
;; (setq -m//load/features '())


;;------------------------------------------------------------------------------
;; Path Helpers
;;------------------------------------------------------------------------------

(defun -m//string/normalize (input)
  "Normalize INPUT.
  - If it's a strings, use the string.
  - If it's a symbol, use the symbol's name via `-m//string/symbol->str'.

Returns the normalized string.
"
  ;; String? Direct to output.
  (cond ((stringp input)
         input)

        ;; Funcs are annoying. E.g.:
        ;;   (-m//string/normalize 'org-mode)
        ;; I wanted it to stringify the symbol but turns out that's
        ;; a function. Removing the function calls for now.
        ;; ;; Bound func or lambda? Call it for string.
        ;; ((or (fboundp input)
        ;;      (functionp input))
        ;;  (push (funcall input) output))

        ;; Symbol? Use its name.
        ((symbolp input)
         ;; Ignore colons (don't want them from keywords).
         (replace-regexp-in-string "[:+]" ""
                                   (symbol-name input)))

        ;; Error? Do the error thing.
        (t
         (error "-m//string/normalize: input '%s' cannot be normalized."
                input))))
;; (let ((name "jeff")) (-m//string/normalize name))


(defun -m//string/normalize.all (&rest inputs)
  "For each item in INPUTS:
  - If it's a strings, use the string.
  - If it's a symbol, use the symbol's name via `-m//string/symbol->str'.

Returns a list of strings.
"
  (let ((output nil))
    ;; Insert each item into the output list as it's normalized...
    (dolist (item inputs output)
      (push (-m//string/normalize item) output))

    ;; `push' pushes to the front of the list, so reverse it for result.
    (nreverse output)))
;; (-m//string/normalize.all "Test/ing" 'jeff :jeff)
;; (let ((name '("jeff" :last-name))) (apply #'-m//string/normalize.all name))


(defun -m//path/append (parent next)
  "Append NEXT element as-is to PARENT, adding dir separator between them if
needed.

NEXT and PARENT are expected to be strings.
"
  (let ((next (car (-m//string/normalize.all next))))
    (if (null parent)
        next
      (concat (file-name-as-directory parent) next))))


(defun -m//path/join (&rest path)
  "Combines PATH elements together into a path platform-agnostically.

(-m//path/join \"jeff\" \"jill.el\")
  ->\"jeff/jill.el\"
"
  (-reduce #'-m//path/append (-flatten path)))


(defun -m//path/get (&rest path-element)
  "Convert list of PATH-ELEMENT(S) to a load path string.
"
  (apply #'-m//path/join
         ;; Starts at -m//path/root...
         (expand-file-name "" -m//path/root)
         ;; ...and finish with the path-elements.
         path-element))
;; (-m//path/get 'jeff 'jill)


;;------------------------------------------------------------------------------
;; Load Name -> String
;;------------------------------------------------------------------------------

(defun -m//load/name (&rest name)
  "Convert symbols into a mis load name string."
  (-m//path/join (-map
                  #'-m//string/normalize.all
                  (-flatten name))))
;; (-m//load/name 'jeff 'jill :home)
;; (-m//load/name 'test)


;;------------------------------------------------------------------------------
;; Load, Require, Provide
;;------------------------------------------------------------------------------

(defun -m//provided? (&rest name)
  "Checks for NAME in `-m//load/features'."
  (when-let ((feature (apply #'-m//load/name name)))
    ;; Check for the feature in our loaded features and convert to
    ;; a boolean (t/nil).
    (not (null (assoc-string feature -m//load/features)))))
;; (-m//provided? 'internal 'load)


(defun -m//provide (&rest name)
  "Record NAME as having been provided."
  (unless (apply #'-m//provided? name)
    (push (apply #'-m//load/name name) -m//load/features)))


(defun -m//load (&rest load-name)
  "Load a file relative to `-m//path/root' based on LOAD-NAME strings/symbols.

For example, to load \"mis/code/comment.el[c]\":
   (-m//load 'code 'comment)

This is for loading done internally in mis.
"
  (let* ((normal (apply #'-m//string/normalize.all load-name))
         (name (apply #'-m//load/name normal))
         (path (apply #'-m//path/get normal)))
    (condition-case-unless-debug e
        (let (file-name-handler-alist)
          ;(load path nil))
          (load path nil 'nomessage))
    (error "mis fail loading: %s (%S); error: %S" path name e))))
;; (-m//load 'test 'something)


(defun -m//require (&rest require-name)
  "Loads REQUIRE-NAME if not already loaded.
"
  (unless (apply #'-m//provided? require-name)
    (apply #'-m//load require-name)))
;; (-m//require 'test 'this)


;;------------------------------------------------------------------------------
;; The End.
;;------------------------------------------------------------------------------
(-m//provide 'internal 'load)
