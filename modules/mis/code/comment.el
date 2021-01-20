;;; mis/code/comment.el -*- lexical-binding: t; -*-

;;----------------------------------------HELP!
;;--         My fancy header generator is broken...                   --
;;------------------------------------------------------------------------------

(-m//require 'internal 'mlist)


;;------------------------------------------------------------------------------
;; Constants & Variables
;;------------------------------------------------------------------------------

(defconst -m//comments
  '(:adjustment)
  "Valid mis :comment section keywords.")


(defconst -m//comment/adjustment.default
  ;; pycodestyle E265: block comments should start with '# '.
  '((python-mode " ")) ;; "# " as comment start for e.g. "# ---" instead of "#---".
  "Adjustments to `comment-start'/`comment-stop' per mode.
e.g. python-mode can ask for a space after it's comment characters to ensure
pylint is happier w/ wrapped or centered comments generated by
these functions.")


;;------------------------------------------------------------------------------
;; General Getters/Setters
;;------------------------------------------------------------------------------

(defun -m//comment/get (key mlist &optional default)
  "Get a comment value from this mlist.
"
  (-m//section/get key :comment mlist -m//comments default))


(defun -m//comment/set (key value mlist)
  "Set a comment value in this mlist.
"
  (-m//section/set key value :comment mlist -m//comments))


(defun -m//comment/first (key mlists &optional default)
  "Get first comment match for KEY in MLISTS. Returns DEFAULT if no matches.

Use `:mis/nil', `:mis/error', etc for default if you have a \"nil is valid\"
situation in the calling code.
"
  (-m//mlists/get.first key :comment mlists -m//comments default))
;; (-m//comment/first :border '((:mis t :string (:mis :string :trim t))) :mis/nil)


;;------------------------------------------------------------------------------
;; Field Setters
;;------------------------------------------------------------------------------

(defun mis/comment/adjustment (width &optional mlist)
  "Sets a `comment-start'/`comment-stop' adjustment. Returns an mlist.
"
  (-m//comment/set :adjustment width mlist))


;;------------------------------------------------------------------------------
;; Helpers
;;------------------------------------------------------------------------------

(defun -m//comment/ignore ()
  "Guesses whether to ignore everything based on Emacs' comment-* vars/funcs.
"
  ;; If comment-start is null, ignore.
  (null comment-start))


(defmacro -m//comment/unless (&rest body)
  "Runs BODY forms if `-m//comment/ignore' is non-nil.
"
  (declare (indent defun))
  `(unless (-m//comment/ignore)
     ,@body))


(defun -m//comment/adjustments (&optional with-adjustments)
  "Gets comment prefix/postfix appropriate for mode.

Uses `comment-*' emacs functions.

Returns a list of (comment-start-str comment-end-str)
  - e.g. elisp-mode: (\";;\" nil)
"
  (-m//comment/unless
    (let* ((adjustment
            (when with-adjustments
                (nth 1 (assoc major-mode
                              -m//comment/adjustment.default))))
           (pad-more (comment-add nil)))

      ;;---
      ;; Return a list of: (prefix postfix)
      ;;---
      (list
       ;;---
       ;; Prefix
       ;;---
       ;; Combine comment start string with optional adjustment string.
       (concat
        (string-trim-right
         ;; Use empty string if no comment-right for current major mode.
         (or (comment-padright comment-start pad-more)
             ""))
        adjustment)

       ;;---
       ;; Postfix
       ;;---
       ;; Combine optional comment end string with optional adjustment string.
       (concat
        adjustment
        (string-trim-left
         ;; Use empty string if no comment-left for current major mode.
         (or (comment-padleft comment-end pad-more)
             "")))))))
;; (-m//comment/adjustments)
;; (nth 0 (-m//comment/adjustments))
;; (nth 1 (-m//comment/adjustments))
;; (length (nth 1 (-m//comment/adjustments)))


;;------------------------------------------------------------------------------
;; Wrap string into comment chars.
;;------------------------------------------------------------------------------

(defun mis/comment/wrap (comment &rest mlists)
  "Turns COMMENT into a string and then into a proper comment based on mode
(uses `comment-*' emacs functions).

If there is a :style/padding in the MLIST(S), use it between comment prefix,
comment, and comment postfix. Else use a space.

If there is a :comment/adjustment in the MLIST(S), pass it to
`-m//comment/borders' as WITH-ADJUSTMENTS arg.

Defaults to trimming the string; override with a :string/trim of
`nil'/`:mis/nil' in the MLIST(S).
"
  (-m//comment/unless
    (-let* (((prefix postfix) (-m//comment/adjustments
                               (-m//comment/first :adjustment mlists :mis/nil)))
            (comment (s-join (-m//style/first :padding mlists " ")
                             (list prefix (format "%s" comment) postfix))))
      (mis/string/trim.if comment mlists))))
;; (mis/comment/wrap "foo")
;; (-m//return/invalid? (-m//string/first :trim '(:mis t :string (:mis :string :trim :mis/nil)) t) t)
;; (mis/comment/wrap "foo" (mis/string/trim :mis/nil))
;; (mis/comment/wrap "foo" (mis/string/trim t))
;; (mis/comment/wrap "---" nil (mis/comment/adjustment ""))
;; (mis/comment/wrap "")
;; (mis/comment/wrap (make-string 3 ?-))
;; (mis/comment/wrap (make-string 3 ?-))


;;------------------------------------------------------------------------------
;; Make headers - like this one!
;;------------------------------------------------------------------------------

(defun mis/comment/line (&optional mlists)
  "Create a commented line separator, like:
;;--------

MLISTS should be nil or the results from other 'mis' calls:
    (mis/comment/line)
    (mis/comment/line (mis/style/width 80) (mis/style/border \"-\"))

If there is a :style/border in t he MLIST(S), use it as the line separator
string. Otherwise use \"-\".

If there is a :comment/adjustment in the MLIST(S), pass it to
`-m//comment/borders' as WITH-ADJUSTMENTS arg.

If there is a :style/width in the MLIST(S), use it as the full width of the
line; otherwise use `fill-column'.
"
  (-let* ((line-fill (-m//style/first :border mlists "-"))
          ((prefix postfix) (-m//comment/adjustments
                             (-m//comment/first :adjustment mlists :mis/nil)))
          ;; Final Width: Full width minus comment pre/postfixes.
          (width (- (-m//style/first :border mlists fill-column)
                    (+ (length prefix)
                       (length postfix)))))
    (message "lf: %S, pre: %S, post: %S, width: %S" line-fill prefix postfix width)
    (message "lf repeats: %S"
(/ width
                                      (length line-fill))
             )
    (message "line: %S"
(s-repeat (/ width
                                      (length line-fill))
                                   line-fill)
             )
    ;; This would divide by zero or some other less helpful error.
    (when (or (null line-fill)
              (= (length line-fill) 0))
      (error "mis/comment/line: Cannot build line without a string: '%s'"
             line-fill))

    ;; Build the line.
    (mis/string/trim.if (concat
                         ;; First: Comment prefix.
                         prefix
                         ;; Second: Line string of correct width.
                         (s-repeat (/ width
                                      (length line-fill))
                                   line-fill)

                         ;; Third: Comment postfix.
                         postfix)
                        mlists)))
;; (mis/comment/line)
;; (insert (mis/comment/line))


(defun mis/comment/header (&optional mlists)
  "Creates a header for a code block of some sort. Uses emacs to figure out
what comment characters to use.

MLISTS should be nil or the results from other 'mis' calls:
    (mis/comment/header)
    (mis/comment/header (mis/string \"title\") (mis/style/border \"-\"))

If there is a :string/string in the MLIST(S), as the header title string.
Otherwise leave the title empty.

See `mis/comment/line' and `mis/comment/wrap' for the rest of the :mis options.
"
  ;; TODO: get all this stuff (optionally) from the mlists
  (let* ((title nil))

    ;; First Line: Separator
    (concat (mis/comment/line mlists)
            "\n"

            ;; Second Line: Title
            (mis/comment/wrap (-m//string/first :string mlists "")
                              mlists)
            ;; TODO: Have wrap able to box? Or make mis/comment/box?
            ;; nth 0 comment-parts)
            ;; itle-prefix
            ;; itle
            ;; ; Pad-right to full width if we have a comment postfix.
            ;; if (null (nth 1 comment-parts))
            ;;    ;; No padding; no postfix if its null.
            ;;    ""
            ;;  ;; Else let's build the right padding and tack the postfix on here.
            ;;  (concat
            ;;   (make-string
            ;;    (- width
            ;;       (length title-prefix)
            ;;       (length title))
            ;;    ?\s)
            ;;   (nth 1 comment-parts)))
            "\n"

            ;; Third Line: Separator
            (mis/comment/line mlists))))
;; (mis/comment/header)


;;------------------------------------------------------------------------------
;; The End.
;;------------------------------------------------------------------------------
;; provide to mis and to everyone
(-m//provide 'code 'comment)
(provide 'mis/code/comment)
