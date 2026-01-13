/// Test module for nft_pass
/// Module test cho nft_pass
#[test_only]
module nft_pass::nft_pass_tests;

use sui::test_scenario::{Self as ts, Scenario};
use nft_pass::nft_pass::{Self, Pass, MintRegistry};

// ===== Test Constants / Hằng số test =====

/// Admin address for setup / Địa chỉ admin để setup
const ADMIN: address = @0xAD;
/// Test user 1 / Người dùng test 1
const USER1: address = @0x1;
/// Test user 2 / Người dùng test 2
const USER2: address = @0x2;

// ===== Helper Functions / Hàm hỗ trợ =====

/// Setup test scenario with initialized MintRegistry
/// Khởi tạo test scenario với MintRegistry đã được tạo
fun setup(): Scenario {
    let mut scenario = ts::begin(ADMIN);
    {
        // Initialize the module (creates shared MintRegistry)
        // Khởi tạo module (tạo MintRegistry dùng chung)
        nft_pass::init_for_testing(ts::ctx(&mut scenario));
    };
    scenario
}

// ===== Tests / Các test case =====

/// Test: User can successfully mint a pass
/// Test: Người dùng có thể mint pass thành công
#[test]
fun test_mint_pass_success() {
    let mut scenario = setup();
    
    // User1 mints a pass / User1 mint một pass
    ts::next_tx(&mut scenario, USER1);
    {
        // Take shared registry to modify / Lấy registry dùng chung để sửa đổi
        let mut registry = ts::take_shared<MintRegistry>(&scenario);
        // Call mint function / Gọi hàm mint
        nft_pass::mint(&mut registry, ts::ctx(&mut scenario));
        // Return registry to shared pool / Trả registry về pool dùng chung
        ts::return_shared(registry);
    };
    
    // Verify User1 received the pass / Xác nhận User1 đã nhận được pass
    ts::next_tx(&mut scenario, USER1);
    {
        // Take pass from sender's inventory / Lấy pass từ inventory của sender
        let pass = ts::take_from_sender<Pass>(&scenario);
        // Assert owner is correct / Kiểm tra owner đúng
        assert!(nft_pass::owner(&pass) == USER1);
        // Return pass to sender / Trả pass cho sender
        ts::return_to_sender(&scenario, pass);
    };
    
    // Verify registry shows User1 has minted
    // Xác nhận registry ghi nhận User1 đã mint
    ts::next_tx(&mut scenario, USER1);
    {
        let registry = ts::take_shared<MintRegistry>(&scenario);
        // User1 should be marked as minted / User1 phải được đánh dấu đã mint
        assert!(nft_pass::has_minted(&registry, USER1));
        // User2 should NOT be marked / User2 không được đánh dấu
        assert!(!nft_pass::has_minted(&registry, USER2));
        ts::return_shared(registry);
    };
    
    // End test scenario / Kết thúc test scenario
    ts::end(scenario);
}

/// Test: Multiple different users can each mint their own pass
/// Test: Nhiều người dùng khác nhau có thể mint pass riêng của họ
#[test]
fun test_multiple_users_can_mint() {
    let mut scenario = setup();
    
    // User1 mints / User1 mint
    ts::next_tx(&mut scenario, USER1);
    {
        let mut registry = ts::take_shared<MintRegistry>(&scenario);
        nft_pass::mint(&mut registry, ts::ctx(&mut scenario));
        ts::return_shared(registry);
    };
    
    // User2 mints (different address, should succeed)
    // User2 mint (địa chỉ khác, phải thành công)
    ts::next_tx(&mut scenario, USER2);
    {
        let mut registry = ts::take_shared<MintRegistry>(&scenario);
        nft_pass::mint(&mut registry, ts::ctx(&mut scenario));
        ts::return_shared(registry);
    };
    
    // Verify both have minted / Xác nhận cả hai đã mint
    ts::next_tx(&mut scenario, ADMIN);
    {
        let registry = ts::take_shared<MintRegistry>(&scenario);
        // Both users should be in registry / Cả hai user phải có trong registry
        assert!(nft_pass::has_minted(&registry, USER1));
        assert!(nft_pass::has_minted(&registry, USER2));
        ts::return_shared(registry);
    };
    
    ts::end(scenario);
}

/// Test: Same address cannot mint twice (soulbound enforcement)
/// Test: Cùng một địa chỉ không thể mint 2 lần (quy tắc soulbound)
/// Expected to fail with EAlreadyMinted error
/// Dự kiến thất bại với lỗi EAlreadyMinted
#[test]
#[expected_failure(abort_code = ::nft_pass::nft_pass::EAlreadyMinted)]
fun test_cannot_mint_twice() {
    let mut scenario = setup();
    
    // User1 mints first time - should succeed
    // User1 mint lần đầu - phải thành công
    ts::next_tx(&mut scenario, USER1);
    {
        let mut registry = ts::take_shared<MintRegistry>(&scenario);
        nft_pass::mint(&mut registry, ts::ctx(&mut scenario));
        ts::return_shared(registry);
    };
    
    // User1 tries to mint again - should FAIL with EAlreadyMinted
    // User1 thử mint lần nữa - phải THẤT BẠI với lỗi EAlreadyMinted
    ts::next_tx(&mut scenario, USER1);
    {
        let mut registry = ts::take_shared<MintRegistry>(&scenario);
        // This call will abort! / Lệnh này sẽ abort!
        nft_pass::mint(&mut registry, ts::ctx(&mut scenario));
        ts::return_shared(registry);
    };
    
    ts::end(scenario);
}

/// Test: has_minted returns false for addresses that haven't minted
/// Test: has_minted trả về false cho địa chỉ chưa mint
#[test]
fun test_has_minted_returns_false_for_new_address() {
    let mut scenario = setup();
    
    ts::next_tx(&mut scenario, USER1);
    {
        let registry = ts::take_shared<MintRegistry>(&scenario);
        // Fresh addresses should return false / Địa chỉ mới phải trả về false
        assert!(!nft_pass::has_minted(&registry, USER1));
        assert!(!nft_pass::has_minted(&registry, USER2));
        ts::return_shared(registry);
    };
    
    ts::end(scenario);
}

/// Test: Pass owner getter returns correct address
/// Test: Hàm getter owner của Pass trả về địa chỉ đúng
#[test]
fun test_pass_owner_getter() {
    let mut scenario = setup();
    
    // Mint a pass for User1 / Mint pass cho User1
    ts::next_tx(&mut scenario, USER1);
    {
        let mut registry = ts::take_shared<MintRegistry>(&scenario);
        nft_pass::mint(&mut registry, ts::ctx(&mut scenario));
        ts::return_shared(registry);
    };
    
    // Verify owner getter / Xác nhận hàm getter owner
    ts::next_tx(&mut scenario, USER1);
    {
        let pass = ts::take_from_sender<Pass>(&scenario);
        // owner() should return the minting address
        // owner() phải trả về địa chỉ đã mint
        assert!(nft_pass::owner(&pass) == USER1);
        ts::return_to_sender(&scenario, pass);
    };
    
    ts::end(scenario);
}
