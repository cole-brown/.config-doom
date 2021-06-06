;;; spy/buffer/+name.el -*- lexical-binding: t; -*-


;;----------------------------------Buffers------------------------------------
;;--                    And Things to Make Them Better.                      --
;;-----------------------------------------------------------------------------

(defcustom spy:buffer/format/bookend-normal
  '("§-" "-§")
  "Start/end strings for special-name formats."
  :group 'spy:group
  :type '(list string string))


(defcustom spy:buffer/format/bookend-high
  '("§!" "!§")
  "Start/end strings for special-name formats."
  :group 'spy:group
  :type '(list string string))


(defcustom spy:buffer/format/bookend-info
  '("ⓘ-" "-ⓘ")
  "Start/end strings for special-name formats."
  :group 'spy:group
  :type '(list string string))


(defcustom spy:buffer/format/priorities
  '((:low    . spy:buffer/format/bookend-normal) ;; no actual low right now
    (:medium . spy:buffer/format/bookend-normal)
    (:high   . spy:buffer/format/bookend-high)

    ;; un-normal priority levels
    (:info   . spy:buffer/format/bookend-info))
  "Priority (for `spy:buffer/special-name') to bookend consts."
  :group 'spy:group
  :type '(alist :key-type symbol :value-type symbol))


(defcustom spy:buffer/regexp/bookend
  (rx
   ;; Start Bookend
   ;; Will need to update (or make smarter) if get more actual priority levels.
   (or (eval (nth 0 spy:buffer/format/bookend-normal))
       (eval (nth 0 spy:buffer/format/bookend-high))
       (eval (nth 0 spy:buffer/format/bookend-info)))

   ;; Actual Buffer Name
   (one-or-more printing)

   ;; End Bookend
   ;; Will need to update (or make smarter) if get more actual priority levels.
   (or (eval (nth 1 spy:buffer/format/bookend-normal))
       (eval (nth 1 spy:buffer/format/bookend-high))
       (eval (nth 1 spy:buffer/format/bookend-info))))

  "Regexp for matching a bookended buffer name string.
Will need to update (or make smarter) if get more actual priority levels."
  :group 'spy:group
  :type 'regexp)


(defcustom spy:buffer/regexp/specials
  (rx
   ;;---
   ;; Begin
   ;;---
   line-start
   (or
    ;;---
    ;; Emacs
    ;;---
    ;; Special buffers start with "*", optionally with leading space.
    (group
     (optional " ")
     "*" ;; literal asterisk
     (one-or-more printing)
     "*")

    ;;---
    ;; :spy/buffer
    ;;---
    ;; Bookended Buffer Names are special
    (group
     (optional " ") ;; Allow optional make-less-visible leading space.
     ;; Start Bookend
     (or (eval (nth 0 spy:buffer/format/bookend-normal))
         (eval (nth 0 spy:buffer/format/bookend-high))
         (eval (nth 0 spy:buffer/format/bookend-info)))

     ;; Actual Buffer Name
     (one-or-more printing)

     ;; End Bookend
     (or (eval (nth 1 spy:buffer/format/bookend-normal))
         (eval (nth 1 spy:buffer/format/bookend-high))
         (eval (nth 1 spy:buffer/format/bookend-info)))))
   ;;---
   ;; Done
   ;;---
   line-end)
  "Regexp for matching a special buffer name string. Special buffers are:
  - Emacs' special, visible \"*<name>*\" buffers.
  - Emacs' special, less-visible \" *<name>*\" buffers (leading space).
  - :spy/buffer's special bookended buffers: \"§- <name> -§\" (and other bookends)."
  :group 'spy:group
  :type 'regexp)


;;-----------------------------------------------------------------------------
;; Naming Functions
;;-----------------------------------------------------------------------------

(defun spy:buffer/special-name (title &optional desc priority)
  "Format TITLE and DESC strings for `spy:buffer/special-name' with PRIORITY.

PRIORITIES can be: :low, :medium, or :high.

TITLE and DESC are formatted by bookending with
`spy:buffer/format/priorities' bookends based on PRIORITY
setting, with nil being medium priority.
"

  ;; PRIORITY is either known or forced to medium
  (let ((priority (if (assoc priority spy:buffer/format/priorities)
                      priority
                    :medium))
        ;; look for bookends in list, default if fail/nil
        (bookends (or (symbol-value
                       (cdr (assoc priority spy:buffer/format/priorities)))
                      spy:buffer/format/bookend-normal))
        ;; "title" or "title: desc"
        (inner-fmt (if (null desc) "%s" "%s: %s")))

    ;; inner format: "title" or "title: desc", as decided above by `inner-fmt'
    (format
     ;; outer format: "<bookend> <inner-format-%s> <bookend>"
     (format "%s %s %s"
             (nth 0 bookends)
             inner-fmt
             (nth 1 bookends))
     title desc)))
;; (spy:buffer/special-name "jeff")
;; (spy:buffer/special-name "jeff" "is here")
;; (spy:buffer/special-name "jeff" nil :high)
;; (spy:buffer/special-name "jeff" "is here" :high)


(defun spy:buffer/is-special (buffer-or-name)
  "Returns non-nil if BUFFER-OR-NAME is a specially named buffer.

Special buffers are:
  - Emacs' special, visible \"*<name>*\" buffers.
  - Emacs' special, less-visible \" *<name>*\" buffers (leading space).
  - :spy/buffer's special bookended buffers: \"§- <name> -§\" (and other bookends)."
  (string-match-p
   spy:buffer/regexp/specials
   (if (bufferp buffer-or-name)
       (buffer-name buffer-or-name)
     buffer-or-name)))
;; (spy:buffer/is-special (spy:buffer/special-name "jeff"))
;; (spy:buffer/is-special "*Messages*")
;; (spy:buffer/is-special "file.txt")


;;------------------------------------------------------------------------------
;; Copy Buffer File/Dir Name Functions
;;------------------------------------------------------------------------------

;; This (or similar (prelude-copy-file-name-to-clipboard)) used to be in Prelude
;; Emacs.
;;   https://github.com/bbatsov/prelude/issues/764
(defun spy:cmd:file-name/clipboard ()
  "Copy the current file name to the clipboard"
  (interactive)
  (let ((filename (if (equal major-mode 'dired-mode)
                      default-directory
                    (buffer-file-name))))
    (when filename
      ;; Copy to the clipboard and kill ring so it's available outside Emacs.
      (with-temp-buffer
        (insert filename)
        (clipboard-kill-region (point-min) (point-max)))
      (message "Copied buffer file name '%s' to the clipboard." filename)
      )))


;; This is more complex. Can do buffer file path or dired. C-u for folder
;; instead of file.
;;   http://ergoemacs.org/emacs/emacs_copy_file_path.html
;; Originally `xah-file-path'. Originally only used `kill-new' - modified to put
;; in clipboard too (`clipboard-kill-region').
(defun spy:cmd:file-or-dir-name/clipboard (&optional dir-path-only-p)
  "Copy the current buffer's file path or dired path to `kill-ring'.
Result is full path.
If `universal-argument' is called first, copy only the dir path.

If in dired, copy the file/dir cursor is on, or marked files.

If a buffer is not file and not dired, copy value of `default-directory' (which
is usually the “current” dir when that buffer was created)."
  (interactive "P")
  (let ((path
         (if (string-equal major-mode 'dired-mode)
             (progn
               (let ((result (mapconcat 'identity (dired-get-marked-files) "\n")))
                 (if (equal (length result) 0)
                     (progn default-directory )
                   (progn result))))
           (if (buffer-file-name)
               (buffer-file-name)
             (expand-file-name default-directory)))))
    (kill-new
     (if dir-path-only-p
         (progn
           (message "Directory path copied: 「%s」" (file-name-directory path))
           (file-name-directory path))
       (progn
         (message "File path copied: 「%s」" path)
         path)))))


;;------------------------------------------------------------------------------
;; The End.
;;------------------------------------------------------------------------------
(spy:provide :spy 'buffer 'name)
