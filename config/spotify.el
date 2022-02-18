;;; config/spotify.el -*- lexical-binding: t; -*-

;;------------------------------------------------------------------------------
;; Smudge/Spotify Helpers
;;------------------------------------------------------------------------------
;; TODO: Make a "smudge-api.el" file and do a pull request?

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


(defmacro async<spy>:spotify:device:when-active (desired:name &rest body)
  "Evaluate BODY when DESIRED:NAME Spotify device is active.

DESIRED:NAME must be a string of the Spotify device's name.

Variables available during BODY:
  - `macro:devices'       - list of all devices
  - `macro:device'        - desired device
  - `macro:device:name'   - DESIRED:NAME, but from Spotify
  - `macro:device:id'     - device's ID
  - `macro:device:active' - boolean

Always returns nil."
  (declare (indent 1))
  `(progn
     (smudge-api-device-list
      (lambda (macro:json)
        "Run the BODY if DESIRED:NAME is active."
        (when-let* ((macro:desired:name ,desired:name)
                    (macro:devices      (gethash 'devices macro:json))
                    (macro:device       (pop macro:devices))
                    (macro:continue     t))
          ;;------------------------------
          ;; Got one or more devices; process them.
          ;;------------------------------
          (while (and macro:device macro:continue)
            ;; Only bother if we have the vars and it's the device name we want.
            (when-let ((macro:device:name   (smudge-device-get-device-name macro:device))
                       (macro:device:id     (smudge-device-get-device-id macro:device))
                       (macro:device:active (smudge-device-get-device-is-active macro:device))
                       (macro:run-body?     (string= macro:desired:name macro:device:name)))
              ;; Run it.
              (setq macro:continue nil)
              ,@body)

            ;; Selecting next device to process in loop.
            (setq macro:device (pop macro:devices))))))
     nil))
;; (async<spy>:spotify:device:when-active (system-name) (message "hello there"))


;;------------------------------------------------------------------------------
;; `use-package': Smudge (previously Spotify.el)
;;------------------------------------------------------------------------------
;; Control Spotify via Spotify Premium app.

(use-package! smudge

  ;; ;;--------------------
  ;; :init
  ;; ;;--------------------


  ;; ;;--------------------
  ;; :hook
  ;; ;;--------------------


  ;;--------------------
  :config
  ;;--------------------

  ;;--------------------
  ;; customization
  ;;--------------------

  ;;---
  ;; Connection Settings
  ;;---
  (customize-set-variable 'smudge-transport 'connect)
  (customize-set-variable 'smudge-oauth2-callback-port "14576")
  (customize-set-variable 'smudge-oauth2-client-id     (plist-get secret:keys:spotify :id))
  (customize-set-variable 'smudge-oauth2-client-secret (plist-get secret:keys:spotify :secret))

  ;; HACK: This is a defconst so it doesn't update when you set a different port number.
  ;; So... Just force it to update.
  (setq smudge-api-oauth2-callback (concat "http://localhost:" smudge-oauth2-callback-port smudge-oauth2-callback-endpoint))

  ;; Refresh rate in seconds.
  ;; This has to make an API call every time, so... don't overdo it and
  ;; throttle yourself.
  (customize-set-variable 'smudge-player-status-refresh-interval 10)

  ;;---
  ;; Keybinds
  ;;---
  ;; Keybind: See config/keybinds/spotify.el
  ;; (define-key smudge-mode-map (kbd "C-c .") 'smudge-command-map)

  ;;---
  ;; Display
  ;;---

  ;; Put status in title-bar instead of modeline
  (customize-set-variable 'smudge-status-location 'title-bar)

  ;; smudge-player-status-format: default is "[%p: %a - %t ◷ %l %r%s]"
  ;;   - https://github.com/danielfm/smudge#customizing-the-player-status
  (customize-set-variable 'smudge-player-status-format
                          ;; TODO: Elapsed/current time?
                          "%r%s%p ╠═ %a ═╬═ %t ═╣ ◷%l")
  (customize-set-variable 'smudge-title-bar-separator "  ┅┅  ")
  ;; frame-title-format

  ;; I got a lot more room in the titlebar than the modeline...
  (customize-set-variable 'smudge-player-status-truncate-length 30) ;; default: 15

  ;;---
  ;; Status Text
  ;;---
  ;; Defaults are a grab-bag of words ("Playing"/"Stopped") and letters ("R"/"-").

  ;; Do I have unicode media icons?
  ;;   Play:         ▶ / ▶️
  ;;   Pause:        ⏸ / ⏸️
  ;;   Play/Pause:   ⏯ / ⏯️
  ;;   Stop:         ⏹ / ⏹️
  ;;   Skip Back:    ⏮ / ⏮️
  ;;   Skip Forward: ⏭ / ⏭️
  ;;   Shuffle:      🔀 / 🔀️
  ;;   Repeat:       🔁 / 🔁️
  ;;   'Blank/Off':  ◻

  ;; Unicode Icons:
  (customize-set-variable 'smudge-player-status-playing-text       "▶")
  (customize-set-variable 'smudge-player-status-paused-text        "⏸")
  (customize-set-variable 'smudge-player-status-stopped-text       "⏹")
  (customize-set-variable 'smudge-player-status-repeating-text     "🔁")
  (customize-set-variable 'smudge-player-status-not-repeating-text "")   ;; "◻️")
  (customize-set-variable 'smudge-player-status-shuffling-text     "🔀")
  (customize-set-variable 'smudge-player-status-not-shuffling-text "")   ;; "◻")

  ;; ASCII:
  ;; (customize-set-variable 'smudge-player-status-playing-text       "p")
  ;; (customize-set-variable 'smudge-player-status-paused-text        "-")
  ;; (customize-set-variable 'smudge-player-status-stopped-text       "x")
  ;; (customize-set-variable 'smudge-player-status-repeating-text     "R")
  ;; (customize-set-variable 'smudge-player-status-not-repeating-text "-")
  ;; (customize-set-variable 'smudge-player-status-shuffling-text     "S")
  ;; (customize-set-variable 'smudge-player-status-not-shuffling-text "-")


  ;;--------------------
  ;; configuration
  ;;--------------------
  )


;;------------------------------------------------------------------------------
;; Pause Spotify and close Smudge
;;------------------------------------------------------------------------------

(defun spy:workday:end/spotify ()
  "Cleans up Smudge for the day so it hopefully doesn't
have 11 zombie connections to spotify api tomorrow..."
  (interactive)
  (async<spy>:spotify:device:when-active
      (system-name)
    ;;---
    ;; [2022-02-18] Cleaner Version?
    ;;---
    (smudge-connect-player-pause)

    ;; TODO: Do I need to clean up any buffers?
    ;; (spy:cmd:buffer/kill.matching ...)?

    ;; ;;---
    ;; ;; [2019-10-22] Ye Olde Version
    ;; ;;   (Do I need the condition case still?
    ;; ;;---
    ;; (condition-case-unless-debug err
    ;;   (progn
    ;;     (smudge-connect-player-pause)
    ;;     (global-smudge-remote-mode -1)
    ;;     ;; TODO: Do I need to clean up any buffers?
    ;;     ;; (spy:cmd:buffer/kill.matching ...)?
    ;;     )
    ;; ;; Catch signaled error 'error': downgrade to just message.
    ;; ;; [2019-10-22]: This is just theory as spotify can get cranky if
    ;; ;; connected but device was left paused...
    ;; (error
    ;;  ;; Downgrade.
    ;;  (message "[ERROR]: spy:workday:end/spotify: Received error signal:" err)))
    )

  ;; Always disable Smudge mode?
  (global-smudge-remote-mode -1))
;; (spy:workday:end/spotify)


(add-hook 'secret:work:end/day:hook #'spy:workday:end/spotify)


;;------------------------------------------------------------------------------
;; Spotify/Smudge Hydra
;;------------------------------------------------------------------------------

;; TODO: Add major-mode-hydra package so I can use pretty-mode-hydra.
;;   - https://github.com/jerrypnz/major-mode-hydra.el#pretty-hydra
;; TODO: Create a pretty hydra with 'Now Playing' info.
;;   - ugly: https://github.com/cole-brown/spotify.el/blob/6c5b3eb9aa35723d04b2126fea36f9cb241bf5c9/spotify-hydra.el
;;   - old spotify.el setup: https://github.com/cole-brown/spotify.el/tree/6c5b3eb9aa35723d04b2126fea36f9cb241bf5c9


;;------------------------------------------------------------------------------
;; The End.
;;------------------------------------------------------------------------------
(imp:provide :dot-emacs 'config 'spotify)
