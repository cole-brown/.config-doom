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


(defun async<spy>:spotify:device:active? (name callback)
  "Calls CALLBACK with nil/non-nil result of checking if device NAME is active.

CALLBACK should be a function with a signature like:
  - (defun CALLBACK (boolean) ...)
  - (lambda (boolean) ...)
That is, it receives a nil/non-nil result for whether the Spotify device NAME is
active.

The CALLBACK's nil/non-nil input is based on NAME, which should be `nil',
`:any', or a string:
  - If NAME is a string, it is whether that exact Spotify device name is active.
  - If `:any', it is whether _any_ Spotify device is active.
  - If `nil', it is whether the Spotify device `(system-name)' active is.

This function always returns nil. Your CALLBACK gets the result."
  (let ((desired:name (or name
                          (system-name))))
    ;;------------------------------
    ;; Error Checks
    ;;------------------------------
    ;; Invalid CALLBACK?
    (cond ((not (functionp callback))
           (error "async<spy>:spotify:device:active?: CALLBACK must be a function. CALLBACK: %S"
                  callback))

          ;; Invalid NAME input?
          ((not (or (eq desired:name :any)
                    (stringp desired:name)))
           (funcall callback
                    (int<spy>:spotify:response nil
                                               "Desired device name must be %s, got: NAME: %S, DESIRED:NAME: %S"
                                               "a string or `:any'"
                                               name
                                               desired:name)))
          ;;------------------------------
          ;; Check if device is active.
          ;;------------------------------
          ;; Make the async Smudge calls.
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
                   (let ((devices (gethash 'devices json))
                         ;; "Don't care about the rest." flag
                         device:found
                         ;; CALLBACK's input.
                         devices:active)
                     (dolist (device devices)
                       ;; Only bother when we need to keep searching and we've got an active device to check.
                       (when-let ((keep-searching (not device:found))
                                  (device:name    (smudge-device-get-device-name device))
                                  (device:id      (smudge-device-get-device-id device))
                                  (device:active  (smudge-device-get-device-is-active device)))
                         ;; Any device? Push active device names to CALLBACK's input.
                         (cond ((eq desired:name :any)
                                (push device:name devices:active))

                               ;; Specific device check.
                               ((and (stringp device:name)
                                     (string= device:name desired:name))
                                ;; Mark that we don't care about the rest.
                                (setq device:found t)
                                (push device:name devices:active))

                               ;; Don't care about this device.
                               (t
                                nil))))

                     ;; Return result.
                     (if devices:active
                         (funcall callback devices:active)
                       (funcall callback
                                (int<spy>:spotify:response nil
                                                           "No devices are active."))))))))))))

  ;; Always return nil so I don't confuse myself again with this async func.
  nil)
;; (async<spy>:spotify:device:active? nil (lambda (active?) (message "active? %S" active?)))
;; (async<spy>:spotify:device:active? :any (lambda (active?) (message "active? %S" active?)))


(defun async<spy>:spotify:device:activate (name)
  "Tell Spotify to transfer to/activate device NAME.

Always returns nil."
  ;; TODO: input validity check
  (smudge-api-device-list
   (lambda (json)
     "Activate NAME device from list, if possible."
     (let (names:known)
       (if-let* ((devices     (gethash 'devices json))
                 (device      (pop devices))
                 (continue    t))
           ;;------------------------------
           ;; Got one or more devices; process them.
           ;;------------------------------
           (progn
             (while (and device continue)
               ;; Only bother if we have the vars and it's the device name we want.
               (when-let ((device:name   (smudge-device-get-device-name device))
                          (device:id     (smudge-device-get-device-id device))
                          (device:active (smudge-device-get-device-is-active device))
                          (activate?     (string= name device:name)))
                 ;; Add to list of known devices.
                 (if (eq names:known t)
                     (setq names:known (list device:name))
                   (push device:name names:known))

                 (if device:active
                     ;; Already active - just say that?
                     (progn
                       ;; NOTE: Could add a "force activate" param or just ignore
                       ;; `device:active' if there are bugs/issues that need worked
                       ;; around, but this seems smart right now?
                       (int<spy>:spotify:response name
                                                  "Device '%s' already active."
                                                  name)
                       (setq continue nil))

                   ;; Activate (transfer to) this desired device.
                   (smudge-api-transfer-player
                    device:id
                    ;; This is what Smudge does in `smudge-device-select-active', so I think we do it here?
                    (lambda (json)
                      (setq smudge-selected-device-id device-id)
                      (int<spy>:spotify:response name
                                                 "Device '%s' selected" name)))
                   ;; We've found and activated the device; stop the loop.
                   (setq continue nil)))

               ;; Finish up by selecting next device to process.
               (setq device (pop devices)))

             ;;------------------------------
             ;; Feedback: Did we activate anything?
             ;;------------------------------
             (if continue
                 ;; Device requested wasn't in the list.
                 (int<spy>:spotify:response nil
                                            "Desired device '%s' isn't available right now. Available devices: %s"
                                            name
                                            (or names:known "none"))
               (int<spy>:spotify:response name
                                          "Active Device: '%s'."
                                          name)))

         ;;------------------------------
         ;; No devices from Spotify!
         ;;------------------------------
         (int<spy>:spotify:response nil
                                    "No devices.")))))

  ;; Async function - always return nil.
  nil)


(defun async<spy>:spotify:init (&rest plist)
  "Initialize Smudge & Spotify, as necessary, using PLIST.

PLIST can have:
  - `:smudge-mode'
    - non-nil (default if key not supplied)
      - Enables `global-smudge-remote-mode' if needed.
    - nil
      - Don't bother `global-smudge-remote-mode'.

  - `:device'
    - nil (default if key not supplied)
      - Activate `system-name' return value as the Spotify device.
    - `preserve'
      - If any device is active, leave it. Otherwise activate `system-name'.
    - STRING
      - Activate STRING as the Spotify device."
  (let* ((func.name "async<spy>:spotify:init")
         (enable:smudge-mode (if (plist-member plist :smudge-mode)
                                 (plist-get plist :smudge-mode)
                               ;; Default to enabling the mode if no key supplied.
                               :enable))
         (device:this        (system-name))
         (device:valid       '("DEVICE-NAME-STRING" device nil)) ;; Only for printed in error message.
         (enable:device      (if (plist-member plist :device)
                                 (plist-get plist :device)
                               ;; Default to activating this system if no key supplied.
                               device:this)))

        ;;------------------------------
    ;; Activate Device
    ;;------------------------------
    ;; If anything is active, ok. Otherwise activate this device.
    (cond ((eq enable:device 'preserve)
           (async<spy>:spotify:device:active? :any
                                              (lambda (active)
                                                "Activate this device if any device is not ACTIVE."
                                                (unless active
                                                  (async<spy>:spotify:device:activate device:this)))))

          ;; Enable a specific device by name.
          ((stringp enable:device)
           ;; Activate if not active already.
           (async<spy>:spotify:device:activate device:this))

          ;; Already converted `nil' into `system-name' string, so...
          ;; Don't know; error.
          (t
           (error "%s: Unknown `:device' option! Allowed: %S, Got: %S"
                  func.name device:valid enable:device)))

    ;;------------------------------
    ;; Global Smudge Remote Mode
    ;;------------------------------
    (when enable:smudge-mode
      (global-smudge-remote-mode 1))
    ;; Just ignore `enable:smudge-mode' == nil; don't disable the mode in an init func.
    ))


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
   (("h"
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
     "Select Device"
     :exit nil)

    ("i" (async<spy>:spotify:init)
     ;; Can't have non-monospaced characters in this column... throws off the later columns.
     ;; "🚀 Initialize"
     "Initialize"
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


(defun int<spy>:spotify:hydra-maybe-init ()
  "Initialize to this device if nothing is active, then open the hydra."
  (interactive)
  (unless smudge-selected-device-id
    (async<spy>:spotify:init :device 'preserve))
  (int<spy>:spotify:hydra/body))


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
        "u" #'int<spy>:spotify:hydra-maybe-init)))

;; (bind-key "a" #'int<spy>:spotify:hydra/body some-map)


;;------------------------------------------------------------------------------
;; The End.
;;------------------------------------------------------------------------------
(imp:provide :dot-emacs 'config 'keybinds 'spotify)
