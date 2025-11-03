;; Global Tutor Registry Smart Contract
;; Decentralized tutor identity and verification system

(define-constant CONTRACT-OWNER tx-sender)
(define-constant ERR-NOT-AUTHORIZED (err u100))
(define-constant ERR-TUTOR-NOT-FOUND (err u101))
(define-constant ERR-ALREADY-REGISTERED (err u102))
(define-constant ERR-INVALID-RATING (err u103))
(define-constant ERR-VERIFICATION-FEE (err u104))
(define-constant ERR-ALREADY-VERIFIED (err u105))
(define-constant ERR-INVALID-SUBJECT (err u106))
(define-constant ERR-SESSION-NOT-FOUND (err u107))
(define-constant ERR-INSUFFICIENT-PAYMENT (err u108))
(define-constant ERR-SESSION-COMPLETED (err u109))
(define-constant ERR-SESSION-CANCELLED (err u110))
(define-constant ERR-INVALID-DURATION (err u111))

(define-constant VERIFICATION-FEE u1000000)
(define-constant MIN-RATING u1)
(define-constant MAX-RATING u5)

(define-data-var total-tutors uint u0)
(define-data-var verification-fee uint VERIFICATION-FEE)
(define-data-var session-counter uint u0)

(define-map tutors 
  principal 
  {
    name: (string-ascii 50),
    bio: (string-ascii 200),
    subjects: (list 10 (string-ascii 30)),
    hourly-rate: uint,
    verified: bool,
    verification-date: (optional uint),
    total-ratings: uint,
    rating-sum: uint,
    created-at: uint
  })

(define-map tutor-qualifications
  principal
  {
    education: (string-ascii 100),
    certifications: (list 5 (string-ascii 50)),
    experience-years: uint,
    background-check: bool
  })

(define-map ratings
  {tutor: principal, student: principal}
  {
    rating: uint,
    comment: (string-ascii 200),
    timestamp: uint
  })

(define-map verification-requests
  principal
  {
    requested-at: uint,
    documents: (string-ascii 200),
    status: (string-ascii 20)
  })

(define-map subject-registry
  (string-ascii 30)
  (list 100 principal))

(define-map sessions
  uint
  {
    student: principal,
    tutor: principal,
    duration-hours: uint,
    total-payment: uint,
    scheduled-at: uint,
    status: (string-ascii 20),
    completed-at: (optional uint)
  })

(define-map session-escrow
  uint
  {
    amount: uint,
    deposited: bool
  })

(define-public (register-tutor 
  (name (string-ascii 50))
  (bio (string-ascii 200))
  (subjects (list 10 (string-ascii 30)))
  (hourly-rate uint)
  (education (string-ascii 100))
  (certifications (list 5 (string-ascii 50)))
  (experience-years uint))
  (let 
    (
      (caller tx-sender)
      (current-block stacks-block-height)
    )
    (asserts! (is-none (map-get? tutors caller)) ERR-ALREADY-REGISTERED)
    (asserts! (> (len subjects) u0) ERR-INVALID-SUBJECT)
    
    (map-set tutors caller {
      name: name,
      bio: bio,
      subjects: subjects,
      hourly-rate: hourly-rate,
      verified: false,
      verification-date: none,
      total-ratings: u0,
      rating-sum: u0,
      created-at: current-block
    })
    
    (map-set tutor-qualifications caller {
      education: education,
      certifications: certifications,
      experience-years: experience-years,
      background-check: false
    })
    
    (map register-subject-mapping subjects)
    (var-set total-tutors (+ (var-get total-tutors) u1))
    (ok true)))

(define-private (register-subject-mapping (subject (string-ascii 30)))
  (let 
    (
      (current-tutors (default-to (list) (map-get? subject-registry subject)))
      (tutor tx-sender)
    )
    (map-set subject-registry subject (unwrap-panic (as-max-len? (append current-tutors tutor) u100)))
    subject))

(define-public (request-verification (documents (string-ascii 200)))
  (let 
    (
      (caller tx-sender)
      (current-block stacks-block-height)
    )
    (asserts! (is-some (map-get? tutors caller)) ERR-TUTOR-NOT-FOUND)
    (asserts! (>= (stx-get-balance caller) (var-get verification-fee)) ERR-VERIFICATION-FEE)
    
    (try! (stx-transfer? (var-get verification-fee) caller CONTRACT-OWNER))
    
    (map-set verification-requests caller {
      requested-at: current-block,
      documents: documents,
      status: "pending"
    })
    (ok true)))

(define-public (verify-tutor (tutor principal))
  (let 
    (
      (current-block stacks-block-height)
      (tutor-data (unwrap! (map-get? tutors tutor) ERR-TUTOR-NOT-FOUND))
    )
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (asserts! (is-eq (get verified tutor-data) false) ERR-ALREADY-VERIFIED)
    
    (map-set tutors tutor (merge tutor-data {
      verified: true,
      verification-date: (some current-block)
    }))
    
    (map-set tutor-qualifications tutor 
      (merge (unwrap-panic (map-get? tutor-qualifications tutor)) {
        background-check: true
      }))
    
    (map-set verification-requests tutor 
      (merge (unwrap-panic (map-get? verification-requests tutor)) {
        status: "approved"
      }))
    (ok true)))

(define-public (rate-tutor (tutor principal) (rating uint) (comment (string-ascii 200)))
  (let 
    (
      (caller tx-sender)
      (current-block stacks-block-height)
      (tutor-data (unwrap! (map-get? tutors tutor) ERR-TUTOR-NOT-FOUND))
    )
    (asserts! (and (>= rating MIN-RATING) (<= rating MAX-RATING)) ERR-INVALID-RATING)
    (asserts! (not (is-eq caller tutor)) ERR-NOT-AUTHORIZED)
    
    (map-set ratings {tutor: tutor, student: caller} {
      rating: rating,
      comment: comment,
      timestamp: current-block
    })
    
    (map-set tutors tutor (merge tutor-data {
      total-ratings: (+ (get total-ratings tutor-data) u1),
      rating-sum: (+ (get rating-sum tutor-data) rating)
    }))
    (ok true)))

(define-public (update-profile 
  (name (string-ascii 50))
  (bio (string-ascii 200))
  (hourly-rate uint))
  (let 
    (
      (caller tx-sender)
      (tutor-data (unwrap! (map-get? tutors caller) ERR-TUTOR-NOT-FOUND))
    )
    (map-set tutors caller (merge tutor-data {
      name: name,
      bio: bio,
      hourly-rate: hourly-rate
    }))
    (ok true)))

(define-public (set-verification-fee (new-fee uint))
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (var-set verification-fee new-fee)
    (ok true)))

(define-read-only (get-tutor (tutor principal))
  (map-get? tutors tutor))

(define-read-only (get-tutor-qualifications (tutor principal))
  (map-get? tutor-qualifications tutor))

(define-read-only (get-rating (tutor principal) (student principal))
  (map-get? ratings {tutor: tutor, student: student}))

(define-read-only (get-verification-request (tutor principal))
  (map-get? verification-requests tutor))

(define-read-only (get-tutors-by-subject (subject (string-ascii 30)))
  (map-get? subject-registry subject))

(define-read-only (get-tutor-average-rating (tutor principal))
  (match (map-get? tutors tutor)
    tutor-data 
      (if (is-eq (get total-ratings tutor-data) u0)
        u0
        (/ (get rating-sum tutor-data) (get total-ratings tutor-data)))
    u0))

(define-read-only (is-tutor-verified (tutor principal))
  (match (map-get? tutors tutor)
    tutor-data (get verified tutor-data)
    false))

(define-read-only (get-total-tutors)
  (var-get total-tutors))

(define-read-only (get-current-verification-fee)
  (var-get verification-fee))

(define-read-only (get-contract-info)
  {
    total-tutors: (var-get total-tutors),
    verification-fee: (var-get verification-fee),
    contract-owner: CONTRACT-OWNER
  })

(define-public (book-session (tutor principal) (duration-hours uint) (scheduled-at uint))
  (let
    (
      (caller tx-sender)
      (tutor-data (unwrap! (map-get? tutors tutor) ERR-TUTOR-NOT-FOUND))
      (session-id (+ (var-get session-counter) u1))
      (total-payment (* (get hourly-rate tutor-data) duration-hours))
    )
    (asserts! (> duration-hours u0) ERR-INVALID-DURATION)
    (asserts! (not (is-eq caller tutor)) ERR-NOT-AUTHORIZED)
    (asserts! (>= (stx-get-balance caller) total-payment) ERR-INSUFFICIENT-PAYMENT)
    
    (try! (stx-transfer? total-payment caller (as-contract tx-sender)))
    
    (map-set sessions session-id {
      student: caller,
      tutor: tutor,
      duration-hours: duration-hours,
      total-payment: total-payment,
      scheduled-at: scheduled-at,
      status: "pending",
      completed-at: none
    })
    
    (map-set session-escrow session-id {
      amount: total-payment,
      deposited: true
    })
    
    (var-set session-counter session-id)
    (ok session-id)))

(define-public (complete-session (session-id uint))
  (let
    (
      (caller tx-sender)
      (session-data (unwrap! (map-get? sessions session-id) ERR-SESSION-NOT-FOUND))
      (escrow-data (unwrap! (map-get? session-escrow session-id) ERR-SESSION-NOT-FOUND))
      (current-block stacks-block-height)
      (tutor-principal (get tutor session-data))
      (payment-amount (get amount escrow-data))
    )
    (asserts! (is-eq caller tutor-principal) ERR-NOT-AUTHORIZED)
    (asserts! (is-eq (get status session-data) "pending") ERR-SESSION-COMPLETED)
    (asserts! (is-eq (get deposited escrow-data) true) ERR-INSUFFICIENT-PAYMENT)
    
    (try! (as-contract (stx-transfer? payment-amount tx-sender tutor-principal)))
    
    (map-set sessions session-id (merge session-data {
      status: "completed",
      completed-at: (some current-block)
    }))
    
    (map-set session-escrow session-id (merge escrow-data {
      deposited: false
    }))
    (ok true)))

(define-public (cancel-session (session-id uint))
  (let
    (
      (caller tx-sender)
      (session-data (unwrap! (map-get? sessions session-id) ERR-SESSION-NOT-FOUND))
      (escrow-data (unwrap! (map-get? session-escrow session-id) ERR-SESSION-NOT-FOUND))
      (student-principal (get student session-data))
      (refund-amount (get amount escrow-data))
    )
    (asserts! (is-eq caller student-principal) ERR-NOT-AUTHORIZED)
    (asserts! (is-eq (get status session-data) "pending") ERR-SESSION-COMPLETED)
    (asserts! (is-eq (get deposited escrow-data) true) ERR-INSUFFICIENT-PAYMENT)
    
    (try! (as-contract (stx-transfer? refund-amount tx-sender student-principal)))
    
    (map-set sessions session-id (merge session-data {
      status: "cancelled",
      completed-at: none
    }))
    
    (map-set session-escrow session-id (merge escrow-data {
      deposited: false
    }))
    (ok true)))

(define-read-only (get-session (session-id uint))
  (map-get? sessions session-id))

(define-read-only (get-session-escrow (session-id uint))
  (map-get? session-escrow session-id))

(define-read-only (get-total-sessions)
  (var-get session-counter))
