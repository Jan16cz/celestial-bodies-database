import express from 'express';
import jwt from 'jsonwebtoken';
import { authenticate } from './middleware/authenticate.js';
import { authorizeModification } from './middleware/authorize.js';
import { getUsers, getWatchlist, addMovie, updateMovie, removeMovie } from './utils/db.js';

const app = express();
app.use(express.json());

const SECRET = process.env.JWT_SECRET || 'secret';

app.post('/api/auth/login', (req, res) => {
  const { username, password } = req.body;
  if (!username || !password) {
    return res.status(400).json({ error: "Username and password required" });
  }

  const users = getUsers();
  const user = users.find(u => u.username === username);
  if (!user || user.password !== password) {
    return res.status(401).json({ error: "Invalid credentials" });
  }

  const token = jwt.sign({ id: user.id, role: user.role, username: user.username }, SECRET, { expiresIn: '1h' });
  res.json({ token });
});

app.get('/api/watchlist/:userId', authenticate, (req, res) => {
  const watchlist = getWatchlist(req.params.userId);
  res.json(watchlist);
});

app.post('/api/watchlist/:userId/movies', authenticate, authorizeModification, (req, res) => {
  const updated = addMovie(req.params.userId, req.body);
  res.status(201).json(updated);
});

app.put('/api/watchlist/:userId/movies/:movieId', authenticate, authorizeModification, (req, res) => {
  const updated = updateMovie(req.params.userId, req.params.movieId, req.body);
  res.status(200).json(updated);
});

app.delete('/api/watchlist/:userId/movies/:movieId', authenticate, authorizeModification, (req, res) => {
  const updated = removeMovie(req.params.userId, req.params.movieId);
  res.status(200).json(updated);
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`Server is running on port ${PORT}`);
});