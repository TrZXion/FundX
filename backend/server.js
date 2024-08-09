"use strict";
var __awaiter = (this && this.__awaiter) || function (thisArg, _arguments, P, generator) {
    function adopt(value) { return value instanceof P ? value : new P(function (resolve) { resolve(value); }); }
    return new (P || (P = Promise))(function (resolve, reject) {
        function fulfilled(value) { try { step(generator.next(value)); } catch (e) { reject(e); } }
        function rejected(value) { try { step(generator["throw"](value)); } catch (e) { reject(e); } }
        function step(result) { result.done ? resolve(result.value) : adopt(result.value).then(fulfilled, rejected); }
        step((generator = generator.apply(thisArg, _arguments || [])).next());
    });
};
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = __importDefault(require("express"));
const axios_1 = __importDefault(require("axios"));
const dotenv_1 = __importDefault(require("dotenv"));
const bcryptjs_1 = __importDefault(require("bcryptjs"));
const jsonwebtoken_1 = __importDefault(require("jsonwebtoken"));
const pg_1 = require("pg");
const cors_1 = __importDefault(require("cors"));
// Import the custom type definitions
// Ensure this path is correct relative to your server file
dotenv_1.default.config();
const app = (0, express_1.default)();
const PORT = 3000;
const API_KEY = process.env.FINNHUB_API_KEY || '';
const JWT_SECRET = process.env.JWT_SECRET || 'your_jwt_secret';
// Set up PostgreSQL client
const pool = new pg_1.Pool({
    connectionString: process.env.DATABASE_URL,
});
// Enable CORS for all routes
app.use((0, cors_1.default)());
app.use(express_1.default.json());
// Middleware to authenticate and extract user ID from JWT
const authenticateToken = (req, res, next) => {
    const authHeader = req.headers.authorization;
    if (!authHeader) {
        return res.status(401).send('No token provided');
    }
    const token = authHeader.split(' ')[1];
    try {
        const decoded = jsonwebtoken_1.default.verify(token, JWT_SECRET);
        req.userId = decoded.userId; // Attach the user ID to the request object
        next();
    }
    catch (error) {
        res.status(401).send('Invalid token');
    }
};
app.get('/test-db', (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    try {
        const client = yield pool.connect();
        const result = yield client.query('SELECT NOW()');
        client.release();
        res.json({ message: 'Connection successful', time: result.rows[0].now });
    }
    catch (error) {
        console.error('Error connecting to the database:', error);
        res.status(500).send('Error connecting to the database');
    }
}));
// Route to initialize stock data for a user
app.post('/init-stocks', authenticateToken, (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    const userId = req.userId; // Retrieve user ID from the authenticated request
    const apiUrl = `https://finnhub.io/api/v1/stock/symbol?exchange=US&mic=XNYS&token=${API_KEY}`;
    try {
        const response = yield axios_1.default.get(apiUrl);
        const symbols = response.data.slice(0, 50);
        const client = yield pool.connect();
        for (const symbol of symbols) {
            yield client.query('INSERT INTO user_stocks (user_id, symbol, name) VALUES ($1, $2, $3) ON CONFLICT (user_id, symbol) DO NOTHING', [userId, symbol.symbol, symbol.description]);
        }
        client.release();
        // Send a response indicating success
        res.json({ message: 'Stock symbols initialized for the user', userId });
    }
    catch (error) {
        console.error('Error initializing stock symbols:', error);
        res.status(500).send('Error initializing stock symbols');
    }
}));
// Route to fetch stock data for the authenticated user
app.get('/stocks', authenticateToken, (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    const userId = req.userId;
    try {
        const client = yield pool.connect();
        const result = yield client.query('SELECT symbol FROM user_stocks WHERE user_id = $1', [userId]);
        const symbols = result.rows.map(row => row.symbol);
        client.release();
        if (symbols.length === 0) {
            return res.status(404).json({ message: 'No stocks found for this user' });
        }
        const stockData = [];
        for (const symbol of symbols) {
            const apiUrl = `https://finnhub.io/api/v1/quote?symbol=${symbol}&token=${API_KEY}`;
            const response = yield axios_1.default.get(apiUrl);
            stockData.push(Object.assign({ symbol }, response.data));
        }
        res.json(stockData);
    }
    catch (error) {
        console.error('Error fetching stock data:', error);
        res.status(500).json({ message: 'Error fetching stock data' });
    }
}));
// Route to fetch stock data for a specific symbol
app.get('/stock/:symbol', (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    const symbol = req.params.symbol;
    const apiUrl = `https://finnhub.io/api/v1/quote?symbol=${symbol}&token=${API_KEY}`;
    try {
        const response = yield axios_1.default.get(apiUrl);
        console.log(`Stock data for ${symbol}:`, response.data);
        res.json(response.data);
    }
    catch (error) {
        console.error('Error fetching stock data:', error);
        res.status(500).send('Error fetching stock data');
    }
}));
// Sign-up endpoint
app.post('/signup', (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    const { username, password } = req.body;
    try {
        const client = yield pool.connect();
        const userExists = yield client.query('SELECT * FROM users WHERE username = $1', [username]);
        if (userExists.rows.length > 0) {
            client.release();
            return res.status(400).send('User already exists');
        }
        const hashedPassword = yield bcryptjs_1.default.hash(password, 10);
        const insertResult = yield client.query('INSERT INTO users (username, password) VALUES ($1, $2) RETURNING id', [username, hashedPassword]);
        const userId = insertResult.rows[0].id;
        client.release();
        const token = jsonwebtoken_1.default.sign({ userId, username }, JWT_SECRET, { expiresIn: '1h' });
        res.json({ token, userId });
        console.log('New user signed up:', username);
    }
    catch (error) {
        console.error('Error during sign-up:', error);
        res.status(500).send('Error during sign-up');
    }
}));
app.post('/signin', (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    const { username, password } = req.body;
    try {
        const client = yield pool.connect();
        const result = yield client.query('SELECT * FROM users WHERE username = $1', [username]);
        if (result.rows.length === 0) {
            client.release();
            return res.status(400).send('Invalid credentials');
        }
        const user = result.rows[0];
        const isPasswordValid = yield bcryptjs_1.default.compare(password, user.password);
        if (!isPasswordValid) {
            client.release();
            return res.status(400).send('Invalid credentials');
        }
        client.release();
        const token = jsonwebtoken_1.default.sign({ userId: user.id, username }, JWT_SECRET, { expiresIn: '1h' });
        res.json({ token, userId: user.id }); // Include userId in the response
    }
    catch (error) {
        console.error('Error during sign-in:', error);
        res.status(500).send('Error during sign-in');
    }
}));
app.get('/protected', authenticateToken, (req, res) => {
    res.json({ message: 'Protected data', userId: req.userId });
});
app.listen(PORT, () => {
    console.log(`Server is running on http://localhost:${PORT}`);
});
