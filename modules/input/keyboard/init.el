;;; layout/keyboard/init.el -*- lexical-binding: t; -*-

;;                                 ──────────                                 ;;
;; ╔════════════════════════════════════════════════════════════════════════╗ ;;
;; ║                            Keyboard Layouts                            ║ ;;
;; ╚════════════════════════════════════════════════════════════════════════╝ ;;
;;                                   ──────                                   ;;
;;             Not everyone uses Qwerty - there are dozens of us!             ;;
;;                                 ──────────                                 ;;


;;------------------------------------------------------------------------------
;; Constants & Variables
;;------------------------------------------------------------------------------

;;------------------------------
;; TESTING
;;------------------------------

(defvar input//kl:testing:disable-start-up-init nil
  "If non-nil, does not run anything during startup.
Just loads files to get all functions and such defined.")


;;------------------------------
;; Layout: Desired/Active
;;------------------------------

(defvar input//kl:layout/desired nil
  "Cached :input/keyboard flag (converted to layout keyword) for desired
keyboard layout.

e.g. flag `+layout/dvorak' -> keyword `:dvorak'

'active' vs 'desired':
  - Desired is set from Doom module flags and comes from user.
  - Active is set in `input:keyboard/layout:set' when called by desired layout.
  - Both are set during 'init' file phase.")

(defvar input//kl:layout/active nil
  "Cached keyword for the active/desired keyboard layout.

'active' vs 'desired':
  - Desired is set from Doom module flags and comes from user.
  - Active is set in `input:keyboard/layout:set' when called by desired layout
  - Both are set during 'init' file phase.")


;;------------------------------------------------------------------------------
;; Load: Required Code Files
;;------------------------------------------------------------------------------

;; NOTE: Order could matter - take care if modifying.
(load! "error")
(load! "load")
(load! "alist")
(load! "register")


;;------------------------------------------------------------------------------
;; Debugging/Testing Helper
;;------------------------------------------------------------------------------

(defun input//kl:loading? ()
  "Use this to hide code you only want to run during Doom/Emacs start-up or to
do some debugging vs actual stuff.

For best, most consistent results: do not use this at all.

Returns non-nil if `doom-init-p' is nil."
  ;; This var is set to `t' after Doom has been initialized.
  ;; ...it's already set by the time this runs.
  ;;(not doom-init-p)

  ;; Maybe this one is more accurate.
  ;; Nope. This gives us 'not loading' when this file is loaded...
  ;; (not doom-init-modules-p)

  ;; I give up? If `load-file-name' is set, some file is being loaded right now.
  load-file-name)


(defun input:keyboard/layout:apply (layout)
  "Initialize, configure, and apply the LAYOUT.

Overrides any current active layout with the new LAYOUT."
  ;; Could do a completing read or something with the valid layout dirs as the choices.
  (interactive "sLoad Layout: ")
  (let ((layout/keyword (input//kl:normalize->keyword layout)))
    ;; Updated desired first.
    (cond ((null input//kl:layout/desired)
           ;; Undefined
           (message "Setting desired keyboard layout: %S -> %S"
                    input//kl:layout/desired
                    layout/keyword))

          ((not (eq input//kl:layout/desired layout/keyword))
           (message "Changing desired keyboard layout: %S -> %S"
                    input//kl:layout/desired
                    layout/keyword))

          (t
           (message "Reapplying desired keyboard layout: %S -> %S"
                    input//kl:layout/desired
                    layout/keyword)))
    (setq input//kl:layout/desired layout/keyword)

    ;; Check/report about active.
    (cond ((null input//kl:layout/active)
           (message "Setting active keyboard layout: %S -> %S"
                    input//kl:layout/active
                    layout/keyword))
          ((not (eq input//kl:layout/active layout/keyword))
           (message "Changing active keyboard layout: %S -> %S"
                    input//kl:layout/active
                    layout/keyword))
          (t
           (message "Reapplying active keyboard layout: %S -> %S"
                    input//kl:layout/active
                    layout/keyword)))

    ;; Load active.
    (input:keyboard/layout:find-and-load-active "init") ;; This will set active.

    ;; Verify it was set before config/finalization.
    (if (not (eq input//kl:layout/active layout/keyword))
        ;; Fail message.
        (message (concat
                  "Initializing layout did not set it to the active layout?!\n"
                  "  Input:   %S\n"
                  "  Desired: %S\n"
                  "  Active:  %S")
                 layout/keyword
                 input//kl:layout/desired
                 input//kl:layout/active)

      ;; Config and finalize the new layout.
      (message "Configuring & binding %S..." input//kl:layout/active)
      (input:keyboard/layout:find-and-load-active "config")
      (input:keyboard/layout:finalize)
      (message "Loaded layout %S." input//kl:layout/active))))
;; (setq input//kl:layout/desired nil)
;; (setq input//kl:layout/active nil)


;;------------------------------------------------------------------------------
;; Module Helpers
;;------------------------------------------------------------------------------

(defun input//kl:valid/layout? (layout &optional compare-active)
  "Returns non-nil if LAYOUT is valid.

LAYOUT must fulfill these criteria:
  - Must be a keyword.
  - If `input//kl:layout/desired' is set, LAYOUT must be `eq' to it (else we
    assume LAYOUT will become the desired layout).
  - If COMPARE-ACTIVE is non-nil, LAYOUT must be `eq' to
   `input//kl:layout/active'."
  (and (keywordp layout)
       ;; Equal to desired?
       (or (not input//kl:layout/desired)
           (eq layout input//kl:layout/desired))
       ;; Equal to active?
       (or (null compare-active)
           (eq layout input//kl:layout/active))))


(defun input//kl:normalize->string (input)
  "Normalize INPUT to a layout string.

If INPUT is:
  - String:  Remove \"+layout/\" prefix,
             (then remove \":\" prefix if exists), and return.
  - Keyword: Get symbol name, remove \":\" prefix, and return.
  - Symbol:  Get symbol name, remove \"+layout/\" prefix,
             (then remove \":\" prefix if exists), and return.
E.g.
  1) \"dvorak\" -> \"dvorak\"
  2) `:dvorak' -> \"dvorak\"
  3) `+layout/dvorak' -> \"dvorak\""
  ;; Remove keyword's leading ":"?
  (string-remove-prefix
   ":"
   ;; Remove the rest of module flag's leading "+layout/"?
   (string-remove-prefix
    "layout/"
    ;; Remove leading "+" from layout dir name or module flag.
    (string-remove-prefix
     "+"
     (if (stringp input)
         input
       (symbol-name input))))))
;; (input//kl:normalize->string '+layout/spydez)
;; (input//kl:normalize->string :spydez)
;; (input//kl:normalize->string "spydez")
;; (input//kl:normalize->string "+spydez")


(defun input//kl:normalize->keyword (input)
  "Convert INPUT to a keyboard layout keyword.

If INPUT is:
  - Keyword: It is returned as is.
  - nil:     nil will be returned (allows for default args).

Otherwise INPUT is normalized to a string and then converted to a keyword.

E.g. `+layout/dvorak' -> `:dvorak'."
  (cond ((null input)
         nil)
        ((keywordp input)
         input)
        (t
         (intern (concat ":"
                         (input//kl:normalize->string input))))))
;; (input//kl:normalize->keyword '+layout/spydez)
;; (input//kl:normalize->keyword :spydez)
;; (input//kl:normalize->keyword "spydez")
;; (input//kl:normalize->keyword nil)


;;------------------------------------------------------------------------------
;; Init: ':input/keyboard' Module
;;------------------------------------------------------------------------------

;;------------------------------
;; Error Checking & Setting of `input//kl:layout/desired'
;;------------------------------

(unless input//kl:testing:disable-start-up-init
  ;; Should not have more than one keyboard layout, but only check when loading.
  (if (input//kl:loading?)
      ;; We are loading, so check our module flags.
      (let ((flags (doom-module-get :input 'keyboard :flags))
            (layouts 0)
            (suppress-warning nil))
        (when (and (> 1
                      (dolist (flag flags layouts)
                        (when (eq flag '+suppress/layouts)
                          (setq suppress-warning t))
                        (when (string-prefix-p "+layout/" (symbol-name flag))
                          ;; Save first/only as desired layout.
                          (when (null input//kl:layout/desired)
                            (setq input//kl:layout/desired
                                  (input//kl:normalize->keyword flag))
                            ;; Count for a warning (if not suppressed).
                            (setq layouts (1+ layouts))))))
                   ;; Warn only if we didn't see the suppression.
                   (not suppress-warning))
          (warn (concat "Doom Module `:input/keyboard' init detected %d keyboard "
                        "layout flags. You should really only have one. Suppress "
                        "this by adding the `+suppress/layouts' flag. flags: %S")
                layouts
                flags)))

    ;; Else we're not running during init... probably evaluating this buffer
    ;; directly for dev/testing. Set desired to a testing default.
    (setq input//kl:layout/desired :spydez)))


;;------------------------------------------------------------------------------
;; Init: Keyboard Layouts
;;------------------------------------------------------------------------------

;;------------------------------
;; Layout Builder and Specific Layouts' Inits
;;------------------------------
(load! "layout/init")


;;------------------------------------------------------------------------------
;; The End.
;;------------------------------------------------------------------------------
