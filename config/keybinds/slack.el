;;; config/keybinds/slack.el -*- lexical-binding: t; -*-

;;                                 ──────────                                ;;
;; ╔════════════════════════════════════════════════════════════════════════╗ ;;
;; ║                                KEYBINDS                                ║ ;;
;; ╚════════════════════════════════════════════════════════════════════════╝ ;;
;;                                 ──────────                                ;;

(imp:require :modules 'spy 'collections 'alist)


;; TODO: Decide between pretty hydra and Doom leader.
;;   - Doom leader is Doom specific... so hydra for now maybe?
;;   - Does Major Mode Hydra work in this case?
;;     - Think all that does is give me a common keybind for all major-mode-hydras?
;;     - So... maybe? Could start having a "my mode leader"?


;;------------------------------------------------------------------------------
;; Pretty Slack Hydra
;;------------------------------------------------------------------------------

(defvar int<spy>:slack:hydra/title
  ;; TODO: Need any height/v-adjust?
  (with-faicon "slack" ;; Font Awesome icon name
               "Slack" ;; Text after icon
               ;; Icon Settings
               :color:icon "teal"
               ;; :height 1
               ;; :v-adjust -0.05
               )
  "Propertized string with icon & name for Slack pretty-hydra.")
;; int<spy>:slack:pretty-hydra/title
;; (insert int<spy>:slack:pretty-hydra/title)


;; Could have plist args if I need to customize?
(defun int<spy>:slack:title ()
  "Get title string for `pretty-hydra'."
  ;; Icon & "Slack"
  (concat int<spy>:slack:hydra/title
          ;; ;; TODO: Unread channels or mentions or something?
          ;; "\n"
          ;; ;; TODO: Unread channels or mentions or something?
          ;; "etc."
          ))
;; (int<spy>:slack:title)


;; Want to be able to use some of these outside of Slack buffers, so don't use
;; Major-Mode Hydra.
(pretty-hydra-define int<spy>:slack:hydra
  (:quit-key "g"
   :color blue ;; Default to `:exit t' for all heads.
   :title (int<spy>:slack:title))

  ;;------------------------------
  ;; Select: Go to Channel, DM, etc.
  ;;------------------------------
  ("Select"
   (("si" slack-im-select
     "Select IM...")
    ("sc" slack-channel-select
     "Select Channel...")
    ("sg" slack-group-select
     "Select Group...")
    ;; Only have one team right now...
    ;; ("c" slack-change-current-team
    ;;  "Change Current Team")
    )

   ;;------------------------------
   ;; Message / Channel
   ;;------------------------------
   "Message / Channel"
   (("sm" slack-message-embed-mention
     "Mention <User>")
    ("sc" slack-message-embed-channel
     "Mention <Channel>")
    ("sf" slack-file-upload
     "Upload <file>..."))

    ;;------------------------------
    ;; Manage: Start, Select, Update...
    ;;------------------------------
    "Manage"
    (("ms" slack-start
      "Start Slack")
     ("mt" slack-ws-close
      "Stop / Close Slack Websocket")
     ("mg" slack-group-list-update
      "Update Group List")
     ("mi" slack-group-list-update
      "Update IM List")
     ("mi" slack-channel-list-update
      "Update Channel List"))))
;; (int<spy>:slack:hydra/body)


;;------------------------------------------------------------------------------
;; Doom Keybind
;;------------------------------------------------------------------------------

(map! :leader       ; Be under the Doom SPC leader.

      ;;------------------------------
      ;; 'spy' Prefix:
      ;;------------------------------
      (:prefix ("-" . "spy")

       ;;------------------------------
       ;; Apps Prefix:
       ;;------------------------------
       (:prefix ("u" . "Apps")

        ;;------------------------------
        ;; Slack:
        ;;------------------------------
        :desc int<spy>:slack:hydra/title "s" #'int<spy>:slack:hydra/body)))

;; (bind-key "a" #'int<spy>:slack:hydra/body some-map)


;;------------------------------------------------------------------------------
;; Emacs / Evil Keybind
;;------------------------------------------------------------------------------

;; TODO: These in a `pretty-hydra-define' or just in a `map!':
;;   (evil-define-key 'normal slack-info-mode-map
;;     ",u" 'slack-room-update-messages)
;;   (evil-define-key 'normal slack-mode-map
;;     ",c" 'slack-buffer-kill
;;     ",ra" 'slack-message-add-reaction
;;     ",rr" 'slack-message-remove-reaction
;;     ",rs" 'slack-message-show-reaction-users
;;     ",pl" 'slack-room-pins-list
;;     ",pa" 'slack-message-pins-add
;;     ",pr" 'slack-message-pins-remove
;;     ",mm" 'slack-message-write-another-buffer
;;     ",me" 'slack-message-edit
;;     ",md" 'slack-message-delete
;;     ",u" 'slack-room-update-messages
;;     ",2" 'slack-message-embed-mention
;;     ",3" 'slack-message-embed-channel
;;     "\C-n" 'slack-buffer-goto-next-message
;;     "\C-p" 'slack-buffer-goto-prev-message)
;;    (evil-define-key 'normal slack-edit-message-mode-map
;;     ",k" 'slack-message-cancel-edit
;;     ",s" 'slack-message-send-from-buffer
;;     ",2" 'slack-message-embed-mention
;;     ",3" 'slack-message-embed-channel)


;;------------------------------------------------------------------------------
;; The End.
;;------------------------------------------------------------------------------
(imp:provide :dot-emacs 'config 'keybinds 'slack)
