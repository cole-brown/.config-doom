;; -*- mode: emacs-lisp; lexical-binding: t -*-


;;------------------Init & Config Help for Multiple Systems.--------------------
;;--                     What computer is this anyways?                       --
;;--------------------------(probably the wrong one)----------------------------

(imp:require :jerky)


;;------------------------------------------------------------------------------
;; Constants & Variables
;;------------------------------------------------------------------------------

;; Default fallback is ok.
(jerky/namespace/create :work ;; Work Namespace
           :title "Namespace for the Job"
           :docstr "Work/Job-related variables.")

;; Default fallback is ok.
(jerky/namespace/create :home ;; Home Namespace
           :title "Namespace for House & Home"
           :docstr "Homework, Side-Projects, Personal Notes, etc...")

;; Default fallback is ok.
(jerky/namespace/create :secret ;; Secret Namespace
           :title "Namespace for the Confidential"
           :docstr "You've seen this, so... Now I have to kill you, I guess?"
           :fallbacks :jerky/namespace/no-fallback)

;; Default system namespace - can overwrite during system multiplex init.
(jerky/set 'namespace 'system
           :default ;; System Namespace
           :title "Namespace for the Confidential"
           :docstr "You've seen this, so... Now I have to kill you, I guess?"
           :fallbacks :jerky/namespace/no-fallback)


;;------------------------------------------------------------------------------
;; Getter/Setter for jerky system keys.
;;------------------------------------------------------------------------------

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
           ;; Check `hash' validity, finally.
           (if (not hash/get)
               (error (concat "`spy:system/get': No hash provided and could "
                              "not find a saved hash... "
                              "provided: %S, saved: %S")
                      hash (jerky/get 'system 'hash))
           (jerky/get 'system hash keys))))))
;; (spy:system/get nil)
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
  ;;          (spy:hash/pretty (list (system-name) system-type)))
  ;;
  ;; Band-aid solution: check if we've got a saved hash.
  (if-let ((saved-hash (spy:system/get nil)))
      saved-hash
    (let ((hash (spy:hash/pretty (list (system-name) system-type))))
      (spy:system/set :hash hash :value hash)
      hash)))
;; (spy:system/hash)
;; (spy:hash/pretty (list (system-name) system-type))


(defun spy:system/unique-id (domain date name)
  "Generate a system UID from the specified DOMAIN, DATE and NAME, with
`system-name' and `system-type' as additional information.
"
  (spy:hash (list domain date name)
            (list (system-name) system-type)))
;; (spy:system/unique-id "jeff" "2020" "compy")


(defun spy:system/path (root unique-id)
  "Generate a path to where the secrets file should be, based
on the UNIQUE-ID of the system and the ROOT path.
"
  (spy:path/to-dir root
                   (replace-regexp-in-string "::" "_"
                                             (replace-regexp-in-string "/" "-"
                                                                       unique-id))))
;; (spy:system/path "c:/foo" ":bar")


;;------------------------------------------------------------------------------
;; Multiple systems (computers) able to use this same Doom Config.
;;------------------------------------------------------------------------------

;; Always load `multiplex' unless specifically removed.
(unless (featurep! -multiplex)
   (load! "+multiplex"))


;;------------------------------------------------------------------------------
;; Config/Load Helpers.
;;------------------------------------------------------------------------------

;; Always load `config' unless specifically removed.
(unless (featurep! -config)
   (load! "+config"))

;; Always load `package' unless specifically removed.
(unless (featurep! -package)
   (load! "+package"))


;;------------------------------------------------------------------------------
;; The End.
;;------------------------------------------------------------------------------
(imp:provide :modules 'spy 'system)
