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
;; Pre-Config Init, Includes
;;------------------------------------------------------------------------------

;; Everything required before the config step is run.
(load! "init/init")


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
;; Secrets
;;------------------------------------------------------------------------------

;; Currently, need to configure my secrets before anything else.
;; TODO: move some stuff to init, use secrets config for /after/ non-secret
;; config is done?
(spy:secret/config)


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

;; Get rid of some Doom annoying functionality with respect to parens...
(spy:config 'parenthesis)


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

;;------------------------------
;; Input Method
;;------------------------------

;; Changes to Evil, Evil Settings, etc.
;;   - No changes to keybinds directly, but this is the most related section?
(spy:config 'evil)


;;------------------------------
;; Keyboard Layout
;;------------------------------

;; Fully controlled by '.doom.d/init.el'.
;;   - ':input/keyboard' module and its '+layout/spydez' flag.


;;------------------------------
;; Keybind Modifications
;;------------------------------

;; Whatever isn't big enough or important enough to warrent its own file.
(spy:config 'keybinds 'misc)

;; Specific things:
(spy:config 'keybinds 'org-mode)

;; My additions to the overabundance of keybindings:
(spy:config 'keybinds 'spy-leader)


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
