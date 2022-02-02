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
        :desc "Edit Workspaces Org File"  "e" #'treemacs-edit-workspaces

        (:prefix ("p" . "Project")
         :desc "Add Project..."            "a" #'treemacs-add-project-to-workspace
         :desc "Remove Project"            "r" #'treemacs-remove-project-from-workspace)

        (:prefix ("o" . "Open")
         :desc "Open - Default"              "d" #'treemacs-visit-node-default
         :desc "Open - No Split"             "o" #'treemacs-visit-node-no-split

         :desc "Open - New Split Vertical"   "v" #'treemacs-visit-node-vertical-split
         :desc "Open - New Split Horizontal" "h" #'treemacs-visit-node-horizontal-split

         :desc "Open - Most Recent Window"   "m" #'treemacs-visit-node-in-most-recently-used-window))))


;;------------------------------------------------------------------------------
;; The End.
;;------------------------------------------------------------------------------
(imp:provide :dot-emacs 'config 'keybinds 'treemacs)
