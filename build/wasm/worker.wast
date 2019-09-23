(module
 (type $FUNCSIG$vi (func (param i32)))
 (type $FUNCSIG$iii (func (param i32 i32) (result i32)))
 (import "env" "memory" (memory $memory 256 256 shared))
 (import "env" "_noop" (func $_noop (param i32)))
 (import "env" "_randomBetween" (func $_randomBetween (param i32 i32) (result i32)))
 (global $STACKTOP (mut i32) (i32.const 6112))
 ;; Taken from https://github.com/WebAssembly/threads/blob/master/proposals/threads/Overview.md
;; Try to lock a mutex at the given address.
;; Returns 1 if the mutex was successfully locked, and 0 otherwise.
(func $_tryLockMutex (param $mutexAddr i32) (result i32)
  ;; Attempt to grab the mutex. The cmpxchg operation atomically
  ;; does the following:
  ;; - Loads the value at $mutexAddr.
  ;; - If it is 0 (unlocked), set it to 1 (locked).
  ;; - Return the originally loaded value.
  (i32.atomic.rmw.cmpxchg
    (local.get $mutexAddr) ;; mutex address
    (i32.const 0)          ;; expected value (0 => unlocked)
    (i32.const 1))         ;; replacement value (1 => locked)

  ;; The top of the stack is the originally loaded value.
  ;; If it is 0, this means we acquired the mutex. We want to
  ;; return the inverse (1 means mutex acquired), so use i32.eqz
  ;; as a logical not.
  (i32.eqz)
)

;; Lock a mutex at the given address, retrying until successful.
(func $__ZNSt3__25mutex4lockEv (param $mutexAddr i32)
  (block $done
    (loop $retry
      ;; Try to lock the mutex. $tryLockMutex returns 1 if the mutex
      ;; was locked, and 0 otherwise.
      (call $_tryLockMutex (local.get $mutexAddr))
      (br_if $done)

      ;; Wait for the other agent to finish with mutex.
      (i32.atomic.wait
        (local.get $mutexAddr) ;; mutex address
        (i32.const 1)          ;; expected value (1 => locked)
        (i64.const -1))        ;; infinite timeout

      ;; i32.atomic.wait returns:
      ;;   0 => "ok", woken by another agent.
      ;;   1 => "not-equal", loaded value != expected value
      ;;   2 => "timed-out", the timeout expired
      ;;
      ;; Since there is an infinite timeout, only 0 or 1 will be returned. In
      ;; either case we should try to acquire the mutex again, so we can
      ;; ignore the result.
      (drop)

      ;; Try to acquire the lock again.
      (br $retry)
    )
  )
)

;; Unlock a mutex at the given address.
(func $__ZNSt3__25mutex6unlockEv (param $mutexAddr i32)
  ;; Unlock the mutex.
  (i32.atomic.store
    (local.get $mutexAddr)     ;; mutex address
    (i32.const 0))             ;; 0 => unlocked

  ;; Notify one agent that is waiting on this lock.
  (drop
    (atomic.notify
      (local.get $mutexAddr)   ;; mutex address
      (i32.const 1)))          ;; notify 1 waiter
)
 (export "_colorCells" (func $_colorCells))
 (func $_colorCells (; 4 ;) (; has Stack IR ;) (param $0 i32) (param $1 i32) (result i32)
  (local $2 i32)
  (local $3 i32)
  (local $4 i32)
  (local $5 i32)
  (local $6 i32)
  (local $7 i32)
  (local $8 i32)
  (local $9 i32)
  (local $10 i32)
  (local $11 i32)
  (local $12 i32)
  (local $13 i32)
  (local $14 i32)
  (local.set $2
   (global.get $STACKTOP)
  )
  (global.set $STACKTOP
   (i32.add
    (global.get $STACKTOP)
    (i32.const 4000)
   )
  )
  (local.set $6
   (local.get $2)
  )
  (local.set $2
   (call $_randomBetween
    (i32.const 1)
    (i32.const 256)
   )
  )
  (local.set $5
   (call $_randomBetween
    (i32.const 1)
    (i32.const 256)
   )
  )
  (local.set $3
   (call $_randomBetween
    (i32.const 1)
    (i32.const 256)
   )
  )
  (if
   (i32.eqz
    (local.tee $4
     (i32.gt_s
      (local.get $1)
      (i32.const 0)
     )
    )
   )
   (block
    (global.set $STACKTOP
     (local.get $6)
    )
    (return
     (i32.const 0)
    )
   )
  )
  (local.set $9
   (i32.mul
    (local.get $0)
    (local.get $1)
   )
  )
  (local.set $0
   (i32.const 0)
  )
  (loop $while-in
   (i32.store
    (i32.add
     (i32.shl
      (i32.add
       (local.get $0)
       (local.get $9)
      )
      (i32.const 2)
     )
     (local.get $6)
    )
    (local.get $0)
   )
   (br_if $while-in
    (i32.ne
     (local.tee $0
      (i32.add
       (local.get $0)
       (i32.const 1)
      )
     )
     (local.get $1)
    )
   )
  )
  (if
   (i32.eqz
    (local.get $4)
   )
   (block
    (global.set $STACKTOP
     (local.get $6)
    )
    (return
     (i32.const 0)
    )
   )
  )
  (local.set $12
   (i32.add
    (local.get $3)
    (i32.shl
     (i32.add
      (local.get $5)
      (i32.shl
       (local.get $2)
       (i32.const 8)
      )
     )
     (i32.const 8)
    )
   )
  )
  (local.set $2
   (local.get $1)
  )
  (local.set $5
   (i32.const 0)
  )
  (loop $while-in1
   (if
    (i32.eqz
     (call $_randomBetween
      (i32.const 0)
      (i32.const 2)
     )
    )
    (block
     (if
      (i32.gt_s
       (local.tee $10
        (call $_randomBetween
         (i32.const 20)
         (i32.const 40)
        )
       )
       (i32.const 1)
      )
      (block
       (local.set $7
        (i32.const 0)
       )
       (loop $while-in3
        (local.set $8
         (i32.const 0)
        )
        (loop $while-in5
         (local.set $0
          (i32.const 1)
         )
         (local.set $1
          (i32.const 1)
         )
         (local.set $3
          (local.get $10)
         )
         (loop $while-in7
          (local.set $11
           (i32.add
            (local.get $3)
            (i32.const -1)
           )
          )
          (local.set $4
           (i32.add
            (local.get $0)
            (local.get $1)
           )
          )
          (if
           (i32.gt_s
            (local.get $3)
            (i32.const 2)
           )
           (block
            (local.set $1
             (local.get $0)
            )
            (local.set $0
             (local.get $4)
            )
            (local.set $3
             (local.get $11)
            )
            (br $while-in7)
           )
          )
         )
         (br_if $while-in5
          (i32.ne
           (local.tee $8
            (i32.add
             (local.get $8)
             (i32.const 1)
            )
           )
           (i32.const 1000)
          )
         )
        )
        (br_if $while-in3
         (i32.ne
          (local.tee $7
           (i32.add
            (local.get $7)
            (i32.const 1)
           )
          )
          (i32.const 3000)
         )
        )
       )
      )
      (local.set $4
       (i32.const 1)
      )
     )
     (call $_noop
      (local.get $4)
     )
    )
   )
   (local.set $0
    (i32.load
     (local.tee $14
      (i32.add
       (i32.shl
        (i32.add
         (local.get $9)
         (local.tee $13
          (call $_randomBetween
           (i32.const 0)
           (local.get $2)
          )
         )
        )
        (i32.const 2)
       )
       (local.get $6)
      )
     )
    )
   )
   (call $__ZNSt3__25mutex4lockEv
    (i32.const 5024)
   )
   (local.set $0
    (if (result i32)
     (i32.load
      (local.tee $0
       (i32.add
        (i32.shl
         (local.get $0)
         (i32.const 2)
        )
        (i32.const 1024)
       )
      )
     )
     (block (result i32)
      (call $__ZNSt3__25mutex6unlockEv
       (i32.const 5024)
      )
      (local.get $5)
     )
     (block (result i32)
      (i32.store
       (local.get $0)
       (local.get $12)
      )
      (call $__ZNSt3__25mutex6unlockEv
       (i32.const 5024)
      )
      (if
       (i32.eqz
        (call $_randomBetween
         (i32.const 0)
         (i32.const 2)
        )
       )
       (block
        (if
         (i32.gt_s
          (local.tee $10
           (call $_randomBetween
            (i32.const 20)
            (i32.const 40)
           )
          )
          (i32.const 1)
         )
         (block
          (local.set $7
           (i32.const 0)
          )
          (loop $while-in9
           (local.set $8
            (i32.const 0)
           )
           (loop $while-in11
            (local.set $0
             (i32.const 1)
            )
            (local.set $1
             (i32.const 1)
            )
            (local.set $3
             (local.get $10)
            )
            (loop $while-in13
             (local.set $11
              (i32.add
               (local.get $3)
               (i32.const -1)
              )
             )
             (local.set $4
              (i32.add
               (local.get $0)
               (local.get $1)
              )
             )
             (if
              (i32.gt_s
               (local.get $3)
               (i32.const 2)
              )
              (block
               (local.set $1
                (local.get $0)
               )
               (local.set $0
                (local.get $4)
               )
               (local.set $3
                (local.get $11)
               )
               (br $while-in13)
              )
             )
            )
            (br_if $while-in11
             (i32.ne
              (local.tee $8
               (i32.add
                (local.get $8)
                (i32.const 1)
               )
              )
              (i32.const 1000)
             )
            )
           )
           (br_if $while-in9
            (i32.ne
             (local.tee $7
              (i32.add
               (local.get $7)
               (i32.const 1)
              )
             )
             (i32.const 3000)
            )
           )
          )
         )
         (local.set $4
          (i32.const 1)
         )
        )
        (call $_noop
         (local.get $4)
        )
       )
      )
      (i32.add
       (local.get $5)
       (i32.const 1)
      )
     )
    )
   )
   (local.set $5
    (i32.add
     (i32.shl
      (i32.add
       (local.get $9)
       (local.tee $1
        (i32.add
         (local.get $2)
         (i32.const -1)
        )
       )
      )
      (i32.const 2)
     )
     (local.get $6)
    )
   )
   (if
    (i32.lt_s
     (i32.add
      (local.get $13)
      (i32.const 1)
     )
     (local.get $2)
    )
    (i32.store
     (local.get $14)
     (i32.load
      (local.get $5)
     )
    )
   )
   (i32.store
    (local.get $5)
    (i32.const -1)
   )
   (if
    (i32.gt_s
     (local.get $2)
     (i32.const 1)
    )
    (block
     (local.set $2
      (local.get $1)
     )
     (local.set $5
      (local.get $0)
     )
     (br $while-in1)
    )
   )
  )
  (global.set $STACKTOP
   (local.get $6)
  )
  (local.get $0)
 )
)
