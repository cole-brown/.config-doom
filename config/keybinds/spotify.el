;;; config/keybinds/spotify.el -*- lexical-binding: t; -*-

;;                                 ──────────                                ;;
;; ╔════════════════════════════════════════════════════════════════════════╗ ;;
;; ║                                KEYBINDS                                ║ ;;
;; ╚════════════════════════════════════════════════════════════════════════╝ ;;
;;                                 ──────────                                ;;

(imp:require :modules 'spy 'collections 'alist)


;;------------------------------------------------------------------------------
;; Unicode Media Control Symbols
;;------------------------------------------------------------------------------
;; - https://en.wikipedia.org/wiki/Media_control_symbols
;;
;;   U+23F5  ⏵     	 U+25B6 ▶/▶ 	Play
;;   U+23F8  ⏸/⏸ 	                	Pause
;;   U+23EF  ⏯/⏯ 	               	Play/Pause toggle
;;   U+23F4  ⏴     	 U+25C0 ◀/◀ 	Reverse
;;   U+23F9  ⏹   	 U+25A0 ■      	Stop
;;   U+23EA  ⏪/⏪ 	               	Back (Fast Backwards)
;;   U+23E9  ⏩/⏩ 	               	Fast forward
;;   U+23EE  ⏮/⏮ 	               	Skip to the start or previous file/track/chapter
;;   U+23ED  ⏭/⏭ 	               	Skip to the end or next file/track/chapter
;;   U+23FA  ⏺/⏺ 	               	Record
;;   U+23CF  ⏏/⏏ 	               	Eject
;;   U+1F500 🔀/🔀 	               	Shuffle
;;   U+1F501 🔁/🔁 	U+1F503 🔃/🔃  	Repeat (indefinitely)
;;   U+1F502 🔂/🔂 	               	Repeat once
;;   U+2139  ℹ/ℹ 	               	Info
;;   U+1F504 🔄/🔄 	               	Reload, Refresh
;; See also:
;;   http://xahlee.info/comp/unicode_computing_symbols.html


;;------------------------------------------------------------------------------
;; Smudge/Spotify Helpers
;;------------------------------------------------------------------------------


(defun int<spy>:spotify:response (keyword msg &rest args)
  "Print MSG and ARGS via `message' for a response from a `smudge' async func.

Prefixes messages with \"Spotify: \""
  (when msg
    (message "Spotify: %s"
             (if args
                 (apply #'format msg args)
               msg)))
  keyword)


(defun async<spy>:spotify:device:select (&optional name)
  "Select device NAME (default `(system-name)') as the active Spotify device.

TODO: Better error handling from Smudge would be nice...
Prints a(n error) message if:
  - NAME is not a string.
  - Spotify user does not have a premium subscription.
  - NAME is not in Spotify's list of devices.
  - NAME not found on the list of Spotify devices.

TODO: Better error handling from Smudge would be nice... Am I allowed to raise error signals?
Returns `:error' or nil."
  (let ((desired:name (or name (system-name)))
        ;; Did we end up finding a device to try to select?
        (desired:active? nil))
    (if (not (stringp desired:name))
        (int<spy>:spotify:response :error
                                   "Desired device name must be a string, got: NAME: %S, DESIRED:NAME: %S"
                                   name
                                   desired:name)

      ;; Check the Spotify user has enough permissions.
      (smudge-api-current-user
       (lambda (user)
         (if (not (string= (gethash 'product user) "premium"))
             (int<spy>:spotify:response :error
                                        "This feature requires a Spotify premium subscription.")

           ;; Get devices currently known to Spotify.
           (smudge-api-device-list
            (lambda (json)
              (if-let ((devices (gethash 'devices json)))
                  (dolist (device devices)
                    (when-let* ((device:name    (smudge-device-get-device-name device))
                                (device:id      (smudge-device-get-device-id device))
                                (device:select? (and (stringp device:name)
                                                     (string= device:name desired:name))))
                      ;; Note the state we found it in.
                      (setq desired:active? (smudge-device-get-device-is-active device))

                      ;;------------------------------
                      ;; Found a matching device; select it.
                      ;;------------------------------
                      (smudge-api-transfer-player
                       device:id
                       (lambda (_)
                         (setq smudge-selected-device-id device:id)
                         (if desired:active?
                             (int<spy>:spotify:response nil
                                                        "Device '%s' already active. Reselected anyways."
                                                        device:name)
                           (int<spy>:spotify:response nil
                                                      "Device '%s' selected."
                                                      device:name))))))

                (int<spy>:spotify:response :error
                                           "No devices are available."))))
           nil))))))
;; (async<spy>:spotify:device:select)


(defun async<spy>:spotify:device:active? (callback &optional name)
  "Calls CALLBACK with nil/non-nil result of checking if device is active.

Always returns nil."
  (let ((desired:name (or name
                          (system-name))))
    (cond ((not (functionp callback))
           (error "async<spy>:spotify:device:active?: CALLBACK must be a function. CALLBACK: %S"
                  callback))
          ((not (stringp desired:name))
           (funcall callback
                    (int<spy>:spotify:response nil
                                               "Desired device name must be a string, got: NAME: %S, DESIRED:NAME: %S"
                                               name
                                               desired:name)))
          (t
           ;; Check the Spotify user has enough permissions.
           (smudge-api-current-user
            (lambda (user)
              (if (not (string= (gethash 'product user) "premium"))
                  (funcall callback
                           (int<spy>:spotify:response nil
                                                      "This feature requires a Spotify premium subscription."))

                ;; Get devices currently known to Spotify.
                (smudge-api-device-list
                 (lambda (json)
                   (if-let ((devices (gethash 'devices json)))
                       (dolist (device devices)
                         (when-let* ((device:name    (smudge-device-get-device-name device))
                                     (device:id      (smudge-device-get-device-id device))
                                     (device:check? (and (stringp device:name)
                                                         (string= device:name desired:name))))
                           ;; Return active status of desired device.
                           (funcall callback (smudge-device-get-device-is-active device))))

                     (funcall callback
                              (int<spy>:spotify:response nil
                                                         "No devices are available.")))))
                desired:active?))))))
  nil)
;; (async<spy>:spotify:device:active? (lambda (active?) (message "active? %S" active?)))


;;------------------------------------------------------------------------------
;; Pretty Spotify Hydra
;;------------------------------------------------------------------------------

(defvar int<spy>:spotify:hydra/title
  ;; TODO: Need any height/v-adjust?
  (with-faicon "spotify" ;; Font Awesome icon name
               "Spotify" ;; Text after icon
               ;; Icon Settings
               :color:icon "limegreen"
               ;; :height 1
               ;; :v-adjust -0.05
               )
  "Propertized string with icon & name for Spotify pretty-hydra.")
;; int<spy>:spotify:hydra/title
;; (insert int<spy>:spotify:hydra/title)


;; Could have plist args if I need to customize?
(defun int<spy>:spotify:title ()
  "Get title string for `pretty-hydra'."
  ;; Icon & "Spotify"
  (concat int<spy>:spotify:hydra/title
          "\n"
          ;; Player Status formatted string.
          smudge-controller-player-status))


;; TODO: pretty-hydra needs to know about unicode character widths in order to make nice tables? :(
;;   - In the mean time, move the icon stuff to last in the columns.
;;
;; TODO: pretty-hydra: Would be nice if there was an `:enabled' that could grey things out & ignore keybind if not true.
;;
;; TODO: Update the 'now playing' status line more often?
;;   - Currently it only updates when a key is pressed, then the hydra is close/reopened.
;;   - Use `:formatter' arg/function?
;;     - https://github.com/jerrypnz/major-mode-hydra.el#pretty-hydra-define
(pretty-hydra-define int<spy>:spotify:hydra
  (:quit-key "g" :title (int<spy>:spotify:title))

  ;;------------------------------
  ;; Search: Playlists, Artist, etc.
  ;;------------------------------
  ("Search"
   (("d"
     smudge-my-playlists
     "My Playlists")

    ("t"
     smudge-featured-playlists
     "Featured Playlists")

    ("n"
     smudge-user-playlists
     "User Playlists")

    ("s"
     smudge-track-search
     "Search for Track"))

   ;;------------------------------
   ;; Manage: Devices
   ;;------------------------------
   "Manage"
   (("d" smudge-select-device
     "Device"
     :exit nil)

    ;; TODO: A 'refresh' which makes a call to get a new status string, then redraws the hydra when the result comes back?
    ;; "🔄 Refresh Status"
    ;;   - TODO: Would putting a zero-width space in there make pretty-hydra align things correctly due to the double-wide glyph?
    )

   ;;------------------------------
   ;; Control: Play, Volume, etc.
   ;;------------------------------
   "Track"
   ;; TODO: Toggle/choose from play or pause: "▶" "⏸"
   (("p"
     smudge-controller-toggle-play
     "⏯")
    ;; Could do?:
    ;;   :toggle #'func-that-gets-current-state
    ;;   :exit nil

    ("u" ;; character forward
     smudge-controller-next-track
     "⏭"
     :exit nil)

    ("o" ;; character backwards
     smudge-controller-previous-track
     "⏮"
     :exit nil)

    (";"
     smudge-controller-toggle-shuffle
     "🔀"
     ;; TODO: :toggle #'func-that-gets-current-state
     )

    ("q"
     smudge-controller-toggle-repeat
     "🔁"
     ;; TODO: :toggle #'func-that-gets-current-state
     ))

   "Volume"
   (("." ;; line previous
     smudge-controller-volume-up
     "🔊"
     :exit nil)

    ("e" ;; line next
     smudge-controller-volume-down
     "🔉"
     :exit nil)

    ;; TODO: choose from mute or unmute: "🔇" "🔈"
    ("x" smudge-controller-volume-mute-unmute
     "🔇"
     ;; ??-TODO-??: :toggle #'func-that-gets-current-state
     :exit nil))))
;; (int<spy>:spotify:hydra/body)


;;------------------------------------------------------------------------------
;; The Actual Keybind
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
        ;; Spotify:
        ;;------------------------------
        :desc (concat int<spy>:spotify:hydra/title " Remote")
        "u" #'int<spy>:spotify:hydra/body)))

;; (bind-key "a" #'int<spy>:spotify:hydra/body some-map)


;;------------------------------------------------------------------------------
;; The End.
;;------------------------------------------------------------------------------
(imp:provide :dot-emacs 'config 'keybinds 'spotify)
