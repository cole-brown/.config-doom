;;; mis/code/comment.el -*- lexical-binding: t; -*-

;;----------------------------------------HELP!
;;--         My fancy header generator is broken...                   --
;;------------------------------------------------------------------------------

(-m//require 'internal 'mlist)
(-m//provide 'internal 'debug)


;;------------------------------------------------------------------------------
;; Constants & Variables
;;------------------------------------------------------------------------------

(defconst -m//comments
  '(:adjustment)
  "Valid mis :comment section keywords.")


(defconst -m//comment/adjustment.default
  ;; pycodestyle E265: block comments should start with '# '.
  '(
    (python-mode " ")
    ) ;; "# " as comment start for e.g. "# ---" instead of "#---".
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
           (pad-more (1+ (comment-add nil))))

      (comment-normalize-vars)

      ;;---
      ;; Return a list of: (prefix postfix)
      ;;---
      (list
       ;;---
       ;; Prefix
       ;;---
       ;; Combine comment start string with optional adjustment string.
       (string-trim-left
        (concat
         ;; Use empty string if no comment-right for current major mode.
         (if comment-start
             (s-repeat pad-more comment-start)
           ""))
         adjustment)

       ;;---
       ;; Postfix
       ;;---
       ;; Combine optional comment end string with optional adjustment string.
       (string-trim-right
        (concat
         adjustment
          ;; Use empty string if no comment-left for current major mode.
         (if comment-end
             (s-repeat pad-more comment-end)
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
                                (-m//comment/first :adjustment mlists t)))
            (indent-str (-m//string/indent.get mlists)))
      ;; If we've been asked to box the comment, mirror the prefix.
      (if (and (not (-m//return/invalid?
                     (-m//style/first :boxed mlists nil)))
               (or (null postfix)
                   (string-empty-p postfix)))
          (setq postfix prefix))
      (message "mlists: %S" mlists)
      (message "boxed: %S" (-m//style/first :boxed mlists nil))
      (message "boxed? %s, no postfix? %s->\n  do boxing? %s\n    ->pre/post: ('%s' '%s')"
               (not (-m//return/invalid?
                     (-m//style/first :boxed mlists nil)))
               (null postfix)
               (and (not (-m//return/invalid?
                          (-m//style/first :boxed mlists nil)))
                    (null postfix))
               prefix postfix)

      (concat
       ;; Always indent - will be an empty string if none wanted.
       indent-str
       ;; Trim if asked for. Don't trim the indent string though.
       (mis/string/trim.if
        ;; Build our comment from the mlist and pre/postfixes.
        (s-join (-m//style/first :padding mlists "")
                (list prefix
                      (format "%s" (-m//or comment ""))
                      postfix))
        mlists)))))
;; (mis/comment/wrap "foo")
;; (mis/comment/wrap "foo" (mis/style/padding " "))
;; (-m//return/invalid? (-m//string/first :trim '(:mis t :string (:mis :string :trim :mis/nil)) t) t)
;; (mis/comment/wrap "foo" (mis/string/trim :mis/nil))
;; (mis/comment/wrap "foo" (mis/string/trim t))
;; (mis/comment/wrap "---" nil (mis/comment/adjustment ""))
;; (mis/comment/wrap "")
;; (mis/comment/wrap nil)
;; (mis/comment/wrap (make-string 3 ?-))
;; (mis/comment/wrap (make-string 3 ?-) (mis/string/trim t))
;; (mis/comment/wrap (make-string 3 ?-) (mis/string/indent 'existing))
;; (mis/comment/wrap (make-string 3 ?-) (mis/string/indent 'fixed))
;; (mis/comment/wrap (-m//style/align " foo " (list (mis/style/align :center) (mis/style/padding "-"))))
;; (mis/comment/wrap (-m//style/align " foo " (list (mis/style/align :center) (mis/style/padding "-"))))
;; (mis/comment/wrap "foo" (mis/style/boxed t))


;;------------------------------------------------------------------------------
;; Make headers - like this one!
;;------------------------------------------------------------------------------

(defun mis/comment/line (&rest mlists)
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

If there is a :string/indent in the MLIST(S), use that as the indention amount.
"
  (-let* ((line-fill (-m//style/first :border mlists "-"))
          ((prefix postfix) (-m//comment/adjustments
                             (-m//comment/first :adjustment mlists t)))
          (indent-amt (-m//string/indent.amount mlists))
          (indent-str (-m//string/indent.get mlists))
          ;; Final Width: Full width minus comment pre/postfixes.
          ;; TODO: Make this just (width (-m//line/width ??? mlists))
          (width (- (-m//line/width nil)
                    (-m//style/first :border mlists 0)
                    indent-amt
                    (+ (length prefix)
                       (length postfix)))))

    (mis//when-debugging
     (mis//debug "mis/comment/line"
                 (concat "width: %d <- (- line-width(%d) border(%d) indent(%d) "
                         "prefix(%d) postfix(%d))")
                 width
                 (-m//line/width nil)
                 (-m//style/first :border mlists 0)
                 indent-amt
                 (length prefix)
                 (length postfix)))

    ;; This would divide by zero or some other less helpful error.
    (when (or (null line-fill)
              (= (length line-fill) 0))
      (error "mis/comment/line: Cannot build line without a string: '%s'"
             line-fill))

    ;; Build the line.
    (mis//when-debugging
      (let* ((dbg-fill-len (/ width (length line-fill)))
             (dbg-fill (s-repeat dbg-fill-len line-fill))
             (dbg-line (concat
                        indent-str
                        prefix
                        dbg-fill
                        postfix)))
        (mis//debug "mis/comment/line"
                    "width: %d, line-file: '%s', line-fill-len: %d"
                    width
                    line-fill
                    dbg-fill-len)
        (mis//debug "mis/comment/line"
                    "   fill: ..... '%s'"
                    dbg-fill)
        (mis//debug "mis/comment/line"
                    "   line: '%s'"
                    dbg-line)
        (mis//debug "mis/comment/line"
                    "trimmed: '%s'"
                    (mis/string/trim.if dbg-line mlists))
        (mis//debug "mis/comment/line"
                    "trimmed length: %d"
                    (length (mis/string/trim.if dbg-line mlists)))))

    (mis/string/trim.if (concat
                         indent-str
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
;; (mis/comment/line '((:mis t :string (:mis :string :string nil)) (:mis t :string (:mis :string :indent auto))))
;; (mis/comment/line '((:mis t :string (:mis :string :string nil)) (:mis t :string (:mis :string :indent 4))))
;; (mis/comment/line (mis/string/string nil) (mis/string/indent 'existing))
;; (mis/comment/line (mis/string/indent 'existing))
;; (mis/comment/line (mis/string/indent 4))
;;   -> "    ;;--------------------------------------------------------------------------"
;; (mis/comment/line)
;;   -> ";;------------------------------------------------------------------------------"



(defun mis/comment/header (&rest mlists)
  "Creates a header for a code block of some sort. Uses emacs to figure out
what comment characters to use.

MLISTS should be nil or the results from other 'mis' calls:
    (mis/comment/header)
    (mis/comment/header (mis/string \"title\") (mis/style/border \"-\"))

If there is a :string/string in the MLIST(S), as the header title string.
Otherwise leave the title empty.

See `mis/comment/line' and `mis/comment/wrap' for the rest of the :mis options.
"
  ;; First Line: Separator
  (concat (apply #'mis/comment/line mlists)
          "\n"

          ;; Second Line: Title
          (apply #'mis/comment/wrap (-m//string/first :string mlists "")
                            mlists)
          ;; TODO: Have wrap able to box? Or make mis/comment/box?
          "\n"

          ;; Third Line: Separator
          (apply #'mis/comment/line mlists)))
;; (mis/comment/header)
;; (mis/comment/header (mis/string/string "") (mis/string/indent 'auto))
;; (mis/comment/header (mis/string/string "") (mis/string/indent 'existing))


;;------------------------------------------------------------------------------
;; Comment Output
;;------------------------------------------------------------------------------

(defun mis//out.comment/adjustment.get (mout)
  "Get :comment/adjustment from MOUT list.

Returns :mis/nil if none."
  (-m//out/entry.get :adjustment mout))


(defun mis//out.comment/adjustment.set (value mout)
  "Set :comment/adjustment to VALUE in MOUT list.

Returns updated MOUT list."
  (-m//out/entry.set :adjustment value mout))


;;------------------------------------------------------------------------------
;; The End.
;;------------------------------------------------------------------------------
;; provide to mis and to everyone
(-m//provide 'code 'comment)
(provide 'mis/code/comment)