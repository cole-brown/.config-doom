;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;;------------------------------------------------------------------------------
;;                                    DOOM
;;------------------------------------------------------------------------------
;;
;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!
;;   - You do, however, need to restart or do that command I forget to get
;;     the changes.


;;---------------------------------
;; DOOM INFO

;; Here are some additional functions/macros that could help you configure Doom:
;;
;; - `load!' for loading external *.el files relative to this one
;; - `use-package!' for configuring packages
;; - `after!' for running code after a package has loaded
;; - `add-load-path!' for adding directories to the `load-path', relative to
;;   this file. Emacs searches the `load-path' when you load packages with
;;   `require' or `use-package'.
;; - `map!' for binding new keys
;;
;; To get information about any of these functions/macros, move the cursor over
;; the highlighted symbol at press 'K' (non-evil users must press 'C-c c k').
;; This will open documentation for it, including demos of how they are used.
;;
;; You can also try 'gd' (or 'C-c c d') to jump to their definition and see how
;; they are implemented.

;; DOOM INFO
;;---------------------------------


;;------------------------------------------------------------------------------
;; Includes
;;------------------------------------------------------------------------------

;;------------------------------
;; Set-Up imp Roots
;;------------------------------

(imp:path:root :modules (imp:path:paths->path doom-private-dir "modules"))
(imp:path:root :config (imp:path:paths->path doom-private-dir "config"))

;;------------------------------
;; Include Some of my 'Packages'
;;------------------------------

;; These /should/ all be loaded already via Doom's module init.
(spy:require :spy 'jerky)   ;; modules/spy/jerky/+jerky
(imp:require :modules 'spy 'file 'path)
(imp:require :config 'spy 'system 'config)
(imp:provide :modules 'spy 'system 'package)


;;------------------------------------------------------------------------------
;; NOTE: Function Naming
;;------------------------------------------------------------------------------

;; NOTE: My functions are named thusly:
;;   - "spy:<category>/<func>": A *public* function in "category" namespace.
;;   - "sss:<category>/<func>": A *private* function in "category" namespace.
;;     + I don't want 'em all polluting the auto-complete, help, etc for "spy:".
;;   - "spy:cmd:<category>/<func>": aka "spy cmd"
;;     + A *public* and also /interactive/ function.


;; TODO: a readme...
;;   - func naming scheme


;;------------------------------------------------------------------------------
;; Config Set-Up.
;;------------------------------------------------------------------------------

;; Our config files for different bits of emacs/doom/packages are in the
;; config sub-dir.
(defun spy:doom/find-user-root ()
  "Finds the user's base doom dir by walking down from this file's path."
  (let* ((file-path-this (if load-in-progress
                             (file-name-directory load-file-name)
                           (buffer-file-name)))
         (directory-path (directory-file-name
                          (file-name-directory file-path-this)))
         (directory-path-prev "")
         directory-doom)
    (while (and directory-path
                (not (string= directory-path directory-path-prev)))
      (let ((dirname (file-name-nondirectory directory-path)))
        (if (or (string= dirname ".doom.d") ;; for: ~/
                (string= dirname "doom"))   ;; for: ~/.config
            (setq directory-doom directory-path
                  directory-path nil)
          (setq directory-path-prev directory-path
                directory-path (directory-file-name
                                (file-name-directory directory-path))))))
    directory-doom))
;; (spy:doom/find-user-root)

(spy:config.root/set (spy:path/join (spy:doom/find-user-root) "config"))


;;------------------------------------------------------------------------------
;; Emacs Set-Up.
;;------------------------------------------------------------------------------

(spy:config 'emacs)
(spy:config 'daemons)
(spy:config 'completion)


;;------------------------------------------------------------------------------
;; Look & Feel
;;------------------------------------------------------------------------------

(spy:config 'theme 'config)
(spy:config 'ui)
(spy:config 'whitespace)


;;------------------------------------------------------------------------------
;; Cole Brown, Multi-pass.
;;------------------------------------------------------------------------------

(spy:config 'identity)

;; TODO: need to change whatever snippet doom uses for new .el files. My github
;; username is not my computer username.


;;------------------------------------------------------------------------------
;; Keybinds
;;------------------------------------------------------------------------------

;; (spy:package 'hercules)

;; Changes to Emacs/Evil keybinds.
(spy:config 'keybinds)

;; Changes to Evil, Evil Settings, etc.
(spy:config 'evil)

;; My additions to a new entry in the SPC leader.
(spy:config 'spy 'keybinds)

;; Get rid of some Doom functionality...
(spy:config 'parenthesis)


;;------------------------------------------------------------------------------
;; Notes, Org-Mode and Legions, etc.
;;------------------------------------------------------------------------------

(spy:config 'taskspace)
(spy:config 'org-mode)


;;------------------------------------------------------------------------------
;; yasnippet
;;------------------------------------------------------------------------------

(spy:config 'yasnippet)


;;------------------------------------------------------------------------------
;; Programming & Stuff
;;------------------------------------------------------------------------------

(spy:config 'code)
