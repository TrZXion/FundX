import express, { Request, Response, NextFunction } from 'express';
import axios from 'axios';
import dotenv from 'dotenv';
import bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken';
import { Pool } from 'pg';
import cors from 'cors';

// Import the custom type definitions
// Ensure this path is correct relative to your server file

dotenv.config();

const app = express();
const PORT = 3000;
const API_KEY = process.env.FINNHUB_API_KEY || '';
const JWT_SECRET = process.env.JWT_SECRET || '';

// Set up PostgreSQL client
const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
});

// Enable CORS for all routes
app.use(cors());
app.use(express.json());


const authenticateToken = (req: Request, res: Response, next: NextFunction) => {
  const authHeader = req.headers.authorization;
  if (!authHeader) {
    return res.status(401).send('No token provided');
  }

  const token = authHeader.split(' ')[1];
  try {
    const decoded: any = jwt.verify(token, JWT_SECRET);
    req.userId = decoded.userId;
    next();
  } catch (error) {
    res.status(401).send('Invalid token');
  }
};

app.get('/test-db', async (req: Request, res: Response) => {
  try {
    const client = await pool.connect();
    const result = await client.query('SELECT NOW()');
    client.release();
    res.json({ message: 'Connection successful', time: result.rows[0].now });
  } catch (error) {
    console.error('Error connecting to the database:', error);
    res.status(500).send('Error connecting to the database');
  }
});


app.post('/init-stocks', authenticateToken, async (req: Request, res: Response) => {
  const userId = req.userId;
  const apiUrl = `https://finnhub.io/api/v1/stock/symbol?exchange=US&mic=XNYS&token=${API_KEY}`;

  try {
    const response = await axios.get(apiUrl);
    const symbols = response.data.slice(0, 50);

    const client = await pool.connect();
    for (const symbol of symbols) {
      await client.query(
        'INSERT INTO user_stocks (user_id, symbol, name) VALUES ($1, $2, $3) ON CONFLICT (user_id, symbol) DO NOTHING',
        [userId, symbol.symbol, symbol.description]
      );
    }
    client.release();

    res.json({ message: 'Stock symbols initialized for the user', userId });
  } catch (error) {
    console.error('Error initializing stock symbols:', error);
    res.status(500).send('Error initializing stock symbols');
  }
});

// Route to fetch stock data for the authenticated user
app.get('/stocks', authenticateToken, async (req: Request, res: Response) => {
  const userId = req.userId;

  try {
    const client = await pool.connect();
    const result = await client.query('SELECT symbol FROM user_stocks WHERE user_id = $1', [userId]);
    const symbols = result.rows.map(row => row.symbol);
    client.release();

    if (symbols.length === 0) {
      return res.status(404).json({ message: 'No stocks found for this user' });
    }

    const stockData = [];
    for (const symbol of symbols) {
      const apiUrl = `https://finnhub.io/api/v1/quote?symbol=${symbol}&token=${API_KEY}`;
      const response = await axios.get(apiUrl);
      stockData.push({ symbol, ...response.data });
    }

    res.json(stockData);
  } catch (error) {
    console.error('Error fetching stock data:', error);
    res.status(500).json({ message: 'Error fetching stock data' });
  }
});

// Route to fetch stock data for a specific symbol
app.get('/stock/:symbol', async (req: Request, res: Response) => {
  const symbol = req.params.symbol;
  const apiUrl = `https://finnhub.io/api/v1/quote?symbol=${symbol}&token=${API_KEY}`;

  try {
    const response = await axios.get(apiUrl);
    console.log(`Stock data for ${symbol}:`, response.data);
    res.json(response.data);
  } catch (error) {
    console.error('Error fetching stock data:', error);
    res.status(500).send('Error fetching stock data');
  }
});

// Sign-up endpoint
app.post('/signup', async (req: Request, res: Response) => {
  const { username, password } = req.body;

  try {
    const client = await pool.connect();

    const userExists = await client.query('SELECT * FROM users WHERE username = $1', [username]);
    if (userExists.rows.length > 0) {
      client.release();
      return res.status(400).send('User already exists');
    }

    const hashedPassword = await bcrypt.hash(password, 10);
    const insertResult = await client.query(
      'INSERT INTO users (username, password) VALUES ($1, $2) RETURNING id',
      [username, hashedPassword]
    );

    const userId = insertResult.rows[0].id;
    client.release();

    const token = jwt.sign({ userId, username }, JWT_SECRET, { expiresIn: '1h' });
    res.json({ token, userId });
    console.log('New user signed up:', username);
  } catch (error) {
    console.error('Error during sign-up:', error);
    res.status(500).send('Error during sign-up');
  }
});

app.post('/signin', async (req: Request, res: Response) => {
  const { username, password } = req.body;

  try {
    const client = await pool.connect();

    const result = await client.query('SELECT * FROM users WHERE username = $1', [username]);
    if (result.rows.length === 0) {
      client.release();
      return res.status(400).send('Invalid credentials');
    }

    const user = result.rows[0];
    const isPasswordValid = await bcrypt.compare(password, user.password);
    if (!isPasswordValid) {
      client.release();
      return res.status(400).send('Invalid credentials');
    }

    client.release();

    const token = jwt.sign({ userId: user.id, username }, JWT_SECRET, { expiresIn: '1h' });
    res.json({ token, userId: user.id });  // Include userId in the response
  } catch (error) {
    console.error('Error during sign-in:', error);
    res.status(500).send('Error during sign-in');
  }
});

app.get('/protected', authenticateToken, (req: Request, res: Response) => {
  res.json({ message: 'Protected data', userId: req.userId });
});

app.listen(PORT, () => {
  console.log(`Server is running on http://localhost:${PORT}`);
});
