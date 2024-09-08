const express = require("express");
const morgan = require("morgan");
const cors = require("cors");
const mysql = require('mysql2/promise');
const axios = require('axios');
require('dotenv').config();

const app = express();

app.use(morgan("dev"));
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Database connection
const pool = mysql.createPool({
  host: process.env.HOST,
  user: process.env.USERDB,
  password: process.env.PASSWORDDB,
  database: process.env.DATABASE,
  waitForConnections: true,
  connectionLimit: 10,
  queueLimit: 0
});

// Investor registration CRUD
app.post("/investors", async (req, res) => {
  try {
    const { investor_kyc_id, investor_kyc_provider, investor_wallet_address, email, phone, nickname } = req.body;
    const [result] = await pool.query(
      "INSERT INTO investors (investor_kyc_id, investor_kyc_provider, investor_wallet_address, email, phone, nickname) VALUES (?, ?, ?, ?, ?, ?)",
      [investor_kyc_id, investor_kyc_provider, investor_wallet_address, email, phone, nickname]
    );
    res.status(201).json({ id: result.insertId, investor_kyc_id, investor_kyc_provider, investor_wallet_address, email, phone, nickname });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.get("/investors/:id", async (req, res) => {
  try {
    const [rows] = await pool.query("SELECT * FROM investors WHERE investor_id = ?", [req.params.id]);
    if (rows.length > 0) {
      res.json(rows[0]);
    } else {
      res.status(404).json({ error: "Investor not found" });
    }
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// ... Add other CRUD operations (UPDATE, DELETE) for investors

/*/ Call validocs API CHANGE THIS 
app.post("/validate-docs", async (req, res) => {
  try {
    // Placeholder for validocs API call
    const response = await axios.post('https://api.validocs.com/validate', req.body);
    res.json(response.data);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

/*/

// Get case data by Case ID
app.get("/cases/:id", async (req, res) => {
  try {
    const [rows] = await pool.query("SELECT * FROM cases WHERE case_id = ?", [req.params.id]);
    if (rows.length > 0) {
      res.json(rows[0]);
    } else {
      res.status(404).json({ error: "Case not found" });
    }
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Get all cases including all data
app.get("/cases", async (req, res) => {
  try {
    const [rows] = await pool.query("SELECT * FROM cases");
    res.json(rows);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Get contract address for case ID
app.get("/cases/:id/contract", async (req, res) => {
  try {
    const [rows] = await pool.query("SELECT case_wallet_address FROM cases WHERE case_id = ?", [req.params.id]);
    if (rows.length > 0) {
      res.json({ contract_address: rows[0].case_wallet_address });
    } else {
      res.status(404).json({ error: "Case not found" });
    }
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Check if investor is verified (based on KYC information)
app.get("/investors/:id/verified", async (req, res) => {
  try {
    const [rows] = await pool.query("SELECT investor_kyc_id, investor_kyc_provider FROM investors WHERE investor_id = ?", [req.params.id]);
    if (rows.length > 0) {
      // Assuming an investor is verified if they have KYC information
      const isVerified = !!rows[0].investor_kyc_id && !!rows[0].investor_kyc_provider;
      res.json({ verified: isVerified });
    } else {
      res.status(404).json({ error: "Investor not found" });
    }
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// ... existing error handling middleware ...

// Get investors by case ID
app.get("/cases/:id/investors", async (req, res) => {
  try {
    const [rows] = await pool.query(`
      SELECT i.investor_id, i.investor_kyc_id, i.investor_wallet_address, i.nickname, i.email, 
             inv.amount_invested, inv.investment_timestamp
      FROM investors i
      JOIN investments inv ON i.investor_id = inv.investor_id
      WHERE inv.case_id = ?
    `, [req.params.id]);
    
    if (rows.length > 0) {
      res.json(rows);
    } else {
      res.status(404).json({ error: "No investors found for this case" });
    }
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`Server is listening on http://localhost:${PORT}`);
});
