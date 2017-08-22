#|
  This file is a part of clbatis-caveman2 project.
  Copyright (c) 2017 tamura shingo (tamura.shingo@gmail.com)
|#

(in-package :cl-user)
(defpackage clbatis-caveman2-test-asd
  (:use :cl :asdf))
(in-package :clbatis-caveman2-test-asd)

(defsystem clbatis-caveman2-test
  :author "tamura shingo"
  :license "MIT"
  :depends-on (:clbatis-caveman2
               :prove)
  :components ((:module "t"
                :components
                ((:test-file "clbatis-caveman2"))))
  :description "Test system for clbatis-caveman2"

  :defsystem-depends-on (:prove-asdf)
  :perform (test-op :after (op c)
                    (funcall (intern #.(string :run-test-system) :prove-asdf) c)
                    (asdf:clear-system c)))
