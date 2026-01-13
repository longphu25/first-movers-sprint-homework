# NFT Pass - Soulbound NFT System
# Hệ thống NFT Pass Soulbound

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
# Đọc REGISTRY_OBJECT_ID từ file client.publish.txt
# MintRegistry được tạo tự động khi publish (shared object)
# Tìm ObjectID của object có ObjectType là ::nft_pass::MintRegistry
export REGISTRY_ID=$(grep -B 3 "ObjectType:.*::nft_pass::MintRegistry" client.publish.txt | grep "ObjectID:" | awk '{print $4}')
echo "Registry Object ID: $REGISTRY_ID"
```

```sh {"terminalRows":"22"}
# Xem thông tin MintRegistry object
sui client object $REGISTRY_ID
```

```sh {"terminalRows":"15"}
# Mint NFT Pass cho địa chỉ hiện tại
# Mỗi địa chỉ chỉ được mint 1 lần (soulbound)
sui client call \
  --package $PACKAGE_ID \
  --module nft_pass \
  --function mint \
  --args $REGISTRY_ID \
  --gas-budget 10000000 | tee pass.mint.txt
```

```sh
# Đọc PASS_OBJECT_ID từ file pass.mint.txt
# Tìm ObjectID của object có ObjectType là ::nft_pass::Pass
export PASS_ID=$(grep -B 3 "ObjectType:.*::nft_pass::Pass" pass.mint.txt | grep "ObjectID:" | awk '{print $4}')
echo "Pass Object ID: $PASS_ID"
```

```sh {"terminalRows":"22"}
# Xem thông tin Pass object của bạn
sui client object $PASS_ID
```

```sh {"terminalRows":"22"}
# Xem lại MintRegistry để kiểm tra địa chỉ đã được ghi nhận
sui client object $REGISTRY_ID
```

```sh
# Thử mint lần 2 - sẽ bị lỗi EAlreadyMinted (error code 0)
# Vì mỗi địa chỉ chỉ được mint 1 lần
sui client call \
  --package $PACKAGE_ID \
  --module nft_pass \
  --function mint \
  --args $REGISTRY_ID \
  --gas-budget 10000000
```

```sh
# Ví dụ đầy đủ với các giá trị thật (sau khi đã publish)
# Bước 1: Lấy PACKAGE_ID từ file client.publish.txt
export PACKAGE_ID=$(grep 'PackageID:' client.publish.txt | awk '{print $4}')
echo "Package ID: $PACKAGE_ID"

# Bước 2: Lấy REGISTRY_ID từ file client.publish.txt (tạo tự động khi publish)
export REGISTRY_ID=$(grep -B 3 "ObjectType:.*::nft_pass::MintRegistry" client.publish.txt | grep "ObjectID:" | awk '{print $4}')
echo "Registry ID: $REGISTRY_ID"

# Bước 3: Mint Pass và lưu output
sui client call \
  --package $PACKAGE_ID \
  --module nft_pass \
  --function mint \
  --args $REGISTRY_ID \
  --gas-budget 10000000 | tee pass.mint.txt

# Bước 4: Lấy PASS_ID từ file pass.mint.txt
export PASS_ID=$(grep -B 3 "ObjectType:.*::nft_pass::Pass" pass.mint.txt | grep "ObjectID:" | awk '{print $4}')
echo "Pass ID: $PASS_ID"

# Bước 5: Xem thông tin Pass
sui client object $PASS_ID
```

```sh
# Lưu ý quan trọng về NFT Pass Soulbound:
# 1. Mỗi địa chỉ chỉ được mint 1 Pass duy nhất
# 2. Pass không thể chuyển nhượng (không có ability "store")
# 3. MintRegistry là shared object, lưu danh sách địa chỉ đã mint
# 4. Khi mint, event PassMinted sẽ được phát ra
echo "NFT Pass is soulbound - cannot be transferred!"
```
