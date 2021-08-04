;;; config/keybinds/org-mode.el -*- lexical-binding: t; -*-

;;                                                               ──────────                                                               ;;
;; ╔════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════╗ ;;
;; ║                                                              KEYBINDS                                                              ║ ;;
;; ╚════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════╝ ;;
;;                                                               ──────────                                                               ;;


;;------------------------------------------------------------------------------------------------------------------------------------------
;; Org-Mode
;;------------------------------------------------------------------------------------------------------------------------------------------

;; Map some things for org-mode.
(map! :after org
      :map org-mode-map
      :localleader
      ;; :map evil-org-mode-map
      :prefix "l" ;; links
      :desc "Link as 'here'." "h" #'spy:cmd:org/here.link
      :desc "Paste as 'here' link." "p" #'spy:cmd:org/here.yank)


;; TODO: Do I want this again?
;; ;; 'C-c <tab>' to show headings only (no top parent notes, no
;; ;; children notes, just headings). Org-Mode had 'C-c <tab>' as
;; ;; outline-show-children, which only shows direct children
;; ;; headings, not all descendants' headings.
;; ;; https://yiufung.net/post/org-mode-hidden-gems-pt1/
;; ("C-c <tab>" . #'org-kill-note-or-show-branches)


;;------------------------------------------------------------------------------------------------------------------------------------------
;; Org-Agenda
;;------------------------------------------------------------------------------------------------------------------------------------------

;;---
;; Thanks to: https://emacs.stackexchange.com/a/20438
;;---

(after! org-mode
  ;; `org-agenda-quit' is evil - it leaves a billion org mode buffers open.
  ;; And it's innocently sat there at "q" that apparently nothing in evil overrides...
  (bind-key [remap org-agenda-quit]
            #'org-agenda-exit
            org-agenda-keymap)
  ;; And this is at "Q".
  (bind-key [remap org-agenda-Quit]
            #'org-agenda-exit
            org-agenda-keymap)
  ;; Fuck y'all both.
  )


;;------------------------------------------------------------------------------------------------------------------------------------------
;; Org-Journal
;;------------------------------------------------------------------------------------------------------------------------------------------

(spy:secret/if "config/keybinds/org-mode.el"
    '(:skip "Skipping org-journal keybind config."
      :eval "")
  (when (jerky/namespace/has :work)
    ;; Add `:home' namespaced org-journal stuff.
    (when (featurep! :lang org +journal)
      ;; Insert :work dir local variable(s).
      (jerky/dlv/set nil
                     (jerky/get 'path 'org 'journal :namespace :work)
                     'org-journal-mode
                     'org-journal-dir
                     :namespace :work
                     :value (jerky/get 'path 'org 'journal :namespace :work)
                     :docstr "org-journal's :work directory"
                     :dlv 'full
                     :safe t)
      ;; (jerky/dlv/set nil
      ;;                (jerky/get 'path 'taskspace :namespace :work)
      ;;                'taskspace-mode
      ;;                'org-journal-dir
      ;;                :namespace :work
      ;;                :value (jerky/get 'path 'org 'journal :namespace :work)
      ;;                :docstr "org-journal's :work directory"
      ;;                :dlv 'full
      ;;                :safe t)

      ;; Insert :work journal shortcuts if appropriate.
      ;; Add to Doom Leader...
      (map! :leader
            ;; :normal, :visual states of evil
            ;; (not :motion, :emacs, :insert, :operator-pending)
            (:prefix "n" ;; notes
             (:prefix "j" ;; ("j" . "journal")
              ;; Work namespaced commands.
              (:prefix ("w" . ":work journal")
               :desc ":work - New Entry"           "w" (cmd!
                                                        (sss:org.journal/namespaced
                                                         :work
                                                         (funcall-interactively #'org-journal-new-entry current-prefix-arg)))
               :desc ":work - New Entry"           "j" (cmd!
                                                        (sss:org.journal/namespaced
                                                         :work
                                                         (funcall-interactively #'org-journal-new-entry current-prefix-arg)))
               :desc ":work - New Scheduled Entry" "J" (cmd!
                                                        (sss:org.journal/namespaced
                                                         :work
                                                         (funcall-interactively #'org-journal-new-scheduled-entry current-prefix-arg)))
               :desc ":work - Visit Journal"       "v" (cmd!
                                                        (sss:org.journal/namespaced
                                                         :work
                                                         (funcall-interactively #'org-journal-open-current-journal-file)))
               :desc ":work - Search Forever"      "s" (cmd!
                                                        (sss:org.journal/namespaced
                                                         :work
                                                         (funcall-interactively #'org-journal-search-forever nil)))))))))

  ;; Insert :home journal shortcuts if appropriate.
  (when (jerky/namespace/has :home)
    ;; Add `:home' namespaced org-journal stuff.
    (when (featurep! :lang org +journal)
      ;; Insert :home dir local variable(s).
      (jerky/dlv/set nil
                     (jerky/get 'path 'org 'journal :namespace :home)
                     'org-journal-mode
                     'org-journal-dir
                     :namespace :home
                     :value (jerky/get 'path 'org 'journal :namespace :home)
                     :docstr "org-journal's :home directory"
                     :dlv 'full
                     :safe t)

      ;; Insert :home journal shortcuts if appropriate.
      ;; Add to Doom Leader...
      (map! :leader
            ;; :normal, :visual states of evil
            ;; (not :motion, :emacs, :insert, :operator-pending)
            (:prefix "n" ;; notes
             (:prefix "j" ;; journal
              ;; Home namespaced commands.
              (:prefix ("h" . ":home journal")
               :desc ":home - New Entry"           "h" (cmd!
                                                        (sss:org.journal/namespaced
                                                         :home
                                                         (funcall-interactively #'org-journal-new-entry current-prefix-arg)))
               :desc ":home - New Entry"           "j" (cmd!
                                                        (sss:org.journal/namespaced
                                                         :home
                                                         (funcall-interactively #'org-journal-new-entry current-prefix-arg)))
               :desc ":home - New Scheduled Entry" "J" (cmd!
                                                        (sss:org.journal/namespaced
                                                         :home
                                                         (funcall-interactively #'org-journal-new-scheduled-entry current-prefix-arg)))
               :desc ":home - Visit Journal"       "v" (cmd!
                                                        (sss:org.journal/namespaced
                                                         :home
                                                         (funcall-interactively #'org-journal-open-current-journal-file)))
               :desc ":home - Search Forever"      "s" (cmd!
                                                        (sss:org.journal/namespaced
                                                         :home
                                                         (funcall-interactively #'org-journal-search-forever nil))))))))))


;;------------------------------------------------------------------------------------------------------------------------------------------
;; Org-Roam
;;------------------------------------------------------------------------------------------------------------------------------------------

;; Org-Roam is currently not enabled [2021-06-10].
(when (featurep! :lang org +roam)
  (spy:secret/if "config/keybinds/org-mode.el"
      "Skipping org-roam keybind set-up."
    (map! :leader
          :prefix "nr" ;; notes -> roam
          :desc "Kill roam info buffer" "K" #'sss:org-roam/buffer/deactivate
          :desc "Delete roam info window" "k" #'org-roam-buffer-deactivate)
    (map! :after org
          :map org-mode-map
          :localleader
          :prefix "m" ;; org-roam is... 'm' here instead of 'r'.
          ;; and copy the above 'map!':
          :desc "Kill roam info buffer" "K" #'sss:org-roam/buffer/deactivate
          :desc "Delete roam info window" "k" #'org-roam-buffer-deactivate)))
