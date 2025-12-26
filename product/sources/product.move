/// Module product trong package product
module product::product {
    /// Import function sender từ tx_context để lấy địa chỉ người gọi
    use sui::tx_context::sender;
    use std::string::String;

    /// Struct Product đại diện cho một sản phẩm
    /// - has key: cho phép lưu trữ on-chain với ID duy nhất
    /// - has store: cho phép lưu trong object khác
    public struct Product has key, store {
        id: UID,        // ID duy nhất của object (bắt buộc cho mọi object trên Sui)
        name: String,   // Tên sản phẩm
        price: u64,     // Giá sản phẩm (số nguyên không âm 64-bit)
        owner: address, // Địa chỉ người sở hữu sản phẩm
    }

    /// Function để tạo sản phẩm mới và trả về Product object
    /// - public: có thể gọi từ module khác
    /// - Trả về Product object để caller tự quyết định xử lý (transfer, wrap, etc.)
    public fun create_product(
        name: String,       // Tên sản phẩm - người dùng truyền vào
        price: u64,         // Giá sản phẩm - người dùng truyền vào
        ctx: &mut TxContext // Context của transaction - Sui tự động truyền
    ): Product {
        // Tạo object Product mới
        let product = Product {
            id: object::new(ctx),  // Tạo UID mới cho object
            name,                   // Gán tên sản phẩm
            price,                  // Gán giá sản phẩm
            owner: sender(ctx),     // Lấy địa chỉ người gọi làm owner
        };
        // Trả về Product để caller có thể sử dụng linh hoạt trong programmable transactions
        product
    }

    /// Entry function để tạo sản phẩm mới và tự động chuyển giao cho người gọi
    /// - entry: có thể gọi trực tiếp từ transaction
    /// - Tự động transfer product cho sender sau khi tạo
    entry fun mint_and_transfer_product(
        name: String,       // Tên sản phẩm
        price: u64,         // Giá sản phẩm
        ctx: &mut TxContext
    ) {
        // Tạo product mới
        let product = create_product(name, price, ctx);
        // Chuyển giao product cho người gọi transaction
        transfer::transfer(product, sender(ctx));
    }
}
