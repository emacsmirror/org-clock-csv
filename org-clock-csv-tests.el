;; -*- lexical-binding: t -*-

(require 'org-clock-csv)

;;; Helper Code:

(defun org-clock-csv-should-match (input output)
  "Test that clock entries in INPUT match the .csv OUTPUT file."
  (let* ((entries (with-temp-buffer
                    (insert-file-contents input)
                    (org-mode)
                    (org-element-map (org-element-parse-buffer) 'clock
                      #'org-clock-csv--parse-element nil nil)))
         (in (with-temp-buffer
               (insert org-clock-csv-header "\n")
               (mapc (lambda (entry)
                       (insert (concat (funcall org-clock-csv-row-fmt entry) "\n")))
                     entries)
               (buffer-string)))
         (out (with-temp-buffer
                (insert-file-contents output)
                (buffer-string))))
    (should (equal in out))))

(defvar org-clock-csv-header-all-props
  "task,headline,parents,category,start,end,duration,effort,ishabit,tags")

(defun org-clock-csv-all-props-row-fmt (plist)
  "Formatting function including all properties."
  (mapconcat #'identity
             (list (org-clock-csv--escape (plist-get plist ':task))
                   (org-clock-csv--escape
                    (org-element-property :raw-value (plist-get plist ':headline)))
                   (org-clock-csv--escape
                    (s-join org-clock-csv-headline-separator
                            (plist-get plist ':parents)))
                   (org-clock-csv--escape (plist-get plist ':category))
                   (plist-get plist ':start)
                   (plist-get plist ':end)
                   (plist-get plist ':duration)
                   (plist-get plist ':effort)
                   (plist-get plist ':ishabit)
                   (plist-get plist ':tags))
             ","))

;;; Tests:

(ert-deftest test-sample ()
  "Docs."
  (org-clock-csv-should-match "tests/sample.org" "tests/sample.csv"))

(ert-deftest test-all-props ()
  "Test all available properties."
  (let ((org-clock-csv-header org-clock-csv-header-all-props)
        (org-clock-csv-row-fmt #'org-clock-csv-all-props-row-fmt))
    (org-clock-csv-should-match "tests/sample.org" "tests/all-props.csv")))

(ert-deftest test-issue-2 ()
  "Test tasks with commas in them, as in issue #2."
  (org-clock-csv-should-match "tests/issue-2.org" "tests/issue-2.csv"))

(ert-deftest test-issue-3 ()
  "Test tasks with headline ancestors, as in issue #3."
  (org-clock-csv-should-match "tests/issue-3.org" "tests/issue-3.csv"))

;; Local Variables:
;; coding: utf-8
;; End:

;;; org-clock-csv-tests.el ends here
