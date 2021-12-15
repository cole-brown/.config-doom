;;; mis/code/comment.el -*- lexical-binding: t; -*-


;;----------------------------------------HELP!
;;--         My fancy header generator is broken...                   --
;;------------------------------------------------------------------------------

(imp:require :mis 'internal 'mlist)
(imp:require :mis 'internal 'debug)


;;------------------------------------------------------------------------------
;; Constants & Variables
;;------------------------------------------------------------------------------

(defconst int<mis>:comments
  '(:adjustment)
  "Valid mis :comment section keywords.")


(defconst int<mis>:comment:adjustment.default
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

(defun int<mis>:comment:get (key mlist &optional default)
  "Get a comment value from this mlist.
"
  (int<mis>:section/get key :comment mlist int<mis>:comments default))


(defun int<mis>:comment:set (key value mlist)
  "Set a comment value in this mlist.
"
  (int<mis>:section/set key value :comment mlist int<mis>:comments))


(defun int<mis>:comment:first (key mlists &optional default)
  "Get first comment match for KEY in MLISTS. Returns DEFAULT if no matches.

Use `:mis/nil', `:mis/error', etc for default if you have a \"nil is valid\"
situation in the calling code.
"
  (int<mis>:mlists/get.first key :comment mlists int<mis>:comments default))
;; (int<mis>:comment:first :border '((:mis t :string (:mis :string :trim t))) :mis/nil)


;;------------------------------------------------------------------------------
;; Field Setters
;;------------------------------------------------------------------------------

(defun mis:comment:adjustment (width &optional mlist)
  "Sets a `comment-start'/`comment-stop' adjustment. Returns an mlist.
"
  (int<mis>:comment:set :adjustment width mlist))


;;------------------------------------------------------------------------------
;; Helpers
;;------------------------------------------------------------------------------

(defun int<mis>:comment:ignore ()
  "Guesses whether to ignore everything based on Emacs' comment-* vars/funcs.
"
  ;; If comment-start is null, ignore.
  (null comment-start))


(defmacro int<mis>:comment:unless (&rest body)
  "Runs BODY forms if `int<mis>:comment:ignore' is non-nil.
"
  (declare (indent defun))
  `(unless (int<mis>:comment:ignore)
     ,@body))


(defun int<mis>:comment:adjustments (&optional with-adjustments)
  "Gets comment prefix/postfix appropriate for mode.

Uses `comment-*' emacs functions.

Returns a list of (comment-start-str comment-end-str)
  - e.g. elisp-mode: (\";;\" nil)
"
  (int<mis>:comment:unless
    (let* ((adjustment
            (when with-adjustments
              (nth 1 (assoc major-mode
                            int<mis>:comment:adjustment.default))))
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
;; (int<mis>:comment:adjustments)
;; (nth 0 (int<mis>:comment:adjustments))
;; (nth 1 (int<mis>:comment:adjustments))
;; (length (nth 1 (int<mis>:comment:adjustments)))


;;------------------------------------------------------------------------------
;; Wrap string into comment chars.
;;------------------------------------------------------------------------------

(defun mis:comment:wrap (comment &rest mlists)
  "Turns COMMENT into a string and then into a proper comment based on mode
(uses `comment-*' emacs functions).

If there is a :style/padding in the MLIST(S), use it between comment prefix,
comment, and comment postfix. Else use a space.

If there is a :comment/adjustment in the MLIST(S), pass it to
`int<mis>:comment:borders' as WITH-ADJUSTMENTS arg.

Defaults to trimming the string; override with a :string/trim of
`nil'/`:mis/nil' in the MLIST(S).
"
  (int<mis>:comment:unless
    (-let* (((prefix postfix) (int<mis>:comment:adjustments
                               (int<mis>:comment:first :adjustment mlists t)))
            (indent-str (int<mis>:string:indent.get mlists)))
      ;; If we've been asked to box the comment, mirror the prefix.
      (if (and (not (int<mis>:return:invalid?
                     (int<mis>:style:first :boxed mlists nil)))
               (or (null postfix)
                   (string-empty-p postfix)))
          (setq postfix prefix))
      (message "mlists: %S" mlists)
      (message "boxed: %S" (int<mis>:style:first :boxed mlists nil))
      (message "boxed? %s, no postfix? %s->\n  do boxing? %s\n    ->pre/post: ('%s' '%s')"
               (not (int<mis>:return:invalid?
                     (int<mis>:style:first :boxed mlists nil)))
               (null postfix)
               (and (not (int<mis>:return:invalid?
                          (int<mis>:style:first :boxed mlists nil)))
                    (null postfix))
               prefix postfix)

      (concat
       ;; Always indent - will be an empty string if none wanted.
       indent-str
       ;; Trim if asked for. Don't trim the indent string though.
       (mis:string:trim.if
        ;; Build our comment from the mlist and pre/postfixes.
        (s-join (int<mis>:style:first :padding mlists "")
                (list prefix
                      (format "%s" (int<mis>:or comment ""))
                      postfix))
        mlists)))))
;; (mis:comment:wrap "foo")
;; (mis:comment:wrap "foo" (mis:style:padding " "))
;; (int<mis>:return:invalid? (int<mis>:string:first :trim '(:mis t :string (:mis :string :trim :mis/nil)) t) t)
;; (mis:comment:wrap "foo" (mis:string:trim :mis/nil))
;; (mis:comment:wrap "foo" (mis:string:trim t))
;; (mis:comment:wrap "---" nil (mis:comment:adjustment ""))
;; (mis:comment:wrap "")
;; (mis:comment:wrap nil)
;; (mis:comment:wrap (make-string 3 ?-))
;; (mis:comment:wrap (make-string 3 ?-) (mis:string:trim t))
;; (mis:comment:wrap (make-string 3 ?-) (mis:string:indent 'existing))
;; (mis:comment:wrap (make-string 3 ?-) (mis:string:indent 'fixed))
;; (mis:comment:wrap (int<mis>:style:align " foo " (list (mis:style:align :center) (mis:style:padding "-"))))
;; (mis:comment:wrap (int<mis>:style:align " foo " (list (mis:style:align :center) (mis:style:padding "-"))))
;; (mis:comment:wrap "foo" (mis:style:boxed t))


;;------------------------------------------------------------------------------
;; Make headers - like this one!
;;------------------------------------------------------------------------------

(defun mis:comment:line (&rest mlists)
  "Create a commented line separator, like:
;;--------

MLISTS should be nil or the results from other 'mis' calls:
    (mis:comment:line)
    (mis:comment:line (mis:style:width 80) (mis:style:border \"-\"))

If there is a :style/border in t he MLIST(S), use it as the line separator
string. Otherwise use \"-\".

If there is a :comment/adjustment in the MLIST(S), pass it to
`int<mis>:comment:borders' as WITH-ADJUSTMENTS arg.

If there is a :style/width in the MLIST(S), use it as the full width of the
line; otherwise use `fill-column'.

If there is a :string/indent in the MLIST(S), use that as the indention amount.
"
  (-let* ((func.name "mis:comment:line")
          (debug.tags '(:output :comment))
          (line-fill (int<mis>:style:first :border mlists "-"))
          ((prefix postfix) (int<mis>:comment:adjustments
                             (int<mis>:comment:first :adjustment mlists t)))
          (indent-amt (int<mis>:string:indent.amount mlists))
          (indent-str (int<mis>:string:indent.get mlists))
          ;; Final Width: Full width minus comment pre/postfixes.
          ;; TODO: Make this just (width (int<mis>:line/width ??? mlists))
          (width (- (int<mis>:line/width nil)
                    (int<mis>:style:first :border mlists 0)
                    indent-amt
                    (+ (length prefix)
                       (length postfix)))))

    (int<mis>:when-debugging
     (nub:debug int<mis>:nub:user
                func.name
                debug.tags
                '("width: %d <- (- line-width(%d) border(%d) indent(%d) "
                  "prefix(%d) postfix(%d))")
                width
                (int<mis>:line/width nil)
                (int<mis>:style:first :border mlists 0)
                indent-amt
                (length prefix)
                (length postfix)))

    ;; This would divide by zero or some other less helpful error.
    (when (or (null line-fill)
              (= (length line-fill) 0))
      (nub:error int<mis>:nub:user
                 func.name
                 "Cannot build line without a string: '%s'"
                 line-fill))

    ;; Build the line.
    (int<mis>:when-debugging
     (let* ((dbg-fill-len (/ width (length line-fill)))
            (dbg-fill (s-repeat dbg-fill-len line-fill))
            (dbg-line (concat
                       indent-str
                       prefix
                       dbg-fill
                       postfix)))
       (nub:debug int<mis>:nub:user
                  func.name
                  debug.tags
                  "width: %d, line-file: '%s', line-fill-len: %d"
                  width
                  line-fill
                  dbg-fill-len)
       (nub:debug  int<mis>:nub:user
                   func.name
                   debug.tags
                   "   fill: ..... '%s'"
                   dbg-fill)
       (nub:debug  int<mis>:nub:user
                   func.name
                   debug.tags
                   "   line: '%s'"
                   dbg-line)
       (nub:debug  int<mis>:nub:user
                   func.name
                   debug.tags
                   "trimmed: '%s'"
                   (mis:string:trim.if dbg-line mlists))
       (nub:debug  int<mis>:nub:user
                   func.name
                   debug.tags
                   "trimmed length: %d"
                   (length (mis:string:trim.if dbg-line mlists)))))

    (mis:string:trim.if (concat
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
;; (mis:comment:line)
;; (insert (mis:comment:line))
;; (mis:comment:line '((:mis t :string (:mis :string :string nil)) (:mis t :string (:mis :string :indent auto))))
;; (mis:comment:line '((:mis t :string (:mis :string :string nil)) (:mis t :string (:mis :string :indent 4))))
;; (mis:comment:line (mis:string:string nil) (mis:string:indent 'existing))
;; (mis:comment:line (mis:string:indent 'existing))
;; (mis:comment:line (mis:string:indent 4))
;;   -> "    ;;--------------------------------------------------------------------------"
;; (mis:comment:line)
;;   -> ";;------------------------------------------------------------------------------"



(defun mis:comment:header (&rest mlists)
  "Creates a header for a code block of some sort. Uses emacs to figure out
what comment characters to use.

MLISTS should be nil or the results from other 'mis' calls:
    (mis:comment:header)
    (mis:comment:header (mis:string \"title\") (mis:style:border \"-\"))

If there is a :string/string in the MLIST(S), as the header title string.
Otherwise leave the title empty.

See `mis:comment:line' and `mis:comment:wrap' for the rest of the :mis options.
"
  ;; First Line: Separator
  (concat (apply #'mis:comment:line mlists)
          "\n"

          ;; Second Line: Title
          (apply #'mis:comment:wrap (int<mis>:string:first :string mlists "")
                 mlists)
          ;; TODO: Have wrap able to box? Or make mis:comment:box?
          "\n"

          ;; Third Line: Separator
          (apply #'mis:comment:line mlists)))
;; (mis:comment:header)
;; (mis:comment:header (mis:string:string "") (mis:string:indent 'auto))
;; (mis:comment:header (mis:string:string "") (mis:string:indent 'existing))


;;------------------------------------------------------------------------------
;; Comment Output
;;------------------------------------------------------------------------------

(defun int<mis>:out.comment:adjustment.get (mout)
  "Get :comment/adjustment from MOUT list.

Returns :mis/nil if none."
  (int<mis>:mlist:entry.get :adjustment mout))


(defun int<mis>:out.comment:adjustment.set (value mout)
  "Set :comment/adjustment to VALUE in MOUT list.

Returns updated MOUT list."
  (int<mis>:mlist:entry.set :adjustment value mout))


;;------------------------------------------------------------------------------
;; The End.
;;------------------------------------------------------------------------------
(imp:provide:with-emacs :mis 'code 'comment)
