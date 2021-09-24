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

;;------------------------------
;; Org-Mode & the Thousand Different "RET" Key Functions
;;------------------------------

;; Auto-indent is a bit odd... Try swapping around RET and S-RET these so the literal newline is on normal enter? Also, `evil-org-return'
;; is... fucked up. It's description says 'Pressing return twice cancels the continuation of the itemlist or table.', but it's not used for
;; continuing lists. "C-RET" is - `+org/insert-item-below'.
;; But you can do "C-RET C-u" to delete the indentation...
;; ...But you can keep doing that to delete previous lines. So - fuck that noise.
;; And it's attempt to detect that you're on an empty line (eolp) and (bolp) to do a literal `org-return' isn't working for me?
;; ...Am I using `evil-org-return' even? I don't think so...
;; +org/shift-return

(after! evil-org
  (map! :map evil-org-mode-map
    ;; Fuck your "more intuitive RET keybinds", Doom.
    :i [return]   #'+org/shift-return
    :i "RET"      #'+org/shift-return
    :i [S-return] (cmd! (org-return electric-indent-mode))
    :i "S-RET"    (cmd! (org-return electric-indent-mode))
  ))


;;------------------------------------------------------------------------------------------------------------------------------------------
;; Org-Agenda
;;------------------------------------------------------------------------------------------------------------------------------------------

(after! org-mode
  ;;------------------------------
  ;; Org-Agenda & the Billion Orphaned Org Buffers
  ;;------------------------------
  ;; Thanks to: https://emacs.stackexchange.com/a/20438
  ;;---

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

(defun sss:keybinds/org-journal ()
  "Run the org-journal keybinds."
  (when (jerky/namespace/has :work)
    ;; Add `:home' namespaced org-journal stuff.
    (when (featurep! :lang org +journal)
      ;; Insert :work dir local variable(s).
      (dlv:set (jerky/get 'path 'org 'journal :namespace :work)
               'org-journal-mode
               (list 'org-journal-dir
                     (jerky/get 'path 'org 'journal :namespace :work)
                     :safe))

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
      (dlv:set (jerky/get 'path 'org 'journal :namespace :home)
               'org-journal-mode
               (list 'org-journal-dir
                     (jerky/get 'path 'org 'journal :namespace :home)
                     :safe))

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

(spy:secret/if "config/keybinds/org-mode.el"
    '(:skip "Skipping org-journal keybind config."
      :eval "")
  ;; Issue:
  ;;   Getting: `invalid string 'nil'`
  ;;
  ;; Re-evaluating the `map!' here fixed it.
  ;;   - Thought it was a one off. See [[*"SPC n j ww" errors out?][here]].
  ;;     + ...but it's a problem every start.
  ;;
  ;; See:
  ;;   file:~/.lily.d/taskspace/work/2021-02-05_1_emacs-27-on-windows.notes.org
  ;;   "SPC n j ww" still a problem

  ;; Set up the org-journal keybinds - want them to exist before org-journal is auto-loaded.
  (sss:keybinds/org-journal)

  ;; Also set up the keybinds after `org-journal' loaded?
  ;; TODO: Figure out the not-just-a-bandaid solution?
  (after! org-journal
    (sss:keybinds/org-journal)))


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
