;;; mis/args/+mlist.el -*- lexical-binding: t; -*-

;; General Layout of a MisList (mlist):
;;
;; It is a recursive plist.
;;
;; Example:
;;    '(:mis :root
;;      :style (...)
;;      :content (
;;          :string "Hello "
;;          :complex (:mis :something
;;                    :style (...)
;;                    :string "there")
;;          :string "."
;;      )
;;    )


;;------------------------------------------------------------------------------
;; Constants
;;------------------------------------------------------------------------------

(defconst -m//sections
  '(:mis
    :style
    :string)
  "Valid mis section keywords for mlists."
  )


;;------------------------------------------------------------------------------
;; Predicates
;;------------------------------------------------------------------------------

(defun -m//return/no-error (input)
  "Converts INPUT of `:mis/error' to nil. Leaves other inputs alone."
  (if (eq input :mis/error)
      nil
    input))


(defun -m//input/invalid? (input valids)
  "Returns t if INPUT is not a member of valids, or if INPUT is a special case
  like `:mis/error'."

  (cond
   ;; Special case invalid?
   ((eq input :mis/error)
    t)

   ;; Member of specified valids?
   ((memq input valids)
    nil)

   ;; Not a valid member, so... invalid.
   (t
    t)))
;; (-m//input/invalid? :trim '(:trim :string))


(defun -m//return/invalid? (values &optional invalids)
  "Returns t if any VALUES are considered \"invalid\".

`:mis/error' is always considered invalid; any other invalids (e.g. `nil',
`:mis/nil') should be provided in INVALIDS as a list.
  - For convenience, an INVALIDS of `t' means `nil' and `:mis/nil' are invalid.
"
  ;; Convert shortcut invalids into the nil&niller list.
  (let ((invalids (if (eq invalids t)
                      '(nil :mis/nil)
                    invalids))
        ;; Allow for either a list or a value by turning the latter into a list.
        ;; Watch out for the friendly neighborhood list/value Schrodenger's nil.
        (values (if (and (listp values)
                         (not (eq values nil)))
                    values
                  (list values))))
    (if invalids
        ;; If we have extra invalid values, we got to check for too...
        (-any? (lambda (val)
                 "Check for values that are invalid."
                 (or (memq val invalids)
                     (eq val :mis/error)))
               values)

      ;; Else only `:mis/error' is invalid.
      (-any? (lambda (val)
               "Check that values are not invalid."
               (eq val :mis/error))
             values))))
;; (-m//return/invalid? '(jeff))
;; (-m//return/invalid? 'jeff)
;; (-m//return/invalid? '(:mis/error))
;; (-m//return/invalid? :mis/error)
;; (-m//return/invalid? '(nil :mis/error 'jeff))
;; (-m//return/invalid? '("" 'jeff))
;; (-m//return/invalid? '(nil 'jeff) t) ;; nil is invalid
;; (-m//return/invalid? '(:mis/nil 'jeff) t) ;; :mis/nil is invalid


(defun -m//mlist/valid? (mlist)
  "Returns t if MLIST is a mis-plist (aka 'mlist'), else nil.
"
  ;; `mlist' exists and has a `:mis' key? Good enough.
  (and (not (null mlist))
       (listp mlist)
       (not (null (plist-member mlist :mis)))))


(defun -m//mlist/valid.key? (key)
  "Returns t if KEY is a valid mlist key.
"
  ;; Stupid version for now; can check that key is part of a "known good"
  ;; sequence after we know what some more of those are...
  (keywordp key))


(defun -m//mlist/valid.section? (section)
  "Returns t if SECTION is a valid mlist section.
"
  (and (-m//mlist/valid.key? section)
       (memq section -m//sections)))


;; (defun -m//mlist/keys? (&rest keys)
;;   "Returns t if KEY is a valid mlist key.
;; "
;;   ;; Make sure all keys are... keys. Flatten list to be a bit more forgiving of
;;   ;; inputs.
;;   (-all? #'-m//mlist/key (-flatten keys)))


(defun -m//mlist/exists.section? (section mlist)
  "Returns t if MLIST is an mlist and has SECTION, else nil.
"
  ;; `mlist' is an mlist and has the section key? Good enough.
  (and (-m//mlist/valid? mlist)
       (-m//mlist/valid.section? section)
       (not (null (-m//mlist/get.section section check)))))


;;------------------------------------------------------------------------------
;; General Getters/Setters
;;------------------------------------------------------------------------------

(defun -m//mlist/ensure (mlist &optional type)
  "Creates and returns an empty mlist if MLIST doesn't exist already.
If MLIST is something, but is not a valid mlist, returns `:mis/error'.
"
  ;; Return a basic mlist if given nil.
  (cond ((eq mlist nil)
         (list :mis (or type t)))

        ;; Return the input if it's already a valid list.
        ((-m//mlist/valid? mlist)
         mlist)

        ;; Otherwise error.
        (t
         :mis/error)))
;; (-m//mlist/ensure nil)
;; (-m//mlist/ensure nil 'jeff)


(defun -m//mlist/ensure.section (section mlist &optional type)
  "Creates and returns an empty mlist with an empty SECTION if MLIST doesn't
exist already. If MLIST is a valid mlist, ensures that SECTION exists (creates
empty one if necessary). If MLIST is something, but is not a valid mlist,
returns `:mis/error'.
"
  (let ((mlist (-m//mlist/ensure mlist type)))
    ;; Return an mlist if given a valid one.
    (cond ((-m//mlist/valid? mlist)
           (if (plist-member mlist section)
               ;; Everything ok; return as-is.
               mlist
             ;; Gotta make the section first.
             (plist-put mlist section
                        ;; Make the section's (sub-)mlist.
                        (-m//mlist/ensure nil section))))

          ;; Otherwise error.
          ((eq mlist :mis/error)
           :mis/error)
          (t
           :mis/error))))


(defun -m//mlist/get.value (key mlist &optional default)
  "Get a value from this MLIST based on KEY.

Checks that MLIST is an mlist, and that KEY is a valid mis key first;
returns `:mis/error' if not.

Tries to get KEY value from MLIST next; returns DEFAULT if unable.
"
  (if (or (not (-m//mlist/valid? mlist))
          (not (-m//mlist/valid.key? key)))
      ;; Return error value because we don't have valid inputs.
      :mis/error

    ;; Valid inputs! Get or default.
    (or (plist-get mlist key)
        default)))


(defun -m//mlist/set.value (key value mlist)
  "Set a value in this mlist.

Checks that MLIST is an mlist, and that KEY is a valid mis key first;
returns `:mis/error' if not.
"
  (if (or (not (-m//mlist/valid? mlist))
          (not (-m//mlist/valid.key? key)))
      ;; Return error value because we don't have valid inputs.
      :mis/error

    ;; Valid key and list; insert value.
    (plist-put mlist key value)))


(defun -m//mlist/get.section (section mlist &optional default)
  "Get a section from this MLIST based on SECTION.

Checks that MLIST is an mlist, and that SECTION is a valid mis section first;
returns `:mis/error' if not.

Tries to get SECTION value from MLIST next; returns DEFAULT if unable.
"
  (if (or (not (-m//mlist/valid? mlist))
          (not (-m//mlist/valid.section? section)))
      ;; Return error value because we don't have valid inputs.
      :mis/error

    ;; Valid inputs! Get or default.
    (-m//mlist/get.value section mlist default)))


(defun -m//mlist/set.section (section value mlist)
  "Set the SECTION to the VALUE in this MLIST.

Checks that MLIST is an mlist, and that SECTION is a valid mis section first;
returns `:mis/error' if not.
"
  (let ((mlist (-m//mlist/ensure.section section mlist)))
    (if (or (not (-m//mlist/valid? mlist))
            (not (-m//mlist/valid.section? section)))
        ;; Return error value because we don't have valid inputs.
        :mis/error

      ;; Valid section and list; insert value.
      (plist-put mlist section value))))



;;------------------------------------------------------------------------------
;; Sections
;;------------------------------------------------------------------------------

(defun -m//section/get (key section mlist valid-keys &optional default)
  "Get KEY's value from this mlist's SECTION.

Checks that MLIST is an mlist, and that KEY is a valid mis key (using
VALID-KEYS) first; returns `:mis/error' if not.

If MLIST has no SECTION, returns DEFAULT.

If MLIST's SECTION has no KEY, returns DEFAULT.
"
  (if (-m//input/invalid? key valid-keys)
      :mis/error

    ;; Get key from the section mlist.
    (-m//mlist/get.value key
                         ;; Get section from base mlist.
                         (-m//mlist/get.section section
                                                (-m//mlist/ensure.section section mlist))
                         default)))
;; (-m//mlist/get.section :string (-m//mlist/ensure.section :string nil))
;; (-m//mlist/get.section :string nil)


;; TODO: macro for: (setq x (-m//section/set key value x))
(defun -m//section/set (key value section mlist valid-keys)
  "Set a value for KEY in this MLIST's SECTION.
"
  (let ((mlist (-m//mlist/ensure.section section mlist)))
    (if (-m//input/invalid? key valid-keys)
        :mis/error

      (if-let* ((m-section (-m//mlist/get.section section mlist))
                (result (-m//mlist/set.value key value m-section)))
          (if (-m//return/invalid? (list m-section result))
              ;; Error out; couldn't get style or set value or something...
              :mis/error

            ;; Ok; Set the style section in the base mlist.
            (-m//mlist/set.section section
                                   result
                                   mlist))

        ;; No section found or result from set value?
        :mis/error))))
;; (-m//section/set :trim t :string nil '(:trim :string))


;;------------------------------------------------------------------------------
;; Multiple mlists
;;------------------------------------------------------------------------------

(defun -m//mlists/get.all (key section mlists valid-keys)
  "Looks through the list of MLISTS for a KEY in SECTION.

Returns list of nil(s) if no KEY or SECTION found.
"
  (let ((results nil)
        (value nil))
    ;; Check all mlists, saving any values we find for the section & key.
    (dolist (mlist mlists)
      (setq value (-m//section/get key section mlist valid-keys))
      (unless (-m//return/invalid? value)
        (push value results)))

    ;; Return `results', be it nil or actually filled with some value(s).
    results))
;; (-m//mlists/get.all :padding :style '((:mis t :string (:mis :string :trim t))) '(:padding :width))
;; (-m//mlists/get.all :trim :string '(:mis t :string (:mis :string :trim :mis/nil)) '(:trim :string))


(defun -m//mlists/get.first (key section mlists valid-keys &optional default)
  "Get first match for KEY in SECTION in MLISTS.

Returns first match if there are matches found.
Returns DEFAULT if no matches and default is not nil.
Else returns `:mis/error'.
"
  (-let* ((results (-m//mlists/get.all key section mlists valid-keys))
          (first (nth 0 results)))
    ;; Leave `:mis/nil' default alone - the caller wants to know the difference
    ;; between "nothing found" and "nil found".
    (cond ((and (eq default :mis/nil)
                (null first))
           ;; Yeah, this case is the same, logically, as the next "return
           ;; default when no result", but leave this for its explicitness.
           :mis/nil)

          ;; If no first result and default requested, give back the default.
          ((and default
                (null first))
           default)

          ;; Otherwise give back first result or just nil.
          ((not (null first))
           first)

          (t
           :mis/error))))
;; (-m//mlists/get.first :padding :style '((:mis t :string (:mis :string :trim t))) '(:padding :width) :mis/nil)
;; These should return `:mis/nil'...
;; (-m//mlists/get.first :trim :string '((:mis t :string (:mis :string :trim :mis/nil))) '(:trim :string) nil)
;; (-m//mlists/get.first :trim :string '((:mis t :string (:mis :string :trim :mis/nil))) '(:trim :string) t)
;; This should return the default " "
;; (-m//mlists/get.first :padding :style '((:mis t :string (:mis :string :trim :mis/nil))) '(:padding :width) " ")


;;------------------------------------------------------------------------------
;; The End.
;;------------------------------------------------------------------------------
(-m//provide 'internal 'mlist)
