;;; spy/buffer/manage.el -*- lexical-binding: t; -*-



;;------------------------------------------------------------------------------
;; Kill Functions
;;------------------------------------------------------------------------------

;; Like `kill-buffer-ask' but no confirmation for unmodified buffers.
(defun spy:buffer/kill.ask (buffer &optional delete-process)
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
      (when delete-process (spy:buffer/process.delete buffer))
      (kill-buffer buffer))
    ;; else, ret nil when no kill
    nil))


(defun spy:buffer/kill.special (arg)
  "Kills my special(ly named) buffers, and deletes any process they may have
running.

If ARG is the symbol `by-regexp', use `spy:buffer/regexp/bookend' to kill
special buffers.

If ARG is a string, the `spy:buffer/regexp/bookend' is checked to see if the
stcring/regexp is 'correctly' guarded by them, adding them in if needed. It uses
`spy:buffer/special-name' with nil priority to add the bookends.

If ARG is not a string, assume it's a buffer and try to kill it's process and it
directly."

  (cond ((null arg)
         (mis0/warning nil nil
                      "spy:buffer/kill.special: Cannot kill; null arg."))

        ((and (symbolp arg)
              (eq arg 'by-regexp))
         ;; Use our regexp to try to kill them all without confirmation.
           (spy:buffer/kill.matching spy:buffer/regexp/bookend nil t t t))

        ((stringp arg)
         ;; We have a string. Make sure it's formatted as "special-buffer",
         ;; and then try to kill any matching without confirmation.
         (let ((arg (if (string-match-p spy:buffer/regexp/bookend arg)
                        arg
                      (spy:buffer/special-name arg))))
           (spy:buffer/kill.matching arg nil t t t)))

        (t
         ;; Else we have a buffer, probably? Go for the kill ourselves.
         (spy:buffer/process.delete arg)
         (kill-buffer arg))))
;; (spy:buffer/kill.special 'by-regexp)
;; (spy:buffer/kill.special (rx word-boundary (1+ printing) word-boundary))
;; (spy:buffer/kill.special "\\b[[:print:]]+\\b")
;; (spy:buffer/special-name "\\b[[:print:]]+\\b")
;; (spy:buffer/kill.special "§- \\b[[:print:]]+\\b -§")


(defun spy:buffer/process.delete (buffer-or-name)
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
;; `spy:buffer/kill.matching'?

(defun spy:buffer/kill.matching (regex &rest keywords)
  "Kill buffers whose name matches the specified REGEX.

KEYWORDS should be nil or keywords. Valid KEYWORDS are:
  - `:internal'
    - Don't ignore buffers whose name starts with a space (internal buffers).
      - Default is to ignore them.
  - `:modified'
    - Kill modified buffers without confirmation.
      - Default is to ask for confirmation for each modified buffer.
  - `:process'
    - Kill buffers with attached/associated processes.
      - Default is to ask for confirmation for each buffer with a process.
  - `:quiet'
    - Do not output the informative messages."
  ;; What KEYWORD flags were set?
  (let ((kill/internal? (memq :internal keywords))
        (kill/modified? (memq :modified keywords))
        (kill/process?  (memq :process  keywords))
        (quiet?         (memq :quiet    keywords))
        ;; List: "buffer name matches regex".
        buffer/matches
        ;; List: "actually killed buffer name".
        buffer/killed
        ;; If not `quiet?', a progress reporter will be created.
        progress-reporter)

    ;;------------------------------
    ;; Regex Match Buffer Names
    ;;------------------------------
    ;; Basically:
    ;;   - Find matching buffers first.
    ;;   - Ask w/ summary if desired.
    ;;   - Kill w/ progress reporter.
    (dolist (buffer (buffer-list))
      (let ((name (buffer-name buffer)))
        (when (and (stringp name)
                   (not (string-equal name ""))
                   ;; Leading space means "internal buffer" - check name obeys `kill/internal?' type restriction.
                   (or kill/internal? (/= (aref name 0) ?\s))
                   ;; ...and matches regex.
                   (string-match regexp name))
          (push name buffer/matches))))

    ;;------------------------------
    ;; TODO: Confirmation?
    ;;------------------------------
    ;; TODO: Find all matching buffers and do a "Does this look about right?" prompt?

    (if (not buffer/matches)
        ;;------------------------------
        ;; No matches - inform!
        ;;------------------------------
        (unless quiet?
          (message "Nothing killed; no buffers matching '%s'."
                   regexp))

      ;;------------------------------
      ;; Kill!
      ;;------------------------------
      ;; But first, set up progress reporter?
      (unless quiet?
        (setq progress-reporter
              (make-progress-reporter (format "Killing all '%s' buffers..."
                                              regex)
                                      0
                                      (length buffer/matches))))

      ;; Annnd... kill buffers!
      (let ((count 0))
        (dolist (buffer buffer/matches)
          (setq count (1+ count))
          (if kill/modified?
              ;; Ask if we should kill it if modifed, else just kill it.
              (when-let ((maybe-kill-name (spy:buffer/kill.ask buffer
                                                               kill/process?)))
                (push maybe-kill-name buffer/killed))

            ;; Just kill it.
            (when kill/process?
              (spy:buffer/process.delete buffer))
            (kill-buffer buffer)
            (push name buffer/killed))

          ;; Update progress.
          (unless quiet?
            (progress-reporter-update progress-reporter count))))

      ;;------------------------------
      ;; Final output.
      ;;------------------------------
      (unless quiet?
        (progress-reporter-done progress-reporter)

        ;; And finally, give some goddamn output (looking at you, kill-matching-buffers).
        (cond
         ((null buffer/killed)
          (message "No buffers killed matching '%s'."
                   regexp))
         ((>= (length buffer/killed) 10)
          (message "Killed %s buffers matching '%s'."
                   (length buffer/killed)
                   regexp))
         (t
          (message "Killed %s buffers matching '%s': %s"
                   (length buffer/killed)
                   regexp
                   buffer/killed))))

      ;; Return number of buffers killed.
      (length buffer/killed))))


(defun spy:cmd:buffer/kill.matching (regex)
  "Kill buffers whose name matches the specified REGEX.

If you want to control what gets killed & how, see `spy:buffer/kill.matching'
for kewords like:
  - `:internal'
    - Don't ignore buffers whose name starts with a space (internal buffers).
      - Default is to ignore them.
  - `:modified'
    - Kill modified buffers without confirmation.
      - Default is to ask for confirmation for each modified buffer.
  - `:process'
    - Kill buffers with attached/associated processes.
      - Default is to ask for confirmation for each buffer with a process.
  - `:quiet'
    - Do not output the informative messages."
  (interactive "sKill buffers matching regex: ")
  (spy:buffer/kill.matching regex))


;;------------------------------------------------------------------------------
;; The End.
;;------------------------------------------------------------------------------
(imp:provide :modules 'spy 'buffer 'manage)
