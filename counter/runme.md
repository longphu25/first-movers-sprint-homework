```sh
# Xem địa chỉ ví đang active
sui client active-address
```

```sh
# Xem network đang kết nối (devnet/testnet)
sui client active-env
```

```sh
# Nếu cần chuyển network sang testnet
sui client switch --env testnet
```

```sh
# Tất cả các ví addresses
sui client addresses
```

```sh
# Đổi ví active sang ví khác
# sui client switch --address <địa_chỉ_ví_mới>
sui client switch --address 0x70b56e23fff713cc617cc8e14f3c947e9ee9ced42547fcd952b69df4bee32f70
sui client addresses
```

```sh
# Kiểm tra balance ví hiện tại
sui client balance
```

```sh
# Faucet SUI token (chỉ dành cho devnet chạy tốt và testnet thì sẽ hiện link đến webUI)
# sui client faucet --address <your_wallet_address>
sui client faucet --address $(sui client active-address)
```

```sh
# Chạy lệnh build
sui move build
```

```sh
# Chạy tests
sui move test
```

```sh
# Publish package và lưu output vào file client.publish.txt
sui client publish --gas-budget 100000000 | tee client.publish.txt
```

```sh
# Đọc Package ID từ file client.publish.txt
export PACKAGE_ID=$(grep 'PackageID:' client.publish.txt | awk '{print $4}')
echo "Package ID: $PACKAGE_ID"
```

```sh
# Tạo Counter mới
# Sau khi publish, đọc PACKAGE_ID từ file client.publish.txt chạy lệnh và lưu output
sui client call --package $PACKAGE_ID --module counter --function create --gas-budget 10000000 | tee counter.create.txt
```

```sh
# Đọc COUNTER_OBJECT_ID từ file counter.create.txt
# Tìm ObjectID của object có ObjectType là ::counter::Counter
export COUNTER_OBJECT_ID=$(grep -B 3 "ObjectType:.*::counter::Counter" counter.create.txt | grep "ObjectID:" | awk '{print $4}')
echo "Counter Object ID: $COUNTER_OBJECT_ID"
```

```sh {"terminalRows":"22"}
# Xem thông tin Counter object
# COUNTER_OBJECT_ID từ file counter.create.txt  
sui client object $COUNTER_OBJECT_ID
```

```sh {"terminalRows":"15"}
# Tăng giá trị Counter lên 1
# PACKAGE_ID từ file client.publish.txt và COUNTER_OBJECT_ID từ file counter.create.txt
sui client call \
  --package $PACKAGE_ID \
  --module counter \
  --function increment \
  --args $COUNTER_OBJECT_ID \
  --gas-budget 10000000

# Xem thông tin Counter object
# COUNTER_OBJECT_ID từ file counter.create.txt  
sui client object $COUNTER_OBJECT_ID
```

```sh {"terminalRows":"12"}
# Đặt Counter về một giá trị cụ thể (ví dụ: 100)
# PACKAGE_ID từ file client.publish.txt và COUNTER_OBJECT_ID từ file counter.create.txt
sui client call \
  --package $PACKAGE_ID \
  --module counter \
  --function set_value \
  --args $COUNTER_OBJECT_ID 100 \
  --gas-budget 10000000


# Xem thông tin Counter object
# COUNTER_OBJECT_ID từ file counter.create.txt  
sui client object $COUNTER_OBJECT_ID
```

```sh
# Đặt lại Counter về 0
# PACKAGE_ID từ file client.publish.txt và COUNTER_OBJECT_ID từ file counter.create.txt
sui client call \
  --package $PACKAGE_ID \
  --module counter \
  --function reset \
  --args $COUNTER_OBJECT_ID \
  --gas-budget 10000000


# Xem thông tin Counter object
# COUNTER_OBJECT_ID từ file counter.create.txt  
sui client object $COUNTER_OBJECT_ID
```

```sh
# Xem thông tin Counter object
# COUNTER_OBJECT_ID từ file counter.create.txt  
sui client object $COUNTER_OBJECT_ID
```

```sh
# Ví dụ đầy đủ với các giá trị thật (sau khi đã publish)
# Bước 1: Lấy PACKAGE_ID từ file client.publish.txt
export PACKAGE_ID=$(grep 'PackageID:' client.publish.txt | awk '{print $4}')
echo "Package ID: $PACKAGE_ID"

# Bước 2: Tạo counter mới và lưu output vào counter.create.txt
sui client call \
  --package $PACKAGE_ID \
  --module counter \
  --function create \
  --gas-budget 10000000 | tee counter.create.txt

# Bước 3: Lấy COUNTER_OBJECT_ID từ file counter.create.txt
# Tìm ObjectID của object có ObjectType là ::counter::Counter
export COUNTER_ID=$(grep -B 3 "ObjectType:.*::counter::Counter" counter.create.txt | grep "ObjectID:" | awk '{print $4}')
echo "Counter ID: $COUNTER_ID"

# Bước 4: Increment counter
sui client call \
  --package $PACKAGE_ID \
  --module counter \
  --function increment \
  --args $COUNTER_ID \
  --gas-budget 10000000

# Bước 5: Xem thông tin counter
sui client object $COUNTER_ID
```