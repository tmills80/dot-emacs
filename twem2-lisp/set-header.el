;;; set-header.el --- Set the window header -*- lexical-binding: t; -*-
(require 'project)

(defvar show-header nil
  "Show the header if no other header is set")

(setq show--header nil)
(setq set--header-set nil)

;; all horribly specific
;; TODO customize somehow
(defun set--header ()
  (message (format "set-header %s %s %s" show--header set--header-set header-line-format))
  (cond ((and show--header (not set--header-set))
      (progn (setq header-line-format
		   `(
		     ,(propertize "Project: " 'face 'bold)
		     ,(project-name (project-current))))
	     (setq set--header-set 't)
	     (message (format "%s" set--header-set))))
	((not show--header)
	 (progn (setq header-line-format nil)
		(setq set--header-set nil)
		(message "unsetting header line")))))



;; logic required
;;    if we want to show the header
;;      and if there is a current project
;;   check if there is a header, and the header is not ours -> don't set the header
;;   else if there is a header,

(defun enable-header ()
  "set, or unset the header"
  (interactive)
  (if (and show-header
	   (project-current)
	   (derived-mode-p 'prog-mode)
	   )
      (setq show--header 't)
    (setq show--header nil))
  (set--header))

(setq show-header 't)

(add-hook 'buffer-list-update-hook 'enable-header)

(provide 'set-header)
