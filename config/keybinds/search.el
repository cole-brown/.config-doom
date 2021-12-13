;;; config/keybinds/search.el -*- lexical-binding: t; -*-

;;------------------------------------------------------------------------------
;; Search
;;------------------------------------------------------------------------------

(defun spy:cmd:search/project/dir (directory &optional arg)
  "Conduct a text search in the supplied directory.
If prefix ARG is set, include ignored/hidden files."
  (interactive (list (read-directory-name "Start Search: ")
                     current-prefix-arg))
  (let* ((projectile-project-root nil)
         (disabled-command-function nil))
    (funcall-interactively #'+ivy/project-search arg nil directory)))


(defun spy:cmd:search/project/here (&optional arg)
  "Conduct a text search in the current buffer's `default-directory'.
If prefix ARG is set, include ignored/hidden files."
  (interactive "P")
  (funcall-interactively #'spy:cmd:search/project/dir
                         default-directory
                         arg))


;;------------------------------------------------------------------------------
;; Evil Spy Stuff.
;;------------------------------------------------------------------------------
;; See Doom's keybindings for how to do complicated things:
;; https://github.com/hlissner/doom-emacs/blob/develop/modules/config/default/+evil-bindings.el
(map! :leader       ; Be under the Doom SPC leader.

      ;;------------------------------
      ;; Start of 'spy' prefix "-"
      ;;------------------------------
      (:prefix ("-" . "spy") ; Not my first choice but no one uses dash, and it's easy on Dvorak.

       ;;------------------------------
       ;; Search
       ;;------------------------------
       (:prefix ("/" . "Search")
        :desc "Deadgrep"                  "/" #'deadgrep
        :desc "Search from here..."       "h" #'spy:cmd:search/project/here
        :desc "Search from directory..."  "s" #'spy:cmd:search/project/dir)))
