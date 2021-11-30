;;; spy/system/+multiplex.el -*- lexical-binding: t; -*-


;;------------------Init & Config Help for Multiple Systems.--------------------
;;--                     What computer is this anyways?                       --
;;--------------------------(probably the wrong one)----------------------------

(require 'cl-lib) ;; cl-defun for '&keys'

(imp:require :jerky)
(imp:require :str)
(imp:require :modules 'spy 'file 'path)


;;------------------------------------------------------------------------------
;; Constants & Variables
;;------------------------------------------------------------------------------


;;------------------------------------------------------------------------------
;; Getter/Setter for jerky system keys.
;;------------------------------------------------------------------------------

(defun sss:systems/add (hash)
  "Add HASH to the list of system hashes if not already present."
  (let ((hashes (jerky/get 'system 'hashes)))
    (when (not (member hash hashes))
      (jerky/set 'system 'hashes
                 :value (cons hash hashes)
                 :docstr "List of all system hashes."))))


(defun sss:systems/hashes ()
  "Get a list of all system hashes."
  (jerky/get 'system 'hashes))
;; (sss:systems/hashes)


(defun spy:system/set (&rest plist)
  "For setting a system's multiplex settings.

PLIST is a plist with keys:
  - REQUIRED:
    + `:hash'  - This system's hash string.
    + `:keys'  - A list of keys to use for storing setting (will be prepended with (:system hash).
    + `:value' - The value to store.
  - OPTIONAL:
    + `:docstr' - Documentation string."

  (let ((hash   (plist-get plist :hash))
        (keys   (plist-get plist :keys))
        (value  (plist-get plist :value))
        (docstr (plist-get plist :docstr)))

    ;; Check for required plist keys:
    (cond ((not hash)
           (error "`spy:system/set' must have a `:hash' in params: %S"
                  plist))
          ((not value)
           (error "`spy:system/set' must have a `:value' in params: %S"
                  plist))

          ;; Special case: save value as this system's hash if `hash' and
          ;; `value' are equal and there are no `keys' or `docstr'.
          ((and hash
                value
                (not keys)
                (not docstr)
                (stringp hash)
                (stringp value)
                (string= hash value))
           (sss:systems/add hash)
           (jerky/set 'system 'hash
                      :value value))

          ;; Check for required plist keys:
          ((not keys)
           (error "`spy:system/set' must have a `:keys' list in params: %S"
                  plist))

          ;; Check validitiy:
          ((not (listp keys))
           (error "`spy:system/set': Keys must be a list; got: %S" keys))
          ((and docstr
                (not (stringp docstr)))
           (error "`spy:system/set': Docstr must be a string; got: %S" docstr))

          ;; Valid - save it.
          (t
           (sss:systems/add hash)
           (if docstr
               (jerky/set 'system hash keys
                          :value value
                          :docstr docstr)
             (jerky/set 'system hash keys
                        :value value))))))
;; (spy:system/set :hash "foo" :keys '(bar) :value 42 :docstr "hello there")
;; (spy:system/set :hash "jeff" :value "jeff")
;; (jerky/get 'system 'hash)
;; (spy:system/set :hash "5730ce-91e149" :value "5730ce-91e149")
;; (jerky/get 'system 'hash)


(defun spy:system/get (&optional hash &rest keys)
  "For getting a system's multiplex settings.

HASH should be the system's hash used when saving the setting.
  - If both HASH and KEYS are nil, this will return the saved hash for
    /this/ system.
  - If HASH is nil, it will use /this/ system's hash.

KEYS will be prepended with `:system' and the HASH."
  ;; Special case: get saved hash.
  (cond ((and (null hash)
              (null keys))
         (jerky/get 'system 'hash))

        ;; Check validitiy:
        ((not keys)
         (error "`spy:system/get' must have `keys' in params; got: %S"
                keys))

        ;; Try to get it.
        (t
         (let ((hash/get (or hash
                             (jerky/get 'system 'hash))))
           ;; Check `hash/get' validity, finally.
           (if (not hash/get)
               (error (concat "`spy:system/get': No hash provided and could "
                              "not find a saved hash... "
                              "provided: %S, saved: %S")
                      hash (jerky/get 'system 'hash))
             (jerky/get 'system hash/get keys))))))
;; (spy:system/get nil)
;; (spy:system/get nil 'path 'secret 'emacs)
;; (spy:system/get (jerky/get 'system 'hash) 'path 'secret 'emacs)
;; (spy:system/get "foo" 'bar)
;; (jerky//parse '(system "foo" (bar)) t)
;; (jerky/get 'system "foo" '(bar))


;;------------------------------------------------------------------------------
;; System UID
;;------------------------------------------------------------------------------

(defun spy:system/hash ()
  "Return /this/ system's hash.

If a system hash has been saved, return the saved hash.

Else, generate a system hash from `system-name' and `system-type'."
  ;; TODO: Why does a system have a different hash at start of init compared
  ;; to after doom/emacs is running? Is it intentional? Cuz it's confusing to
  ;; me when adding a new system.
  ;; (message "system hash for system-name %S system-type %S: %S"
  ;;          (system-name) system-type
  ;;          (str:hash:pretty (list (system-name) system-type)))
  ;;
  ;; Band-aid solution: check if we've got a saved hash.
  (if-let ((saved-hash (spy:system/get nil)))
      saved-hash
    (let ((hash (str:hash:pretty (list (system-name) system-type))))
      (spy:system/set :hash hash :value hash)
      hash)))
;; (spy:system/hash)
;; (str:hash:pretty (list (system-name) system-type))


(defun spy:system/unique-id (domain date name)
  "Generate a system UID from the specified DOMAIN, DATE and NAME, with
`system-name' and `system-type' as additional information.
"
  (str:hash (list domain date name)
            (list (system-name) system-type)))
;; (spy:system/unique-id "jeff" "2020" "compy")


(defun spy:system/path (root unique-id)
  "Generate a path to where the secrets file should be, based
on the UNIQUE-ID of the system and the ROOT path.
"
  (spy:path:dir-path root
                   (replace-regexp-in-string "::" "_"
                                             (replace-regexp-in-string "/" "-"
                                                                       unique-id))))
;; (spy:system/path "c:/foo" ":bar")


;;------------------------------------------------------------------------------
;; Define a System
;;------------------------------------------------------------------------------

(cl-defun spy:system/define (&key hash
                                  domain
                                  date
                                  type
                                  description
                                  (path/secret/root "~/.config/secret")
                                  (path/secret/init "emacs/doom")
                                  (debug nil))
  "Defines a system based on the keywords.

HASH - /MUST/ be a static string of a system's hash from `spy:system/hash',
       not a return value from dynamically calling `spy:system/hash'.

DOMAIN - A string/symbol of \"home\", \"work\", or whatever domain names you use.

DATE - A string/symbol of the year, or year-month-day, to identify similar systems.

TYPE - Another string/symbol for identifying the system.
       \"desk\", \"desktop\", \"lap\", etc.

DOMAIN, DATE, and TYPE are combined with forward slashes to create the
human-readable part of the system's ID. The HASH is applied after these:
  id = \"<domain>/<date>/<type>::<hash>\"
    e.g. \"home/2021/desk::12345-abcdef\"
  - See `str:hash:recreate'

DESCRIPTION - A short string for the 'docstr' of the ID and the path.

PATH/SECRET/ROOT - Absolute path to the specified system's secret folder.

PATH/SECRET/INIT - Relative path from PATH/SECRET/ROOT to the Emacs init files
                   for this system.
                 - NOTE: Can be the init for the specified system, or for all
                         systems, depending on how your secret's init is itself
                         set up.

DEBUG - if non-nil, just print out stuff instead of setting it into Jerky."
  (when debug
    (message (mapconcat #'identity
                        '("spy:system/define:"
                          "  hash:   %S"
                          "  domain: %S"
                          "  date:   %S"
                          "  desc:   %S"
                          "  root:   %S"
                          "  init:   %S"
                          "  debug:  %S"
                          )
                        "\n")
             hash
             domain
             date
             type
             description
             path/secret/root
             path/secret/init
             debug))

  ;;------------------------------
  ;; Error Checking
  ;;------------------------------
  (let (errors)
    (unless (stringp hash)
      (push (format "HASH must be a string. Got type %S: %S"
                    (type-of hash)
                    hash)
            errors))
    (unless (or (stringp domain)
                (symbolp domain))
      (push (format "DOMAIN must be a string or symbol. Got type: %S"
                    (type-of domain)
                    domain)
            errors))
    (unless (or (stringp date)
                (symbolp date))
      (push (format "DATE must be a string or symbol. Got type: %S"
                    (type-of date)
                    date)
            errors))
    (unless (or (stringp type)
                (symbolp type))
      (push (format "TYPE must be a string or symbol. Got type: %S"
                    (type-of type)
                    type)
            errors))
    (unless (stringp description)
      (push (format "DESCRIPTION must be a string. Got type %S: %S"
                    (type-of description)
                    description)
            errors))
    (unless (stringp path/secret/root)
      (push (format "PATH/SECRET/ROOT must be a string. Got type %S: %S"
                    (type-of path/secret/root)
                    path/secret/root)
            errors))
    (unless (stringp path/secret/init)
      (push (format "PATH/SECRET/INIT must be a string. Got type %S: %S"
                    (type-of path/secret/init)
                    path/secret/init)
            errors))

    (when errors
        (error (concat "spy:system/define: Invalid parameter"
                       (when (!= 1 (length errors))
                         "s")
                       ": "
                       (mapconcat #'identity
                                  errors
                                  "\n")))))


  (let* ((id (str:hash:recreate (list domain date type) hash))
         (path/secret/init.abs (spy:path:dir-path path/secret/root path/secret/init)))
    ;;------------------------------
    ;; Debug?
    ;;------------------------------
    (if debug
        (message (concat "System:\n"
                         "  -> hash:          %S\n"
                         "  -> domain:        %S\n"
                         "  -> date:          %S\n"
                         "  -> type:          %S\n"
                         "  -> description:   %S\n"
                         "  -> path/root:     %S\n"
                         "  -> path/init:     %S\n"
                         "  <- id:            %S\n"
                         "  <- path/init.abs: %S")
                 hash domain date type description
                 path/secret/root path/secret/init
                 id path/secret/init.abs)

      ;;------------------------------
      ;; Define the System.
      ;;------------------------------

      (spy:system/set :hash hash
                      :keys (list 'path 'secret 'root)
                      :value path/secret/root
                      :docstr "Root for .secret.d")
      (spy:system/set :hash hash
                      :keys (list 'path 'secret 'emacs)
                      :value path/secret/init.abs
                      :docstr "Root for Per-Computer Set-Up of Emacs")
      (spy:system/set :hash hash
                      :keys (list 'id)
                      :value id
                      :docstr description)

      ;; Have to set path per-system since work comps have restrictions on where
      ;; things can be, and home comps tend to have a random number of hard drives
      ;; just wherever.
      (spy:system/set :hash hash
                      :keys (list 'path 'secret 'system)
                      :value  (spy:system/path path/secret/init.abs id)
                      :docstr description))))
;; (spy:system/define :debug t
;;                    :hash "123456-abcdef"
;;                    :domain "home"
;;                    :date "2021"
;;                    :type "desk"
;;                    :description "test description"
;;                    :path/secret/root "~/.config/spydez/secret"
;;                    :path/secret/init "path/emacs/doom")


(defun spy:system/show (&optional hash)
  "Displays system info for system identified by HASH.

If HASH is nil, displays all systems' infos."
  (interactive)
  ;;------------------------------
  ;; Error Checking
  ;;------------------------------
  (unless (or (null hash)
              (stringp hash))
    (error "spy:system/show: HASH must be a string or nil. Got type %S: %S"
           (type-of hash)
           hash))

  ;; Show each system, or just the matching system.
  (let ((buffer (spy:buffer/special-name "Systems" nil :info)))
    (if hash
        (sss:system/show hash buffer)

      (dolist (hash/system (sss:systems/hashes))
        (sss:system/show hash/system buffer)))))
;; (spy:system/show)


(defun sss:system/show (hash buffer)
  "Displays system info for system identified by HASH."
  (with-current-buffer (get-buffer-create buffer)
    (goto-char (point-max))
    (let* ((current (string= hash (spy:system/hash)))
           (id (spy:system/get hash 'id))
           ;; Split ID up into domain, date, and type.
           (prefixes (nth 0 (if id
                                (str:hash:split id)
                              nil)))
           (domain   (nth 0 prefixes))
           (date     (nth 1 prefixes))
           (type     (nth 2 prefixes))
           (description (jerky/get 'system hash 'id
                                   :field :docstr))
           (path/root (spy:system/get hash 'path 'secret 'root))
           (path/init (spy:system/get hash 'path 'secret 'emacs)))
      (insert
       (format (concat "\n\n"
                       "System %s:\n"
                       "%s"
                       "    -> hash:          %s\n"
                       "    -> domain:        %s\n"
                       "    -> date:          %s\n"
                       "    -> type:          %s\n"
                       "    -> description:   %s\n"
                       "    -> path/root:     %s\n"
                       "    -> path/init:     %s")
               id
               (if current
                   "  --> THIS SYSTEM! <--\n"
                 "")
               hash domain date type description
               path/root path/init)))))


;; ;;------------------------------------------------------------------------------
;; ;; Load the System Defs.
;; ;;------------------------------------------------------------------------------
;;
;; (load! "systems")
;;
;; [2021-07-11]: This is done in .doom.d/init/systems.el now.


;;------------------------------------------------------------------------------
;; The End.
;;------------------------------------------------------------------------------
(imp:provide :modules 'spy 'system 'multiplex)
