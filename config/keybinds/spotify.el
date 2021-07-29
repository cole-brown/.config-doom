;;; config/keybinds/spotify.el -*- lexical-binding: t; -*-

;;                                                               ──────────                                                               ;;
;; ╔════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════╗ ;;
;; ║                                                              KEYBINDS                                                              ║ ;;
;; ╚════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════╝ ;;
;;                                                               ──────────                                                               ;;


;;------------------------------------------------------------------------------------------------------------------------------------------
;; Smudge package for controlling Spotify
;;------------------------------------------------------------------------------------------------------------------------------------------

(defhydra hydra:spotify (:hint none)
  "
^Search^                  ^Control^               ^Manage^
^------^------------------^-------^---------------^------^-----------------
_t_: ?t?^^^^^^^^^^^^^^^^  _SPC_: ?SPC?^^^^^^^^^^^  _+_: ?+?
_m_: ?m?^^^^^^^^^^^^^^^^  _n_  : ?n?^^^^^^^^^^^^^  _-_: ?-?
_f_: ?f?^^^^^^^^^^^^^^^^  _p_  : ?p?^^^^^^^^^^^^^  _x_: ?x?
_u_: ?u?^^^^^^^^^^^^^^^^  _r_  : ?r?^^^^^^^^^^^^^  _d_: ?d?
^ ^                       _s_  : ?s?^^^^^^^^^^^^^  _q_: ?q?
"
  ("t" smudge-track-search
   (format "%-19s"
           "Track")
   :exit t)

  ("m" smudge-my-playlists
   (format "%-19s"
           "My Playlists")
   :exit t)

  ("f" smudge-featured-playlists
   (format "%-19s"
           "Featured Playlists")
   :exit t)

  ("u" smudge-user-playlists
   (format "%-19s"
           "User Playlists")
   :exit t)

  ("SPC" smudge-controller-toggle-play
   (format "%-15s"
           "Play/Pause")
   :exit nil)

  ("n" smudge-controller-next-track
   (format "%-15s"
           "Next Track")
   :exit nil)

  ("p" smudge-controller-previous-track
   (format "%-15s"
           "Previous Track")
   :exit nil)

  ("r" smudge-controller-toggle-repeat
   (format "%-15s"
           "Repeat")
   :exit nil)

  ("s" smudge-controller-toggle-shuffle
   (format "%-15s"
           "Shuffle")
   :exit nil)

  ("+" smudge-controller-volume-up
   (format "%s"
           "Volume Up")
   :exit nil)

  ("-" smudge-controller-volume-down
   (format "%s"
           "Volume Down")
   :exit nil)

  ("x" smudge-controller-volume-mute-unmute
   (format "%s"
           "Mute")
   :exit nil)

  ("d" smudge-select-device
   (format "%s"
           "Device")
   :exit nil)

  ("q" quit-window
   (format "%s"
           "Quit")
   :color blue))

;; (bind-key "a" #'hydra-spotify/body some-map)
