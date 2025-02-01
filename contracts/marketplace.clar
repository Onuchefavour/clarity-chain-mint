;; Marketplace Contract

;; Constants
(define-constant contract-owner tx-sender)

;; Listing data structure
(define-map listings
  uint 
  {
    seller: principal,
    price: uint,
    status: (string-ascii 20)
  })

;; List asset for sale
(define-public (list-asset (asset-id uint) (price uint))
  (let ((asset-contract (contract-call? .asset-registry get-asset asset-id)))
    (asserts! (is-some asset-contract) (err u200))
    (asserts! (is-eq (get owner (unwrap-panic asset-contract)) tx-sender) (err u201))
    (map-set listings asset-id
      {
        seller: tx-sender,
        price: price,
        status: "active"
      })
    (ok true)))

;; Purchase listed asset
(define-public (purchase-asset (asset-id uint))
  (let ((listing (unwrap! (map-get? listings asset-id) (err u202))))
    (asserts! (is-eq (get status listing) "active") (err u203))
    (try! (stx-transfer? (get price listing) tx-sender (get seller listing)))
    (try! (contract-call? .asset-registry transfer-asset asset-id tx-sender))
    (map-delete listings asset-id)
    (ok true)))
