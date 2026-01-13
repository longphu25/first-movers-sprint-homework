# Final Assessment — On-chain Logic Challenge (Sui & Move)

## Description

This final assessment evaluates your **real understanding of Sui's object-centric model and Move smart contract logic**.

You are required to design and implement a simple on-chain application on Sui, focusing on:

* Object ownership & access control
* On-chain state management
* Correct transaction behavior (success & failure cases)
* Clear technical explanation of your design decisions

This is not a frontend challenge.
Your ability to **explain, reason, and demonstrate on-chain logic** is more important than the amount of code you write.

---

## Challenge: Mint Pass NFT (Soulbound Logic)

Build a "Pass" NFT system where:
- Each address can mint only once
- The NFT cannot be transferred
- There is a way to check whether an address already owns a pass

---

## Solution Explanation / Giải thích giải pháp

### 1. Structs Design / Thiết kế cấu trúc dữ liệu

#### Pass Struct (Soulbound NFT)

```move
public struct Pass has key {
    id: UID,
    owner: address,
    minted_at: u64,
}
```

**Why `has key` only? / Tại sao chỉ có `key`?**

- `key`: Cho phép object được lưu trữ on-chain với unique ID
- **Không có `store`**: Đây là điểm quan trọng nhất! Khi không có ability `store`, object **không thể được chuyển nhượng** bởi người dùng thông qua `transfer::public_transfer`. Chỉ module tạo ra nó mới có thể transfer bằng `transfer::transfer`.
- Đây chính là cách implement **Soulbound Token** trên Sui - NFT gắn liền với địa chỉ, không thể trade/sell.

**Fields explanation / Giải thích các trường:**
- `id: UID`: Unique identifier bắt buộc cho mọi Sui object
- `owner: address`: Lưu địa chỉ chủ sở hữu để query
- `minted_at: u64`: Epoch khi mint, dùng để tracking

#### MintRegistry Struct (Shared Object)

```move
public struct MintRegistry has key {
    id: UID,
    minted_addresses: vector<address>,
}
```

**Why Shared Object? / Tại sao dùng Shared Object?**

- `MintRegistry` được tạo trong `init()` và share bằng `transfer::share_object()`
- Shared object cho phép **bất kỳ ai** cũng có thể đọc/ghi (với mutable reference)
- Cần thiết vì nhiều user khác nhau cần gọi hàm `mint()` và cập nhật registry
- Nếu dùng owned object, chỉ owner mới có thể modify

**Why vector instead of Table? / Tại sao dùng vector thay vì Table?**

- `vector<address>` đơn giản, phù hợp với số lượng nhỏ-trung bình
- Dễ iterate và check với `vector::contains()`
- Với scale lớn hơn, nên dùng `Table<address, bool>` để O(1) lookup

---

### 2. Init Function / Hàm khởi tạo

```move
fun init(ctx: &mut TxContext) {
    let registry = MintRegistry {
        id: object::new(ctx),
        minted_addresses: vector::empty(),
    };
    transfer::share_object(registry);
}
```

**Why? / Tại sao?**

- `init()` chạy **một lần duy nhất** khi publish package
- Tạo `MintRegistry` rỗng và share cho toàn bộ network
- Không có admin/owner - ai cũng có thể mint (decentralized)
- `transfer::share_object()` biến object thành shared, không thuộc về ai

---

### 3. Mint Function / Hàm mint

```move
public fun mint(registry: &mut MintRegistry, ctx: &mut TxContext) {
    let sender = tx_context::sender(ctx);
    
    // Check if address has already minted
    assert!(!has_minted(registry, sender), EAlreadyMinted);
    
    // Record the mint
    vector::push_back(&mut registry.minted_addresses, sender);
    
    // Create the soulbound pass
    let pass = Pass {
        id: object::new(ctx),
        owner: sender,
        minted_at: tx_context::epoch(ctx),
    };
    
    // Emit event
    event::emit(PassMinted {
        pass_id: object::id(&pass),
        owner: sender,
    });
    
    // Transfer to sender (soulbound - no store ability)
    transfer::transfer(pass, sender);
}
```

**Step-by-step explanation / Giải thích từng bước:**

1. **Get sender address**: `tx_context::sender(ctx)` lấy địa chỉ người gọi transaction

2. **Check duplicate mint**: 
   - `assert!(!has_minted(registry, sender), EAlreadyMinted)`
   - Nếu đã mint rồi → abort với error code 0
   - Đảm bảo **mỗi địa chỉ chỉ mint được 1 lần**

3. **Record to registry**:
   - `vector::push_back()` thêm địa chỉ vào danh sách
   - Cần `&mut MintRegistry` để modify shared object

4. **Create Pass object**:
   - `object::new(ctx)` tạo unique ID
   - `tx_context::epoch(ctx)` lấy epoch hiện tại

5. **Emit event**:
   - `event::emit()` phát sự kiện on-chain
   - Dùng để indexer/frontend tracking

6. **Transfer to sender**:
   - `transfer::transfer(pass, sender)` - dùng `transfer` không phải `public_transfer`
   - Vì Pass không có `store` ability, chỉ module này mới có quyền transfer
   - Sau khi transfer, Pass thuộc về sender nhưng **không thể chuyển tiếp**

**Why `transfer::transfer` not `public_transfer`? / Tại sao dùng `transfer` thay vì `public_transfer`?**

- `public_transfer`: Yêu cầu object có `key + store`, ai cũng có thể gọi
- `transfer`: Chỉ module định nghĩa type mới được gọi, không cần `store`
- Đây là cách **enforce soulbound** - chỉ module mint mới có thể transfer, user không thể

---

### 4. View Functions / Hàm đọc dữ liệu

```move
public fun has_minted(registry: &MintRegistry, addr: address): bool {
    vector::contains(&registry.minted_addresses, &addr)
}

public fun owner(pass: &Pass): address {
    pass.owner
}

public fun minted_at(pass: &Pass): u64 {
    pass.minted_at
}
```

**Why? / Tại sao?**

- `has_minted()`: Kiểm tra địa chỉ đã mint chưa - **yêu cầu của đề bài**
- `owner()`, `minted_at()`: Getter functions để đọc thông tin Pass
- Nhận `&` (immutable reference) vì chỉ đọc, không modify
- Public để ai cũng có thể query

---

### 5. Error Handling / Xử lý lỗi

```move
const EAlreadyMinted: u64 = 0;
```

**Why constant error code? / Tại sao dùng constant?**

- Convention trong Move: `E` prefix cho error codes
- Dễ debug và test với `#[expected_failure(abort_code = ...)]`
- Clear meaning: `EAlreadyMinted` = địa chỉ đã mint rồi

---

### 6. Events / Sự kiện

```move
public struct PassMinted has copy, drop {
    pass_id: ID,
    owner: address,
}
```

**Why events? / Tại sao cần events?**

- Events được lưu on-chain và có thể query bởi indexers
- Frontend/backend có thể subscribe để real-time tracking
- `has copy, drop`: Bắt buộc cho event structs trong Sui

---

## Transaction Behavior / Hành vi transaction

### Success Case / Trường hợp thành công

1. User A gọi `mint()` lần đầu
2. Check `has_minted()` → false
3. Thêm address vào registry
4. Tạo Pass và transfer cho User A
5. Emit `PassMinted` event
6. Transaction success ✅

### Failure Case / Trường hợp thất bại

1. User A gọi `mint()` lần thứ 2
2. Check `has_minted()` → true
3. `assert!` fail với `EAlreadyMinted`
4. Transaction abort ❌
5. Không có thay đổi state (atomic)

---

## Object Ownership Summary / Tóm tắt quyền sở hữu

| Object | Ownership Type | Reason |
|--------|---------------|--------|
| MintRegistry | Shared | Nhiều user cần access để mint |
| Pass | Owned (Soulbound) | Thuộc về 1 user, không transfer được |

---

## Key Design Decisions / Quyết định thiết kế quan trọng

1. **Soulbound = No `store` ability**: Cách đơn giản và hiệu quả nhất trên Sui
2. **Shared Registry**: Cho phép decentralized minting
3. **Vector for tracking**: Đơn giản, phù hợp scale nhỏ-trung
4. **Event emission**: Best practice cho tracking và indexing
5. **Single mint per address**: Enforced bằng registry check + assert

---

## How to Test / Cách test

```bash
# Build
sui move build

# Run tests
sui move test

# Publish
sui client publish --gas-budget 100000000
```

See `runme.md` for detailed CLI commands.
