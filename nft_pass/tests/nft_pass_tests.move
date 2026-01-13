#[test_only]
module nft_pass::nft_pass_tests;

use sui::test_scenario::{Self as ts, Scenario};
use nft_pass::nft_pass::{Self, Pass, MintRegistry};

// ===== Test Constants =====
const ADMIN: address = @0xAD;
const USER1: address = @0x1;
const USER2: address = @0x2;

// ===== Helper Functions =====

fun setup(): Scenario {
    let mut scenario = ts::begin(ADMIN);
    {
        nft_pass::init_for_testing(ts::ctx(&mut scenario));
    };
    scenario
}

// ===== Tests =====

#[test]
fun test_mint_pass_success() {
    let mut scenario = setup();
    
    // User1 mints a pass
    ts::next_tx(&mut scenario, USER1);
    {
        let mut registry = ts::take_shared<MintRegistry>(&scenario);
        nft_pass::mint(&mut registry, ts::ctx(&mut scenario));
        ts::return_shared(registry);
    };
    
    // Verify User1 received the pass
    ts::next_tx(&mut scenario, USER1);
    {
        let pass = ts::take_from_sender<Pass>(&scenario);
        assert!(nft_pass::owner(&pass) == USER1);
        ts::return_to_sender(&scenario, pass);
    };
    
    // Verify registry shows User1 has minted
    ts::next_tx(&mut scenario, USER1);
    {
        let registry = ts::take_shared<MintRegistry>(&scenario);
        assert!(nft_pass::has_minted(&registry, USER1));
        assert!(!nft_pass::has_minted(&registry, USER2));
        ts::return_shared(registry);
    };
    
    ts::end(scenario);
}

#[test]
fun test_multiple_users_can_mint() {
    let mut scenario = setup();
    
    // User1 mints
    ts::next_tx(&mut scenario, USER1);
    {
        let mut registry = ts::take_shared<MintRegistry>(&scenario);
        nft_pass::mint(&mut registry, ts::ctx(&mut scenario));
        ts::return_shared(registry);
    };
    
    // User2 mints
    ts::next_tx(&mut scenario, USER2);
    {
        let mut registry = ts::take_shared<MintRegistry>(&scenario);
        nft_pass::mint(&mut registry, ts::ctx(&mut scenario));
        ts::return_shared(registry);
    };
    
    // Verify both have minted
    ts::next_tx(&mut scenario, ADMIN);
    {
        let registry = ts::take_shared<MintRegistry>(&scenario);
        assert!(nft_pass::has_minted(&registry, USER1));
        assert!(nft_pass::has_minted(&registry, USER2));
        ts::return_shared(registry);
    };
    
    ts::end(scenario);
}

#[test]
#[expected_failure(abort_code = ::nft_pass::nft_pass::EAlreadyMinted)]
fun test_cannot_mint_twice() {
    let mut scenario = setup();
    
    // User1 mints first time
    ts::next_tx(&mut scenario, USER1);
    {
        let mut registry = ts::take_shared<MintRegistry>(&scenario);
        nft_pass::mint(&mut registry, ts::ctx(&mut scenario));
        ts::return_shared(registry);
    };
    
    // User1 tries to mint again - should fail
    ts::next_tx(&mut scenario, USER1);
    {
        let mut registry = ts::take_shared<MintRegistry>(&scenario);
        nft_pass::mint(&mut registry, ts::ctx(&mut scenario));
        ts::return_shared(registry);
    };
    
    ts::end(scenario);
}

#[test]
fun test_has_minted_returns_false_for_new_address() {
    let mut scenario = setup();
    
    ts::next_tx(&mut scenario, USER1);
    {
        let registry = ts::take_shared<MintRegistry>(&scenario);
        assert!(!nft_pass::has_minted(&registry, USER1));
        assert!(!nft_pass::has_minted(&registry, USER2));
        ts::return_shared(registry);
    };
    
    ts::end(scenario);
}

#[test]
fun test_pass_owner_getter() {
    let mut scenario = setup();
    
    ts::next_tx(&mut scenario, USER1);
    {
        let mut registry = ts::take_shared<MintRegistry>(&scenario);
        nft_pass::mint(&mut registry, ts::ctx(&mut scenario));
        ts::return_shared(registry);
    };
    
    ts::next_tx(&mut scenario, USER1);
    {
        let pass = ts::take_from_sender<Pass>(&scenario);
        assert!(nft_pass::owner(&pass) == USER1);
        ts::return_to_sender(&scenario, pass);
    };
    
    ts::end(scenario);
}
