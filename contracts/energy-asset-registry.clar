;; Energy Asset Registry Contract

(define-map energy-assets
  { asset-id: uint }
  {
    owner: principal,
    asset-type: (string-ascii 20),
    capacity: uint,
    location: (string-utf8 100),
    active: bool
  }
)

(define-data-var asset-id-nonce uint u0)

(define-constant CONTRACT_OWNER tx-sender)
(define-constant ERR_UNAUTHORIZED (err u403))
(define-constant ERR_NOT_FOUND (err u404))
(define-constant ERR_ALREADY_EXISTS (err u409))

(define-read-only (get-energy-asset (asset-id uint))
  (map-get? energy-assets { asset-id: asset-id })
)

(define-public (register-energy-asset
    (asset-type (string-ascii 20))
    (capacity uint)
    (location (string-utf8 100)))
  (let
    ((new-asset-id (+ (var-get asset-id-nonce) u1)))
    (map-set energy-assets
      { asset-id: new-asset-id }
      {
        owner: tx-sender,
        asset-type: asset-type,
        capacity: capacity,
        location: location,
        active: true
      }
    )
    (var-set asset-id-nonce new-asset-id)
    (ok new-asset-id)
  )
)

(define-public (update-asset-status (asset-id uint) (active bool))
  (let
    ((asset (unwrap! (get-energy-asset asset-id) ERR_NOT_FOUND)))
    (asserts! (is-eq tx-sender (get owner asset)) ERR_UNAUTHORIZED)
    (map-set energy-assets
      { asset-id: asset-id }
      (merge asset { active: active })
    )
    (ok true)
  )
)

(define-read-only (get-all-energy-assets)
  (ok (var-get asset-id-nonce))
)

