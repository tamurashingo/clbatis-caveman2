(in-package :cl-user)
(defpackage clbatis-caveman2-test
  (:use :cl
        :clbatis-caveman2
        :cl-batis
        :prove))
(in-package :clbatis-caveman2-test)

(cl-syntax:use-syntax :annot)

;; ----------------------------------------
;; DEFINE SQL
;; ----------------------------------------
@select
(" select
     *
   from
     product "
 (sql-where
  " id = :id "))
(defsql search-product (id))

@update
(" update
     product "
 (sql-set
  (sql-cond (not (null name))
            " name = :name, ")
  (sql-cond (not (null price))
            " price = :price "))
 (sql-where
  " id = :id "))
(defsql update-product (id name price))

@update
(" insert into
     product
   (
     id,
     name,
     price
   )
   values (
     :id,
     :name,
     :price
   ) ")
(defsql register-product (id name price))


(plan nil)

;; ----------------------------------------
;; Set Up
;; ----------------------------------------
(initialize-database :mysql
                     :database-name "batiscaveman2"
                     :username "nobody"
                     :password "nobody"
                     :initial-size 10
                     :max-size 30)

(transaction-manager (db)
  (do-sql db "drop table if exists product")
  (do-sql db "create table product (id integer primary key, name varchar(20) not null, price integer not null)"))


;; ----------------------------------------
;; TEST
;; ----------------------------------------
(subtest "transactional macro"
  (is (transactional (db)
        (update-one db register-product :id 1 :name "NES" :price 14800)
        (select-one db search-product :id 1))
      '(:|id| 1 :|name| "NES" :|price| 14800)
      "updated by transactional macro")

  (is (transactional (db)
        (select-one db search-product :id 1))
      '(:|id| 1 :|name| "NES" :|price| 14800)
      "commited automatically by transactional macro"))

(subtest "transaction-manager macro"
  (is (transaction-manager (db)
        (update-one db update-product :id 1 :name "Famicom")
        (select-one db search-product :id 1))
      '(:|id| 1 :|name| "Famicom" :|price| 14800)
      "updated by transaction-manager macro")

  (is (transaction-manager (db)
        (select-one db search-product :id 1))
      '(:|id| 1 :|name| "NES" :|price| 14800)
      "not commited automatically by transaction-manager macro")

  (transaction-manager (db)
    (update-one db register-product :id 2 :name "Game Boy" :price 12500)
    (commit db))

  (is (transaction-manager (db)
        (select-one db search-product :id 2))
      '(:|id| 2 :|name| "Game Boy" :|price| 12500)
      "make sure that commit in transaction-manager"))

(subtest "error case"
  (handler-case
      (transaction-manager (db)
        (do-sql db "insert into product")
        (fail "transaction-manager: expect error but not occurred"))
    (error (e)
      (pass (format NIL "transaction-manager:expect erorr:~A" e))))


  (handler-case
      (transactional (db)
        (do-sql db "insert into product")
        (fail "transactional: expect error but not occurred"))
    (error (e)
      (pass (format NIL "transactional: expect error:~A" e)))))

(subtest "error case (rollback automatically)"
  (handler-case
      (transactional (db)
        (update-one db update-product :id 1 :name "OriginalConsole" :price 4500)

        (is (select-one db search-product :id 1)
            '(:|id| 1 :|name| "OriginalConsole" :|price| 4500)
            "update ok")

        ; error SQL
        (do-sql db "insert into product")
        (fail "not reached"))
    (error (e)
      (declare (ignore e))
      (is (transactional (db)
            (select-one db search-product :id 1))
          '(:|id| 1 :|name| "NES" :|price| 14800)
          "rollback automatically"))))


;; ----------------------------------------
;; Tear Down
;; ----------------------------------------
(finalize-database)

(finalize)
