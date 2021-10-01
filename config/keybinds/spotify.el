;;; config/keybinds/spotify.el -*- lexical-binding: t; -*-

;;                                                               ──────────                                                               ;;
;; ╔════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════╗ ;;
;; ║                                                              KEYBINDS                                                              ║ ;;
;; ╚════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════╝ ;;
;;                                                               ──────────                                                               ;;

(imp:require :modules 'spy 'collections 'alist)


;;------------------------------------------------------------------------------------------------------------------------------------------
;; Unicode Media Control Symbols
;;------------------------------------------------------------------------------------------------------------------------------------------
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
;;
;; See also:
;;   http://xahlee.info/comp/unicode_computing_symbols.html

;;------------------------------------------------------------------------------------------------------------------------------------------
;; Hydra Formatting
;;------------------------------------------------------------------------------------------------------------------------------------------

(defvar int<spy>:spotify:hydra/heads nil
  "An alist of formatted strings for hydra heads.

Each assoc in alist is: '(:KEYWORD UNICODE-SYMBOL RAW-STRING nil/FORMATTED-STRING)")


(defvar int<spy>:spotify:hydra/width.keybind nil
  "Width of format strings used for formatting keybinds of hydra heads.")


(defvar int<spy>:spotify:hydra/width.name nil
  "Width of format strings used for formatting `int<spy>:spotify:hydra/heads' and hydra's column names.")


(defvar int<spy>:spotify:hydra/width.full nil
  "Width of format strings used for formatting `int<spy>:spotify:hydra/heads' and hydra's column names.")

(defconst int<spy>:spotify:hydra/separator ": "
  "String to separate hydra head's keybind from its name.")


(defun int<spy>:spotify:hydra/fmt.name (add subtract)
  "Create a format string given width `int<spy>:spotify:hydra/width.name'.

Adds ADD list, subtracts SUBTRACT list."
  (let ((width (number-to-string
                (apply #'-
                       (apply #'+ int<spy>:spotify:hydra/width.name add)
                       ;; In case subtract is nil, subtract zero so we don't just negate what we added.
                       0
                       subtract))))
    (concat "%-"
            width
            "."
            width
            "s")))
;; (int<spy>:spotify:hydra/fmt nil '(2))


(defun int<spy>:spotify:hydra/fmt.keybind ()
  "Create a format string for the hydra head's keybind."
  (concat "%"
          (number-to-string (+ 1   ; "_"
                               int<spy>:spotify:hydra/width.keybind ; keybind string
                               1   ; "_"
                               (length int<spy>:spotify:hydra/separator))) ; ": "
          "s"))
;; (int<spy>:spotify:hydra/fmt.keybind)


(defun int<spy>:spotify:hydra/fmt.full (string &optional center)
  "Create a format string for the full width of keybind + name."
  (if center
      ;; Center the string.
      (let* ((pad.total (- int<spy>:spotify:hydra/width.full (length string)))
             (pad.left (/ pad.total 2))
             (pad.right (/ (1+ pad.total) 2)))
        (concat (make-string pad.left ?\s)
                string
                (make-string pad.right ?\s)))

    ;; Left align the string.
    (format (concat "%-"
                    (number-to-string int<spy>:spotify:hydra/width.full)
                    "."
                    (number-to-string int<spy>:spotify:hydra/width.full)
                    "s")
            string)))
;; (int<spy>:spotify:hydra/fmt.full "Hello")
;; (int<spy>:spotify:hydra/fmt.full "Hello" :center)
;; (= (length (int<spy>:spotify:hydra/fmt.full "Hello")) (length (int<spy>:spotify:hydra/fmt.full "Hello" :center)))


(defun int<spy>:spotify:hydra/head (key keybind unicode-symbol string &optional add subtract)
  "Create keyword KEY's formatted strings for both UNICODE-SYMBOL and STRING.

Adds/updates entry in `int<spy>:spotify:hydra/heads'."
  (spy:alist/update
    key
    (list :keybind      keybind
          :name.unicode unicode-symbol
          :name.title   string
          :fmt.add      add
          :fmt.subtract subtract)
    int<spy>:spotify:hydra/heads
    :update-in-place))


(int<spy>:spotify:hydra/head :track              "t"   nil  "Search for Track")
(int<spy>:spotify:hydra/head :lists:my           "m"   nil  "My Playlists")
(int<spy>:spotify:hydra/head :lists:featured     "f"   nil  "Featured Playlists")
(int<spy>:spotify:hydra/head :lists:user         "u"   nil  "User Playlists")
(int<spy>:spotify:hydra/head :device             "d"   nil  "Device")
(int<spy>:spotify:hydra/head :quit               "q"   nil  "Quit")
(int<spy>:spotify:hydra/head :volume:mute        "x"   "🔇" "Mute")
(int<spy>:spotify:hydra/head :volume:unmute      "x"   "🔈" "Unmute")
(int<spy>:spotify:hydra/head :volume:mute/unmute "x"   "🔇" "Mute/Unmute")
(int<spy>:spotify:hydra/head :volume:up          "+"   "🔊" "Volume Up")
(int<spy>:spotify:hydra/head :volume:down        "-"   "🔉" "Volume Down")
(int<spy>:spotify:hydra/head :play               nil   "▶" "Play")
(int<spy>:spotify:hydra/head :pause              nil   "⏸" "Pause")
(int<spy>:spotify:hydra/head :play/pause         "SPC" "⏯" "Play/Pause" nil '(1))
(int<spy>:spotify:hydra/head :skip:next          "p"   "⏮" "Previous Track" nil '(1)) ; aka "Skip Backwards"
(int<spy>:spotify:hydra/head :skip:previous      "n"   "⏭" "Next Track" nil '(1)) ; aka "Skip Forwards"
(int<spy>:spotify:hydra/head :shuffle            "s"   "🔀" "Shuffle")
(int<spy>:spotify:hydra/head :repeat             "r"   "🔁" "Repeat")
(int<spy>:spotify:hydra/head :refresh            nil   "🔄" "Refresh")

;; (int<spy>:spotify:hydra/head :info           "ℹ" "Info")
;; (int<spy>:spotify:hydra/head :record         "⏺" "Record")
;; (int<spy>:spotify:hydra/head :eject          "⏏" "Eject")
;; (int<spy>:spotify:hydra/head :reverse        "◀" "Reverse")
;; (int<spy>:spotify:hydra/head :stop           "⏹" "Stop")
;; (int<spy>:spotify:hydra/head :fast:backwards "⏪" "Fast Forwards")
;; (int<spy>:spotify:hydra/head :fast:forwards  "⏩" "Fast Backwards")


(defun int<spy>:spotify:hydra/format ()
  "Format the hydra heads in `int<spy>:spotify:hydra/heads'."
  (setq int<spy>:spotify:hydra/width.name
        ;; Get the longest name string's length.
        (apply #'max
               (mapcar (lambda (head)
                         "Get length of hydra head's string."
                         ;; Plist is the cdr of the alist assoc list.
                         ;;   - (:keyword . (:keybind "x" :name.unicode "x" ...))
                         (max (length (plist-get (cdr head) :name.unicode))
                              (length (plist-get (cdr head) :name.title))))
                       int<spy>:spotify:hydra/heads)))
  (setq int<spy>:spotify:hydra/width.keybind
        ;; Get the longest keybind string's length.
        (apply #'max
               (mapcar (lambda (head)
                         "Get length of hydra head's string."
                         (length (plist-get (cdr head) :keybind)))
                       int<spy>:spotify:hydra/heads)))
  (setq int<spy>:spotify:hydra/width.full
        (+ int<spy>:spotify:hydra/width.name
           int<spy>:spotify:hydra/width.keybind
           (length int<spy>:spotify:hydra/separator)))

  (let (hydra/head:new)
    ;; Create/update formatted string for each head.
    (dolist (head int<spy>:spotify:hydra/heads)
      (let* ((fmt.add      (plist-get (cdr head) :fmt.add))
             (fmt.subtract (plist-get (cdr head) :fmt.subtract))
             (fmt
              ;; Make a format string that fits all names in heads.
              (int<spy>:spotify:hydra/fmt.name fmt.add fmt.subtract)))

        ;; Each hydra head is a cons of the keyword and the plist of head properties.
        (push (cons (car head) ; keyword
                    ;; plist
                    (list :keybind      (plist-get (cdr head) :keybind)
                          :name.unicode (plist-get (cdr head) :name.unicode)
                          :name.title   (plist-get (cdr head) :name.title)
                          :fmt.add      fmt.add
                          :fmt.subtract fmt.subtract
                          :fmt.unicode  (when (plist-get (cdr head) :name.unicode)
                                          (format fmt (plist-get (cdr head) :name.unicode))) ; formatted unicode or nil
                          :fmt.title    (when (plist-get (cdr head) :name.title)
                                          (format fmt (plist-get (cdr head) :name.title))))) ; formatted title
              hydra/head:new)))

    ;; Replace old stuff with new.
    (setq int<spy>:spotify:hydra/heads hydra/head:new)))


(int<spy>:spotify:hydra/format)

;; (pp int<spy>:spotify:hydra/heads)


(defun int<spy>:spotify:hydra/get (keyword plist-key)
  "Get KEYWORD's hydra head's PLIST-KEY."
  (plist-get (alist-get keyword int<spy>:spotify:hydra/heads)
             plist-key))
;; (int<spy>:spotify:hydra/get :play/pause :name.title)
;; (length (int<spy>:spotify:hydra/get :play/pause :name.unicode))
;; (length (int<spy>:spotify:hydra/get :repeat :name.unicode))


(defun int<spy>:spotify:hydra/get.name (keyword &optional prefer)
  "Get KEYWORD's hydra head's formatted name.

Chooses between 'title' and 'unicode' names, preferring 'unicode'
if PREFER is nil or `:unicode'."
  (let* ((head/plist (alist-get keyword int<spy>:spotify:hydra/heads))
         ;; Get the formatted unicode and title.
         (unicode    (plist-get head/plist :fmt.unicode))
         (title      (plist-get head/plist :fmt.title))
         preferred
         fallback)
    ;; Return string, preferring unicode.
    (cond ((or (null prefer)
               (eq prefer :unicode))
           (setq preferred unicode
                 fallback title))
          ((eq prefer :title)
           (setq preferred title
                 fallback unicode))
          (t
           (error "int<spy>:spotify:hydra/get.name: Unknown PREFER: %S" prefer)))

    ;; Try to return preferred if it exists.
    (cond (preferred
           preferred)
          (fallback
           fallback)
          (t
           (error "int<spy>:spotify:hydra/get.name: Both unicode and title are nil for keyword: %S" keyword)))))
;; (int<spy>:spotify:hydra/get.description :play/pause)


(defun int<spy>:spotify:hydra/get.keybind (keyword)
  "Get keybind string for KEYWORD."
  (int<spy>:spotify:hydra/get keyword :keybind))
;; (int<spy>:spotify:hydra/get.keybind :play/pause)


(defun int<spy>:spotify:hydra/description:shortcut (keyword &optional add subtract)
  "Create a description entry for the KEYWORD's keybind.

If ADD or SUBTRACT are non-nil: Adds ADD list to width, subtracts SUBTRACT list."
  (let ((keybind (int<spy>:spotify:hydra/get.keybind keyword)))
    (concat
     ;; Keybind
     (format (int<spy>:spotify:hydra/fmt.keybind)
             (concat "_"
                     keybind
                     "_: "))

     ;; Key's description field.
     (format (int<spy>:spotify:hydra/fmt.name add subtract)
             (concat "?"
                     keybind
                     "?"
                     (make-string int<spy>:spotify:hydra/width.name ?^))))))
;; (int<spy>:spotify:hydra/description:shortcut :play/pause)
;; (int<spy>:spotify:hydra/description:shortcut :repeat)


(defun int<spy>:spotify:hydra/description:empty ()
  "Create an empty field."
  (int<spy>:spotify:hydra/fmt.full ""))
;; (int<spy>:spotify:hydra/description:empty)


(defun int<spy>:spotify:hydra/row (separator &rest columns)
  "Create a row from COLUMNS strings with SEPARATOR in between columns."
  (apply #'str:join separator columns))


(defun int<spy>:spotify:hydra/description:rows ()
  "Creates the `hydra:spotify' description row strings."
  (let* ((titles '("Search" "Control" "Manage"))
         (separator.char:horizontal "─")
         (separator.char:vertical "│")
         (separator.char:intersect "┼")
         (separator.empty (concat " "
                                  separator.char:vertical
                                  " "))
         (separator.full (concat separator.char:horizontal
                                 separator.char:intersect
                                 separator.char:horizontal))
         rows)

    ;;---
    ;; Column Titles Line & Separator Line
    ;;---
    (let (row.title
          row.separator)
      ;; Format each title to width and each separator for title to the same width.
      (dolist (title titles)
        (push (concat "^^^^" ;; Two underscores and two question marks to ignore.
                      (int<spy>:spotify:hydra/fmt.full title :center))
              row.title)
        (push (concat "^^^^" ;; Two underscores and two question marks to ignore.
                      (int<spy>:spotify:hydra/fmt.full
                       (make-string int<spy>:spotify:hydra/width.full ?─)))
              row.separator))
      ;; And join 'em up before adding to our rows.
      (push (apply #'str:join separator.empty row.title)
            rows)
      (push (apply #'str:join separator.full  row.separator)
            rows))

    ;;---
    ;; Hydra Head Rows
    ;;---
    ;; Row 01:
    (push
     (int<spy>:spotify:hydra/row
      separator.empty
      (int<spy>:spotify:hydra/description:shortcut :track)   ; Track Search
      (int<spy>:spotify:hydra/description:shortcut :play/pause) ; Play Toggle
      (int<spy>:spotify:hydra/description:shortcut :volume:up))  ; Volume Up
     rows)

    ;; Row 02:
    (push
     (int<spy>:spotify:hydra/row
      separator.empty
      (int<spy>:spotify:hydra/description:shortcut :lists:my)   ; My Playlists
      (int<spy>:spotify:hydra/description:shortcut :skip:next)   ; Next Track
      (int<spy>:spotify:hydra/description:shortcut :volume:down))  ; Volume Down
     rows)

    ;; Row 03:
    (push
     (int<spy>:spotify:hydra/row
      separator.empty
      (int<spy>:spotify:hydra/description:shortcut :lists:featured)   ; Featured Playlists
      (int<spy>:spotify:hydra/description:shortcut :skip:previous)   ; Previous Track
      (int<spy>:spotify:hydra/description:shortcut :volume:mute/unmute))  ; Mute Toggle
     rows)

    ;; Row 04:
    (push
     (int<spy>:spotify:hydra/row
      separator.empty
      (int<spy>:spotify:hydra/description:shortcut :lists:user)   ; User Playlists
      (int<spy>:spotify:hydra/description:shortcut :repeat)   ; Repeat
      (int<spy>:spotify:hydra/description:shortcut :device))  ; Device
     rows)

    ;; Row 05:
    (push
     (int<spy>:spotify:hydra/row
      separator.empty
      (int<spy>:spotify:hydra/description:empty)          ; "            "
      (int<spy>:spotify:hydra/description:shortcut :shuffle)   ; Shuffle Toggle
      (int<spy>:spotify:hydra/description:shortcut :quit))  ; Quit
     rows)

    ;;---
    ;; Now we have all the rows (backwards). Reverse and return.
    ;;---
    (nreverse rows)))
;; (int<spy>:spotify:hydra/description:rows)


(defun int<spy>:spotify:hydra/description ()
  "Create a full description for the hydra.

This allows you to create your docstring like so:
(defhydra hydra:example (...)
  (format \"%s\" (int<spy>:spotify:hydra/description))
  ...)"
  (concat "\n"
          (apply #'str:join "\n"
                 (int<spy>:spotify:hydra/description:rows))
          "\n"))
;; (int<spy>:spotify:hydra/description)


;;---
;; Doesn't work. :/
;;---
;; (defun int<spy>:spotify:hydra/head (keyword func &rest args)
;;   "Create a hydra head for keyword."
;;   (apply #'list
;;          (int<spy>:spotify:hydra/get.keybind keyword)
;;          func
;;          (int<spy>:spotify:hydra/get.name    keyword)
;;          args))
;; ;; (int<spy>:spotify:hydra/head :play/pause #'ignore :hello "there")
;;---
;; (defmacro int<spy>:spotify:hydra/head (keyword func &rest args)
;;   "Create a hydra head for keyword."
;;   `(list ,(int<spy>:spotify:hydra/get.keybind keyword)
;;     ,func
;;     ,(int<spy>:spotify:hydra/get.name    keyword)
;;     ,@args))
;; ;; (int<spy>:spotify:hydra/head :play/pause #'ignore :hello "there")
;;---


;;------------------------------------------------------------------------------------------------------------------------------------------
;; Hydra for Smudge package for controlling Spotify
;;------------------------------------------------------------------------------------------------------------------------------------------

;; TODO: How does that pretty hydra package thingy work compared to this?
(defhydra hydra:spotify (:hint none)
  (format "%s" (int<spy>:spotify:hydra/description))

  ;;  "
  ;; ^Search^                  ^Control^               ^Manage^
  ;; ^------^------------------^-------^---------------^------^-----------------
  ;; _t_: ?t?^^^^^^^^^^^^^^^^  _SPC_: ?SPC?^^^^^^^^^^^  _+_: ?+?
  ;; _m_: ?m?^^^^^^^^^^^^^^^^  _n_  : ?n?^^^^^^^^^^^^^  _-_: ?-?
  ;; _f_: ?f?^^^^^^^^^^^^^^^^  _p_  : ?p?^^^^^^^^^^^^^  _x_: ?x?
  ;; _u_: ?u?^^^^^^^^^^^^^^^^  _r_  : ?r?^^^^^^^^^^^^^  _d_: ?d?
  ;; ^ ^                       _s_  : ?s?^^^^^^^^^^^^^  _q_: ?q?
  ;; "

  ;; (int<spy>:spotify:hydra/head :track #'smudge-track-search :exit t)

  ("t" smudge-track-search
   (int<spy>:spotify:hydra/get.name :track)
   :exit t)

  ("m" smudge-my-playlists
   (int<spy>:spotify:hydra/get.name :lists/my)
   :exit t)

  ("f" smudge-featured-playlists
   (int<spy>:spotify:hydra/get.name :lists/featured)
   :exit t)

  ("u" smudge-user-playlists
   (int<spy>:spotify:hydra/get.name :lists/user)
   :exit t)

  ("SPC" smudge-controller-toggle-play
   (int<spy>:spotify:hydra/get.name :play/pause)
   :exit nil)

  ("n" smudge-controller-next-track
   (int<spy>:spotify:hydra/get.name :skip:next)
   :exit nil)

  ("p" smudge-controller-previous-track
   (int<spy>:spotify:hydra/get.name :skip:previous)
   :exit nil)

  ("r" smudge-controller-toggle-repeat
   (int<spy>:spotify:hydra/get.name :repeat)
   :exit nil)

  ("s" smudge-controller-toggle-shuffle
   (int<spy>:spotify:hydra/get.name :shuffle)
   :exit nil)

  ("+" smudge-controller-volume-up
   (int<spy>:spotify:hydra/get.name :volume/up)
   :exit nil)

  ("-" smudge-controller-volume-down
   (int<spy>:spotify:hydra/get.name :volume/down)
   :exit nil)

  ("x" smudge-controller-volume-mute-unmute
   (int<spy>:spotify:hydra/get.name :volume/mute)
   :exit nil)

  ("d" smudge-select-device
   (int<spy>:spotify:hydra/get.name :device)
   :exit nil)

  ("q" quit-window
   (int<spy>:spotify:hydra/get.name :quit)
   :color blue))
;; (hydra:spotify/body)


;;------------------------------------------------------------------------------------------------------------------------------------------
;; The Actual Keybind
;;------------------------------------------------------------------------------------------------------------------------------------------

(map! :leader       ; Be under the Doom SPC leader.

      ;;------------------------------
      ;; 'spy' Prefix:
      ;;------------------------------
      (:prefix ("-" . "spy")

       ;;------------------------------
       ;; Spotify:
       ;;------------------------------
       :desc "Spotify Remote"    "<apps>" #'hydra:spotify/body))


;; (bind-key "a" #'hydra-spotify/body some-map)
