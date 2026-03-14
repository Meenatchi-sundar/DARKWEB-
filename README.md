# CryptoTrace – Dark Web Cryptocurrency Flow Analyzer

CryptoTrace is a full-stack cybersecurity application designed to investigate stolen cryptocurrency and trace transaction flows across Bitcoin and Ethereum networks.

## Features
- **Wallet Investigation:** Analyze multi-hop transaction history.
- **Risk Scoring:** AI-driven detection of suspicious patterns and mixer usage.
- **Visual Flow Graph:** Interactive D3.js powered visualization of fund movements.
- **Investigation Reports:** Downloadable PDF reports for forensics evidence.
- **Dark Web Theme:** Premium cybersecurity dashboard design.

## Tech Stack
- **Frontend:** React.js, Tailwind CSS, D3.js, Lucide Icons, Framer Motion.
- **Backend:** Node.js, Express.js.
- **Data:** Axios, Blockchain APIs (Etherscan, Blockchain.com).
- **Reporting:** PDFKit.

## Getting Started

### Prerequisites
- Node.js (v16 or higher)
- npm or yarn

### Installation

1. Clone the repository:
```bash
# Extract the files to your local directory
```

2. Install Backend Dependencies:
```bash
cd backend
npm install
```

3. Install Frontend Dependencies:
```bash
cd frontend
npm install
```

### Configuration
Create a `.env` file in the `backend` directory:
```env
PORT=5000
# Optional: Add your API keys for real blockchain data
ETHERSCAN_API_KEY=your_etherscan_key_here
```

### Running the Application

1. Start the Backend Server:
```bash
cd backend
npm run dev # or: "node index.js"
```

2. Start the Frontend Development Server:
```bash
cd frontend
npm run dev
```

3. Open your browser and navigate to `http://localhost:5173`.

### Demo Access
Use the following demo wallet to see the analyzer in action:
- **Ethereum:** `0x71c7656ec7ab88b098defb751b7401b5f6d8976f`
- **Bitcoin:** `1A1zP1eP5QGefi2DMPTfTL5SLmv7DivfNa`

## License
MIT
