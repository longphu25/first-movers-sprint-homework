#[test_only]
module counter::counter_tests;

use counter::counter::{Self, Counter};

#[test]
fun test_counter_create_and_increment() {
    let mut ctx = tx_context::dummy();
    
    // Create a counter
    counter::create(&mut ctx);
}

#[test]
fun test_counter_operations() {
    let mut ctx = tx_context::dummy();
    
    // Create a counter for testing
    let mut counter = counter::create_for_testing(&mut ctx);
    
    // Test initial value
    assert!(counter::value(&counter) == 0, 0);
    
    // Test increment
    counter::increment(&mut counter);
    assert!(counter::value(&counter) == 1, 1);
    
    // Test multiple increments
    counter::increment(&mut counter);
    counter::increment(&mut counter);
    assert!(counter::value(&counter) == 3, 2);
    
    // Test set_value
    counter::set_value(&mut counter, 100);
    assert!(counter::value(&counter) == 100, 3);
    
    // Test reset
    counter::reset(&mut counter);
    assert!(counter::value(&counter) == 0, 4);
    
    // Clean up
    counter::destroy_for_testing(counter);
}
