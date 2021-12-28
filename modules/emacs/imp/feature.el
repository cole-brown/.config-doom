;;; emacs/imp/utils.el -*- lexical-binding: t; -*-

;;------------------------------------------------------------------------------
;; Normalize to keywords/symbols.
;;------------------------------------------------------------------------------

(defun imp:feature:normalize (&rest input)
  "Normalize INPUT to feature in one of two ways.

If only one INPUT param, returns a symbol/keyword.
  - This is useful for converting strings to symbols for e.g. `imp:provide'.
If more than one INPUT param, returns a list of symbol/keywords.

If INPUT item is:
  - Keyword: Return as-is.
  - Symbol:  Return as-is.
  - String:  Convert to a keyword.
E.g.
  1) `:modules' -> `:modules'
  2) `feature' -> `feature'
  3) \"str-4874\" -> `:str-4874'"
  (let (output)
    (dolist (item input)
      (push
       ;; Keyword or symbol? -> no-op
       (cond ((symbolp item)
              item)

             ;; String? Convert to keyword and return.
             ((and (stringp item)
                   (not (string-empty-p item)))
              (message "string->symbol: %S->%S"
                       item
                       (intern
                        ;; Add leading ":" to make it a keyword.
                        (if (not (string-prefix-p ":" item))
                            (concat ":" item)
                          item)))
              (intern
               ;; Add leading ":" to make it a keyword.
               (if (not (string-prefix-p ":" item))
                   (concat ":" item)
                 item)))

             ;; Other? Error.
             (t
              (iii:error "imp:feature:normalize"
                         (concat "Cannot convert INPUT item type to a symbol. "
                                 "Need a string or symbol/keyword. Got: %S")
                         item)))
       output))

    ;; Return the list, the one item, or what?
    (cond ((null output)
           (iii:error "imp:feature:normalize"
                      "No normalized features produced from INPUT: %S"
                      input))

          ((= 1 (length output))
           (nth 0 output))

          (t
           (nreverse output)))))
;; (imp:feature:normalize '+layout/spydez)
;; (imp:feature:normalize :spydez)
;; (imp:feature:normalize "spydez")
;; (imp:feature:normalize "+spydez")
;; (imp:feature:normalize "+spydez" "foo" "bar")
