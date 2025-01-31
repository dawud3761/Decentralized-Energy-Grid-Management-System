;; Renewable Energy Milestone NFT Contract

(define-non-fungible-token renewable-energy-milestone uint)

(define-map milestone-data
  { milestone-id: uint }
  {
    asset-id: uint,
    milestone-type: (string-ascii 20),
    description: (string-utf8 200),
    achievement-date: uint,
    value: uint
  }
)

(define-data-var milestone-id-nonce uint u0)

(define-constant CONTRACT_OWNER tx-sender)
(define-constant ERR_UNAUTHORIZED (err u403))
(define-constant ERR_NOT_FOUND (err u404))

(define-read-only (get-last-token-id)
  (ok (var-get milestone-id-nonce))
)

(define-read-only (get-token-uri (milestone-id uint))
  (ok none)
)

(define-read-only (get-owner (milestone-id uint))
  (ok (nft-get-owner? renewable-energy-milestone milestone-id))
)

(define-public (transfer (milestone-id uint) (sender principal) (recipient principal))
  (begin
    (asserts! (is-eq tx-sender sender) ERR_UNAUTHORIZED)
    (nft-transfer? renewable-energy-milestone milestone-id sender recipient)
  )
)

(define-public (mint-milestone
    (asset-id uint)
    (milestone-type (string-ascii 20))
    (description (string-utf8 200))
    (value uint))
  (let
    ((new-milestone-id (+ (var-get milestone-id-nonce) u1)))
    (try! (nft-mint? renewable-energy-milestone new-milestone-id tx-sender))
    (map-set milestone-data
      { milestone-id: new-milestone-id }
      {
        asset-id: asset-id,
        milestone-type: milestone-type,
        description: description,
        achievement-date: block-height,
        value: value
      }
    )
    (var-set milestone-id-nonce new-milestone-id)
    (ok new-milestone-id)
  )
)

(define-read-only (get-milestone-data (milestone-id uint))
  (map-get? milestone-data { milestone-id: milestone-id })
)

