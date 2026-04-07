;;; twem2-scratch.el --- Create scratch buffers in any mode -*- lexical-binding: t -*-

(defvar twem2-scratch-modes
  '(org-mode emacs-lisp-mode markdown-mode text-mode
    python-ts-mode json-ts-mode typescript-ts-mode)
  "List of modes offered when `twem2-scratch' is called interactively.
With a prefix argument, all `text-mode' and `prog-mode' derivatives are offered instead.")

(defun twem2--scratch-all-modes ()
  "Return all modes derived from `text-mode' or `prog-mode'."
  (let (modes)
    (mapatoms
     (lambda (sym)
       (when (and (functionp sym)
                  (provided-mode-derived-p sym 'text-mode 'prog-mode))
         (push sym modes))))
    (sort modes (lambda (a b) (string< (symbol-name a) (symbol-name b))))))

(defun twem2--scratch-mode-name (mode)
  "Derive a short name from MODE symbol by stripping the -mode suffix."
  (let ((name (symbol-name mode)))
    (if (string-suffix-p "-mode" name)
        (substring name 0 (- (length name) 5))
      name)))

(defun twem2--scratch-read-mode (all)
  "Prompt for a mode using `completing-read'.
When ALL is non-nil, offer all valid modes instead of `twem2-scratch-modes'."
  (intern
   (completing-read "Mode: "
                    (mapcar #'symbol-name
                            (if all
                                (twem2--scratch-all-modes)
                              twem2-scratch-modes))
                    nil t)))

(defun twem2--scratch-find-buffer (mode)
  "Find an existing scratch buffer in MODE, or nil if none exists."
  (let ((prefix (concat "*scratch-" (twem2--scratch-mode-name mode))))
    (seq-find (lambda (buf)
                (with-current-buffer buf
                  (and (string-prefix-p prefix (buffer-name buf))
                       (derived-mode-p mode))))
              (buffer-list))))

(defun twem2--scratch-create-buffer (mode)
  "Create a new scratch buffer in MODE and return it."
  (unless (provided-mode-derived-p mode 'text-mode 'prog-mode)
    (user-error "Mode %s is not derived from text-mode or prog-mode" mode))
  (let* ((base (concat "*scratch-" (twem2--scratch-mode-name mode)))
         (n 0)
         bufname)
    (catch 'done
      (while t
        (setq bufname (concat base
                              (if (= n 0) "" (int-to-string n))
                              "*"))
        (setq n (1+ n))
        (when (not (get-buffer bufname))
          (let ((buffer (get-buffer-create bufname)))
            (with-current-buffer buffer
              (funcall mode))
            (throw 'done buffer)))))))

(defun twem2-scratch (&optional mode)
  "Switch to an existing scratch buffer in MODE, or create one.
MODE defaults to `org-mode'.  When called interactively, prompt
for a mode from `twem2-scratch-modes'.  With a prefix argument,
offer all modes derived from `text-mode' or `prog-mode'."
  (interactive (list (twem2--scratch-read-mode current-prefix-arg)))
  (let* ((mode (or mode 'org-mode))
         (buffer (or (twem2--scratch-find-buffer mode)
                     (twem2--scratch-create-buffer mode))))
    (display-buffer buffer t)))

(defun twem2-scratch-new (&optional mode)
  "Create a new scratch buffer in MODE.
MODE defaults to `org-mode'.  When called interactively, prompt
for a mode from `twem2-scratch-modes'.  With a prefix argument,
offer all modes derived from `text-mode' or `prog-mode'."
  (interactive (list (twem2--scratch-read-mode current-prefix-arg)))
  (let* ((mode (or mode 'org-mode))
         (buffer (twem2--scratch-create-buffer mode)))
    (display-buffer buffer t)))

(defun twem2-scratch-org ()
  "Switch to an org scratch buffer, or create one.
With a prefix argument, always create a new buffer."
  (interactive)
  (if current-prefix-arg
      (twem2-scratch-new 'org-mode)
    (twem2-scratch 'org-mode)))

(defun twem2-scratch-elisp ()
  "Switch to an elisp scratch buffer, or create one.
With a prefix argument, always create a new buffer."
  (interactive)
  (if current-prefix-arg
      (twem2-scratch-new 'emacs-lisp-mode)
    (twem2-scratch 'emacs-lisp-mode)))

(provide 'twem2-scratch)
;;; twem2-scratch.el ends here
