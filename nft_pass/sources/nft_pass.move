/// Module: nft_pass
/// A soulbound NFT pass system where each address can mint only once
/// and the NFT cannot be transferred
/// 
/// Module: nft_pass
/// Hệ thống NFT Pass soulbound - mỗi địa chỉ chỉ được mint một lần
/// và NFT không thể chuyển nhượng
module nft_pass::nft_pass;

use sui::event;

// ===== Error Codes / Mã lỗi =====

/// Error: Address has already minted a pass
/// Lỗi: Địa chỉ đã mint pass rồi
const EAlreadyMinted: u64 = 0;

// ===== Structs / Cấu trúc dữ liệu =====

/// The soulbound NFT Pass - no store ability means it cannot be transferred
/// NFT Pass soulbound - không có ability "store" nên không thể chuyển nhượng
public struct Pass has key {
    id: UID,
    /// Owner address / Địa chỉ chủ sở hữu
    owner: address,
    /// Epoch when minted / Epoch khi mint
    minted_at: u64,
}

/// Registry to track which addresses have minted
/// Registry để theo dõi địa chỉ nào đã mint
public struct MintRegistry has key {
    id: UID,
    /// List of addresses that have minted / Danh sách địa chỉ đã mint
    minted_addresses: vector<address>,
}

// ===== Events / Sự kiện =====

/// Event emitted when a pass is minted
/// Sự kiện phát ra khi pass được mint
public struct PassMinted has copy, drop {
    pass_id: ID,
    owner: address,
}

// ===== Init / Khởi tạo =====

/// Initialize the module - creates shared MintRegistry
/// Khởi tạo module - tạo MintRegistry dùng chung
fun init(ctx: &mut TxContext) {
    let registry = MintRegistry {
        id: object::new(ctx),
        minted_addresses: vector::empty(),
    };
    transfer::share_object(registry);
}

// ===== Public Functions / Hàm công khai =====

/// Mint a new pass - each address can only mint once
/// Mint pass mới - mỗi địa chỉ chỉ được mint một lần
public fun mint(registry: &mut MintRegistry, ctx: &mut TxContext) {
    let sender = tx_context::sender(ctx);
    
    // Check if address has already minted
    // Kiểm tra địa chỉ đã mint chưa
    assert!(!has_minted(registry, sender), EAlreadyMinted);
    
    // Record the mint / Ghi nhận việc mint
    vector::push_back(&mut registry.minted_addresses, sender);
    
    // Create the soulbound pass / Tạo pass soulbound
    let pass = Pass {
        id: object::new(ctx),
        owner: sender,
        minted_at: tx_context::epoch(ctx),
    };
    
    // Emit event / Phát sự kiện
    event::emit(PassMinted {
        pass_id: object::id(&pass),
        owner: sender,
    });
    
    // Transfer to sender (soulbound - no store ability)
    // Chuyển cho người gửi (soulbound - không có ability store)
    transfer::transfer(pass, sender);
}

/// Check if an address has already minted a pass
/// Kiểm tra địa chỉ đã mint pass chưa
public fun has_minted(registry: &MintRegistry, addr: address): bool {
    vector::contains(&registry.minted_addresses, &addr)
}

/// Get the owner of a pass
/// Lấy chủ sở hữu của pass
public fun owner(pass: &Pass): address {
    pass.owner
}

/// Get when the pass was minted
/// Lấy thời điểm pass được mint
public fun minted_at(pass: &Pass): u64 {
    pass.minted_at
}

// ===== Test Functions / Hàm test =====

#[test_only]
/// Initialize for testing / Khởi tạo để test
public fun init_for_testing(ctx: &mut TxContext) {
    init(ctx);
}
