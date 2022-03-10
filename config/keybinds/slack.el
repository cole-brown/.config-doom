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
   (("2" slack-message-embed-mention
     "Mention <User>")
    ("3" slack-message-embed-channel
     "Mention <Channel>")
    ("f" slack-file-upload
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

;; TODO: Do I need to get rid of snipe first?
;; (map!
;;  ;; Wait for slack to be lazy/auto-loaded.
;;  (:after slack
;;
;;   ;; Get rid of evil-snipe
;;   :n "," nil))

;; TODO: Some of these functions don't exist (right now? *shrug*) - may need to check & update...
;;   - `slack-room-update-messages'
;;   - `slack-buffer-kill'
;;     - is this supposed to be `slack-buffer-kill-buffer-window'?
(map!
 ;; Wait for slack to be lazy/auto-loaded.
 (:after slack

  (:mode slack-info-mode
   (:prefix ("," . "slack")
    :desc "Update Messages" :nm "u" #'slack-room-update-messages))

  (:mode slack-mode
   (:prefix ("," . "slack")
    :desc "Kill Buffer"              :nm "c" #'slack-buffer-kill
    :desc "Update Messages"          :nm "u" #'slack-room-update-messages
    :desc "Embed Mention (@user)"    :nm "2" #'slack-message-embed-mention
    :desc "Embed Channel (@channel)" :nm "3" #'slack-message-embed-channel

    ;; TODO: Better like this or with `:prefix'?
    :desc "Reaction: Add"        :nm "ra" #'slack-message-add-reaction
    :desc "Reaction: Remove"     :nm "rr" #'slack-message-remove-reaction
    :desc "Reaction: Show Users" :nm "rs" #'slack-message-show-reaction-users

    (:prefix ("p" . "Pins")
     :desc "Pin: List Room Pins" :nm "l" #'slack-room-pins-list
     :desc "Pin: Add"            :nm "a" #'slack-message-pins-add
     :desc "Pin: Remove"         :nm "r" #'slack-message-pins-remove)

    (:prefix ("m" . "Message")
     :desc "Compose in Another Buffer" :nm "m" #'slack-message-write-another-buffer
     :desc "Edit"                      :nm "e" #'slack-message-edit
     :desc "Delete"                    :nm "d" #'slack-message-delete))

   :desc "Next Message" :nm "M-e" #'slack-buffer-goto-next-message
   :desc "Prev Message" :nm "M-." #'slack-buffer-goto-prev-message)

  (:mode slack-edit-message-mode
   (:prefix ("," . "Slack")
    :desc "Cancel Edit"              :nm "k" #'slack-message-cancel-edit
    :desc "Send from Buffer"         :nm "s" #'slack-message-send-from-buffer
    :desc "Embed Mention (@user)"    :nm "2" #'slack-message-embed-mention
    :desc "Embed Channel (@channel)" :nm "3" #'slack-message-embed-channel))))


;;------------------------------------------------------------------------------
;; The End.
;;------------------------------------------------------------------------------
(imp:provide :dot-emacs 'config 'keybinds 'slack)
