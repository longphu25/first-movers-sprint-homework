/// Module: counter
/// Module: Bộ đếm
module counter::counter;

/// The Counter object that holds a value
/// Đối tượng Counter lưu trữ một giá trị
public struct Counter has key {
    id: UID,
    value: u64  // Giá trị của bộ đếm / Counter value
}

/// Create a new Counter object with initial value 0
/// Tạo một đối tượng Counter mới với giá trị ban đầu là 0
public fun create(ctx: &mut TxContext) {
    // Tạo counter mới / Create new counter
    let counter = Counter {
        id: object::new(ctx),
        value: 0
    };
    // Chuyển counter cho người gửi giao dịch / Transfer counter to transaction sender
    transfer::transfer(counter, tx_context::sender(ctx));
}

/// Increment the counter by 1
/// Tăng giá trị bộ đếm lên 1
public fun increment(counter: &mut Counter) {
    counter.value = counter.value + 1;
}

/// Get the current value of the counter
/// Lấy giá trị hiện tại của bộ đếm
public fun value(counter: &Counter): u64 {
    counter.value
}

/// Set the counter to a specific value
/// Đặt bộ đếm về một giá trị cụ thể
public fun set_value(counter: &mut Counter, new_value: u64) {
    counter.value = new_value;
}

/// Reset the counter to 0
/// Đặt lại bộ đếm về 0
public fun reset(counter: &mut Counter) {
    counter.value = 0;
}

#[test_only]
/// Create a Counter for testing purposes
/// Tạo Counter cho mục đích kiểm thử
public fun create_for_testing(ctx: &mut TxContext): Counter {
    Counter {
        id: object::new(ctx),
        value: 0
    }
}

#[test_only]
/// Destroy a Counter for testing purposes
/// Hủy Counter cho mục đích kiểm thử
public fun destroy_for_testing(counter: Counter) {
    let Counter { id, value: _ } = counter;
    object::delete(id);
}


