import {
  Clarinet,
  Tx,
  Chain,
  Account,
  types
} from 'https://deno.land/x/clarinet@v1.0.0/index.ts';
import { assertEquals } from 'https://deno.land/std@0.90.0/testing/asserts.ts';

Clarinet.test({
  name: "Can list asset for sale",
  async fn(chain: Chain, accounts: Map<string, Account>) {
    const wallet_1 = accounts.get("wallet_1")!;
    
    let block = chain.mineBlock([
      Tx.contractCall(
        "asset-registry",
        "create-asset", 
        [types.utf8("Test Asset")],
        wallet_1.address
      ),
      Tx.contractCall(
        "marketplace",
        "list-asset",
        [types.uint(1), types.uint(1000)],
        wallet_1.address
      )
    ]);
    
    assertEquals(block.receipts[1].result.expectOk(), true);
  },
});

Clarinet.test({
  name: "Can purchase listed asset",
  async fn(chain: Chain, accounts: Map<string, Account>) {
    const wallet_1 = accounts.get("wallet_1")!;
    const wallet_2 = accounts.get("wallet_2")!;
    
    let block = chain.mineBlock([
      Tx.contractCall(
        "asset-registry",
        "create-asset",
        [types.utf8("Test Asset")],
        wallet_1.address
      ),
      Tx.contractCall(
        "marketplace",
        "list-asset",
        [types.uint(1), types.uint(1000)],
        wallet_1.address
      ),
      Tx.contractCall(
        "marketplace", 
        "purchase-asset",
        [types.uint(1)],
        wallet_2.address
      )
    ]);
    
    assertEquals(block.receipts[2].result.expectOk(), true);
  },
});
