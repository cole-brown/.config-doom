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

    ("x" (spy:workday:end/spotify)
     "Pause & Quit"
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
