;;; config/spy:taskspace.el -*- lexical-binding: t; -*-


;;------------------------------------------------------------------------------
;; Jerky Directory Local Variables
;;------------------------------------------------------------------------------

(require 'taskspace)
(imp:require :modules 'spy 'file 'path)


;;------------------------------------------------------------------------------
;; Taskspace Helper Functions
;;------------------------------------------------------------------------------

(defun sss:taskspace/generate (group taskname taskpath)
  "NOTE: Could be redefined later for more group-specific
details, so check e.g. secrets init for a redef. Or 'C-h f
sss:taskspace/generate' and see what file it's defined in."
  ;; Format:
  ;; header snippet key
  ;;
  ;; taskname
  ;; taskpath
  ;;
  ;; 'mkdir cmd'
  ;;
  ;; fancy box to separate this stuff from start of normal notes
  (format (concat "%s\n" ;; header
                  "\n"
                  "#+TASKSPACE: %s\n" ;; taskpath
                  "             %s\n" ;; translated path
                  "%s\n" ;; taskname
                  "\n"
                  "%s\n" ;; mkdir
                  "\n"
                  "%s\n" ;; fancy box top
                  "%s\n" ;; fancy box middle
                  "%s\n" ;; fancy box bottom
                  "\n\n")
          "header" ;; yasnippet
          taskpath
          (spy:path/translate :windows :wsl taskpath)
          taskname
          (format "mkdir ~/00-cole-temp/%s" taskname)
          "     ┌┬┬┬──────────────────────────────────────────────────────────────┬┬┬┐"
          "     ├┼┼┤                             ...                              ├┼┼┤"
          "     └┴┴┴──────────────────────────────────────────────────────────────┴┴┴┘"
          ))
;; (spydez/taskspace/generate "" "")


;;------------------------------------------------------------------------------
;; Taskspace Config
;;------------------------------------------------------------------------------

(after! taskspace
  ;;------------------------------
  ;; Configuration
  ;;------------------------------

  ;;---
  ;; General (Non-Per-Domain) Config...
  ;;---

  (taskspace/keybind/doom)

  ;;---
  ;; "Home" Domain
  ;;---
  (let* ((group :home) ; taskspace "group" == jerky "namespace"
         (group-str (spy:string/symbol->str group)))

    ;; Add taskspace paths to jerky for info.
    (jerky/set 'path 'taskspace 'notes
               :namespace group
               :value (spy:path/to-dir
                       (jerky/get 'path 'lily :namespace group)
                       "taskspace"
                       (spy:string/symbol->str group))
               :docstr (format "directory for %s taskspace notes" group-str))
    (jerky/set 'path 'taskspace 'root
               :namespace group
               :value (jerky/get 'path 'taskspace :namespace group)
               :docstr (format "directory for %s taskspace data/files" group-str))

    ;; Alias our function here in case we want to redefine it later.
    ;; We'll just have to redefine it instead of edit the taskspace settings again.
    (defalias 'sss:taskspace/generate.home 'sss:taskspace/generate)

    ;; And create our `:home' group custom settings.
    (defvar sss:taskspace/custom.home
      `((:type/notes      :noteless)
        (:format/datetime (spy:datetime/format.get 'iso-8601 'short))
        (:dir/tasks (jerky/get 'path 'taskspace 'root :namespace ,group))
        (:dir/notes (jerky/get 'path 'taskspace 'notes :namespace ,group))
        (:file/new/generate ((".projectile" "") ;; projectile: empty file
                             ;; notes.org: setup with org header snippet
                             ;; ready to go
                             ((-t//config :group :file/notes)
                              sss:taskspace/generate.home))))
      "Custom settings for my `:home' taskspace group.")

    ;; Set an over-arching taskspace DLV for whole work dir.
    (taskspace/group/dlv group
                         (jerky/get 'path 'taskspace 'root :namespace group))
    ;; Set a dir-local-var for home taskspace folders.
    (taskspace/group/dlv group
                         (jerky/get 'path 'taskspace 'notes :namespace group))
    (taskspace/group/dlv group
                         (jerky/get 'path 'org 'journal :namespace group))

    )
  ;; /"Home" Domain


  ;;---
  ;; "Work" Domain
  ;;---
  (let* ((group :work) ; taskspace "group" == jerky "namespace"
         (group-str (spy:string/symbol->str group)))

    ;; Add taskspace paths to jerky for info.
    (jerky/set 'path 'taskspace 'notes
               :namespace group
               :value (spy:path/to-dir
                       (jerky/get 'path 'lily :namespace group)
                       "taskspace"
                       (spy:string/symbol->str group))
               :docstr (format "directory for %s taskspace notes" group-str))
    (jerky/set 'path 'taskspace 'root
               :namespace group
               :value (jerky/get 'path 'taskspace :namespace group)
               :docstr (format "directory for %s taskspace data/files" group-str))

    ;; Alias our function here in case we want to redefine it later.
    ;; We'll just have to redefine it instead of edit the taskspace settings again.
    (defalias 'sss:taskspace/generate.work 'sss:taskspace/generate)

    ;; And create our `:work' group custom settings.
    (defvar sss:taskspace/custom.work
      `((:type/notes      :noteless)
        (:format/datetime (spy:datetime/format.get 'iso-8601 'short))
        (:dir/tasks (jerky/get 'path 'taskspace 'root :namespace ,group))
        (:dir/notes (jerky/get 'path 'taskspace 'notes :namespace ,group))
        (:file/new/generate ((".projectile" "") ;; projectile: empty file
                             ;; notes.org: setup with org header snippet
                             ;; ready to go
                             ((-t//config :group :file/notes)
                              sss:taskspace/generate.work))))
      "Custom settings for my `:work' taskspace group.")

  ;; Set a dir-local-var for home taskspace folders.
  (taskspace/group/dlv group
                       (jerky/get 'path 'taskspace 'root :namespace group))
  (taskspace/group/dlv group
                       (jerky/get 'path 'taskspace 'notes :namespace group))
  (taskspace/group/dlv group
                       (jerky/get 'path 'org 'journal :namespace group)))


  ;;------------------------------
  ;; Groups
  ;;------------------------------

  (customize-set-variable 'taskspace/groups
                          '((:work    "Work Taskspace" sss:taskspace/custom.work)
                            (:home    "Home Taskspace" sss:taskspace/custom.home)
                            (:default "Defaults"       taskspace/group/default))))
