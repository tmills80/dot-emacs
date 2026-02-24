(defun custom/find-test (file)
  "Try to find a test for the current file"
  (interactive (custom--find-test-file))
  ;; main body - open the file and switch to it
  ;; in a new buffer if necessary
  (when file
    (pop-to-buffer
     (find-file-noselect file))))

(defun custom--find-test-file ()
  ;; Returns a single item list with the filename or nil
   (let* ((leaf (file-name-sans-extension (file-name-nondirectory (buffer-file-name))))
	  (files (project-files (project-current)))
	  (regexp (rx (not "#")
		      (literal leaf)
		      anything
		     "test"
		     ))
	  (candidates (seq-filter
		       (lambda (x) (string-match regexp x))
		       files)))
     ;; if there's more than one option use completing-read to provide a list
     (if candidates
	 (if (length> candidates 1)
	     `(,(completing-read "Test files: " candidates))
	   candidates)
       '(nil))))

(defun custom--ts-test-file-name (file-name)
  "infer the typescript test file from the given filename including path"
  (let* ((test-file-name (concat (file-name-base file-name) ".test.ts"))
	 (file-directory (file-name-split (file-name-directory file-name)))
	 (src-location (seq-position file-directory "src"))
 	 (split (seq-split file-directory (1+ src-location)))
	 (test-path (string-join (append (nth 0 split) '("__tests__") (nth 1 split)) "/")))
    (concat test-path test-file-name)))

(custom--ts-test-file-name "/Users/tristan/src/bar/foo.ts")

(defun custom/create-ts-test (file)
  "Try to create a test for a typescript file"
  (interactive `(,(buffer-file-name)))
  (let ((file-name  (custom--ts-test-file-name file)))
    (progn
      (make-empty-file file-name 't)
      (pop-to-buffer file-name))))
  ;; (progn (make-empty-file file 't)
  ;; 	 (pop-to-buffer
  ;;    (find-file-noselect file))))
