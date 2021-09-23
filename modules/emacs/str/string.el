;;; emacs/str/string.el -*- lexical-binding: t; -*-

;;------------------------------------------------------------------------------
;; Regions
;;------------------------------------------------------------------------------

(defun str:region->region (start end func &rest args)
  "Convert region from START to END by appling FUNC to that substring and then
replacing the region with the function's results.

FUNC should be a function that returns a string and should have parameters:
  (defun FUNC (string [optional-args]) ...)"
  (save-excursion
    (replace-region-contents start end
                             (apply func (buffer-substring-no-properties (point-min) (point-max)) args))))


;; TODO: (str:word-at-point->region ...)
;; or (str:thing-at-point->region thing-type ...)


;;------------------------------------------------------------------------------
;; Split / Join
;;------------------------------------------------------------------------------

(defun str:split (regex string)
  "Split STRING based on REGEX separators; returns a list of strings
with nils filtered out.

NOTE: Obeys `case-fold-search'! Set `case-fold-search' appropriately for your
needs, or use `str:rx:with/case.sensitive' macro if you want to have
case sensitivity!"
  (declare (pure t) (side-effect-free t))

  ;; Uses character ?\0 (ASCII 0; null) as a marker in the string while working on it.
  (let ((separator (string ?\0)))
    (split-string (save-match-data
                    (replace-regexp-in-string regex
                                              separator
                                              string))
                  separator :omit-nulls)))
;; (str:split (rx (one-or-more (not alphanumeric))) "hello:there")


(defun str:join (separator &rest strings)
  "Join STRINGS with SEPARATOR between them."
  (declare (pure t) (side-effect-free t))
  (string-join strings separator))


;;------------------------------------------------------------------------------
;; Conversion
;;------------------------------------------------------------------------------

(defun str:normalize->keyword (input)
  "Convert INPUT to a keyword.

If INPUT is already a keyword, return as-is.
If INPUT is nil, return nil.
If INPUT is a symbol, get its `symbol-name', and convert to a keyword.
If INPUT is a string (leading ':' is optional), convert to a keyword."
  (cond ((null input)
         nil)
        ((keywordp input)
         input)
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
         (error "Unsupported INPUT type of '%S': %S"
                (type-of input)
                input))))


;;------------------------------------------------------------------------------
;; The End.
;;------------------------------------------------------------------------------
(imp:provide:with-emacs :str 'string)
