;;; config/spy/art.el -*- lexical-binding: t; -*-


(require 'hydra)


;;------------------------------------------------------------------------------
;; Helpers
;;------------------------------------------------------------------------------

(defun spy:evil:replace-state:toggle ()
  "Toggle overwrite mode.

Toggles between 'insert' and 'replace' evil states."
  (if (evil-replace-state-p)
      (evil-append 0)
    (evil-replace-state)))


;; TODO: Move to buffer.el...
(defun spy:buffer:insert-or-overwrite (character)
  "Insert or overwrite CHARACTER into active buffer at point.

Need to fix the hydra's deleting before figuring out the integration into
evil's replace state backspace 'undo' functionality."
  ;; If overwriting, first delete a character at point so we end up "replacing" it.
  (when (evil-replace-state-p)
    ;; TODO: Will this let evil's backspace/delete 'undo' functionality work?
    ;; (evil-replace-pre-command)

    ;; TODO: Will this work on its own to allow evil's 'undo' functionality?
    (evil-delete-char (point) (1+ (point))))
  (insert character))


;;------------------------------------------------------------------------------
;; Manual Unicode Box Drawing Chars That Don't Work Right Now
;;------------------------------------------------------------------------------
;; Don't work with current font(s)....
;;
;;------------------------------
;; Rounded Corners.
;;------------------------------
;; "╭" "arc down and right"
;; "╮" "arc down and left"
;; "╰" "arc up and right"
;; "╯" "arc up and left"
;;
;;------------------------------
;; Heavy Lines
;;------------------------------
;; "━" "heavy horizontal"
;; "┃" "heavy vertical"
;; "┅" "heavy triple dash horizontal"
;; "┇" "heavy triple dash vertical"
;; "┉" "heavy quadruple dash horizontal"
;; "┋" "heavy quadruple dash vertical"
;; "┏" "heavy down and right"
;; "┓" "heavy down and left"
;; "┗" "heavy up and right"
;; "┛" "heavy up and left"
;; "┣" "heavy vertical and right"
;; "┫" "heavy vertical and left"
;; "┳" "heavy down and horizontal"
;; "┻" "heavy up and horizontal"
;; "╋" "heavy vertical and horizontal"
;; "╍" "heavy double dash horizontal"
;; "╏" "heavy double dash vertical"
;; "╸" "heavy left"
;; "╹" "heavy up"
;; "╺" "heavy right"
;; "╻" "heavy down"
;;
;;------------------------------
;; Heavy/Light Transitions
;;------------------------------
;; "┍" "down light and right heavy"
;; "┎" "down heavy and right light"
;; "┑" "down light and left heavy"
;; "┒" "down heavy and left light"
;; "┕" "up light and right heavy"
;; "┖" "up heavy and right light"
;; "┙" "up light and left heavy"
;; "┚" "up heavy and left light"
;; "┝" "vertical light and right heavy"
;; "┞" "up heavy and right down light"
;; "┟" "down heavy and right up light"
;; "┠" "vertical heavy and right light"
;; "┡" "down light and right up heavy"
;; "┢" "up light and right down heavy"
;; "┥" "vertical light and left heavy"
;; "┦" "up heavy and left down light"
;; "┧" "down heavy and left up light"
;; "┨" "vertical heavy and left light"
;; "┩" "down light and left up heavy"
;; "┪" "up light and left down heavy"
;; "┭" "left heavy and right down light"
;; "┮" "right heavy and left down light"
;; "┯" "down light and horizontal heavy"
;; "┰" "down heavy and horizontal light"
;; "┱" "right light and left down heavy"
;; "┲" "left light and right down heavy"
;; "┵" "left heavy and right up light"
;; "┶" "right heavy and left up light"
;; "┷" "up light and horizontal heavy"
;; "┸" "up heavy and horizontal light"
;; "┹" "right light and left up heavy"
;; "┺" "left light and right up heavy"
;; "┽" "left heavy and right vertical light"
;; "┾" "right heavy and left vertical light"
;; "┿" "vertical light and horizontal heavy"
;; "╀" "up heavy and down horizontal light"
;; "╁" "down heavy and up horizontal light"
;; "╂" "vertical heavy and horizontal light"
;; "╃" "left up heavy and right down light"
;; "╄" "right up heavy and left down light"
;; "╅" "left down heavy and right up light"
;; "╆" "right down heavy and left up light"
;; "╇" "down light and up horizontal heavy"
;; "╈" "up light and down horizontal heavy"
;; "╉" "right light and left vertical heavy"
;; "╊" "left light and right vertical heavy"
;; "╼" "light left and heavy right"
;; "╽" "light up and heavy down"
;; "╾" "heavy left and light right"
;; "╿" "heavy up and light down"
;;
;; ;;------------------------------
;; ;; Block Characters
;; ;;------------------------------
;; "█" "full block"
;; ;; left to right "▏▎▍▌▋▊▉█"
;; "▏" "left one eighth block"
;; "▎" "left one quarter block"
;; "▍" "left three eighths block"
;; "▌" "left half block"
;; "▋" "left five eighths block"
;; "▊" "left three quarters block"
;; "▉" "left seven eighths block"
;; ;; bottom to top: "▁▂▃▄▅▆▇█"
;; "▁" "lower one eighth block"
;; "▂" "lower one quarter block"
;; "▃" "lower three eighths block"
;; "▄" "lower half block"
;; "▅" "lower five eighths block"
;; "▆" "lower three quarters block"
;; "▇" "lower seven eighths block"
;; ;; quadrants
;; "▖" "quadrant lower left"
;; "▗" "quadrant lower right"
;; "▘" "quadrant upper left"
;; "▙" "quadrant upper left and lower left and lower right"
;; "▚" "quadrant upper left and lower right"
;; "▛" "quadrant upper left and upper right and lower left"
;; "▜" "quadrant upper left and upper right and lower right"
;; "▝" "quadrant upper right"
;; "▞" "quadrant upper right and lower left"
;; ;; shading
;; "░" "light shade"
;; "▒" "medium shade"
;; "▓" "dark shade"
;; ;; misc.
;; "▐" "right half block"
;; "▔" "upper one eighth block"
;; "▕" "right one eighth block"


;;------------------------------------------------------------------------------
;; Single Lines Hydra
;;------------------------------------------------------------------------------

(defhydra hydra:art/box/single (:color amaranth ;; default to warn if non-hydra key
                                ;;:color pink   ;; defaults to not exit unless explicit
                                ;;:idle 0.75    ;; no help for x seconds
                                :hint none)     ;; no hint - just docstr)
  "
Draw box characters.
_'_: ?'?  _,_: ?,?  _._: ?.?   _p_: ?p?   ^ ^  ^ ^     ^ ^        _c_: up    ^ ^            _-_: undo     _d_: ?d?
_a_: ?a?  _o_: ?o?  _e_: ?e?   _u_: ?u?   ^ ^  ^ ^     _h_: left  _t_: down  _n_: right     ^ ^           _g_: ?g?
_;_: ?;?  _q_: ?q?  _j_: ?j?   ^ ^  ^ ^   ^ ^  ^ ^     ^ ^        ^ ^        ^ ^            ^ ^           _G_: ?G?
^ ^  ^ ^  ^ ^  ^ ^  ^ ^  ^ ^   ^ ^  ^ ^   ^ ^  ^ ^     ^ ^        ^ ^        ^ ^            ^ ^           _<SPC>_: ?<SPC>?
^ ^  ^ ^  ^ ^  ^ ^  ^ ^  ^ ^   ^ ^  ^ ^   ^ ^  ^ ^     ^ ^        _x_: ?x?   ^ ^            ^ ^   ^^^^^^^^_<insert>_: ?<insert>?
^ ^  ^ ^  ^ ^  ^ ^  ^ ^  ^ ^   ^ ^  ^ ^   ^ ^  ^ ^     ^ ^        _X_: ?X?
"
  ;; NOTE: You _MUST_ start off with a newline in docstr, otherwise you will get:
  ;;  > Debugger entered--Lisp error: (error "Not enough arguments for format string")
  ;;  > format("Draw box characters.\n%s: %s  %s: %s  %s: %s   %s: ...")
  ;;  > ...

  ;;------------------------------
  ;; Box Characters
  ;;------------------------------
  ("'" (spy:buffer:insert-or-overwrite "┌") "┌") ;; down and right
  ("," (spy:buffer:insert-or-overwrite "┬") "┬") ;; down and horizontal
  ("." (spy:buffer:insert-or-overwrite "┐") "┐") ;; down and left

  ("a" (spy:buffer:insert-or-overwrite "├") "├") ;; vertical and right
  ("o" (spy:buffer:insert-or-overwrite "┼") "┼") ;; vertical and horizontal
  ("e" (spy:buffer:insert-or-overwrite "┤") "┤") ;; vertical and left

  (";" (spy:buffer:insert-or-overwrite "└") "└") ;; up and right
  ("q" (spy:buffer:insert-or-overwrite "┴") "┴") ;; up and horizontal
  ("j" (spy:buffer:insert-or-overwrite "┘") "┘") ;; up and left

  ("p" (spy:buffer:insert-or-overwrite "─") "─") ;; horizontal
  ("u" (spy:buffer:insert-or-overwrite "│") "│") ;; vertical

  ;;---
  ;; Not Working in Emacs w/ Current Fonts:
  ;;---
  ;; The keymap string if these worked:
  ;; _'_: ?'?  _,_: ?,?  _._: ?.?   _p_: ?p?   _y_: ?y?     ^ ^        _c_: up    ^ ^            _-_: undo     _d_: ?d?
  ;; _a_: ?a?  _o_: ?o?  _e_: ?e?   _u_: ?u?   _i_: ?i?     _h_: left  _t_: down  _n_: right     ^ ^           _g_: ?g?
  ;; _;_: ?;?  _q_: ?q?  _j_: ?j?   ^ ^  ^ ^   ^ ^  ^ ^     ^ ^        ^ ^        ^ ^            ^ ^           _G_: ?G?
  ;; ^ ^  ^ ^  ^ ^  ^ ^  ^ ^  ^ ^   ^ ^  ^ ^   ^ ^  ^ ^     ^ ^        ^ ^        ^ ^            SPC: ?<SPC>?
  ;; ^ ^  ^ ^  _<_: ?<?  ^ ^  ^ ^   _P_: ?P?   _Y_: ?Y?     ^ ^        ^ ^        ^ ^            _x_: ?x?
  ;; _A_: ?A?  ^ ^  ^ ^  _E_: ?E?   _U_: ?U?   _I_: ?I?     ^ ^        ^ ^        ^ ^            _X_: ?X?
  ;; ^ ^  ^ ^  _Q_: ?Q?  ^ ^  ^ ^   ^ ^  ^ ^   ^ ^  ^ ^     ^ ^        ^ ^        ^ ^            ^ ^           ^ ^  (hi)
  ;;
  ;; ("y" (spy:buffer:insert-or-overwrite "┄") "┄") ;; triple dash horizontal
  ;; ("i" (spy:buffer:insert-or-overwrite "┆") "┆") ;; triple dash vertical
  ;;
  ;; ;; These are named backwards by Unicode - don't blame me.
  ;; ("<" (spy:buffer:insert-or-overwrite "╷") "╷") ;; down
  ;; ("A" (spy:buffer:insert-or-overwrite "╶") "╶") ;; right
  ;; ("Q" (spy:buffer:insert-or-overwrite "╵") "╵") ;; up
  ;; ("E" (spy:buffer:insert-or-overwrite "╴") "╴") ;; left
  ;;
  ;; ("P" (spy:buffer:insert-or-overwrite "╌") "╌") ;; double dash horizontal
  ;; ("U" (spy:buffer:insert-or-overwrite "╎") "╎") ;; double dash vertical
  ;;
  ;; ("Y" (spy:buffer:insert-or-overwrite "┈") "┈") ;; quadruple dash horizontal
  ;; ("I" (spy:buffer:insert-or-overwrite "┊") "┊") ;; quadruple dash vertical


  ;;------------------------------
  ;; Movement Keys
  ;;------------------------------
  ("c" #'evil-previous-line "up")
  ("h" #'evil-backward-char "left")
  ("t" #'evil-next-line "down")
  ("n" #'evil-forward-char "right")

  ;;------------------------------
  ;; Misc.
  ;;------------------------------
  ("<SPC>" (spy:buffer:insert-or-overwrite " ") "insert space")
  ("<insert>"
   (funcall #'spy:evil:replace-state:toggle)
   (if (evil-replace-state-p)
       "insert state"
     "replace state"))
  ("x" #'evil-delete-char "delete char")
  ("X" #'evil-delete-char "delete backwards char")
  ("-" #'undo "undo")
  ("_" #'undo "undo")
  ("C-_" #'undo "undo")

  ;;------------------------------
  ;; Get Me Out Of Here!!!
  ;;------------------------------
  ("d"   (spy:hydra/nest 'hydra:art/box/double) "double lines (╬)" :exit t)
  ("G"   nil                 "quit (to insert state)" :color blue)
  ("g"   (evil-normal-state) "quit (to normal state)" :color blue)
  ("C-g" (evil-normal-state) "quit (to normal state)" :color blue))


;;------------------------------------------------------------------------------
;; Double Lines Hydra
;;------------------------------------------------------------------------------

(defhydra hydra:art/box/double (:color amaranth ;; default to warn if non-hydra key
                                ;;:color pink   ;; defaults to not exit unless explicit
                                ;;:idle 0.75    ;; no help for x seconds
                                :hint none)     ;; no hint - just docstr)
  "
Draw box characters.
_'_: ?'?  _,_: ?,?  _._: ?.?   _p_: ?p?   ^ ^  ^ ^     ^ ^        _c_: up    ^ ^            _-_: undo     _d_: ?d?
_a_: ?a?  _o_: ?o?  _e_: ?e?   _u_: ?u?   ^ ^  ^ ^     _h_: left  _t_: down  _n_: right     ^ ^           _g_: ?g?
_;_: ?;?  _q_: ?q?  _j_: ?j?   ^ ^  ^ ^   ^ ^  ^ ^     ^ ^        ^ ^        ^ ^            ^ ^           _G_: ?G?
^ ^  ^ ^  ^ ^  ^ ^  ^ ^  ^ ^   ^ ^  ^ ^   ^ ^  ^ ^     ^ ^        ^ ^        ^ ^            ^ ^           _<SPC>_: ?<SPC>?
^ ^  ^ ^  ^ ^  ^ ^  ^ ^  ^ ^   ^ ^  ^ ^   ^ ^  ^ ^     ^ ^        _x_: ?x?   ^ ^            ^ ^   ^^^^^^^^_<insert>_: ?<insert>?
^ ^  ^ ^  ^ ^  ^ ^  ^ ^  ^ ^   ^ ^  ^ ^   ^ ^  ^ ^     ^ ^        _X_: ?X?
"
  ;; If ever the single line hydra gets its dotted lines and/or line-termination chars working, add this to the keymap string:
  ;; ^ ^  ^ ^  ^ ^  ^ ^  ^ ^  ^ ^   ^ ^  ^ ^   ^ ^  ^ ^     ^ ^        ^ ^        ^ ^            ^ ^           ^ ^  (hi)

  ;; NOTE: You _MUST_ start off with a newline in docstr, otherwise you will get:
  ;;  > Debugger entered--Lisp error: (error "Not enough arguments for format string")
  ;;  > format("Draw box characters.\n%s: %s  %s: %s  %s: %s   %s: ...")
  ;;  > ...

  ;;------------------------------
  ;; Box Characters:
  ;; Double Lines! Double Lines!
  ;;------------------------------
  ("'" (spy:buffer:insert-or-overwrite "╔") "╔") ;; double down and right
  ("," (spy:buffer:insert-or-overwrite "╦") "╦") ;; double down and horizontal
  ("." (spy:buffer:insert-or-overwrite "╗") "╗") ;; double down and left

  ("a" (spy:buffer:insert-or-overwrite "╠") "╠") ;; double vertical and righ
  ("o" (spy:buffer:insert-or-overwrite "╬") "╬") ;; double vertical and horizontal
  ("e" (spy:buffer:insert-or-overwrite "╣") "╣") ;; double vertical and left

  (";" (spy:buffer:insert-or-overwrite "╚") "╚") ;; double up and right
  ("q" (spy:buffer:insert-or-overwrite "╩") "╩") ;; double up and horizontal
  ("j" (spy:buffer:insert-or-overwrite "╝") "╝") ;; double up and left

  ("p" (spy:buffer:insert-or-overwrite "═") "═") ;; double horizontal
  ("u" (spy:buffer:insert-or-overwrite "║") "║") ;; double vertical

  ;;------------------------------
  ;; Movement Keys
  ;;------------------------------
  ("c" #'evil-previous-line "up")
  ("h" #'evil-backward-char "left")
  ("t" #'evil-next-line "down")
  ("n" #'evil-forward-char "right")

  ;;------------------------------
  ;; Misc.
  ;;------------------------------
  ("<SPC>" (spy:buffer:insert-or-overwrite " ") "insert space")
  ("<insert>"
   (funcall #'spy:evil:replace-state:toggle)
   (if (evil-replace-state-p)
       "insert state"
     "replace state"))
  ("x" #'evil-delete-char "delete char")
  ("X" #'evil-delete-char "delete backwards char")
  ("-" #'undo "undo")
  ("_" #'undo "undo")
  ("C-_" #'undo "undo")

  ;;------------------------------
  ;; Get Me Out Of Here!!!
  ;;------------------------------
  ("d"   (spy:hydra/nest 'hydra:art/box/single) "single lines (┼)" :exit t)
  ("G"   nil                 "quit (to insert state)" :color blue)
  ("g"   (evil-normal-state) "quit (to normal state)" :color blue)
  ("C-g" (evil-normal-state) "quit (to normal state)" :color blue))


;;------------------------------------------------------------------------------
;; Double/Single Line Transitions Hydra
;;------------------------------------------------------------------------------

;; TODO: This hydra.

;; ;;------------------------------
;; ;; Double/Single Transitions.
;; ;;------------------------------
;; "╒" ;; down single and right double
;; "╤" ;; down single and horizontal double
;; "╕" ;; down single and left double

;; "╞" ;; vertical single and right double
;; "╪" ;; vertical single and horizontal double
;; "╡" ;; vertical single and left double

;; "╘" ;; up single and right double
;; "╧" ;; up single and horizontal double
;; "╛" ;; up single and left double

;; "╓" ;; down double and right single
;; "╥" ;; down double and horizontal single
;; "╖" ;; down double and left single

;; "╟" ;; vertical double and right single
;; "╫" ;; vertical double and horizontal single
;; "╢" ;; vertical double and left single

;; "╙" ;; up double and right single
;; "╨" ;; up double and horizontal single
;; "╜" ;; up double and left single


(defun spy:art.box/draw ()
  "`spy' namespaced function to get into the box drawing hydra.
"
  (interactive)
  (evil-insert 0)
  (call-interactively #'hydra:art/box/single/body))
;; ┌────┐
;; ├────┤
;; │ hi │
;; └────┘


;;------------------------------------------------------------------------------
;; The End
;;------------------------------------------------------------------------------
(imp:provide :dot-emacs 'config 'spy 'art)
