;;; -*- lexical-binding: t -*-

;; Copyright (C) 2025 Tristan Mills

;; Author: Tristan Mills <tristan@eridu.org.uk>
;; Version: 0.1

;; This file is not part of GNU Emacs

;; functions to guess the test and run it using compile

(defvar twem2/last-test nil)

(defun twem2/get-test-file (&optional use-last)
  "Guess the test name from the buffername.
Only works for typescript projects, and assumes the buffername is the filename
ues-last will return the last test run."
  (if (and use-last twem2/last-test)
      twem2/last-test
    (let ((file (apply 'file-name-concat (last (file-name-split (buffer-file-name)) 2))))
    (if (string-search ".test." file)
	 file
      (concat (car (split-string file ".ts")) ".test.ts")))))

(defun run-test (run-last)
  "Run the test associated with the current file.

With a prefix argument this will run the last test.
Currently this requires the selected buffer to be associated with the current project."
  (interactive "P")
  (let* ((test-file (twem2/get-test-file run-last))
	 (compile-command (format "task run-tests -- %s" (shell-quote-argument test-file))))
    (progn
      (call-interactively (compile compile-command))
      (setq twem2/last-test test-file))))

(provide 'twem2-run-test)
