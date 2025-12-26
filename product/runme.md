```sh {"terminalRows":"2"}
# Kiểm tra version Sui CLI
sui --version
```

```sh {"terminalRows":"2"}
# Xem địa chỉ ví đang active
sui client active-address
```

```sh {"terminalRows":"2"}
# Xem network đang kết nối (devnet/testnet)
sui client active-env
```

```sh {"terminalRows":"2"}
# Nếu cần chuyển network sang testnet
sui client switch --env testnet
```

```sh {"terminalRows":"8"}
# tất cả các ví addresses
sui client addresses
```

```sh
# Đổi Ví active sang ví khác
# sui client switch --address <địa_chỉ_ví_mới>
sui client switch --address 0x70b56e23fff713cc617cc8e14f3c947e9ee9ced42547fcd952b69df4bee32f70
sui client addresses
```

```sh
# show balance ví hiện tại
sui client balance
```

```sh
# faucet SUI token (chỉ dành cho devnet chạy tốt và testnet thì sẽ hiện link đến webUI )
# sui client faucet --address <your_wallet_address>
sui client faucet --address $(sui client active-address)
```

```sh
# Chạy lệnh build
sui move build
```

```sh {"terminalRows":"14"}
# Publish package và lưu output vào file client.publish.txt
sui client publish --gas-budget 100000000 | tee client.publish.txt
```