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
;; - `imp:load' for loading external *.el files relative to this one
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

;;------------------------------
;; Step Zero:
;;------------------------------
;; Enable imp timing.
(customize-set-variable 'imp:timing:enabled? t)

;; Set the root path to our init files for Emacs.
(imp:path:root :dot-emacs
               ;;------------------------------
               ;; Figure out what kind of Emacs this is.
               ;;------------------------------
               ;; ".emacs.d", or ".doom.d", or ".config/emacs", or etc...
               (cond
                ;;---
                ;; Doom Emacs?
                ;;---
                ((boundp 'doom-private-dir)
                 doom-private-dir)

                ;;---
                ;; <Other Emacs Here>
                ;;---

                ;;---
                ;; Plain old vanilla Emacs
                ;;---
                (t
                 user-emacs-directory))
               ;;------------------------------
               ;; Init Files: init & locate features.
               ;;------------------------------
               ;; By default, these are:
               ;;   - `imp:path:filename:init'     -> "imp-init.el"
               ;;   - `imp:path:filename:features' -> "imp-features.el"
               ;; Could set here if I wanted different names/paths.
               )

;;------------------------------
;; Step 01: Load the Pre-Config Init.
;;------------------------------

;; Everything required before the config step is run.
(imp:load :feature  '(:dot-emacs init)
          :filename "init/init")


;;------------------------------
;; Step 02: Prep for Config.
;;------------------------------

(defconst dot-emacs:path:config "config"
  "Relative path from `:dot-emacs' root directory to the config directory.")


;;------------------------------------------------------------------------------
;; NOTE: Function Naming
;;------------------------------------------------------------------------------

;; TODO: Rename (again (again (...)))?
;;   - spy:<category>:<func>
;;   - int<spy>:<category>:<func>
;;   - spy:cmd:<category>:<func>
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
;; Emacs Set-Up.
;;------------------------------------------------------------------------------

(imp:load :feature  '(:dot-emacs config emacs)
          :path     dot-emacs:path:config
          :filename "emacs")

;; Speed up Emacs for files with long-ass lines.
(imp:load :feature  '(:dot-emacs config long-lines)
          :path     dot-emacs:path:config
          :filename "long-lines")

(imp:load :feature  '(:dot-emacs config daemons)
          :path     dot-emacs:path:config
          :filename "daemons")

(imp:load :feature  '(:dot-emacs config completion)
          :path     dot-emacs:path:config
          :filename "completion")

;; Get rid of some Doom annoying functionality with respect to parens...
(imp:load :feature  '(:dot-emacs config parenthesis)
          :path     dot-emacs:path:config
          :filename "parenthesis")

(imp:load :feature  '(:dot-emacs config search)
          :path     dot-emacs:path:config
          :filename "search")


;;------------------------------------------------------------------------------
;; Look & Feel
;;------------------------------------------------------------------------------

(imp:load :feature  '(:dot-emacs config theme config)
          :path     (imp:path:join dot-emacs:path:config "theme")
          :filename "config")

(imp:load :feature  '(:dot-emacs config ui)
          :path     dot-emacs:path:config
          :filename "ui")

(imp:load :feature  '(:dot-emacs config whitespace)
          :path     dot-emacs:path:config
          :filename "whitespace")

(imp:load :feature  '(:dot-emacs config hydra)
          :path     dot-emacs:path:config
          :filename "hydra")


;;------------------------------------------------------------------------------
;; Cole Brown, Multi-pass.
;;------------------------------------------------------------------------------

(imp:load :feature  '(:dot-emacs config identity)
          :path     dot-emacs:path:config
          :filename "identity")


;; TODO: need to change whatever snippet doom uses for new .el files. My github
;; username is not my computer username.


;;------------------------------------------------------------------------------
;; Notes, Org-Mode and its Minions, etc.
;;------------------------------------------------------------------------------


(imp:load :feature  '(:dot-emacs config taskspace)
          :path     dot-emacs:path:config
          :filename "taskspace")

(imp:load :feature  '(:dot-emacs config org-mode)
          :path     dot-emacs:path:config
          :filename "org-mode")

(imp:load :feature  '(:dot-emacs config markdown)
          :path     dot-emacs:path:config
          :filename "markdown")


;;------------------------------------------------------------------------------
;; yasnippet
;;------------------------------------------------------------------------------

(imp:load :feature  '(:dot-emacs config yasnippet)
          :path     dot-emacs:path:config
          :filename "yasnippet")


;;------------------------------------------------------------------------------
;; Programming & Stuff
;;------------------------------------------------------------------------------

(imp:load :feature  '(:dot-emacs config code)
          :path     (imp:path:join dot-emacs:path:config "code")
          :filename "config")

(imp:load :feature  '(:dot-emacs config docker)
          :path     dot-emacs:path:config
          :filename "docker")

(imp:load :feature  '(:dot-emacs config treemacs)
          :path     dot-emacs:path:config
          :filename "treemacs")

;; vterm and friends
(imp:load :feature  '(:dot-emacs config terminal)
          :path     dot-emacs:path:config
          :filename "terminal")


;;------------------------------------------------------------------------------
;; Apps
;;------------------------------------------------------------------------------

;;------------------------------
;; Music: Spotify
;;------------------------------
(imp:load :feature  '(:dot-emacs config spotify)
          :path     dot-emacs:path:config
          :filename "spotify")


;;------------------------------
;; Comms: Slack
;;------------------------------
(imp:load :feature  '(:dot-emacs config slack)
          :path     dot-emacs:path:config
          :filename "slack")


;;------------------------------------------------------------------------------
;; Keybinds
;;------------------------------------------------------------------------------

;; Last so stuff doesn't get overwritten?
;; Not sure if that's actually a concern or not...

;;------------------------------
;; Input Method
;;------------------------------

;; Changes to Evil, Evil Settings, etc.
;;   - No changes to keybinds directly, but this is the most related section?
(imp:load :feature  '(:dot-emacs config evil)
          :path     dot-emacs:path:config
          :filename "evil")


;;------------------------------
;; Keyboard Layout
;;------------------------------

;; Fully controlled by '.doom.d/init.el'.
;;   - ':input/keyboard' module and its '+layout/spydez' flag.


;;------------------------------
;; Keybind Modifications
;;------------------------------

;; My additions to the overabundance of keybindings:
(imp:load :feature  '(:dot-emacs config keybinds spy-leader)
          :path     (imp:path:join dot-emacs:path:config "keybinds")
          :filename "spy-leader")

;; Specific things:
(imp:load :feature  '(:dot-emacs config keybinds autogit)
          :path     (imp:path:join dot-emacs:path:config "keybinds")
          :filename "autogit")

(imp:load :feature  '(:dot-emacs config keybinds org-mode)
          :path     (imp:path:join dot-emacs:path:config "keybinds")
          :filename "org-mode")

(imp:load :feature  '(:dot-emacs config keybinds search)
          :path     (imp:path:join dot-emacs:path:config "keybinds")
          :filename "search")

(imp:load :feature  '(:dot-emacs config keybinds spotify)
          :path     (imp:path:join dot-emacs:path:config "keybinds")
          :filename "spotify")

(imp:load :feature  '(:dot-emacs config keybinds slack)
          :path     (imp:path:join dot-emacs:path:config "keybinds")
          :filename "slack")

(imp:load :feature  '(:dot-emacs config keybinds treemacs)
          :path     (imp:path:join dot-emacs:path:config "keybinds")
          :filename "treemacs")

;; Whatever isn't big enough or important enough to warrent its own file.
(imp:load :feature  '(:dot-emacs config keybinds misc)
          :path     (imp:path:join dot-emacs:path:config "keybinds")
          :filename "misc")


;;------------------------------------------------------------------------------
;; Work / Workday Stuff
;;------------------------------------------------------------------------------
;; Have near the end as it could depend on any previous config being done...

(imp:load :feature  '(:dot-emacs config work)
          :path     (imp:path:join dot-emacs:path:config)
          :filename "work")


;;------------------------------------------------------------------------------
;; The End
;;------------------------------------------------------------------------------

;; Gives me double warning buffers in Doom, maybe?
;; ;; Show warnings if mis0 got any during init.
;; (mis0/init/complete 'show-warning)

;; Output final time for imp loads.
(imp:timing:final)

;; Done; provide this feature.
(imp:provide :dot-emacs 'config)
