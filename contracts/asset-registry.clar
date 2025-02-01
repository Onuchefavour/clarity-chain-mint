;; Asset Registry Contract
(define-non-fungible-token asset-token uint)

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-not-owner (err u100))
(define-constant err-asset-exists (err u101))
(define-constant err-unauthorized (err u102))

;; Asset data structure
(define-map assets
  uint 
  {
    owner: principal,
    metadata: (string-utf8 256),
    created-at: uint,
    status: (string-ascii 20)
  })

(define-data-var asset-counter uint u0)

;; Create new asset
(define-public (create-asset (metadata (string-utf8 256)))
  (let ((asset-id (+ (var-get asset-counter) u1)))
    (try! (nft-mint? asset-token asset-id tx-sender))
    (map-set assets asset-id
      {
        owner: tx-sender,
        metadata: metadata,
        created-at: block-height,
        status: "active"
      })
    (var-set asset-counter asset-id)
    (ok asset-id)))

;; Transfer asset
(define-public (transfer-asset (asset-id uint) (recipient principal))
  (let ((asset (unwrap! (map-get? assets asset-id) (err u103))))
    (asserts! (is-eq (get owner asset) tx-sender) err-not-owner)
    (try! (nft-transfer? asset-token asset-id tx-sender recipient))
    (map-set assets asset-id
      (merge asset { owner: recipient }))
    (ok true)))

;; Get asset details
(define-read-only (get-asset (asset-id uint))
  (map-get? assets asset-id))
