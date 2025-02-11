// Backend Structure (Node.js)

// /backend/config/database.js
const oracledb = require('oracledb');

const dbConfig = {
  user: 'your_username',
  password: 'your_password',
  connectString: 'localhost:1521/your_service'
};

async function initialize() {
  try {
    await oracledb.createPool(dbConfig);
    console.log('Connected to Oracle database');
  } catch (err) {
    console.error('Error connecting to database:', err);
    throw err;
  }
}

module.exports = { initialize };

// /backend/models/walletModel.js
const oracledb = require('oracledb');

class WalletModel {
  static async createWallet(userId, walletName, currency) {
    const connection = await oracledb.getConnection();
    try {
      const result = await connection.execute(
        `BEGIN
           wallet_mgmt.create_wallet(:user_id, :wallet_name, :currency, :wallet_id);
         END;`,
        {
          user_id: userId,
          wallet_name: walletName,
          currency: currency,
          wallet_id: { dir: oracledb.BIND_OUT, type: oracledb.NUMBER }
        }
      );
      await connection.commit();
      return result.outBinds.wallet_id;
    } finally {
      await connection.close();
    }
  }

  static async getWalletBalance(walletId) {
    const connection = await oracledb.getConnection();
    try {
      const result = await connection.execute(
        `SELECT wallet_mgmt.get_wallet_balance(:wallet_id) as balance FROM dual`,
        { wallet_id: walletId }
      );
      return result.rows[0].BALANCE;
    } finally {
      await connection.close();
    }
  }
}

module.exports = WalletModel;

// /backend/controllers/walletController.js
const WalletModel = require('../models/walletModel');

class WalletController {
  static async createWallet(req, res) {
    try {
      const { userId, walletName, currency } = req.body;
      const walletId = await WalletModel.createWallet(userId, walletName, currency);
      res.json({ success: true, walletId });
    } catch (err) {
      res.status(500).json({ error: err.message });
    }
  }

  static async getBalance(req, res) {
    try {
      const { walletId } = req.params;
      const balance = await WalletModel.getWalletBalance(walletId);
      res.json({ balance });
    } catch (err) {
      res.status(500).json({ error: err.message });
    }
  }
}

module.exports = WalletController;

// /backend/routes/walletRoutes.js
const express = require('express');
const WalletController = require('../controllers/walletController');
const router = express.Router();

router.post('/create', WalletController.createWallet);
router.get('/:walletId/balance', WalletController.getBalance);

module.exports = router;

// /backend/server.js
const express = require('express');
const cors = require('cors');
const database = require('./config/database');
const walletRoutes = require('./routes/walletRoutes');

const app = express();
app.use(cors());
app.use(express.json());

// Routes
app.use('/api/wallets', walletRoutes);

// Initialize database and start server
database.initialize()
  .then(() => {
    app.listen(3000, () => {
      console.log('Server running on port 3000');
    });
  })
  .catch(err => {
    console.error('Failed to start server:', err);
  });

// Frontend Structure (React)

// /frontend/src/services/api.js
import axios from 'axios';

const API_URL = 'http://localhost:3000/api';

export const api = axios.create({
  baseURL: API_URL,
  headers: {
    'Content-Type': 'application/json'
  }
});

// /frontend/src/services/walletService.js
import { api } from './api';

export const walletService = {
  createWallet: async (userId, walletName, currency) => {
    const response = await api.post('/wallets/create', {
      userId,
      walletName,
      currency
    });
    return response.data;
  },

  getBalance: async (walletId) => {
    const response = await api.get(`/wallets/${walletId}/balance`);
    return response.data;
  }
};

// /frontend/src/components/WalletCard.js
import React from 'react';

const WalletCard = ({ wallet, balance }) => {
  return (
    <div className="p-4 border rounded-lg shadow-md">
      <h3 className="text-xl font-bold">{wallet.name}</h3>
      <div className="mt-2">
        <span className="text-gray-600">Balance:</span>
        <span className="ml-2 text-2xl font-bold">
          {new Intl.NumberFormat('en-US', {
            style: 'currency',
            currency: wallet.currency
          }).format(balance)}
        </span>
      </div>
    </div>
  );
};

export default WalletCard;

// /frontend/src/components/TransactionList.js
import React from 'react';

const TransactionList = ({ transactions }) => {
  return (
    <div className="mt-4">
      <h3 className="text-lg font-bold mb-2">Recent Transactions</h3>
      <div className="space-y-2">
        {transactions.map(transaction => (
          <div key={transaction.id} className="p-3 border rounded">
            <div className="flex justify-between">
              <span>{transaction.description}</span>
              <span className={transaction.type === 'INCOME' ? 'text-green-600' : 'text-red-600'}>
                {transaction.type === 'INCOME' ? '+' : '-'}
                {new Intl.NumberFormat('en-US', {
                  style: 'currency',
                  currency: 'USD'
                }).format(transaction.amount)}
              </span>
            </div>
            <div className="text-sm text-gray-500">
              {new Date(transaction.date).toLocaleDateString()}
            </div>
          </div>
        ))}
      </div>
    </div>
  );
};

export default TransactionList;

// /frontend/src/pages/Dashboard.js
import React, { useState, useEffect } from 'react';
import { walletService } from '../services/walletService';
import WalletCard from '../components/WalletCard';
import TransactionList from '../components/TransactionList';

const Dashboard = () => {
  const [wallets, setWallets] = useState([]);
  const [transactions, setTransactions] = useState([]);

  useEffect(() => {
    // Load wallets and transactions
    const loadDashboardData = async () => {
      try {
        // Implementation for loading data
      } catch (error) {
        console.error('Error loading dashboard data:', error);
      }
    };

    loadDashboardData();
  }, []);

  return (
    <div className="container mx-auto p-4">
      <h1 className="text-2xl font-bold mb-4">Dashboard</h1>
      
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
        {wallets.map(wallet => (
          <WalletCard key={wallet.id} wallet={wallet} />
        ))}
      </div>

      <TransactionList transactions={transactions} />
    </div>
  );
};

export default Dashboard;

// /frontend/src/App.js
import React from 'react';
import { BrowserRouter as Router, Routes, Route } from 'react-router-dom';
import Dashboard from './pages/Dashboard';

const App = () => {
  return (
    <Router>
      <Routes>
        <Route path="/" element={<Dashboard />} />
      </Routes>
    </Router>
  );
};

export default App;