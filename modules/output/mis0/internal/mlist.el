;;; mis0/args/+mlist.el -*- lexical-binding: t; -*-

;; General Layout of a Mis0List (mlist):
;;
;; It is a recursive plist.
;;
;; Example:
;;    '(:mis0 :root
;;      :style (...)
;;      :content (
;;          :string "Hello "
;;          :complex (:mis0 :something
;;                    :style (...)
;;                    :string "there")
;;          :string "."
;;      )
;;    )

(-m//require 'internal 'const)
(-m//require 'internal 'valid)

;;------------------------------------------------------------------------------
;; Constants
;;------------------------------------------------------------------------------

(defconst -m//sections
  '(:mis0
    :style
    :string)
  "Valid mis0 section keywords for mlists."
  )


;;------------------------------------------------------------------------------
;; mlist validity
;;------------------------------------------------------------------------------

(defun -m//mlist/valid? (mlist)
  "Returns t if MLIST is a mis0-plist (aka 'mlist'), else nil.
"
  ;; `mlist' exists and has a `:mis0' key? Good enough.
  (and (not (null mlist))
       (listp mlist)
       (not (null (plist-member mlist :mis0)))))


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
If MLIST is something, but is not a valid mlist, returns `:mis0/error'.
"
  ;; Return a basic mlist if given nil.
  (cond ((eq mlist nil)
         (list :mis0 (or type t)))

        ;; Return the input if it's already a valid list.
        ((-m//mlist/valid? mlist)
         mlist)

        ;; Otherwise error.
        (t
         :mis0/error)))
;; (-m//mlist/ensure nil)
;; (-m//mlist/ensure nil 'jeff)


(defun -m//mlist/ensure.section (section mlist &optional type)
  "Creates and returns an empty mlist with an empty SECTION if MLIST doesn't
exist already. If MLIST is a valid mlist, ensures that SECTION exists (creates
empty one if necessary). If MLIST is something, but is not a valid mlist,
returns `:mis0/error'.
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
          ((eq mlist :mis0/error)
           :mis0/error)
          (t
           :mis0/error))))


(defun -m//mlist/get.value (key mlist &optional default)
  "Get a value from this MLIST based on KEY.

Checks that MLIST is an mlist, and that KEY is a valid mis0 key first;
returns `:mis0/error' if not.

Tries to get KEY value from MLIST next; returns DEFAULT if unable.
"
  (if (or (not (-m//mlist/valid? mlist))
          (not (-m//mlist/valid.key? key)))
      ;; Return error value because we don't have valid inputs.
      :mis0/error

    ;; Valid inputs! Get or default.
    (or (plist-get mlist key)
        default)))


(defun -m//mlist/set.value (key value mlist)
  "Set a value in this mlist.

Checks that MLIST is an mlist, and that KEY is a valid mis0 key first;
returns `:mis0/error' if not.
"
  (if (or (not (-m//mlist/valid? mlist))
          (not (-m//mlist/valid.key? key)))
      ;; Return error value because we don't have valid inputs.
      :mis0/error

    ;; Valid key and list; insert value.
    (plist-put mlist key value)))


(defun -m//mlist/get.section (section mlist &optional default)
  "Get a section from this MLIST based on SECTION.

Checks that MLIST is an mlist, and that SECTION is a valid mis0 section first;
returns `:mis0/error' if not.

Tries to get SECTION value from MLIST next; returns DEFAULT if unable.
"
  (if (or (not (-m//mlist/valid? mlist))
          (not (-m//mlist/valid.section? section)))
      ;; Return error value because we don't have valid inputs.
      :mis0/error

    ;; Valid inputs! Get or default.
    (-m//mlist/get.value section mlist default)))


(defun -m//mlist/set.section (section value mlist)
  "Set the SECTION to the VALUE in this MLIST.

Checks that MLIST is an mlist, and that SECTION is a valid mis0 section first;
returns `:mis0/error' if not.
"
  (let ((mlist (-m//mlist/ensure.section section mlist)))
    (if (or (not (-m//mlist/valid? mlist))
            (not (-m//mlist/valid.section? section)))
        ;; Return error value because we don't have valid inputs.
        :mis0/error

      ;; Valid section and list; insert value.
      (plist-put mlist section value))))



;;------------------------------------------------------------------------------
;; Sections
;;------------------------------------------------------------------------------

(defun -m//section/get (key section mlist valid-keys &optional default)
  "Get KEY's value from this mlist's SECTION.

Checks that MLIST is an mlist, and that KEY is a valid mis0 key (using
VALID-KEYS) first; returns `:mis0/error' if not.

If MLIST has no SECTION, returns DEFAULT.

If MLIST's SECTION has no KEY, returns DEFAULT.
"
  (if (-m//input/invalid? key valid-keys)
      :mis0/error

    ;; Get key from the section mlist.
    (-m//mlist/get.value key
                         ;; Get section from base mlist.
                         (-m//mlist/get.section section
                                                (-m//mlist/ensure.section section mlist))
                         default)))
;; (-m//mlist/get.section :string (-m//mlist/ensure.section :string nil))
;; (-m//mlist/get.section :string nil)
;; (-m//section/get :string :string (mis0/string/trim t) '(:string :trim :indent :align))
;; (-m//section/get :string :string (mis0/string/string "  testing     ") '(:string :trim :indent :align))


;; TODO: macro for: (setq x (-m//section/set key value x))
(defun -m//section/set (key value section mlist valid-keys)
  "Set a value for KEY in this MLIST's SECTION.
"
 (let ((mlist (-m//mlist/ensure.section section mlist)))
    (if (-m//input/invalid? key valid-keys)
        :mis0/error

      (if-let* ((m-section (-m//mlist/get.section section mlist))
                (result (-m//mlist/set.value key value m-section)))
          (if (-m//return/invalid? (list m-section result))
              ;; Error out; couldn't get style or set value or something...
              :mis0/error

            ;; Ok; Set the style section in the base mlist.
            (-m//mlist/set.section section
                                   result
                                   mlist))

        ;; No section found or result from set value?
        :mis0/error))))
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
      (setq value (-m//section/get key section mlist valid-keys :mis0/nil))
      (unless (-m//return/invalid? value '(:mis0/nil))
        (push value results)))

    ;; Return `results', be it nil or actually filled with some value(s).
    results))
;; (-m//mlists/get.all :padding :style '((:mis0 t :string '((:mis0 :string :trim t)))) '(:padding :width))
;; (-m//mlists/get.all :trim :string '((:mis0 t :string (:mis0 :string :trim :mis0/nil))) '(:trim :string))
;; (-m//mlists/get.all :indent :string (list (mis0/string/string nil) (mis0/string/indent 'existing)) '(:trim :string :indent))
;; (-m//mlists/get.all :string :string (list (mis0/string/string "  testing     ") (mis0/string/trim t)) '(:string :trim :indent :align))


(defun -m//mlists/get.first (key section mlists valid-keys &optional default)
  "Get first match for KEY in SECTION in MLISTS.

Returns first match if there are matches found.
Returns DEFAULT if no matches and default is not nil.
Else returns `:mis0/error'.
"
  (when (-m//input/invalid? key valid-keys)
    ;; TODO: Would be nice to have more info than just `:mis0/error'.
    :mis0/error)

  (-let* ((results (-m//mlists/get.all key section mlists valid-keys))
          (first (nth 0 results)))
    ;; Leave `:mis0/nil' default alone - the caller wants to know the difference
    ;; between "nothing found" and "nil found".
    (cond ((and (eq default :mis0/nil)
                (null first))
           ;; Yeah, this case is the same, logically, as the next "return
           ;; default when no result", but leave this for its explicitness.
           :mis0/nil)

          ;; If no first result and default requested, give back the default.
          ((and default
                (null first))
           default)

          ;; Otherwise give back first result or just nil.
          ((not (null first))
           first)

          (t
           :mis0/error))))
;; (-m//mlists/get.first :padding :style '((:mis0 t :string (:mis0 :string :trim t))) '(:padding :width) :mis0/nil)
;; These should return `:mis0/nil'...
;; (-m//mlists/get.first :trim :string '((:mis0 t :string (:mis0 :string :trim :mis0/nil))) '(:trim :string) nil)
;; (-m//mlists/get.first :trim :string '((:mis0 t :string (:mis0 :string :trim :mis0/nil))) '(:trim :string) t)
;; This should return the default " "
;; (-m//mlists/get.first :padding :style '((:mis0 t :string (:mis0 :string :trim :mis0/nil))) '(:padding :width) " ")
;; This should return 'existing
;; (-m//mlists/get.first :indent :string (list (mis0/string/string nil) (mis0/string/indent 'existing)) '(:trim :string :indent))
;; I want the string...
;; (-m//mlists/get.first :string :string (list (mis0/string/string "  testing     ") (mis0/string/trim t)) '(:string :trim :indent :align))


;;------------------------------------------------------------------------------
;; The End.
;;------------------------------------------------------------------------------
(-m//provide 'internal 'mlist)
