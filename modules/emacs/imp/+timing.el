;;; emacs/imp/+timing.el -*- lexical-binding: t; -*-

;;                                 ──────────                                 ;;
;; ╔════════════════════════════════════════════════════════════════════════╗ ;;
;; ║                              Load Timing                               ║ ;;
;; ╚════════════════════════════════════════════════════════════════════════╝ ;;
;;                                   ──────                                   ;;
;;                  Be done is as little as 98.765 seconds.                   ;;
;;                                 ──────────                                 ;;


;;------------------------------
;; Future Features:
;;------------------------------
;;   - Delayed output mode:
;;     - If enabled, just save info about load ordering to a tree list.
;;       Then once some 'loading done' condition is hit (emacs hook?),
;;       construct the whole loading tree of messages and print.
;;       - Saves some start-up time by not doing (expensive) output.
;;     - If disabled, normal 'print-as-you-go' that slows down start-up some.
;;------------------------------


;;------------------------------------------------------------------------------
;; Timings Toggle
;;------------------------------------------------------------------------------

(defcustom imp:timing:enabled? nil
  "Should loading & timing messages be printed?"
  :group 'imp:group
  :type '(boolean)
  :risky t)


;; NOTE: Doom Emacs only, protected by `fboundp' check for the `featurep!' macro.
(defconst imp:timing:feature? (when (fboundp 'featurep!)
                                (featurep! +timing))
  "Cache of our feature flag.")


(defun imp:timing:enabled? ()
  "Returns non-nil if `imp:timing:enabled?' is non-nil or imp's `+timing'
feature flag is set."
  (or imp:timing:enabled?
      imp:timing:feature?))
;; (imp:timing:enabled?)


;;------------------------------------------------------------------------------
;; Constants & Variables
;;------------------------------------------------------------------------------

(defconst imp:timing:format:tree
  '(;; Supplied types:
    :root   ""
    :leaf   "└─"
    ;; Derived types:
    :branch "├─"
    :trunk  "│ ")
  "Strings for creating loading trees like:
  loading xxx...
  ├─loading yyy...
  │ └─cc.dd seconds
  └─aa.bb seconds")


(defconst int<imp>:timing:precision:time 4
  "Show this many places after decimal for default `imp:timing:format:time'.")


(defvar int<imp>:timing:indent 0
  "Current tree indent level of loading.

Example:
  loading xxx...     : level 0
  ├─loading yyy...   : level 1
  │ └─cc.dd seconds  : level 1
  └─aa.bb seconds    : level 0")


(defvar imp:timing:sum 0.0
  "Sum of all timings at indent 0 level.")


;;------------------------------------------------------------------------------
;; Custom Variables
;;------------------------------------------------------------------------------

(defcustom imp:timing:buffer:name
  "ⓘ-imp:timing-ⓘ"
  "Buffer name to print to. If you want it to go to *Messages* with the usual
minibuffer interaction, set to: `:messages'"
  :group 'autogit:group
  :type '(choice (string :tag "Name of Buffer")
                 (const :tag "Use `message' to send to *Messages* buffer with the usual minibuffer interactions."
                        :messages)))


(defcustom imp:timing:buffer:show t
  "If non-nil, show `imp:timing:buffer:name' every time it gets a new message.")


(defcustom imp:timing:format:load "loading %1$S..."
  "Format string for loading a filename.

Args to this format string are:
  1. Feature symbol: :imp/+timing
  2. File name:      +timing.el
  3. File path:      /path/to/imp/+timing.el"
  :group 'imp:group
  :type '(string)
  :risky t)


(defcustom imp:timing:format:already-provided "skip %1$S; feature already provided"
  "Format string for loading a filename.

Args to this format string are:
  1. Feature symbol: :imp/+timing
  2. File name:      +timing.el
  3. File path:      /path/to/imp/+timing.el"
  :group 'imp:group
  :type '(string)
  :risky t)


(defcustom imp:timing:format:time:total
  (concat "\n"
          ;;---
          ;; Open Box.
          ;;---
          "┌───────┬──────────────────┐\n"
          "│ total │ "
          ;;---
          ;; Start of Line
          ;;---

          ;;---
          ;; Elapsed Seconds Format
          ;;---
          ;; Format total elapsed time like: "111.2345", "  1.2345", etc.
          "%"                                      ;; Fill with spaces.
          (number-to-string
           (+ 3 1 int<imp>:timing:precision:time)) ;; Full seconds precision + "." + fractional seconds precision
          "."
          (number-to-string
           int<imp>:timing:precision:time)         ;; Fractional seconds precision
          "f"                                      ;; Format as a floating point.

          ;;---
          ;; End of Line
          ;;---
          " seconds │\n"

          ;;---
          ;; Close Box.
          ;;---
          "└───────┴──────────────────┘")
  "String format for total elapsed time according to `imp:timing:sum'.")


(defcustom imp:timing:format:time
  (concat "%0"                                     ;; Fill with zeros.
          (number-to-string
           (+ 2 1 int<imp>:timing:precision:time)) ;; Full seconds precision + "." + fractional seconds precision
          "."
          (number-to-string
           int<imp>:timing:precision:time)         ;; Fractional seconds precision
          "f"                                      ;; Format as a floating point.
          " seconds")                              ;; And... say what the units are.
  "Format string for number of seconds it took to load a file."
  :group 'imp:group
  :type '(string)
  :risky t)


(defcustom imp:timing:separator:launch
  (concat "\n\n"
          (make-string 40 ?─ :multibyte))
  "String that can be inserted into the output buffer via `int<imp>:timing:launch'."
  :group 'imp:group
  :type '(string)
  :risky t)


;;------------------------------------------------------------------------------
;; Indentation
;;------------------------------------------------------------------------------

(defun int<imp>:timing:tree:type (type indent)
  "Get tree type string for current TYPE and INDENT level.

INDENT is an integer where 0 the TYPE's indent and 1+ are its parents
indention levels."
  (plist-get imp:timing:format:tree
             ;;------------------------------
             ;; Indent 0: Return the type's actual format.
             ;;------------------------------
             (cond ((= indent 0)
                    type)
                   ;;------------------------------
                   ;; Indents above 0: Derive a type based on the actual type.
                   ;;------------------------------
                   ((and (= indent 1)
                         (eq type :root))
                    :branch)
                   ((and (= indent 1)
                         (not (eq type :root)))
                    :trunk)
                   (t ;; (> indent 1)
                    :trunk))))
;; (int<imp>:timing:tree:type :root 0)
;; (int<imp>:timing:tree:type :root 1)
;; (int<imp>:timing:tree:type :root 2)
;; (int<imp>:timing:tree:type :leaf 0)
;; (int<imp>:timing:tree:type :leaf 1)
;; (int<imp>:timing:tree:type :leaf 2)


(defun int<imp>:timing:tree:string (type)
  "Get tree type string for current type."
  (mapconcat
   #'identity
   (let (prefix)
     ;; For each indent level, build the trunks/branches.
     ;; Need to loop at least once (for indent 0), so 1+ indent level.
     (dotimes (i (1+ int<imp>:timing:indent) prefix)
       (push
        (int<imp>:timing:tree:type type i)
        prefix)))
   ;; Join w/ no padding.
   ""))
;; (int<imp>:timing:tree:string :root)
;; (let ((int<imp>:timing:indent 2))
;;   (int<imp>:timing:tree:string :root))


;;------------------------------------------------------------------------------
;; Buffer Functions
;;------------------------------------------------------------------------------

(defun int<imp>:timing:buffer:messages? ()
  "Returns `t' if `imp:timing:buffer:name' is the \"*Messages*\" buffer.

NOTE: This covers a value `:messages' as well as the string name."
  ;; Check for `:messages' keyword as well as a name match to the buffer.
  (cond ((and (keywordp imp:timing:buffer:name)
              (eq :messages
                  imp:timing:buffer:name)))
        ((and (stringp imp:timing:buffer:name)
              (string= "*Messages*"
                       imp:timing:buffer:name)))
        ;; Else it's some other buffer.
        (t
         nil)))


(defun imp:timing:buffer:name ()
  "Returns the string name of `imp:timing:buffer:name' custom variable.

NOTE: This converts a value `:messages' to \"*Messages*\"."
  (if (int<imp>:timing:buffer:messages?)
      "*Messages*"
    imp:timing:buffer:name))


(defun int<imp>:timing:buffer:show (force-show?)
  "Show timing buffer or not, depending on settings.

FORCE-SHOW?, if non-nil, will always show the buffer."
  (when (or force-show?
            (int<imp>:timing:buffer:messages?))
    (display-buffer (imp:timing:buffer:name))))


(defun imp:cmd:timing:buffer:bury (&optional ignore-messages-buffer)
  "Hide and bury the imp timing output buffer.

If IGNORE-MESSAGES-BUFFER is non-nil and the output buffer is \"*Messages*\",
does nothing instead."
  (interactive)
  ;; Ignore entirely if IGNORE-MESSAGES-BUFFER is set and we are using the messages buffer.
  (unless (and ignore-messages-buffer
               (int<imp>:timing:buffer:messages?))
    ;; Bury only when we find the window currently displaying it.
    (when-let* ((name (imp:timing:buffer:name))
                (window (get-buffer-window name)))
      (with-selected-window window
        (bury-buffer))
      (message "imp:timing: Buried timing buffer: %s"
               name))))
;; (imp:cmd:timing:buffer:bury)


(defun imp:cmd:timing:buffer:kill (&optional ignore-messages-buffer)
  "Kill the imp timing output buffer.

If IGNORE-MESSAGES-BUFFER is non-nil and the output buffer is \"*Messages*\",
does nothing instead."
  (interactive)
  ;; Ignore entirely if IGNORE-MESSAGES-BUFFER is set and we are using the messages buffer.
  (unless (and ignore-messages-buffer
               (int<imp>:timing:buffer:messages?))
    ;; Bury only when we find the window currently displaying it.
    (when-let* ((name (imp:timing:buffer:name))
                ;; Get the buffer in order to prevent "No buffer named <...>" messages.
                (buffer (get-buffer name)))
      (kill-buffer buffer)
      (message "imp:timing: Killed timing buffer: %s"
               name))))
;; (imp:cmd:timing:buffer:kill)


;;------------------------------------------------------------------------------
;; Output
;;------------------------------------------------------------------------------

(defun int<imp>:timing:buffer:insert (string)
  "Inserts finalized message STRING into output buffer."
  ;; Don't do anything unless enabled.
  (when-let ((enabled? (imp:timing:enabled?))
             (name (imp:timing:buffer:name)))
    (cond
     ;;------------------------------
     ;; Buffers
     ;;------------------------------
     ;; *Messages* buffer: Just use the `message' function.
     ((int<imp>:timing:buffer:messages?)
      (message string))

     ;; Some other buffer: Insert at the end.
     ((stringp name)
      ;; Should we force tailing of the buffer or leave that up to user and `auto-revert-tail-mode'?
      ;; I think start off with `auto-revert-tail-mode'.
      (with-current-buffer (get-buffer-create name)
        ;; We are now in BUFFER, so just insert the formatted string on a new line at the end.
        (goto-char (point-max))
        ;; Prepend a newline, unless this is a new/empty buffer.
        (insert (concat (if (= (buffer-size) 0)
                            ""
                          "\n")
                        string))))

     ;;------------------------------
     ;; Errors
     ;;------------------------------
     (t
      (error "int<imp>:timing:buffer:insert: unhandled %s buffer: '%s'"
             (if (int<imp>:timing:buffer:messages?)
                 "(*Messages*)"
               "(non-*Messages*)")
             name)))

    ;; Show buffer if desired.
    (when imp:timing:buffer:show
      (display-buffer name))))


(defun int<imp>:timing:message (type formatting &rest args)
  "Prepends indentation and prints timing message for FORMATTING string and ARGS.

TYPE should be either `:root' or `:leaf'. Uses TYPE to get the indent string."
  (int<imp>:timing:buffer:insert
   (format "%s%s"
           (int<imp>:timing:tree:string type)
           (apply #'format formatting args))))


(defun int<imp>:timing:start (feature filename path)
  "Print a loading message for this FEATURE, FILENAME, and/or PATH.

Message depends on `imp:timing:format:load'."
  (int<imp>:timing:message :root
                           imp:timing:format:load
                           (int<imp>:feature:normalize:display feature)
                           filename
                           path))


(defun int<imp>:timing:end (time:start)
  "Print the time since TIME:START.

Message depends on `imp:timing:format:time'."
  (let ((elapsed (float-time (time-since time:start))))
    (int<imp>:timing:message :leaf
                             imp:timing:format:time
                             elapsed)
    ;; Add `elapsed' to running sum if at base indent level.
    (when (= int<imp>:timing:indent 0)
      (setq imp:timing:sum (+ imp:timing:sum elapsed)))))


;; TODO: move
(defun imp:timing:restart ()
  "'Restart' timing.

1) Print a starting separator to the timing buffer if needed.
2) Reset `imp:timing:sum' to zero.

If `imp:timing:buffer:name' doesn't exists or is *Messages*, does nothing."
  ;; Reset timing sum variable.
  (setq imp:timing:sum 0.0)

  ;; Broken up because it's too early for this... :|
  (cond
   ;; Not enabled = no output.
   ((not (imp:timing:enabled?))
    nil)
   ;; *Messages* buffer = no output.
   ((int<imp>:timing:buffer:messages?)
    nil)
   ;; Not *Messages* and exists = output!
   ((get-buffer (imp:timing:buffer:name))
    (int<imp>:timing:buffer:insert imp:timing:separator:launch))
   ;; Else, no output.
   (t
    nil)))


(defun imp:timing:already-provided (feature filename path)
  "Prints out a message about skipping this FEATURE / FILENAME / PATH.

Message depends on `imp:timing:format:skip'."
  (when (imp:timing:enabled?)
    (int<imp>:timing:message :root
                             imp:timing:format:already-provided
                             (int<imp>:feature:normalize:display feature)
                             filename
                             path)))


(defmacro imp:timing (feature filename path &rest body)
  "Measure & prints the time it takes to evaluate BODY.

Message depends on `imp:timing:format:time'.

Returns result of evaluating BODY."
  (declare (indent 3))

  `(if (imp:timing:enabled?)
       ;; Timings enabled: Run body in between timing start/end messages.
       (let ((macro<imp>:feature  ,feature)
             (macro<imp>:filename ,filename)
             (macro<imp>:path     ,path)
             (macro<imp>:time     (current-time)))
         (prog2
             ;; Start with load message.
             (int<imp>:timing:start macro<imp>:feature
                                    macro<imp>:filename
                                    macro<imp>:path)
             ;; Increase indent level for body.
             (let ((int<imp>:timing:indent (1+ int<imp>:timing:indent)))
               ;; Run the body...
               ,@body)
           ;; Finish with the timing message.
           (int<imp>:timing:end macro<imp>:time)))

     ;; Timings disabled: Just run body.
     ,@body))
;; (imp:timing :test "+timing.el" ".config/doom/modules/emacs/imp" (message "Time!"))
;; (let ((imp:timing:enabled? nil))
;;   (imp:timing:launch)
;;   (imp:timing :test "+timing.el" ".config/doom/modules/emacs/imp"
;;               (imp:timing :test/foo "+foo.el" ".config/doom/modules/emacs/imp"
;;                           (message "Double Time!"))))
;; (let ((imp:timing:enabled? t))
;;   (imp:timing:launch)
;;   (imp:timing :test "+timing.el" ".config/doom/modules/emacs/imp"
;;               (imp:timing :test/foo "+foo.el" ".config/doom/modules/emacs/imp"
;;                           (message "Double Time!"))))


;;------------------------------------------------------------------------------
;; Output: Init / Finalize
;;------------------------------------------------------------------------------


(defun imp:timing:final ()
  "Print out total timing summary."
  (when (imp:timing:enabled?)
    (int<imp>:timing:buffer:insert
     (format imp:timing:format:time:total
             imp:timing:sum))))
