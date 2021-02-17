;;; config/keybinds.el -*- lexical-binding: t; -*-

;;------------------------------------------------------------------------------
;; Useful Keys I've Found So Far...
;;------------------------------------------------------------------------------

;; s - snipe - a two char search & goto.
;; o - insert line below point and go into insert mode there.
;; e - forward to word end
;; b - backward to word begin
;; u - undo
;; - - previous line that isn't blank
;; i - insert - switch to insert mode at/before point.
;; a - append - switch to insert mode just after point.
;; f - snipe - 1 character forward search
;; s - snipe - 2 character forward search
;; ; - repeat forwards
;; , - repeat backwards
;; ] SPC - insert newline below
;; [ SPC - insert newline above
;; Y - yank - yank to end of line


;;------------------------------------------------------------------------------
;; Keybinds
;;------------------------------------------------------------------------------

;; TODO: Add these?
;;   C-d for backwards delete char
;;   movement keys for in insert mode?
;;   search, reverse search
;;
;; TODO: REMOVE!!!
;;   Redo is mean. I'm too used to Emacs's ring and using C-r for reverse search.

;; explanation of map!
;; http://github.com/hlissner/doom-emacs/issues/814#issuecomment-414051945
(map!
 ;; :normal, :visual states of evil
 ;; (not :motion, :emacs, :insert, :operator-pending)
 :nv "h" nil  ; was: 'evil-backward-char
 :nv "j" nil  ; was: 'evil-forward-char
 :nv "k" nil  ; was: 'evil-next-line
 :nv "l" nil  ; was 'evil-previous-line

 ;; Rebind to Dvorak-friendly, WASD-style keys.
 ;; Blows up some evil/vim commands, I'm sure, but hjkl is awkward as fuck.
 :nv "h" 'evil-backward-char
 :nv "n" 'evil-forward-char
 :nv "t" 'evil-next-line
 :nv "c" 'evil-previous-line)
