;; Energy Trading Contract

(define-map energy-offers
  { offer-id: uint }
  {
    seller: principal,
    energy-amount: uint,
    price: uint,
    expiration: uint
  }
)

(define-map energy-trades
  { trade-id: uint }
  {
    seller: principal,
    buyer: principal,
    energy-amount: uint,
    price: uint,
    timestamp: uint
  }
)

(define-data-var offer-id-nonce uint u0)
(define-data-var trade-id-nonce uint u0)

(define-constant CONTRACT_OWNER tx-sender)
(define-constant ERR_UNAUTHORIZED (err u403))
(define-constant ERR_NOT_FOUND (err u404))
(define-constant ERR_EXPIRED (err u410))

(define-read-only (get-energy-offer (offer-id uint))
  (map-get? energy-offers { offer-id: offer-id })
)

(define-read-only (get-energy-trade (trade-id uint))
  (map-get? energy-trades { trade-id: trade-id })
)

(define-public (create-energy-offer
    (energy-amount uint)
    (price uint)
    (expiration uint))
  (let
    ((new-offer-id (+ (var-get offer-id-nonce) u1)))
    (map-set energy-offers
      { offer-id: new-offer-id }
      {
        seller: tx-sender,
        energy-amount: energy-amount,
        price: price,
        expiration: expiration
      }
    )
    (var-set offer-id-nonce new-offer-id)
    (ok new-offer-id)
  )
)

(define-public (accept-energy-offer (offer-id uint))
  (let
    ((offer (unwrap! (get-energy-offer offer-id) ERR_NOT_FOUND))
     (new-trade-id (+ (var-get trade-id-nonce) u1)))
    (asserts! (< block-height (get expiration offer)) ERR_EXPIRED)
    (asserts! (is-eq (stx-transfer? (get price offer) tx-sender (get seller offer)) (ok true)) ERR_UNAUTHORIZED)
    (map-delete energy-offers { offer-id: offer-id })
    (map-set energy-trades
      { trade-id: new-trade-id }
      {
        seller: (get seller offer),
        buyer: tx-sender,
        energy-amount: (get energy-amount offer),
        price: (get price offer),
        timestamp: block-height
      }
    )
    (var-set trade-id-nonce new-trade-id)
    (ok new-trade-id)
  )
)

(define-read-only (get-all-energy-offers)
  (ok (var-get offer-id-nonce))
)

(define-read-only (get-all-energy-trades)
  (ok (var-get trade-id-nonce))
)

