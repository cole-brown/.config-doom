;;; config/keybinds/terminal.el -*- lexical-binding: t; -*-


;;                                 ──────────                                 ;;
;; ╔════════════════════════════════════════════════════════════════════════╗ ;;
;; ║                         TERMINAL and/or SHELL                          ║ ;;
;; ╚════════════════════════════════════════════════════════════════════════╝ ;;
;;                                 ──────────                                 ;;


;;------------------------------------------------------------------------------
;; Doom Leader Keybinds
;;------------------------------------------------------------------------------

(map! :leader       ; Be under the Doom SPC leader.

      ;;------------------------------
      ;; 'spy' Prefix:
      ;;------------------------------
      (:prefix ("-" . "spy")

       ;;------------------------------
       ;; Apps Prefix:
       ;;------------------------------
       (:prefix ("c" . "Terminal/Shell")

        ;;------------------------------
        ;; Shelldon:
        ;;------------------------------
        :desc "shelldon"         "c" #'shelldon
        :desc "shelldon loop"    "t" #'shelldon-loop
        :desc "shelldon history" "h" #'shelldon-output-hist

        ;; This is "C-x C-f" by default in `minibuffer-local-shelldon-command-map'
        ;; (which requires `enable-recursive-minibuffers' set to t to use).
        :desc "shelldon cd"      "d" #'shelldon-cd

        ;; Invoke commands from other buffers
        :desc "shelldon send region" "p" #'shelldon-send-region
        :desc "shelldon send line"   "u" #'shelldon-send-line)))


;;------------------------------------------------------------------------------
;; Shelldon Keymap Keybinds
;;------------------------------------------------------------------------------

;; Shelldon keymap:
;;   `minibuffer-local-shelldon-command-map'


;;------------------------------------------------------------------------------
;; The End.
;;------------------------------------------------------------------------------
(imp:provide :dot-emacs 'config 'keybinds 'terminal)
