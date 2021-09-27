;;; emacs/str/string.el -*- lexical-binding: t; -*-


;;------------------------------------------------------------------------------
;; Words
;;------------------------------------------------------------------------------

;;------------------------------------------------------------------------------
;; Regions
;;------------------------------------------------------------------------------

;; TODO: move to 'buffer.el'?
(defun str:region->region (start end func &rest args)
  "Convert region from START to END by appling FUNC to that substring and then
replacing the region with the function's results.

FUNC should be a function that returns a string and should have parameters:
  (defun FUNC (string [optional-args]) ...)"
  (save-excursion
    (replace-region-contents start end
                             (apply func (buffer-substring-no-properties (point-min) (point-max)) args))))


;; TODO: (str:thing-at-point->region thing-type ...)


(defun str:word-at-point->region (func &rest cases)
  "Get word at point, then use `str:region->region' to apply the FUNC and ARGS."
  (save-excursion
    ;; We might be in the middle of the word, so go to the end, save that point, and then go back to the start of the word.
    (forward-word)
     (let (start
           (end (point)))
       (backward-word)
       (setq start (point))

       ;; Have a region now, so just call `str:case/region:to'.
       (apply #'str:region->region start end func cases))))


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
;; To String
;;------------------------------------------------------------------------------

(defun int<str>:str:print->str (func &rest args)
  "Calls FUNC with ARGS, returns `standard-output' as a string."
  (with-output-to-string
    (apply func args)))


(defun int<str>:str:insert->str (func &rest args)
  "Calls FUNC with ARGS in a temp buffer, then returns the temp buffer's
contents as a string."
  (with-temp-buffer
    (apply func args)
    (buffer-string)))


;;------------------------------------------------------------------------------
;; The End.
;;------------------------------------------------------------------------------
(imp:provide :str 'string)
