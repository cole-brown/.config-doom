;;; spy/buffer/+name.el -*- lexical-binding: t; -*-


;;----------------------------------Buffers------------------------------------
;;--                    And Things to Make Them Better.                      --
;;-----------------------------------------------------------------------------

(defcustom spy/buffer/format/bookend-normal
  '("§-" "-§")
  "Start/end strings for special-name formats."
  :group 'spy/group
  :type '(list string string))


(defcustom spy/buffer/format/bookend-high
  '("§!" "!§")
  "Start/end strings for special-name formats."
  :group 'spy/group
  :type '(list string string))


(defcustom spy/buffer/format/bookend-info
  '("ⓘ-" "-ⓘ")
  "Start/end strings for special-name formats."
  :group 'spy/group
  :type '(list string string))


(defcustom spy/buffer/format/priorities
  '((:low    . spy/buffer/format/bookend-normal) ;; no actual low right now
    (:medium . spy/buffer/format/bookend-normal)
    (:high   . spy/buffer/format/bookend-high)

    ;; un-normal priority levels
    (:info   . spy/buffer/format/bookend-info))
  "Priority (for `spy/buffer/special-name') to bookend consts."
  :group 'spy/group
  :type '(alist :key-type symbol :value-type symbol))


(defcustom spy/buffer/regexp/bookend
  (rx
   ;; Start Bookend
   ;; Will need to update (or make smarter) if get more actual priority levels.
   (or (eval (nth 0 spy/buffer/format/bookend-normal))
       (eval (nth 0 spy/buffer/format/bookend-high)))

   ;; Actual Buffer Name
   (one-or-more printing)

   ;; End Bookend
   ;; Will need to update (or make smarter) if get more actual priority levels.
   (or (eval (nth 1 spy/buffer/format/bookend-normal))
       (eval (nth 1 spy/buffer/format/bookend-high))))

  "Regexp for matching a bookended buffer name string.
Will need to update (or make smarter) if get more actual priority levels."
  :group 'spy/group
  :type 'regexp)

;;-----------------------------------------------------------------------------
;; Naming Functions
;;-----------------------------------------------------------------------------

(defun spy/buffer/special-name (title &optional desc priority)
  "Format TITLE and DESC strings for `spy/buffer/special-name' with PRIORITY.

PRIORITIES can be: :low, :medium, or :high.

TITLE and DESC are formatted by bookending with
`spy/buffer/format/priorities' bookends based on PRIORITY
setting, with nil being medium priority.
"

  ;; PRIORITY is either known or forced to medium
  (let ((priority (if (assoc priority spy/buffer/format/priorities)
                      priority
                    :medium))
        ;; look for bookends in list, default if fail/nil
        (bookends (or (symbol-value
                       (cdr (assoc priority spy/buffer/format/priorities)))
                      spy/buffer/format/bookend-normal))
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
;; (spy/buffer/special-name "jeff")
;; (spy/buffer/special-name "jeff" "is here")
;; (spy/buffer/special-name "jeff" nil :high)
;; (spy/buffer/special-name "jeff" "is here" :high)

;;------------------------------------------------------------------------------
;; The End.
;;------------------------------------------------------------------------------
(spy/provide :spy 'buffer 'name)
