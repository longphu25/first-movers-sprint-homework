# Final Assessment — Submission Template

## 👤 Participant Information

- **Full Name:** Long Phu
- **Email:** [longphu257@gmail.com]
- **Discord / Telegram Username:** [longphu25]
- **Submission Type:** Individual

---

## 🧪 Selected Challenge

- [ ] Option A — Secure Counter
- [x] Option B — Mint Pass NFT
- [ ] Option C — Simple Voting

---

## 🧠 Short Project Description (Required)

*3–5 sentences describing:*
- *What you built*
- *The core on-chain logic*
- *The main problem your solution addresses*

**Description:**

I built a Soulbound NFT Pass system on Sui blockchain using Move 2024 edition. The core logic ensures each wallet address can only mint one Pass NFT, and the NFT cannot be transferred to other addresses (soulbound). This is achieved by removing the `store` ability from the Pass struct and using a shared MintRegistry to track minted addresses. The solution addresses the need for non-transferable membership/access tokens commonly used in DAOs, event tickets, or identity verification systems.

---

## 📁 Project Structure

```
nft_pass/
├── sources/
│   └── nft_pass.move      # Main contract
├── tests/
│   └── nft_pass_tests.move # Unit tests
├── Move.toml              # Package config
├── README.md              # Detailed explanation
├── runme.md               # CLI commands guide
└── SUBMISSION.md          # This file
```

---

## 🔗 Key Features

1. **Soulbound NFT**: Pass has `key` only (no `store`), cannot be transferred
2. **One mint per address**: Registry tracks minted addresses, prevents duplicate mints
3. **Shared Registry**: Decentralized - anyone can mint without admin
4. **Event emission**: `PassMinted` event for indexing/tracking

---

## 🧪 How to Test

```bash
# Build
sui move build

# Run tests (5 test cases)
sui move test

# Publish to testnet
sui client publish --gas-budget 100000000
```

---

## 📝 Notes

- See `README.md` for detailed technical explanation
- See `runme.md` for step-by-step CLI commands
