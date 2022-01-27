;;; config/treemacs.el -*- lexical-binding: t; -*-


;;------------------------------------------------------------------------------
;; Treemacs - Emacs Tree File/Project Explorer
;;------------------------------------------------------------------------------

(imp:require :jerky)
(imp:require :path)
(imp:require :modules 'spy 'hook)
(imp:require :modules 'spy 'buffer 'search)
(imp:require :modules 'spy 'buffer 'name)
(imp:require :modules 'spy 'datetime 'format)


;;------------------------------------------------------------------------------
;; Treemacs
;;------------------------------------------------------------------------------

;; TODO: Keybinds:
;; Need a keybind for `treemacs'?
;; `treemacs-select-window' looks like a useful one to keybind


;; Example `use-package': https://github.com/Alexander-Miller/treemacs#installation
(use-package! treemacs
  ;; ;;----------------------------------------------------------------------------
  ;; :init
  ;; ;;----------------------------------------------------------------------------


  ;; ;;----------------------------------------------------------------------------
  ;; :hook
  ;; ;;----------------------------------------------------------------------------

  ;; ;; Connect my hooks up.
  ;; ((org-mode . sss:hook/org/jump-to-now-target))


  ;;----------------------------------------------------------------------------
  :config
  ;;----------------------------------------------------------------------------

  ;; See: https://github.com/Alexander-Miller/treemacs

  ;;----------------------------------------------------------------------------
  ;; customization
  ;;----------------------------------------------------------------------------

  ;;---
  ;; NOTE: Automatic/exclusive displaying of projects.
  ;;---
  ;; You can use `treemacs-display-current-project-exclusively' to switch to the current project (deleting any others that might be present).
  ;; You can enable `treemacs-project-follow-mode' to make treemacs automatically switch to the project for the current buffer.


  ;;---
  ;; NOTE: Editting your projects/workspaces:
  ;;---
  ;; There are two ways to edit your projects and workspaces: call up single add/remove/rename/switch commands under either the
  ;; 'C-c C-p' or 'C-c C-w' prefix, or call `treemacs-edit-workspaces' and edit your entire layout in the form of a single org-mode buffer.
  ;;
  ;; The used org-format is quite simple: level 1 headlines are names of workspaces, level 2 headlines are names of projects in a workspace,
  ;; and every project’s path is given as a description list, starting with a - (and an optional leading space). Empty lines and lines
  ;; starting with # are ignored, and everything else leads to an error.
  ;;
  ;; You needn’t worry about making mistakes either. If there’s something wrong when you call treemacs-finish-edit (C-c C-c) then treemacs
  ;; will point you at the incorrect line and tell you what’s missing:


  ;;---
  ;; NOTE: Mouse interface:
  ;;---
  ;; If you prefer to expand/collpase nodes with a single mouse click you can also use treemacs-single-click-expand-action:
  ;;   (with-eval-after-load 'treemacs
  ;;     (define-key treemacs-mode-map [mouse-1] #'treemacs-single-click-expand-action))


  ;;---
  ;; NOTE: Session Persistance:
  ;;---
  ;; treemacs’ sessions - your workspace and the projects it contains - are saved when Emacs shuts down and restored when treemacs is first
  ;; loaded. This persistence process is fully automatic and independant, and should therefore be fully compatible with desktop-save-mode.
  ;;
  ;; The persisted state is saved under "`user-emacs-directory'/.cache/treemacs-persist" by default. The exact file location is saved in the
  ;; variable `treemacs-persist-file'.
  ;;
  ;; If something goes wrong when loading the file the erroneous state will be saved in `treemacs-last-error-persist-file' for debugging.


  ;;---
  ;; Actually set stuff:
  ;;---

  (customize-set-variable 'treemacs-collapse-dirs (if treemacs-python-executable 3 0)
                          (concat "Collapse N 'empty' dirs (ones whose only children are other dirs) if we have python. "
                                  "The script for collapsing is in Python so it needs Python."))

  ;; Example from https://github.com/Alexander-Miller/treemacs#installation:
  ;; (setq treemacs-collapse-dirs                   (if treemacs-python-executable 3 0)
  ;;       treemacs-deferred-git-apply-delay        0.5
  ;;       treemacs-directory-name-transformer      #'identity
  ;;       treemacs-display-in-side-window          t
  ;;       treemacs-eldoc-display                   t
  ;;       treemacs-file-event-delay                5000
  ;;       treemacs-file-extension-regex            treemacs-last-period-regex-value
  ;;       treemacs-file-follow-delay               0.2
  ;;       treemacs-file-name-transformer           #'identity
  ;;       treemacs-follow-after-init               t
  ;;       treemacs-expand-after-init               t
  ;;       treemacs-git-command-pipe                ""
  ;;       treemacs-goto-tag-strategy               'refetch-index
  ;;       treemacs-indentation                     2
  ;;       treemacs-indentation-string              " "
  ;;       treemacs-is-never-other-window           nil
  ;;       treemacs-max-git-entries                 5000
  ;;       treemacs-missing-project-action          'ask
  ;;       treemacs-move-forward-on-expand          nil
  ;;       treemacs-no-png-images                   nil
  ;;       treemacs-no-delete-other-windows         t
  ;;       treemacs-project-follow-cleanup          nil
  ;;       treemacs-persist-file                    (expand-file-name ".cache/treemacs-persist" user-emacs-directory)
  ;;       treemacs-position                        'left
  ;;       treemacs-read-string-input               'from-child-frame
  ;;       treemacs-recenter-distance               0.1
  ;;       treemacs-recenter-after-file-follow      nil
  ;;       treemacs-recenter-after-tag-follow       nil
  ;;       treemacs-recenter-after-project-jump     'always
  ;;       treemacs-recenter-after-project-expand   'on-distance
  ;;       treemacs-litter-directories              '("/node_modules" "/.venv" "/.cask")
  ;;       treemacs-show-cursor                     nil
  ;;       treemacs-show-hidden-files               t
  ;;       treemacs-silent-filewatch                nil
  ;;       treemacs-silent-refresh                  nil
  ;;       treemacs-sorting                         'alphabetic-asc
  ;;       treemacs-select-when-already-in-treemacs 'move-back
  ;;       treemacs-space-between-root-nodes        t
  ;;       treemacs-tag-follow-cleanup              t
  ;;       treemacs-tag-follow-delay                1.5
  ;;       treemacs-user-mode-line-format           nil
  ;;       treemacs-user-header-line-format         nil
  ;;       treemacs-width                           35
  ;;       treemacs-width-is-initially-locked       t
  ;;       treemacs-workspace-switch-cleanup        nil)


  ;;----------------------------------------------------------------------------
  ;; configuration
  ;;----------------------------------------------------------------------------

  ;;---
  ;; Fallback Workspace
  ;;---
  ;; You can interactively set the fallback workspace by calling `treemacs-set-fallback-workspace'.
  ;; NOTE: Call interactive to set the fallback to the current workspace.
  ;;   - Treemacs will persist the fallback internally.
  ;;   - Looks like it's just the first workspace is the default?

  ;; TODO: Check jerky for a key, set if found?
  ;; (treemacs-set-fallback-workspace "workspace-path")


  ;;------------------------------
  ;; Modes
  ;;------------------------------

  ;;---
  ;; `treemacs-follow-mode'
  ;;---
  ;; `treemacs-follow-mode' is a global minor mode which allows the treemacs view to always move its focus to the currently selected file.
  ;; This mode runs on an idle timer - the exact duration of inactivity (in seconds) before a move is called is determined by
  ;; `treemacs-tag-follow-delay'.
  (treemacs-follow-mode t)


  ;;---
  ;; `treemacs-filewatch-mode'
  ;;---
  ;; `treemacs-filewatch-mode' is a global minor mode which enables treemacs to watch the files it is displaying for changes and automatically
  ;; refresh itself when it detects a change in the file system that it decides is relevant.
  ;;   - Doing git stuff doesn't trigger any file system events, so after a commit you'll still need to do a manual refresh.
  (treemacs-filewatch-mode t)


  ;;---
  ;; `treemacs-fringe-indicator-mode'
  ;;---
  ;; `treemacs-fringe-indicator-mode' is a global minor mode that displays a little icon in the fringe that moves with the cursor. It can
  ;; make the selected line more visible if `hl-line-mode' doesn’t stand out with your theme.
  ;;
  ;; The indicator can either be permanently visible, or be only shown when the treemacs window is selected by calling it either with the
  ;; `always' or `only-when-focused' argument.
  (treemacs-fringe-indicator-mode 'always)


  ;;---
  ;; `treemacs-git-mode'
  ;;---
  ;; `treemacs-git-mode' is a global minor mode which enables treemacs to check for files’ and directories’ git status information and
  ;; highlight them accordingly. The mode is available in 3 variants: simple, extended and deferred.
  ;;   - See this for the mode explanations : https://github.com/Alexander-Miller/treemacs#git-mode
  ;;
  ;; Can mess with this if performance is sub-optimal: `treemacs-max-git-entries' (default is 5000)

  ;; Set to `deferred' if treemacs found a Python it can use, else use `simple'.
  (pcase (cons (not (null (executable-find "git")))
               (not (null treemacs-python-executable)))
    (`(t . t)
     (treemacs-git-mode 'deferred))
    (`(t . _)
     (treemacs-git-mode 'simple)))

  ;; Don't hide gitignored files.
  ;; NOTE [2021-10-11]: This is an undefined symbol in older Doom version of treemacs.
  ;;   - TODO: eventually delete the `when' check.
  (when (and (boundp 'treemacs-hide-gitignored-files-mode)
             (functionp 'treemacs-hide-gitignored-files-mode))
    ;; Disable hiding ignored files.
    (treemacs-hide-gitignored-files-mode -1))


  ;;------------------------------
  ;; Themes:
  ;;------------------------------

  ;; Using a different treemacs theme works the same way as using a different Emacs theme: just call treemacs-load-theme, either
  ;; programmatically or interactively. In the former case you need to supply the name of the theme as a string, like this:
  ;; (treemacs-load-theme "Default")


  ;;------------------------------
  ;; 4k Monitors:
  ;;------------------------------

  ;; The default width and height of the icons is 22 pixels. If you are
  ;; using a Hi-DPI display, uncomment this to double the icon size.
  ;;(treemacs-resize-icons 44)
  )
