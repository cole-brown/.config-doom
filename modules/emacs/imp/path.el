;;; emacs/imp/path.el -*- lexical-binding: t; -*-

(require 'dash)

;; imp requirements:
;;   - :imp 'debug
;;   - :imp 'error


;;------------------------------------------------------------------------------
;; Constants & Variables
;;------------------------------------------------------------------------------

(defconst iii:path:roots
  (list (cons :imp (if load-in-progress
                       (file-name-directory load-file-name)
                     (buffer-file-name))))
  "alist of path roots of require/provide root keywords.")


;;------------------------------------------------------------------------------
;; String Helpers
;;------------------------------------------------------------------------------

(defun iii:string:to-string (input)
  "Normalize INPUT.
  - If it's a strings, use the string.
  - If it's a symbol, use the symbol's name.

Returns the normalized string.
"
  ;; String? Direct to output.
  (cond ((stringp input)
         input)

        ;; Funcs are annoying. E.g.:
        ;;   (iii:string:normalize 'org-mode)
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
         (iii:error "iii:string:to-string"
                    "input '%s' cannot be normalized to string."
                    input))))
;; (let ((name "jeff")) (iii:string:to-string name))


(defun iii:string:normalize (&rest inputs)
  "For each item in INPUTS:
  - If it's a strings, use the string.
  - If it's a symbol, use the symbol's name.

Returns a list of strings.
"
  (let ((output nil))
    ;; Insert each item into the output list as it's normalized...
    (dolist (item inputs output)
      (push (iii:string:to-string item) output))

    ;; `push' pushes to the front of the list, so reverse it for result.
    (nreverse output)))
;; (iii:string:normalize "Test/ing" 'jeff :jeff)
;; (let ((name '("jeff" :last-name))) (apply #'iii:string:normalize name))


;;------------------------------------------------------------------------------
;; Path Helpers
;;------------------------------------------------------------------------------

(defun iii:path:get-root (keyword)
  "Get KEYWORD's root path from `iii:path:roots' or signal error.
"
  (or (expand-file-name "" (alist-get keyword iii:path:roots))
      (iii:error "iii:path:get-root"
                 "Root keyword '%S' unknown."
                 keyword)))


(defun iii:path:has-root (keyword)
  "Returns bool based on if `iii:path:roots' contains KEYWORD."
  (not (null (alist-get keyword iii:path:roots))))


(defun iii:path:append (parent next)
  "Append NEXT element as-is to PARENT, adding dir separator between them if
needed.

NEXT and PARENT are expected to be strings.
"
  (let ((next (car (iii:string:normalize next))))
    (if (null parent)
        next
      (concat (file-name-as-directory parent) next))))


(defun iii:path:join (&rest path)
  "Combines PATH elements together into a path platform-agnostically.

(iii:path:join \"jeff\" \"jill.el\")
  ->\"jeff/jill.el\"
"
  (-reduce #'iii:path:append (-flatten path)))


(defun iii:path:get (root &rest path-element)
  "Convert list of PATH-ELEMENT(S) to a load path string.
"
  (apply #'iii:path:join
         ;; Starts at its root...
         (iii:path:get-root root)
         ;; ...and finish with the path-elements.
         path-element))
;; (iii:path:get 'jeff 'jill)


(defun iii:path:valid-root (func path &rest kwargs)
  "Checks that PATH is a vaild root path.

KWARGS should be a plist. All default to `t':
  - :exists - path must exist
  - :dir    - path must be a directory (implies :exists)"
  (-let (((&plist :exists :dir) kwargs)
         (result t))

    ;;---
    ;; Validity Checks
    ;;---
    (when (or exists dir)  ; :dir implies :exists
      (unless (file-exists-p path)
        (iii:error func
                   "Path does not exist: %s"
                   path))
      (setq result nil))

    (when dir
      (unless (file-directory-p path)
        (iii:error func
                   "Path is not a directory: %s"
                   path))
      (setq result nil))

    ;;---
    ;; Return valid
    ;;---
    result))


;;------------------------------------------------------------------------------
;; Load Symbols -> Load Path
;;------------------------------------------------------------------------------

(defun iii:path (&rest symbols)
  "Convert SYMBOLS into a load path."
  (iii:path:join (-map
                  #'iii:string:normalize
                  (-flatten symbols))))
;; (iii:path 'jeff 'jill :home)
;; (iii:path 'test)


;;------------------------------------------------------------------------------
;; Add Root.
;;------------------------------------------------------------------------------

(defun imp:root (keyword path)
  "Set the root PATH of KEYWORD for future `imp:require' calls."
  (cond ((iii:path:has-root keyword)
         (iii:error "imp:root"
                    "Keyword '%S' is already an imp root path: %s"
                    keyword
                    (iii:path:get-root keyword)))

        ((not (keywordp keyword))
         (iii:error "imp:root"
                    "Keyword must be a keyword (e.g. `:foo' `:bar' etc)"))

        ;; iii:path:valid-root will error with better reason, so the error here
        ;; isn't actually triggered.
        ((not (iii:path:valid-root "imp:root" path))
         (iii:error "imp:root"
                    "Path must be a valid directory."))

        ;; Ok; set keyword to path.
        (t
         (push (cons keyword path) iii:path:roots))))



;;------------------------------------------------------------------------------
;; The End.
;;------------------------------------------------------------------------------
;; TODO: provide this
;; (imp:provide :imp 'path)
;; (provide 'imp:path)
