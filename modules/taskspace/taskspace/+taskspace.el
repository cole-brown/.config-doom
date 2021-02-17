;;; taskspace/+taskspace.el --- Extremely Simple Taskspace/Workspace management  -*- lexical-binding: t; -*-

;;; Commentary:

;; taskspace.el is an extremely KISS taskspace/workspace generator/manager.

;; FAQ:
;;   1) Can it do X?
;;      - No... I really meant simple.
;;   2) Can it do multiple taskspace roots?
;;      - Yes... I had to make it less simple.

;; It can make a folder based on a simple dating and numbering scheme, with a
;; simple description tacked on for human usability.

;; It can copy files into the new taskspace. It can generate files based on a
;; static string or a function supplied in taskspace vars.

;; It can copy the taskspace's full path or name to the kill ring/clipboard.

;; It can open the taskspace dir itself (or the taskspace parent dir)
;; in a buffer.

;; It can 'deal' with these kind of taskspaces:
;;   - Self-Contained
;;;    - Taskspace dir contains:
;;       - notes,
;;       - data,
;;       - etc.
;;    - No other directories or files.
;;   - Split (taskspace notes are separate; taskspace dir contains data, etc)
;;;    - Taskspace dir contains:
;;       - data,
;;       - etc.
;;    - Notes file exists separately.


;;---------------
;; Commands:
;;---------------
;;   The Main Command:
;;     `taskspace/create'
;;       - Create a new taskspace. Will prompt for the short description.
;;         - e.g. description of "2019-01-01_2_some-task-name" is
;;           "some-task-name".
;;
;;   DWIM Commands:
;;     - Accepts numeric prefix arg.
;;       - 0 or no prefix: Today's date
;;       - positive: Future date; N days from now.
;;       - negative: Past date; N days back.
;;     - DWIM means:
;;       - If none for date: Create.
;;       - If just one existing: Return it.
;;       - If multiple: Choose from prompt of options.
;;     `taskspace/dir/dwim'
;;       - Returns fully qualified path to taskspace.
;;         - e.g. "c:/home/user/taskspace/2019-01-01_2_some-task-name"
;;     `taskspace/name/dwim'
;;       - Returns taskspace (directory) name only.
;;         - e.g. "2019-01-01_2_some-task-name"
;;
;;   Other Commands:
;;     `taskspace/dired/task'
;;       - Opens the directory of a task in emacs
;;         (uses find-file, so defaults to dired-mode buffer).
;;     `taskspace/dired/root'
;;       - Opens the directory of all tasks in emacs (aka `(-t//config group :dir/tasks)')
;;         (uses find-file, so defaults to dired-mode buffer).
;;     `taskspace/shell'
;;       - Opens a shell.
;;       - Use `taskspace/dir/dwim' to determine which taskspace is
;;         intended from the context.


;;---------------
;; Settings:
;;---------------
;; See 'General Settings' header to find out what all can be customized per
;; group right now.


;;------------------------------
;; Use-Package Config, Simple:
;;------------------------------
;;
;;  (use-package taskspace
;;    :ensure nil)

;;------------------------------
;; Use-Package Config, Multi-Group:
;;------------------------------
;;
;; (use-package taskspace
;;   ;; My own personal package - do not package manager it.
;;   :ensure nil
;;
;;   ;;------------------------------
;;   :init
;;   ;;------------------------------
;;
;;   ;;---
;;   ;; General (Non-Per-Domain) Init...
;;   ;;---
;;   (defun my/taskspace/generate (taskname taskpath)
;;     "NOTE: Could be redefined later for more work-specific details, so check
;; e.g. 'finalize-domain-secret.el' for a redef. Or 'C-h f
;; my/taskspace/generate' and see what file it's defined
;; in.
;; "
;;     ;; Format:
;;     ;; spy-header snippet key
;;     ;;
;;     ;; taskname
;;     ;; taskpath
;;     ;;
;;     ;; 'mkdir cmd'
;;     ;;
;;     ;; fancy box to separate this stuff from start of normal notes
;;     (format (concat "%s\n" ;; header
;;                     "\n"
;;                     "#+TASKSPACE: %s\n" ;; taskpath
;;                     "%s\n" ;; taskname
;;                     "\n"
;;                     "%s\n" ;; mkdir cmd for remote servers
;;                     "\n"
;;                     "%s\n" ;; fancy box top
;;                     "%s\n" ;; fancy box middle
;;                     "%s\n" ;; fancy box bottom
;;                     "\n\n")
;;             "my-header-snippet"
;;             taskpath
;;             taskname
;;             (format "mkdir ~/temp/%s" taskname)
;;             "     ┌┬┬┬──────────────────────────────────────────────────────────────┬┬┬┐"
;;             "     ├┼┼┤                             ...                              ├┼┼┤"
;;             "     └┴┴┴──────────────────────────────────────────────────────────────┴┴┴┘"
;;             ))
;;
;;   ;;---
;;   ;; "Home" Domain
;;   ;;---
;;
;;   ;; I can redef later if I want different ones..
;;   (defalias 'my/taskspace/generate/home 'my/taskspace/generate)
;;
;;   (defvar my/taskspace/group/home
;;     '((:type/notes      :self-contained)
;;       (:format/datetime my/datetime/format/yyyy-mm-dd)
;;       (:dir/tasks my/taskspace/path/tasks/home)
;;       (:dir/notes my/taskspace/path/notes/home)
;;       (:file/new/generate ((".projectile" "") ;; projectile: empty file
;;                            ;; notes.org: setup with org header snippet
;;                            ;; ready to go
;;                            ((-t//config :home :file/notes)
;;                             my/taskspace/generate/home))))
;;     "Custom settings for my `:home' taskspace group.")
;;
;;   ;;---
;;   ;; "Work" Domain
;;   ;;---
;;
;;   ;; I can redef later if I want different ones..
;;   (defalias 'my/taskspace/generate/work 'my/taskspace/generate)
;;
;;   (defvar my/taskspace/group/work
;;     '((:type/notes      :noteless)
;;       (:format/datetime my/datetime/format/yyyy-mm-dd)
;;       (:dir/tasks my/taskspace/path/tasks/work)
;;       (:dir/notes my/taskspace/path/notes/work)
;;       (:file/new/generate ((".projectile" "") ;; projectile: empty file
;;                            ;; notes.org: setup with org header snippet
;;                            ;; ready to go
;;                            ((-t//config :home :file/notes)
;;                             my/taskspace/generate/home))))
;;     "Custom settings for my `:home' taskspace group.")
;;
;;   ;;------------------------------
;;   :custom
;;   ;;------------------------------
;;
;;   (taskspace/groups
;;    '((:work    "Work Taskspace" my/taskspace/group/work)
;;      (:home    "Home Taskspace" my/taskspace/group/home)
;;      (:default "Defaults"       taskspace/group/default))))


;;; Code:


;;---------------------------------taskspace------------------------------------
;;--                   Simple Taskspace / Task Management                     --
;;------------------------------------------------------------------------------

;; §-TODO-§ [2020-02-25]: cleanup pass?
;; §-TODO-§ [2020-02-25]: find/do the todos here?
;; §-TODO-§ [2020-08-19]: Use f.el everywhere?


(require 'cl-lib) ;; for `some'
(require 'seq) ;; for `seq-contains'
(require 'f) ;; for nicer file api
(require 'dash)


(defgroup taskspace nil
  "Tool for creating/using simple taskspaces/workspaces for short tasks,
bug investigation, log munging, or whatever."
  :group 'convenience)


;;------------------------------------------------------------------------------
;; Multiple Separate Taskspaces
;;------------------------------------------------------------------------------

(defcustom taskspace/groups
  '((:default "Taskspace" taskspace/group/default)
    )
  "Definitions for multiple task spaces. Each will have its own settings.
Each entry in the alist is a list of: (keyword/symbol string settings-variable)

'keyword/symbol' is used internally to identify the taskspace groups.

'string' is a name used for display purposes.

'settings-variable' should be the big settings alist (see
`taskspace/group/default' for the default's settings.
"
  :group 'taskspace
  :type '(alist :key-type symbol
                :value-type string))


;;------------------------------------------------------------------------------
;; Per-Taskspace Settings
;;------------------------------------------------------------------------------

;; Need to convert all my old defcustoms into a structure like this per
;; taskspace. Need to also allow for not having these (have a default they can
;; also change maybe?).
(defcustom taskspace/group/default
  '((:type/notes :self-contained
    (concat
     "What kind of taskspace to create by default.\n"
     "\n"
     "It can 'deal' with these kind of taskspaces:\n"
     "  - `:self-contained' - Self-Contained (taskspace contains everything)\n"
     "    - Taskspace dir contains:\n"
     "      - notes,\n"
     "      - data,\n"
     "      - etc.\n"
     "   - No other directories or files.\n"
     "  - `:noteless' - Split (taskspace notes are separate from rest)\n"
     "    - Taskspace dir contains:\n"
     "      - data,\n"
     "      - etc.\n"
     "   - Notes file exists separately.\n"))

   (:format/datetime "%Y-%m-%d"
    "Date format for parsing/naming taskspace directory names.")

   (:function/shell  #'shell
    (concat
     "Function to call to open shell buffer. `shell' and `eshell' work. "
     "Opens the current taskspace's top dir in an emacs shell buffer."))

   (:dir/tasks (file-name-as-directory
                (expand-file-name "taskspace" user-emacs-directory))
    (concat
     "User's root taskspace folder for small work tasks. "
     "All taskspaces for this group will be created here."))

   (:dir/notes (file-name-as-directory
                (expand-file-name "taskspace" user-emacs-directory))
    (concat
     "User's folder for all notes that are in `:noteless' taskspaces. "
     "Unused in `:self-contained' taskspaces."))

   (:file/new/copy (file-name-as-directory
                    (expand-file-name "taskspace-new"
                                      (-t//config :default :dir/tasks)))
    "User's folder for files to copy into new taskspaces.")

   (:file/new/generate (((-t//config :default :file/notes) "") ;; empty file
                        (".projectile" "")) ;; also empty
    (concat
     "Files to generate for new taskspaces. Expects an alist like:\n"
     "(('file1.name' 'contents') ('file2.name' #'your-gen-function))\n"
     "\n"
     "Note: `group', `taskname' and `taskpath' are supplied as the args to \n"
     "the generator functions. Taskpath is the fully expanded file path.\n"
     "Should return a string of the file's contents.\n"
     "e.g.: (defun my/taskspace/gen-org-notes (taskname taskpath)\n"
     "        (format ...))\n"))

   (:file/notes "_notes.org" "File for storing/recording notes about a task.")

   ;; TODO: REGEX
   ;; TODO: regex all these or somethinng?
   ;; TODO: REGEX
   (:dir/tasks/ignore
    ;; TODO: how do I even do string and/or regexes? Different alist entries
    ;; probably since regexes are just strings?
    ("." ".."
     "00_archive"
     (file-name-nondirectory (-t//config :default :file/new/copy)))
    (concat
     "Always ignore these when getting/determining a taskspace directory. "
     "Can be strings or functions."))

   (:naming/separator "_"
    "Split directory name on this to extract date, number, and description.")

   ;; TODO: Turn these into regexes w/ capture groups, I think?..
   ;; Have make-name and split-name use the regexes to make/split.
   ;; http://ergoemacs.org/emacs/elisp_string_functions.html
   ;; TODO: use this nice regex builder (elisp sexprs)?:
   ;;   https://www.reddit.com/r/emacs/comments/cf8r83/easier_editing_of_elisp_regexps/eu84ob1/
   (:naming/parts-alists
    (
      ;; Three part. Code does this all the time?
      ((date . 0)
       (number . 1)
       (description . 2))
      ;; Two part. Human does this most of the time...
      ((date . 0)
       (description . 2))
      )
    (concat
     "Order of items in task's descriptive directory name. List of alists. "
     "First one of the correct length is used currently."))

   ;; §-TODO-§ [2020-08-18]: Turn this into an `(rx ...)'.
   (:naming/description/rx/valid "^[[:alnum:]_\\-]\\{3,\\}$"
    "Letters, numbers, underscore, and hypen are valid.")

   (:dir/tasks/org/keyword "TASKSPACE"
    (concat
     "Name of the Property/Keyword that might hold a pointer to the "
     "taskspace directory in a taskspace's org notes file.\n"
     "\n"
     "e.g.: if this line is in the '_notes.org':"
     "#+TASKSPACE: ~/path/to/taskspace/2020-03-17_0_example"
     "...then `-t//org/keyword/get' can be used to get it for"
     "`taskspace/dir/dwim'.")))

  "Gigantoid alist of custom settings name/value/docstr for supporting
multiple taskspaces.
"
  :group 'taskspace
  ;; :type no idea so I'm leaving it out... sexp?
  )


;;------------------------------------------------------------------------------
;; Variables
;;------------------------------------------------------------------------------

(defvar taskspace/dlv.var/group nil
  "This should always be nil unless used via directory-local-variables.

It should only be set via `taskspace/dlv/group'")


;;------------------------------------------------------------------------------
;; Helper for seeing if jerky is available
;;------------------------------------------------------------------------------

(defun -t//jerky-p ()
  "Returns t if `jerky' and `jerky/dlv' are present as provided features."
  (and (featurep 'jerky)
       (featurep 'jerky/dlv)))


;;------------------------------------------------------------------------------
;; Per-Group Config/Settings Helpers
;;------------------------------------------------------------------------------

(defun -t//config (group key &optional field)
  "Get the FIELD of KEY from GROUP's settings alist in `taskspace/groups'.
If GROUP doesn't exist in `taskspace/groups', this will look for `:default'.
Errors if nothing is found in GROUP or :default settings.

If FIELD is nil or `:setting', gets the setting's value.

If FIELD is `:docstr', gets the setting's docstr.

If FIELD is `:key', gets the setting's key, which is KEY. Almost
useless, but does validate entry's exists.
"
  (let ((entry nil)
        (settings (-t//config/group->settings group)))
    ;; First, try to get from group's settings (if we found group's settings).
    (when settings
      (setq entry (-t//config/get key settings)))

    ;; Second, if needed, try to get from default/fallback settings.
    (when (null entry)
      ;; Didn't find the requested group... use defaults.
      (setq entry
            (-t//config/get
             key
             (-t//config/group->settings :default))))

    ;; Now we can finally either reduce down to the value or error out.
    (if (null entry)
        ;; Not found anywhere; error out.
        (error
         "Taskspace: Could not find setting '%S' in group '%S' or default."
         key group)

      ;; Got group; return value of requested field.
      ;; Entry should be: (symbol value docstr)
      ;; Now figure out which is requested, what it actually is, and return it.
      (cond ((eq field :key)
             (-t//config/entry->key entry))

            ((eq field :docstr)
             (-t//config/entry->docstr entry))

            (t
             (-t//config/entry->setting entry))))))
;; (-t//config :home :format/datetime)
;; (-t//config :home :format/datetime :setting)
;; (-t//config :home :format/datetime :docstr)
;; (-t//config :home :format/datetime :key)
;; (-t//config :home :type/notes)
;; (-t//config :home :dir/tasks)
;; (-t//config :home :dir/tasks/ignore)
;; (-t//config :home :naming/parts-alists)
;; (-t//config :home :file/new/copy)


(defun -t//config/entry->docstr (entry)
  "Helper for -t//config.

Given an ENTRY from a group's settings alist, returns its docstr or nil.
"
  (nth 2 entry))


(defun -t//config/entry->key (entry)
  "Helper for -t//config.

Given an ENTRY from a group's settings alist, returns its key/symbol or nil.
"
  (nth 0 entry))


(defun -t//config/entry->setting (entry)
  "Helper for -t//config.

Given an ENTRY from a group's settings alist, turn it into an actual setting.

ENTRY is the alist tuple of (taskspace's-symbol thing-to-figure-out docstr).

Thing-to-figure-out could be: a symbol that needs evaluated, a string, a
function that needs called, etc.
"
  (let ((setting (nth 1 entry)))
    (cond
     ;; Function: Check before listp. If `setting' is #'ignore then I guess it's
     ;; actually (function ignore), which is a list.
     ;; There's probably a better way to do this...
     ((and (listp setting)
           (eq (nth 0 setting) 'function)
           (functionp (nth 1 setting)))
      (funcall (nth 1 setting)))

     ;; Just a function: Call it.
     ((or (functionp setting)
          (and (listp setting)
               (eq (nth 0 setting) 'function)
               (functionp (nth 1 setting))))
      (funcall setting))

     ;; If setting is a list, figure out what to do with it before returning.
     ((listp setting)
      (cond ((functionp (nth 0 setting))
             ;; List starts with a function; eval list and return.
             (eval setting))

            ;; Any other things to do with a list?

            ;; Default to just returning the list.
            (t setting)))

     ;; Symbol: Return value of symbol; use lexical scope.
     ((symbolp setting)
      (condition-case-unless-debug err
          (eval setting t)
        ;; If it's void, just return symbol itself.
        (void-variable setting)
        ;; Let other errors through?
        ;; (error 'setting)
        ))

     ;; Else just return it.
     (t
      setting))))
;; (-t//config/entry->setting '(jeff (+ 4 1) "list function"))
;; (-t//config/entry->setting '(jeff (4 1)   "just a list"))
;; (-t//config/entry->setting '(jeff #'ignore "a function"))
;; (-t//config/entry->setting '(jeff jeff "symbol, no value"))
;; (let ((a 42)) (-t//config/entry->setting '(jeff a "symbol w/ value")))


(defun -t//config/group->settings (group)
  "Helper for -t//config.

Gets settings from `taskspace/groups' using GROUP as alist key.
Returns just the settings - doesn't return the assoc value.
Can return nil.
"
  ;; Group entry is: (keyword/symbol display-name settings)
  ;; Return only settings, or just nil if assoc/nth don't find anything.
  (let ((settings (nth 2 (assoc group taskspace/groups))))
    (cond ((listp settings)
           ;; (message "list. returning.")
           settings)

          ((symbolp settings)
           ;; (message "symbol. evaluating.")
           (eval settings))

          (t
           ;; (message "nil. returning.")
           nil))))
;; (-t//config/group->settings :default)


(defun -t//config/get (key settings)
  "Helper for -t//config.

Gets value for KEY from settings. Returns nil if not found.
Returns assoc value if found (key's full entry in SETTINGS alist).
"
  (assoc key settings))


;;------------------------------------------------------------------------------
;; Prompt Helpers
;;------------------------------------------------------------------------------

;;------------------------------
;; Prompt: Group
;;------------------------------

(defun -t//prompt/group/name (group-assoc)
  "Takes an entry from `taskspace/groups' and returns a cons of:
  - A string containing both the display name and the symbol name.
  - The symbol.
"
  (cons
   ;; Display string first, since that's what `completing-read' shows to user.
   (concat (format "%-10s" (nth 0 group-assoc))
           " - "
           (nth 1 group-assoc))
   ;; Group symbol second so we can get back to it from user's choice of display
   ;; strings.
   (nth 0 group-assoc)))
;; (-t//prompt/group/name '(:default "Jeff!" taskspace/group/default))


(defun -t//prompt/group/get (choices)
  "Interactive prompt for user to input/choose group name.
Provides both the symbol name and the display string for user to
complete against. Returns symbol name chosen.

CHOICES should be filtered down symbol names from `taskspace/groups'.
"
  (let ((display-choices (-map #'-t//prompt/group/name choices)))
    (alist-get
     (completing-read "Taskspace Group: "
                      ;; Build the names for the options list...
                      display-choices
                      nil
                      ;; Make them confirm if not on the list...
                      'confirm)
     display-choices
     nil nil
     #'string=)))
;; (-t//prompt/group/get '((:a "aaa" nil) (:b "b" nil)))


(defun -t//prompt/group (&optional auto quiet)
  "Filters groups down to options available to user. If only one, uses that. If
only `:default' available, uses that. If multiple user groups, prompts user
via `-t//prompt/group' for which to use.

AUTO can be a few things:
  - nil: No automatically trying to guess group unless there is only one non-default.
  - dlv: -t//group/auto
  - current: -t//group/current
  - auto: -t//group/get
    - Combines `dlv' and `current', preferring `dlv'.

Returns group symbol (aka 0th element of entry in `taskspace/groups').
"
  ;; `or' will give us either:
  ;;   1) the auto group,
  ;;   2) or the prompted group.
  (or
   ;; 1) Check for an auto-group func to try...
   (cond ((eq nil auto)
          nil)
         ((eq 'auto auto)
          (-t//group/auto quiet))
         ((eq 'dlv auto)
          (-t//group/dlv))
         ((eq 'current auto)
          (-t//group/current quiet))
         ((not (null auto))
          (if quiet
              nil
            (error "%s: Unknown AUTO option `%S'."
                   "taskspace: -t//prompt/group" auto))))
   ;; 2) No luck on the auto-group... Check the groups and prompt as needed.
   (let ((groups-sans-default
          ;; Filter down to just non-defaults...
          (-filter (lambda (group) (not (eq (nth 0 group) :default)))
                   taskspace/groups)))
     ;; Just one group? Return it.
     (cond ((= (length groups-sans-default) 1)
            ;; Get the only group there...
            (nth 0 groups-sans-default))

           ;; Multiple groups? That's what we're actually here for - prompt user!
           ((> (length groups-sans-default) 1)
            (-t//prompt/group/get groups-sans-default))

           ;; 0 or less groups.
           (t
            ;; Try to use the default, I guess...
            (assoc :default taskspace/groups))))))
;; (-t//prompt/group)


;;------------------------------
;; Prompt: Task Name (Description)
;;------------------------------

(defun -t//prompt/name (group)
  "Prompt in minibuffer for input, read and format to string, then return.
"
  ;; Replace all whitespace with hyphens.
  (s-replace-regexp (rx (* whitespace))
                    "-"
                    ;; `read-minibuffer' returns a "lisp object", so
                    ;; format to string just in case.
                    (format "%s"
                            (read-minibuffer
                             (format "New `%s` Task Desc.: "
                                     (-t//group/display-name group))))))


;;------------------------------
;; Prompt: Choose Existing Task
;;------------------------------

;; Thank you to this thread:
;; https://emacs.stackexchange.com/questions/32248/how-to-write-a-function-with-an-interactive-choice-of-the-value-of-the-argument
;; I was not finding any usable help/tutorials/documentation
;; for my knowledge/skill level until I found that.
(defun -t//prompt/task-existing (group taskspaces &optional display)
  "Given a list of taskspaces from e.g. `-t//dir/list/date',
prompt user with list of choices, take the user's input, and
match back up with an entry in the list of taskspaces.

DISPLAY can be:
- nil: Pass taskspaces as-is to completion. AKA display as-is.
- nondirectory: Strip each element to `file-name-nondirectory'

Choice is matched back to taskspaces via dumb string matching. First
match in TASKSPACES that substring matches user's choice from
`completing-read' is returned as choice.

Returns nil or a string in TASKSPACES.
"
  ;; Figure out how to display to user first.
  (let (display-names)
    (cond
     ;; nil -> as-is
     ((null display)
      (setq display-names taskspaces))

     ;; nondirectory -> strip each to remove all parent dirs
     ((equal display 'nondirectory)
      (setq display-names (mapcar #'file-name-nondirectory taskspaces)))

     ;; unexpected -> error?
     (t (error "Unknown display option `%s'" display)))

    ;; Give user their choices...
    ;;
    ;; With helm at the wheel, this goes to helm--completing-read-default.
    ;; `confirm' to force completion to one complete choice.
    (let ((choice (completing-read (format "Choose %s: "
                                           (-t//group/display-name group))
                                   display-names nil 'confirm)))

      ;; ...and match their choice back up with a taskname.
      (seq-contains taskspaces
                    choice
                    (lambda (input taskname)
                      "Check substring match of user's input against taskname."
                      (string-match-p (regexp-quote input) taskname)))
      )))
;; (-t//prompt/task-existing :home (-t//dir/list/all :home) 'nondirectory)


;;------------------------------------------------------------------------------
;; Taskspace Internals
;;------------------------------------------------------------------------------

;;------------------------------
;; Groups
;;------------------------------

(defun taskspace/group/dlv (group directory)
  "Create a directory-local-variable for GROUP and DIRECTORY.
This sets the automatic group for that dir (and sub-dirs) to GROUP."
  (if (-t//jerky-p)
      (jerky/dlv/set nil        ; let it auto-create
                     directory
                     nil        ; Set for global mode.
                     'taskspace/dlv.var/group
                     :namespace jerky/custom.namespace/default ; default namespace
                     :value group
                     :docstr "Taskspace's Auto-Group for this directory."
                     :dlv 'full)
    (error (concat "%s: Requires `jerky' and `jerky/dlv' features/packages;"
                   "didn't find them. %s %s")
           "taskspace/group/dlv"
           group directory)))


(defun -t//group/dlv ()
  "Tries to get the directory-local-variable `taskspace/dlv/group'.

`taskspace/dlv/group' is not expected to exist, generally.
This will return it's value or nil."
  ;; Cannot use `condition-case-unless-debug' here... it just doesn't catch
  ;; `void-variable' signal.
  (condition-case nil
      taskspace/dlv/group
    ;; `taskspace/dlv/group' does not exist; return nil.
    (void-variable nil)
    ;; Generic error signal...?
    ;; (error nil)
    ;; All signals?
    ;; (t nil)
    ))
;; (-t//group/dlv)


(defun -t//group/current (&optional quiet)
  "Try to figure out current group given currently visited buffer.

Set `quiet' to non-nil for nil return on error, else will signal an error.
`quiet' also suppresses the \"Current Taskspace Group: ...\" message.
"
  ;; dired doesn't have a buffer-file-name so use its default-directory.
  (let ((path (-t//path/current))
        (current-root nil)
        (current-group nil))

    ;; Search through our groups for something to match to that.
    ;; Start by getting our group symbols...
    (setq current-root
          (car
           (->> (-map #'car taskspace/groups)
                ;; and turning into task and notes dirs...
                (-map (lambda (g) (list
                                   (-t//config g :dir/tasks)
                                   (-t//config g :dir/notes))))
                ;; Have list of tuple lists now; want flat list.
                (-flatten)
                ;; Figure out which one is our current root.
                (-map (lambda (root)
                        ;; If a child or the same dir as root, keep root.
                        ;; Otherwise return nil for a "nope, not this one".
                        (if (or
                             (f-descendant-of? path root)
                             (string= (directory-file-name (f-canonical path))
                                      (directory-file-name (f-canonical root))))
                            root
                          nil)))
                ;; Reduce down to non-nil answer.
                ;; Assumes there is only one non-nil answer.
                (-remove #'null))))

    ;; How'd we do?
    (if (not (stringp current-root))
        ;; Complain if interactive; return nil if not.
        (if quiet
            nil
          (error (format (concat "Could not find a taskspace root for "
                                 "currently visited buffer dir: %s")
                         path)))

      ;; Normalize the path.
      (setq current-root (directory-file-name (f-canonical current-root)))

      ;; ;; Strip to just dir name.
      ;; (setq current-root (f-filename current-root))
      ;; (message "current-root: %S" current-root))))

      ;; Now, finally... We're not done.
      ;; Got to translate some taskspace or notes root dir into its group.
      (setq current-group
            (car ;; not sure what to do if there's more than one choice left...
             ;; reduce down to whatever is non-nil.
             (-remove
              #'null
              (-map (lambda (entry)
                      ;; If we match one of this group's roots, return the
                      ;; group symbol.
                      (if (or
                           (string= (directory-file-name
                                     (f-canonical
                                      (-t//config (nth 0 entry)
                                                         :dir/tasks)))
                                    current-root)
                           (string= (directory-file-name
                                     (f-canonical
                                      (-t//config (nth 0 entry)
                                                         :dir/notes)))
                                    current-root))
                          (nth 0 entry)
                        nil))
                    taskspace/groups))))
      ;; Inform it and return it.
      (unless quiet
          (message "Current Taskspace Group: %s" current-group))
      current-group)))
;; (-t//group/current)


(defun -t//group/auto (&optional quiet)
  "Tries to get either the auto-group or the current-group.

Prefers the auto-group."
  (or (-t//group/dlv)
      (-t//group/current quiet)))
;; (-t//group/auto)


;;------------------------------
;; Group Getters
;;------------------------------

(defun -t//group/symbol (group-entry)
  "Given GROUP-ENTRY list (assoc from `taskspace/groups'), returns group's symbol."
  (nth 0 group-entry))
;; (-t//group/symbol '(:default "Taskspace of Default" this-dne))


(defun -t//group/display-name (group-entry)
  "Given GROUP-ENTRY list (assoc from `taskspace/groups'), returns group's display name."
  (if (null (nth 1 group-entry))
      (symbol-name (-t//group/symbol group-entry))
    (nth 1 group-entry)))
;; (-t//group/display-name '(:default "Taskspace of Default" this-dne))
;; (-t//group/display-name '(:default nil this-dne))


(defun -t//group/settings (group-entry)
  "Given GROUP-ENTRY list (assoc from `taskspace/groups'), returns group's settings."
  (nth 2 group-entry))
;; (-t//group/settings '(:default "Taskspace of Default" this-dne))


;;------------------------------
;; Notes
;;------------------------------

(defun -t//notes/open (group taskpath &optional no-error no-message)
  "Opens the group/taskpath's notes file.

If NO-ERROR, returns nil instead of raising an error signal.

If NO-MESSAGE, skips output message."

  ;; Ok - find and open the notes file. Don't want to just assume they are
  ;; where the settings now indicate new ones will be created; people can
  ;; change their settings. Old ones could be :self-contained and new
  ;; :notesless, for example.

  ;; Assume local/:self-contained first.
  (setq notespath (-t//path/notes group taskpath :self-contained))

  ;; Does it exist?
  (unless (f-file? notespath)
    ;; Nope; try remote/:noteless.
    (setq notespath (-t//path/notes group taskpath :noteless)))

  ;; There is no third try.
  (if (not (f-file? notespath))
      (if no-error
          nil
        (error "No notes file found! Look for it: %s, %s"
               (-t//path/notes group taskpath :self-contained)
               (-t//path/notes group taskpath :noteless)))

    ;; Exists; message and visit it.
    (unless no-message
      (message "Opening taskspace notes: %s" notespath))
    (find-file notespath)))


;;------------------------------
;; Paths
;;------------------------------

(defun -t//path/current ()
  "Returns correct 'current filepath' for both dired mode and not.
"
  (if (equal major-mode 'dired-mode)
      default-directory
    (f-dirname (buffer-file-name))))


(defun -t//path/child-of? (child parent)
  "Returns true if CHILD is actually a direct child directory of PARENT.
CHILD and PARENT are only compared as strings/theoretical paths.
CHILD and PARENT are assumed to be both canonical and directory path names.

f.el's `f-child-of?' and `f-parent-of' require the files to exist for a yes
answer, which makes testing things a tiny bit annoying, so... f-those-function.
I'm making my own `f-child-of?'...
With it's own stupid assumptions.
And Futurama quotes!
In fact, forget the quotes!
"
  (string= parent (f-parent child)))


(defun -t//path/notes (group taskpath &optional type/notes)
  "Given GROUP and TASKPATH, generate the notes file path.

If TYPE/NOTES is `:self-contained' or `:noteless', this ignores the config
settings for the group and returns based on TYPE/NOTES.

Otherwise, it checks GROUP's config settings for :type/notes and
builds the notes file path based on that.
"
  ;; Get filename from config.
  (let ((filename (-t//config group :file/notes))
        ;; Use type/notes if a valid value, else get from config.
        (type/notes (if (or (eq type/notes :self-contained)
                            (eq type/notes :noteless))
                        type/notes
                      (-t//config group :type/notes))))

    ;; Build output based on what type we figured out.
    (cond ((eq type/notes :self-contained)
           ;; :self-contained notes filepath is just filename tacked
           ;; on to taskpath.
           (expand-file-name filename taskpath))

          ((eq type/notes :noteless)

           (expand-file-name
            ;; Remote File Name is:
            (concat
             ;; Task Name
             (file-name-nondirectory taskpath)
             ;; Plus a dot...
             "."
             ;; Plus filename, sans 'sort to top' stuff...
             (string-trim filename "_" "_"))
            ;; ...And the remote notes dir from the group's config to get
            ;; notespath.
            (-t//config group :dir/notes))

           ;; Remote file name is different - you want the task name in it so
           ;; the remote notes folder makes any sense on its own.
           (expand-file-name
            ;; Remote File Name is:
            (concat
             ;; Task Name
             (file-name-nondirectory taskpath)
             ;; Plus a dot...
             "."
             ;; Plus filename, sans 'sort to top' stuff...
             (string-trim filename "_" "_"))
            ;; ...And the remote notes dir from the group's config to get
            ;; notespath.
            (-t//config group :dir/notes))))))
;; (-t//path/notes :home "c:/2020-08-24_11_jeff/" :self-contained)
;; (-t//path/notes :home "c:/2020-08-24_11_jeff/" :noteless)
;; (-t//path/notes :home "c:/2020-08-24_11_jeff/" :jeff)
;; (-t//path/notes :home "c:/2020-08-24_11_jeff/")


(defun -t//path/generate (group taskpath filename)
  "Generates a file path for FILENAME and taskspace's TASKPATH.

This can be outside of the taskspace for e.g. :noteless taskspaces - the note
file will be elsewhere.
"
  (if (not (string= filename (-t//config group :file/notes)))
      ;; Non-note files just go in taskspace...
      (expand-file-name filename taskpath)

    ;; Notes files may or may not go in taskspace. Find out.
    (if (eq (-t//config group :type/notes)
            :self-contained)
        ;; Local file name is just provided name.
        (expand-file-name filename taskpath)

      ;; Remote file name could be different - may want task name in it.
      (expand-file-name (concat ;; remote file name:
                         ;; Task Name
                         (file-name-nondirectory taskpath)
                         ;; Plus a dot...
                         "."
                         ;; Plus filename, sans 'sort to top' stuff...
                         (string-trim filename "_" "_"))
                        (-t//config group :dir/notes)))))
;; (-t//path/generate :default "c:/2020-20-20_20_jeff" "_notes.org")
;; (-t//path/generate :default "c:/2020-20-20_20_jeff" "jeff.data")


;;------------------------------
;; Files
;;------------------------------

(defun -t//file/generate (group taskpath file-alist)
  "Generates each file in alist into the new taskpath. Expects
((filename . string-or-func)...) from alist. Creates 'filename' in taskspace
and then inserts string into it, or uses func to generate contents.
Does not currently support directory structures/trees. Returns nil or error.
Error is all files not generated in alist: ((filename . 'reason')...)
"

  ;; let it just do nothing when empty list
  (let (errors-alist ;; empty return value alist
        ;; Get taskname from path to supply to any file content gen funcs.
        (taskname (file-name-nondirectory taskpath)))
    (dolist (entry file-alist errors-alist)
      (let* ((file (file-name-nondirectory (eval (first entry))))
             (filepath (-t//path/generate group taskpath file))
             (str-or-func (second entry)))

        (cond
         ;; ERROR: already exists...
         ((f-file? filepath)
          (push `(,filepath . "file already exist") errors-alist))

;;         ;; ERROR: generator not bound
;;         ((not (boundp str-or-func))
;;          (push `(,filepath . "string/function not bound") errors-alist))

         ;; ERROR: unknown generator
         ((and (not (stringp str-or-func))
               (not (functionp str-or-func)))
          (push `(,filepath . ,(format "generator is not string or function: %s"
                                       str-or-func))
                errors-alist))

         ;; HAPPY!
         (t
          (with-temp-file filepath
            (if (stringp str-or-func)
                (insert str-or-func)
              ;; Call with group so users can have a function for multiple
              ;; groups if applicable...
              (insert (funcall str-or-func group taskname taskpath))))))

        ;; ;; If made a remote notes file, make a .taskspace config now.
        ;; (when (and (string= file (-t//config group :file/notes))
        ;;            (not (f-parent-of? taskpath filepath)))
        ;;   (taskspace/with/config taskpath
        ;;     (setq taskspace/config
        ;;           (taskspace/config/set :notes filepath taskspace/config))
        ;;     (taskspace/config/write taskspace/config taskpath)))

        ;; dolist returns the errors
        ))))


(defun -t//file/copy (taskpath &rest filepaths)
  "Copy each of the files in `filepaths'. Expects well-qualified filepaths
(absolute, relative, or otherwise). Does not currently support
directory structures/trees. Returns nil or error. Error is all
files not copied in alist: ((filepath . 'reason')...)
"
  ;; let it just do nothing when empty list
  (let (errors-alist) ;; empty return value alist
    (dolist (path filepaths errors-alist)
      (cond
       ;; ERROR: can't find or...
       ((not (file-exists-p path))
        (push `(,path . "file does not exist") errors-alist))
       ;; ERROR: can't read file or...
       ((not (file-readable-p path))
        (push `(,path . "file is not readable") errors-alist))
       ;; ERROR: not a file (dir or symlink or something)
       ((not (file-regular-p path))
        (push `(,path . "path is not a file") errors-alist))

       ;; HAPPY: copy it
       (t
        (copy-file path ;; from "the full path of where it is" to...
                   ;; taskpath + "the filename part of where it is"
                   (expand-file-name (file-name-nondirectory path) taskpath)))

       ;; dolist returns the errors
       ))))


;;------------------------------
;; Directories
;;------------------------------

(defun -t//dir/create (group description date-arg)
  "Creates dir w/ description, date, and (generated) number, if valid &
unused description.
"
  ;; Make sure basic folders exist.
  (unless (f-directory? (-t//config group :dir/tasks))
    (message "Taskspace: Making root directory... %s"
             (-t//config group :dir/tasks))
    (make-directory (-t//config group :dir/tasks)))
  (unless (f-directory? (-t//config group :dir/notes))
    (message "Taskspace: Making remote notes directory... %s"
             (-t//config group :dir/notes))
    (make-directory (-t//config group :dir/notes)))

         ;; Get today's date.
  (let* ((date (-t//naming/get/date group date-arg))
         ;; Get today's dirs.
         (date-dirs (-t//dir/list/date group date))
         ;;   - figure out index of this one
         (number (-t//naming/get/number group date-dirs))

         ;; Build dir string from all that.
         (dir-name (-t//naming/make group date number description))
         (dir-full-path (expand-file-name dir-name (-t//config group :dir/tasks))))

    ;; (message "create-dir: %s %s %s %s" date date-dirs number dir-name)

    ;; Only create if:
    ;;   - valid description input and
    ;;   - no dupes or accidental double creates
    ;;   - it doesn't exist (this is probably redundant if verify-description
    ;;     works right)
    (when (and (-t//naming/verify group description)
               (not (some (lambda (x) (-t//dir= group
                                                      description x
                                                      'description))
                          date-dirs))
               (not (file-exists-p dir-full-path)))

      ;; Make it.
      ;; make-directory helpfully has no data on what it returns or why or when
      ;; or anything. But it returns nil on success so... super useful guys.
      (make-directory dir-full-path)

      ;; How about we report something actually useful maybe?
      ;; Full path of created dir on... success?
      ;; Nil on folder non-existance.
      (if (file-exists-p dir-full-path)
          dir-full-path
        nil))))
;; (-t//dir/create :home "testcreate" nil)


(defun -t//dir= (group name dir part)
  "True if NAME is equal to the split-name PART of DIR.
Else nil.
"
  ;; don't accept nulls
  (unless (or (null name) (null dir) (null part))
    ;; strip dir down to file name and
    ;; strip file name down to part (if non-nil part)
    (let* ((dir-name (file-name-nondirectory dir))
           (dir-part (-t//naming/split group dir-name part)))
      (if (null dir-part)
          nil ;; don't accept nulls
        ;; else, usable data
        ;; check against input name
        (string= name dir-part)
        ))))
;; (-t//dir= :home "2000" "c:/zort/troz/2000_0_testcase" 'date)


;; Get children directories of taskspace/dir, ignoring
;; (-t//config group :dir/tasks/ignore).
(defun -t//dir/list/all (group)
  "Get children directories of taskspace/dir, ignoring
`(-t//config group :dir/tasks/ignore)'.
"
  (let (task-dirs) ;; empty list for return value
    ;; loop on each file in the directory
    (dolist (file
             (directory-files (-t//config group :dir/tasks) 'full)
             task-dirs)
      (when (and (file-directory-p file) ;; ignore files and...
                 (not (member ;; ignore things in ignore list
                       (file-name-nondirectory file)
                       (-t//config group :dir/tasks/ignore))))
        (push file task-dirs)
        ))
    ;; dolist returns our constructed list since we put it as `result'
    ;; so we're done
  ))
;; (message "%s" (-t//dir/list/all :home))


;; Get all, pare list down to date-str, return.
(defun -t//dir/list/date (group date-str)
  "Get any/all taskspaces for today.
"
  (unless (null date-str)
    (let ((task-dirs (-t//dir/list/all group))
          date-dirs) ;; return val
      (dolist (dir task-dirs date-dirs)
        (when (-t//dir= group date-str dir 'date)
          (push dir date-dirs)
          )))))
;; (-t//dir/list/date :home "2020-03-13")
;; (-t//dir/list/date :work "2020-08-26")


;;------------------------------
;; Taskspace Naming
;;------------------------------

(defun -t//naming/get/number (group dir-list)
  "Checks dirs in list, returns highest number part + 1.
"
  ;; Next number is one more than...
  (1+
   ;; The max of map/reduce shenanigans (or just -1 if given no dirs).
   (-max
       (or
        (->>
         ;; First, need to change from paths to dir names.
         (-map #'f-filename dir-list)
         ;; Now pare down to just numbers.
         (-map (lambda (dir) (-t//naming/split group dir 'number)))
         ;; Filter out any nils; don't matter to us.
         (-remove #'null)
         ;; string -> int
         (-map #' string-to-number))

        ;; fallback list: negative 1 so we return zero.
        '(-1)))))
;; (-t//naming/get/number :work (-t//dir/list/date :work "2020-08-26"))
;; (-t//naming/get/number :work (-t//dir/list/date :work "2020-08-26"))
;; (-t//naming/get/number :default '("zort/troz/2000_0_baz"))
;; (-t//naming/get/number :default '())
;; (-t//naming/get/number :default
;;                       '("zort/troz/2000_0_baz" "zort/troz/2000_qux"
;;                         "zort/troz/2000_qux_jeff" "zort/troz/2000_8_quux"))


(defun -t//naming/get/date (group arg)
  "Returns a date in the correct string format.
ARG must be nil or 'today (for today), or numberp.
Returns date requested by arg, or nil.
"
  (let ((day nil))
    ;; check/convert input arg
    (cond ((null arg)
           ;; nil -> today -> 0
           (setq day 0))

          ((numberp arg)
           ;; if arg numberp: 0 today, negative before, positive after
           (setq day arg))

          ((string= arg 'today)
           ;; 'today -> 0
           (setq day 0))

          ;; error case(s): nil
          (t
           (setq day nil)))

    (unless (eq day nil)
      (let* ((now (current-time)) ;; right now
             (now-adjust-secs (* day 24 60 60)) ;; day arg to seconds
             (target (time-add now now-adjust-secs))) ;; actually when we want
        ;; format to spec and return
        (format-time-string (-t//config group :format/datetime)
                            target)))))
;; Examples/Tests:
;;                 Today: (-t//naming/get/date :default nil)
;;            Also Today: (-t//naming/get/date :default 'today)
;; Today Too... I guess?: (-t//naming/get/date :default "today")
;;             Not Today: (-t//naming/get/date :default -1)
;;             Not Today: (-t//naming/get/date :default 1.9)
;;                 Error: (-t//naming/get/date :default "jeff")
;;                 Error: (-t//naming/get/date :default 'jeff)


(defun -t//naming/verify (group name)
  "Verifies that `name' is an allowable part of the directory name.
"

  ;; Sanity check 1: `name' must be a valid filename, for a very loose
  ;;                 definition of valid.
  ;; Sanity check 2: Not a path sep in there?
  ;; Valid check:    Verify name obeys my regexp.
  (let ((matched-invalid (string-match file-name-invalid-regexp name))
        (dir-sep-check (file-name-nondirectory name))
        (valid-name (string-match (-t//config group :naming/description/rx/valid) name)))

    ;; Check for bad input, fail if so... Bad if:
    ;;   - DOES match /invalid/ filename regexp
    (if (or matched-invalid
            ;; - or non-dir name DOES NOT match input name
            (not (string= name dir-sep-check))
            ;; - or DOES NOT match /valid/ name regexp
            (null valid-name))
        ;; Just return nil for fail.
        nil

      ;; else... Ok name. Do something?

      ;; Verify they didn't try to give us the whole thing? (check for date?)
      ;; (Eh... Not gonna bother right now.)

      ;; return input when valid
      name
      )))
;; weird name: (-t//naming/verify :default "\0")
;; too short:  (-t//naming/verify :default "0")
;; good!:      (-t//naming/verify :default "hello-there")
;; dir sep:    (-t//naming/verify :default "hello-there/here")
;; (-t//naming/verify :home "testing-testing")


(defun -t//naming/make (group date number description)
  "Creates a full name from inputs obeying first formatting order
found in parts-alists.
"
  ;; How long is the parts-alist we're looking for?
  ;;   - Stringify each (don't want nulls here...)
  (let* ((name-parts (seq-map (lambda (x) (format "%s" x))
                              ;; But take out nulls?
                              (seq-remove #'null
                                          ;; turn inputs into list
                                          (list date number description))))
         (name-len (length name-parts))
         split-alist)

    ;; find the right alist for building the dir string
    (dolist (alist (-t//config group :naming/parts-alists) split-alist)
      (when (= name-len (length alist))
        (setq split-alist alist)))

    ;; (message "make-name: %s->%s %s %s null?%s"
    ;;          name-parts (seq-remove #'null name-parts)
    ;;          name-len
    ;;          split-alist (null split-alist))

    (unless (null split-alist)
      (mapconcat #'identity (seq-remove #'null name-parts)
                 (-t//config group :naming/separator)))))
;; (-t//naming/make :default "2000" "1" "hi")
;; (-t//naming/make :default "2000" nil "hi")
;; (-t//naming/make :default "hi" nil nil)
;; (-t//naming/make :default "2019-05-14" 0 "testcreate")


;; util to split up dir name and then give desired bit back
;;  - should work for manually made ones that don't have the middle <#> part
(defun -t//naming/split (group name part)
  "Splits name based on taskspace naming/separator rules and returns the
requested part. Part can be one of: 'date 'number 'description

NAME should just be directory name; do not use path.
"
  (unless (or (null name) (null part))
    ;; unless or if/error?
    (let* ((split-name (split-string name
                                     (-t//config group
                                                        :naming/separator)))
           (len-split (length split-name))
           split-alist)

      ;; find the right alist for parsing the split dir string
      (dolist (alist (-t//config group :naming/parts-alists) split-alist)
        (when (= len-split (length alist))
          (setq split-alist alist)))

      ;; now try to pull out part requested
      (if (not (assoc part split-alist))
          nil ;; they requested something invalid for this `name'

        ;; figure out what index is desired,
        ;; then pull out the desired string (and return it)
        (nth (cdr (assoc part split-alist)) split-name)
        ))))
;; (-t//naming/split :home "2020-03-13_0_container-couchbase" 'date)
;; (-t//naming/split :default "2000_0_zort" 'date)
;; (-t//naming/split :default "2000_0_zort" nil)
;; (-t//naming/split :default "2000_0_zort" 'number)
;; (-t//naming/split :default "2000_zort" 'number)


;;------------------------------
;; Org-Mode Helpers
;;------------------------------

(defun -t//org/keywords/list (&optional to-lower)
  "Get keyword elements from this org document. Elements (return value) will
be an alist of (key . value).

'Keyword elements' are lines like this in org-mode files:
#+PROPERTY: value

If TO-LOWER is not nil, converts all keys to lowercase. DOES NOT CHANGE VALUES!
"
  ;; map func to elements...
  (org-element-map
      (org-element-parse-buffer 'element) ;; parse this buffer at 'element level
      'keyword ;; we only care about keywords
    ;; for each keyword element, get it's key and value into the return.
    (lambda (keyword) (cons
                       (if to-lower
                           (downcase (org-element-property :key keyword))
                         (org-element-property :key keyword))
                       (org-element-property :value keyword)))))


(defun -t//org/keyword/get (keyword &optional to-lower)
  "Gets the specified KEYWORD (case insensitive if TO-LOWER is not nil) from
this org document. If there are more than one, it will return whatever is first
in `-t//org/keywords/list' return.

'Keyword elements' are lines like this in org-mode files:
#+PROPERTY: value

So in the non-nil TO-LOWER case, we will return 'value' if asked for:
  'PROPERTY', 'property', 'PrOpeRtY', etc...
"
  (alist-get (if to-lower
                 (downcase keyword)
               keyword)
             (-t//org/keywords/list to-lower)
             nil nil
             #'string=))


;;------------------------------
;; Kill Ring (Copy/Paste)
;;------------------------------

(defun -t//kill-and-return (string &optional msg msg-args)
  "Copy STRING to kill-ring, optionally output MSG via `message' with MSG-ARGS,
and returns string.
"
  ;; copy to kill-ring
  (kill-new string)
  ;; say what we did
  (message msg msg-args)
  ;; return it
  string)
;; (-t//kill-and-return "hello")


;;----------------------------------Taskspace-----------------------------------
;;--                          Interactive Commands                            --
;;------------------------------------------------------------------------------

;;;###autoload
(defun taskspace/name/dwim ()
  "Interactive. DWIM to kill-ring and return today's task string
(partial/final path)... Create if none. Return if just the one.
Choose from multiple.
"
  (interactive)

  ;; Get task's full path, reduce to just task directory...
  (let* ((fullpath (call-interactively #'taskspace/dir/dwim))
         (taskname (file-name-nondirectory fullpath)))

    ;; copy to kill-ring
    (kill-new taskname)

    ;; return it
    taskname
    ))
;; (taskspace/name/dwim)
;; M-x taskspace/name/dwim


;;;###autoload
(defun taskspace/dir/dwim (date-input)
  "Interactive. DWIM to kill-ring and return today's task dir string...

If in an org-mode doc with `(-t//config group :dir/tasks/org/keyword)'
defined and dir it specifices exists:
  - Return the full path'd version of that org-mode keyword's value.

Else:
  - Create if none.
  - Return if just the one.
  - Choose from multiple.
"
  ;; Numeric arg but don't let lower case "p" auto-magic nothing (no prefix arg)
  ;; into 1. Nothing/0/nil is today. 1 is tomorrow.
  (interactive (list current-prefix-arg))

  ;; Try to get group from context.
  (let ((group (-t//group/get t))
        task-dir-shortcut
        task-msg-shortcut)

    ;; Prompt for group if we couldn't guess it.
    (unless group
      (setq group (-t//prompt/group 'auto t)))

    ;; Check for a taskspace keyword if we're in an org-mode buffer. Just use
    ;; that and skip the rest if we find it and it's a directory that exists and
    ;; stuff.
    (when (eq major-mode 'org-mode)
      (let ((task-dir (-t//org/keyword/get
                       (-t//config group :dir/tasks/org/keyword))))
        (when (and (not (null task-dir))
                   (f-directory? task-dir))
          (setq task-dir-shortcut (f-full task-dir))
          (setq task-msg-shortcut
                (format "Got Taskspace from org-mode keyword (#+%s). %s"
                        (-t//config group :dir/tasks/org/keyword)
                        task-dir-shortcut)))))

    ;; Do we have a shortcut out, or do we go looking for the task-dir?
    (if (not (null task-dir-shortcut))
        (-t//kill-and-return task-dir-shortcut task-msg-shortcut)

      ;; No short cut. Start looking at DWIM things in DWIM-y order...

      ;; Default to "today" if date-input isn't parsable string,
      ;; then get date, taskspaces, etc. for that numerical relative day.
      (let* ((date-input (cond
                          ;; no date-input is today is 0
                          ((null date-input) 0)
                          ;; strings should be converted to numbers
                          ((stringp date-input)
                           (string-to-number date-input))
                          ;; just allow numbers through unscathed
                          ((numberp date-input) date-input)
                          ;; default to... today/0 I guess?
                          (t 0)))
             (date (-t//naming/get/date group date-input))
             (taskspaces (-t//dir/list/date group date))
             (length-ts (length taskspaces)))

        (cond
         ;; error out if we have no idea what date to dwim with...
         ((null date) (error "Date string is nil: %s" date))

         ;; if none, create one.
         ((null taskspaces)
          ;; call-interactively will give user prompt for description,
          ;; etc. as if they called themselves.
          (funcall #'taskspace/create
                                 group
                                 (-t//prompt/name group)))

         ;; If just one, return it.
         ;; How to create second in that case? Use a non-dwim create func?
         ;;   - I think yes.
         ((= length-ts 1)

          ;; copy & return
          (-t//kill-and-return (first taskspaces)
                                     "Existing taskspace: %s"
                                     (first taskspaces)))

         ;; For now, only give existing choices. User can use a non-dwim create
         ;; func if they want new.
         ((> length-ts 1)

          ;; list available choices to user, get the taskspace they chose
          (let ((choice (-t//prompt/task-existing group
                                                taskspaces
                                                'nondirectory)))
            (-t//kill-and-return choice
                                       "Chose taskspace: %s"
                                       choice)))

         ;; Don't need a default case... Fall through with nil.
         ;;(t nil)
         )))))
;; M-x taskspace/dir/dwim
;; (taskspace/dir/dwim)
;; (taskspace/dir/dwim -1 :home)

;;;###autoload
(defun taskspace/create (group desc)
  "Interactive. Creates a new taskspace for today with the description
supplied.
"
  ;; Do we need a max len? Leaving out until I feel otherwise.
  (interactive
   (let ((group-prompt (-t//prompt/group 'auto t)))
     (list group-prompt
           (-t//prompt/name group-prompt))))

  ;; Is `desc' ok as description part?
  (if (not (-t//naming/verify group desc))
      ;; fail w/ message and return nil?
      ;; (progn
      ;;   (message "Invalid description: %s" desc)
      ;;   nil)
      ;; Trying out just erroring out instead.
      ;; We are up to the interactive level now.
      (error "Invalid description: %s" desc)

    ;; Create the dir/project for today.
    (let ((taskpath (-t//dir/create group desc 'today)))
      (if (null taskpath)
          ;; Couldn't create it for some reason...
          ;; TODO: Better reasons if known. "already exists" would be nice for
          ;; that case.
          (error "Error creating taskspace directory for: %s" desc)

        ;; Copy files into new taskspace.
        (when (f-dir? (-t//config group :file/new/copy))
          (apply #'-t//file/copy
                 ;; arg 1: our new taskpath
                 taskpath
                 ;; arg &rest: all the files to copy with:
                 ;;   - full path name
                 ;;   - no dot files
                 ;;     - no '.', '..'
                 ;;     - yes actual dotfiles somehow?
                 ;;     - This is what I want, so... ok.
                 (directory-files (-t//config group :file/new/copy)
                                  'full
                                  directory-files-no-dot-files-regexp)))

        ;; Generate files into new taskspace.
        (when (-t//config group :file/new/generate)
          (let ((gen-errors (-t//file/generate
                             group
                             taskpath
                             (-t//config group :file/new/generate))))
            (when gen-errors
              (error "Taskspace file generation errors: %s" gen-errors))))

        ;; Either of those can put a projectile file into the taskspace.
        ;; Just name it: .projectile
        ;;   See: https://projectile.readthedocs.io/en/latest/projects/#ignoring-files

        ;; Can also put skeleton org file. Or just org file with yasnippet ready
        ;; to go...

        ;; Copy taskpath to kill-ring.
        (kill-new taskpath)
        ;; Say something.
        (message "Created taskspace: %s" (file-name-nondirectory taskpath))
        ;; (message "Created taskspace: %s" taskpath)

        ;; Open the notes file.
        (-t//notes/open group taskpath nil t)

        ;; Return it.
        taskpath
        ))))
;; M-x taskspace/create
;; (taskspace/create "testing-create")


;;;###autoload
(defun taskspace/dired/task ()
  "Interactive. Opens the current taskspace's top dir in emacs.

If in a :noteless file, go to that note's task dir, if possible.
If in a file or sub-dir of the task dir, go to the task's dir.
"
  (interactive)

  (let* ((group (or (-t//group/get t)
                    (-t//prompt/group 'auto t)))
         (taskpath (-t//org/keyword/get
                    (-t//config group :dir/tasks/org/keyword))))

    ;; Can short-cut past this if we were in an org file and found the keyword
    ;; link to the task's dir.
    (unless taskpath
      ;; Deduce group or prompt for it.
      (let ((path (-t//path/current))
            (root (-t//config group :dir/tasks)))

        (setq taskpath
              ;; If we are in a dir/file under a task, get the topmost dir that
              ;; isn't the root.
              (cond ((f-descendant-of? path root)
                     ;; Go up from current until we get to direct child.
                     (f-traverse-upwards (lambda (dir)
                                           (-t//path/child-of? dir root))
                                         path))

                    ;; If we are in a remote notes file, dunno.
                    ;;   *shrug* Fallthrough to 't.

                    ;; If we are elsewhere, really dunno.
                    (t
                     nil)))))

    (if (not (f-dir? taskpath))
        ;; Not a dir - error out.
        (error "'%s' taskspace directory doesn't exist?: '%s'"
               group taskpath)

      ;; Ok - message and open (probably in dired but let emacs decide).
      (find-file taskpath)
      (message "Opening '%s' taskspace directory: %s"
               group
               (f-filename taskpath))
      ;; Return the task's path?
      taskpath)))
;; (taskspace/dired/task)
;; M-x taskspace/dired/task


;;;###autoload
(defun taskspace/dired/root (group)
  "Interactive. Opens the taskspace's overall top dir in emacs.
"
  (interactive (list (-t//prompt/group 'auto t)))

  (if (not (file-directory-p (-t//config group :dir/tasks)))
      ;; not a dir - error out
      (error "Can't find taskspace root directory: '%s'" (-t//config group :dir/tasks))

    ;; ok - message and open (probably in dired but let emacs decide)
    (find-file (-t//config group :dir/tasks))
    ;; say something
    (message "Opening taskspace parent: %s"
             (file-name-nondirectory (-t//config group :dir/tasks)))
    ;; return the top dir?
    (-t//config group :dir/tasks)
    ))
;; (taskspace/dired/root :home)
;; M-x taskspace/dired/root


;;;###autoload
(defun taskspace/shell (group)
  "Interactive. Opens the current taskspace's top dir in an emacs shell buffer.
Shell opened can be set by modifying:
  `(-t//config group :function/shell)'.
"
  ;; §-TODO-§ [2020-08-18]: If in a taskspace folder or a remote notes file,
  ;; just let the shell open without prompts.
  (interactive (list (-t//prompt/group 'auto t)))

  (let ((shell-fn (-t//config group :function/shell)))
    (if (not (functionp shell-fn))
        (error "`shell-fn' is not bound to a fuction. %s"
               shell-fn)

      ;; prompt user for the taskspace with an attempt at DWIM
      (let ((task (call-interactively #'taskspace/dir/dwim)))
        ;; expecting a path from task-dir/dwim
        (if (not (file-directory-p task))
            ;; not a dir - error out
            (error "Can't find taskspace (not a directory?): '%s'" task)

          ;; open with shell-fn
          (funcall shell-fn)
          ;; say something
          (message "Opening taskspace shell: %s" (file-name-nondirectory task))
          ;; return the chosen task's dir?
          task
          )))))
;; (taskspace/shell :work)
;; M-x taskspace/shell


;;;###autoload
(defun taskspace/notes (date-input group)
  "Interactive. Opens a taskspace's notes file.

Opens:
  - Today's notes file, if just one taskspace.
  - Auto-complete options for today's notes files, if more than one taskspace.
  - Auto-complete options for all notes files, if prefix arg supplied.
  - If no taskspaces are found for the DATE-INPUT, lists all options.
"
  ;; Numeric arg but don't let lower case "p" auto-magic nothing (no prefix arg)
  ;; into 1. Nothing/0/nil is today. 1 is tomorrow.
  (interactive (list current-prefix-arg
                     (-t//prompt/group 'auto t)))

  ;; Default to "today" if date-input isn't parsable string,
  ;; then get date, taskspaces, etc. for that numerical relative day.
  (let* ((date-parsed (cond
                       ;; no date-input is today is 0
                       ((null date-input) 0)
                       ;; strings should be converted to numbers
                       ((stringp date-input)
                        (string-to-number date-input))
                       ;; just allow numbers through unscathed
                       ((numberp date-input) date-input)
                       ;; default to... today/0 I guess?
                       (t 0)))
         (date        (-t//naming/get/date group date-parsed))
         (taskspaces  (-t//dir/list/date group date))
         (taskspaces  (or taskspaces
                          (-t//dir/list/all group)))
         (length-ts   (length taskspaces))
         taskpath)

    (message "%S tasks for %S: %S" length-ts date taskspaces)

    (cond
     ;; error out if we have no idea what date to dwim with...
     ((null date) (error "Date string is nil: %s" date))

     ;; If just one, open its notes file.
     ((= length-ts 1)
      (setq taskpath (first taskspaces))
      (message "Only taskspace: %s" taskpath))

     ;; For now, only give existing choices. User can use a non-dwim create func
     ;; if they want new.
     ((> length-ts 1)

      ;; list available choices to user, get the taskspace they chose
      (let ((choice (-t//prompt/task-existing group taskspaces 'nondirectory)))
        (setq taskpath choice)
        (message "Chose taskspace: %s" choice)))

     ;; Default case... Fall through with nil.
     (t nil))

    (if (null taskpath)
        (error "No taskspace notes found for date: %s" date)

        ;; Exists; message and visit it.
        (-t//notes/open group taskpath))))
;; M-x taskspace/notes
;; (taskspace/notes)
;; (taskspace/notes -1 (-t//prompt/group 'auto t))


;; TODO: more options for making keybind:
;; (&optional orphaned description prefix)
(defun taskspace/keybind/doom ()
  "Create keybinds in doom.

Create a keymap; insert into doom/evil or vanilla emacs as
appropriate/parameters say.

Creates the taskspace keymap under the doom leader key (default SPC)
TODO: unless ORPHANED is not nil.

TODO: Uses DESCRIPTION if it is a string, else the description is 'taskspace'.

TODO: Uses PREFIX as the keymap prefix if not nil, else tries to use:
TODO:   - doom/evil emacs: doom-leader(?) n T
TODO:   - vanilla emacs:   TODO
TODO:
TODO: PREFIX for doom/evil should be either:
TODO:   1) a key string:
TODO:      - \"t\"
TODO:      - \"n t\"
TODO:        - \"nt\" is equivalent
TODO:   2) a cons of (key-string . description-str):
TODO:      - (\"t\" . \"taskspace\")
TODO:      - (\"n t\" . \"taskspace\")
TODO:   3) a list of 1 or 2 for setting into a sub-map:
TODO:      - (\"t\" (\"n\" (\"t\" . \"taskspace\")))
"
  (if (null (symbolp 'doom!)) ;; Doom's loading function should mean this is doom?
      (error (concat "%s: We are not in a Doom Emacs environment..? "
                     "Cannot set Doom Emacs keybinds.")
             "taskspace/doom/keys")

    ;; Map under the Doom leader, probably.
    (map! :leader
          ;; Give it a description...
          :desc "taskspace"

          ;; ...and give it keybinds.
          (:prefix ("T" . "taskspace")

           ;; Top level commands...
           :desc "Create new..."  "T" #'taskspace/create
           :desc "Visit notes..." "v" #'taskspace/notes
           :desc "Shell..."       "s" #'taskspace/shell

           ;; 'Copy to kill ring' functions:
           (:prefix ("k" . "Kill...")

            :desc "dir"  "k" #'taskspace/dir/dwim
            :desc "name" "n" #'taskspace/name/dwim)

           ;; 'Open a dired buffer' functions:
           (:prefix ("d" . "dired")
            :desc "task dired buffer" "d" #'taskspace/dired/task
            :desc "root dired buffer" "r" #'taskspace/dired/root)))))
;; TODO: prefix: ;; Put it under the prefix(es).
;; TODO: prefix: (cond
;; TODO: prefix:  ;;---
;; TODO: prefix:  ;; NIL
;; TODO: prefix:  ;;---
;; TODO: prefix:  ;; Return just the keybinds.
;; TODO: prefix:  ((null prefix)
;; TODO: prefix:   (-t//keybind/doom))
;; TODO: prefix:
;; TODO: prefix:  ;;---
;; TODO: prefix:  ;; STRING
;; TODO: prefix:  ;;---
;; TODO: prefix:  ;; Put keybinds under the prefix str.
;; TODO: prefix:  ((stringp prefix)
;; TODO: prefix:   (list prefix (-t//keybind/doom)))
;; TODO: prefix:
;; TODO: prefix:  ;;---
;; TODO: prefix:  ;; CONS
;; TODO: prefix:  ;;---
;; TODO: prefix:  ;; Put keybinds under the prefix /CONS/.
;; TODO: prefix:  ;; ONLY CONS!!!
;; TODO: prefix:  ;; No lists.
;; TODO: prefix:  ;; Just cons.
;; TODO: prefix:  ;; https://emacs.stackexchange.com/questions/10489/predicate-function-for-dotted-pairs
;; TODO: prefix:  ((and (cdr var) (atom (cdr var)))
;; TODO: prefix:   ;; Create list with description, key, and our keybids.
;; TODO: prefix:   (list
;; TODO: prefix:    :desc (nth 1 prefix)
;; TODO: prefix:    (nth 0 prefix)
;; TODO: prefix:    (-t//keybind/doom)))
;; TODO: prefix:
;; TODO: prefix:  ;;---
;; TODO: prefix:  ;; LIST
;; TODO: prefix:  ;;---
;; TODO: prefix:  ((listp prefix)
;; TODO: prefix:   ;; Build first layer and do a recursion...
;; TODO: prefix:   (-let [(this-prefix . rest) prefix]
;; TODO: prefix:     (
;; TODO: prefix:      )))
;; TODO: prefix:
;; TODO: prefix:   (list
;; TODO: prefix:    :desc (nth 1 prefix)
;; TODO: prefix:    (nth 0 prefix)
;; TODO: prefix:
;; TODO: prefix:    prefix (-t//keybind/doom)))
;; TODO: prefix:
;; TODO: prefix:
;; TODO: prefix: (defun -t//no-error-predicate (func value)
;; TODO: prefix:   "Checks if VALUE fulfills FUNC function predicate.
;; TODO: prefix:
;; TODO: prefix: Wraps check in a `condition-case-unless-debug', returns nil if error signal caught."
;; TODO: prefix:   (condition-case-unless-debug nil
;; TODO: prefix:       (funcall func value)
;; TODO: prefix:     (error nil)))
;; TODO: prefix:
;; TODO: prefix:
;; TODO: prefix: (defun -t//keybind/doom.level (key description rest)
;; TODO: prefix:   "Creates a level of a doom `map!'.
;; TODO: prefix:
;; TODO: prefix: KEY must be a string for the key(s) to use for this level of the keybind tree.
;; TODO: prefix:
;; TODO: prefix: DESCRIPTION must be a (short) description string or nil.
;; TODO: prefix:
;; TODO: prefix: REST must be a function to call, or a deeper (child) level of the keybind tree."
;; TODO: prefix:   ;; Error check our inputs...
;; TODO: prefix:   (cond ((not (-t//no-error-predicate #'stringp key))
;; TODO: prefix:          (error "%s: Key must be a string: %S"
;; TODO: prefix:                 "-t//keybind/doom.level" key))
;; TODO: prefix:
;; TODO: prefix:         ((and (not (null description))
;; TODO: prefix:               (not (-t//no-error-predicate #'stringp description)))
;; TODO: prefix:          (error "%s: Description must be nil or a string: %S"
;; TODO: prefix:                 "-t//keybind/doom.level" description))
;; TODO: prefix:
;; TODO: prefix:         ((null rest)
;; TODO: prefix:          (error "%s: Must have something to bind: %S"
;; TODO: prefix:                 "-t//keybind/doom.level" rest))
;; TODO: prefix:
;; TODO: prefix:         ;;---
;; TODO: prefix:         ;; Success - make the level.
;; TODO: prefix:         ;;---
;; TODO: prefix:         (t
;; TODO: prefix:          (if (null description)
;; TODO: prefix:              (list key rest)
;; TODO: prefix:            (list :desc description
;; TODO: prefix:                  key
;; TODO: prefix:                  rest)))))


;;------------------------------------------------------------------------------
;; Tasks, Wants, Feature Requests, etc.
;;------------------------------------------------------------------------------

;; TODO-PKG:
;;   - Comments/layout like a real package.
;;     e.g. https://github.com/tarsius/moody/blob/master/moody.el


;;------------------------------------------------------------------------------
;; The End.
;;------------------------------------------------------------------------------
(provide 'taskspace)
;;; taskspace.el ends here
