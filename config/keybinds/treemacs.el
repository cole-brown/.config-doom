;;; config/keybinds/treemacs.el -*- lexical-binding: t; -*-

;;                                                               ──────────                                                               ;;
;; ╔════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════╗ ;;
;; ║                                                              KEYBINDS                                                              ║ ;;
;; ╚════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════╝ ;;
;;                                                               ──────────                                                               ;;


;;------------------------------------------------------------------------------------------------------------------------------------------
;; Treemacs
;;------------------------------------------------------------------------------------------------------------------------------------------

;; Don't think we want to wait, or else we'd not get them until after it's loaded and... lazy loading.
;; (map! :after treemacs
(map! :leader       ; Be under the Doom SPC leader.

      ;;------------------------------
      ;; 'spy' Prefix:
      ;;------------------------------
      (:prefix ("-" . "spy") ; Not my first choice but no one uses dash,
                             ; and it's easy on Dvorak.

       ;;------------------------------
       ;; Treemacs Prefix:
       ;;------------------------------
       (:prefix ("r" . "Treemacs")
        :desc "Select Treemacs Window"    "r" #'treemacs-select-window
        :desc "Toggle Treemacs Window"    "t" #'treemacs
        :desc "Edit Workspaces Org File"  "e" #'treemacs-edit-workspaces)))
