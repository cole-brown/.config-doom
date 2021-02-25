;;; spy/buffer/+manage.el -*- lexical-binding: t; -*-



;;------------------------------------------------------------------------------
;; Kill Functions
;;------------------------------------------------------------------------------

;; Like `kill-buffer-ask' but no confirmation for unmodified buffers.
(defun spy/buffer/kill.ask (buffer &optional delete-process)
  "Kill BUFFER if confirmed. No confirm given for unmodified
buffers; just kill.

Returns buffer-name on kill, nil on no kill."
  ;; so... kill?
  (if (or
         ;; just kill it if not modified
         (not (buffer-modified-p buffer))
         ;; or ask first if modded
         (yes-or-no-p (format "Buffer '%s' HAS BEEN EDITED.  Kill? "
                                 (buffer-name buffer))))
    ;; ok - kill
    (prog1
        ;; return name when killed
        (buffer-name buffer)
      (when delete-process (spy/buffer/process.delete buffer))
      (kill-buffer buffer))
    ;; else, ret nil when no kill
    nil))


(defun spy/buffer/kill.special (arg)
  "Kills my special(ly named) buffers, and deletes any process they may have
running.

If ARG is the symbol `by-regexp', use `spy/buffer/regexp/bookend' to kill
special buffers.

If ARG is a string, the `spy/buffer/regexp/bookend' is checked to see if the
stcring/regexp is 'correctly' guarded by them, adding them in if needed. It uses
`spy/buffer/special-name' with nil priority to add the bookends.

If ARG is not a string, assume it's a buffer and try to kill it's process and it
directly."

  (cond ((null arg)
         (mis/warning nil nil
                      "spy/buffer/kill.special: Cannot kill; null arg."))

        ((and (symbolp arg)
              (eq arg 'by-regexp))
         ;; Use our regexp to try to kill them all without confirmation.
           (spy/buffer/kill.matching spy/buffer/regexp/bookend nil t t t))

        ((stringp arg)
         ;; We have a string. Make sure it's formatted as "special-buffer",
         ;; and then try to kill any matching without confirmation.
         (let ((arg (if (string-match-p spy/buffer/regexp/bookend arg)
                        arg
                      (spy/buffer/special-name arg))))
           (spy/buffer/kill.matching arg nil t t t)))

        (t
         ;; Else we have a buffer, probably? Go for the kill ourselves.
         (spy/buffer/process.delete arg)
         (kill-buffer arg))))
;; (spy/buffer/kill.special 'by-regexp)
;; (spy/buffer/kill.special (rx word-boundary (1+ printing) word-boundary))
;; (spy/buffer/kill.special "\\b[[:print:]]+\\b")
;; (spy/buffer/special-name "\\b[[:print:]]+\\b")
;; (spy/buffer/kill.special "§- \\b[[:print:]]+\\b -§")


(defun spy/buffer/process.delete (buffer-or-name)
  "Gets buffer, gets buffer's process (if any), and ends/deletes/kills/SIGKILLs
it. BUFFER-OR-NAME must be exact."
  (let ((proc (get-buffer-process (get-buffer buffer-or-name))))
    (if (not (process-live-p proc))
        (message "No live process in '%s'?" buffer-or-name)
      (delete-process proc))))


;;------------------------------------------------------------------------------
;; Better Kill-Matching-Buffer
;;------------------------------------------------------------------------------

;; §-TODO-§ [2020-02-13]: A "bury-matching in all windows" like
;; `spy/buffer/kill.matching'?

;; I could just grub my meaty hooks into kill-matching-buffers, but... eh.
;; I'd probably just forget the function that way.
(defun smd/buffer/kill.matching (regexp &optional
                                        internal-too
                                        no-ask
                                        delete-process
                                        quiet)
  "Kill buffers whose name matches the specified REGEXP.

Ignores buffers whose name starts with a space (internal
buffers), unless optional prefix argument INTERNAL-TOO is
non-nil.

Asks before killing each buffer if it is modified,
unless NO-ASK is non-nil.

Deletes buffer's process (if any) if DELETE-PROCESS is non-nil."
  (interactive "sKill buffers matching regex: ")
  ;; TODO: find all matching buffers and do a "does this look about right?"
  ;; prompt?

  (let ((killed-names ()))
    ;; for all open buffers...
    (dolist (buffer (buffer-list))
      (let ((name (buffer-name buffer)))
        ;; (message "kill.match plz name:%s e?%s it?%s regex?%s ok?%s"
        ;;          ;; has a name
        ;;          name
        ;;          ;; not empty
        ;;          (not (string-equal name ""))
        ;;          ;; internal-too or not internal
        ;;          (or internal-too (/= (aref name 0) ?\s))
        ;;          ;; matches regex
        ;;          (string-match regexp name)
        ;;          ;; total
        ;;          (and name (not (string-equal name ""))
        ;;               (or internal-too (/= (aref name 0) ?\s))
        ;;               (string-match regexp name)))

        ;; check name obeys `internal-too' type restriction and matches regex
        (when (and name (not (string-equal name ""))
                   (or internal-too (/= (aref name 0) ?\s))
                   (string-match regexp name))
          ;; and kill it maybe
          (if no-ask
              ;; either just kill it...
              (progn
                (push name killed-names)
                (when delete-process
                  (spy/buffer/process.delete buffer))
                (kill-buffer buffer))
            ;; ...or probably kill it? Save the name if so.
            (let ((maybe-kill-name (spy/buffer/kill.ask buffer
                                                           delete-process)))
              (unless (null maybe-kill-name)
                (push maybe-kill-name killed-names)))))))
    (if quiet
        ;; return number of buffers killed if quiet Mode
        (length (or killed-names '()))
      ;; And finally, give some goddamn output (looking at you,
      ;; kill-matching-buffers).
      (cond
       ((null killed-names)
        (message "No buffers killed matching '%s'."
                 regexp))
       ((>= (length killed-names) 10)
        (message "Killed %s buffers matching '%s'."
                 (length killed-names)
                 regexp))
       (t
        (message "Killed %s buffers matching '%s': %s"
                 (length killed-names)
                 regexp
                 killed-names))))))
;; (spy/buffer/kill.special "§- \\b[[:print:]]+\\b -§")
;; (string-match-p "§- \\b[[:print:]]+\\b -§" "§- Kill All The Things! -§")
;; (string-match-p "§- \\b[[:print:]]+\\b -§\\b" "§- Kill All The Things! -§")
;; (string-match-p "§- [[:print:]]+\\b -§" "§- Kill All The Things! -§")


;;------------------------------------------------------------------------------
;; The End.
;;------------------------------------------------------------------------------
(spy/provide :spy 'buffer 'manage)
