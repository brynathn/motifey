const express = require("express");
const bcrypt = require("bcryptjs");
const jwt = require("jsonwebtoken");

const app = express();
const PORT = 3000;

const pool = require("./db");

app.use(express.json());

const SECRET_KEY = "motifey_secret"; // nanti pindah ke .env

/// 🏠 TEST
app.get("/", (req, res) => {
  res.send("🚀 Motifey Backend Running!");
});

/// 🔐 AUTH MIDDLEWARE
function authMiddleware(req, res, next) {
  const authHeader = req.headers["authorization"];

  if (!authHeader) {
    return res.status(401).json({ message: "No token provided" });
  }

  const token = authHeader.split(" ")[1];

  try {
    const decoded = jwt.verify(token, SECRET_KEY);
    req.user = decoded;
    next();
  } catch {
    return res.status(403).json({ message: "Invalid token" });
  }
}

//////////////////////////////////////////////////////
// 🔐 AUTH
//////////////////////////////////////////////////////

app.post("/signup", async (req, res) => {
  const { username, password } = req.body;

  try {
    const existing = await pool.query(
      "SELECT * FROM users WHERE username = $1",
      [username]
    );

    if (existing.rows.length > 0) {
      return res.status(400).json({ message: "User already exists" });
    }

    const hashedPassword = await bcrypt.hash(password, 10);

    const defaultProfile =
      "https://xyfdsaighjmiiketlhep.supabase.co/storage/v1/object/public/profile/default_profile.png";

    const result = await pool.query(
      `INSERT INTO users (id, username, password, profile_image)
       VALUES (gen_random_uuid(), $1, $2, $3)
       RETURNING id, username, profile_image`,
      [username, hashedPassword, defaultProfile]
    );

    res.json(result.rows[0]);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.post("/login", async (req, res) => {
  const { username, password } = req.body;

  try {
    const result = await pool.query(
      "SELECT * FROM users WHERE username = $1",
      [username]
    );

    if (result.rows.length === 0) {
      return res.status(401).json({ message: "User not found" });
    }

    const user = result.rows[0];

    const isMatch = await bcrypt.compare(password, user.password);

    if (!isMatch) {
      return res.status(401).json({ message: "Wrong password" });
    }

    const token = jwt.sign(
      { userId: user.id, username: user.username },
      SECRET_KEY,
      { expiresIn: "1h" }
    );

    res.json({
      token,
      user: {
        id: user.id,
        username: user.username,
        profile_image: user.profile_image,
      },
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

//////////////////////////////////////////////////////
// 🎵 SONGS
//////////////////////////////////////////////////////

app.get("/songs", async (req, res) => {
  try {
    const result = await pool.query(
      "SELECT * FROM songs ORDER BY title ASC"
    );
    res.json(result.rows);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.post("/songs", authMiddleware, async (req, res) => {
  const { title, artist, url, cover } = req.body;

  if (!title || !artist || !url) {
    return res.status(400).json({ message: "Data tidak lengkap" });
  }

  try {
    const result = await pool.query(
      `INSERT INTO songs (id, title, artist, url, cover)
       VALUES (gen_random_uuid(), $1, $2, $3, $4)
       RETURNING *`,
      [title, artist, url, cover]
    );

    res.json(result.rows[0]);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.put("/songs/:id", async (req, res) => {
  const { id } = req.params;
  const { url, cover } = req.body;

  try {
    const result = await pool.query(
      `UPDATE songs
       SET url = $1, cover = $2
       WHERE id = $3
       RETURNING *`,
      [url, cover, id]
    );

    res.json(result.rows[0]);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.put("/playlists/:id", authMiddleware, async (req, res) => {
  const { id } = req.params;
  const { title, description, cover } = req.body;

  try {
    // 🔍 cek playlist ada & milik user
    const existing = await pool.query(
      "SELECT * FROM playlists WHERE id = $1 AND creator_id = $2",
      [id, req.user.userId]
    );

    if (existing.rows.length === 0) {
      return res.status(404).json({
        message: "Playlist not found or not yours",
      });
    }

    // 🔄 update (partial update)
    const result = await pool.query(
      `
      UPDATE playlists
      SET 
        title = COALESCE($1, title),
        description = COALESCE($2, description),
        cover = COALESCE($3, cover)
      WHERE id = $4
      RETURNING *
      `,
      [title, description, cover, id]
    );

    res.json(result.rows[0]);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

//////////////////////////////////////////////////////
// 📁 PLAYLIST
//////////////////////////////////////////////////////

app.post("/playlists", authMiddleware, async (req, res) => {
  const { title, description, cover } = req.body;
  const userId = req.user.userId;

  if (!title) {
    return res.status(400).json({ message: "Title wajib" });
  }

  try {
    const result = await pool.query(
      `INSERT INTO playlists (id, title, creator_id, description, cover)
       VALUES (gen_random_uuid(), $1, $2, $3, $4)
       RETURNING *`,
      [title, userId, description, cover]
    );

    res.json(result.rows[0]);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.get("/playlists", authMiddleware, async (req, res) => {
  const userId = req.user.userId;

  try {
    const result = await pool.query(
      `
      SELECT 
        p.*, 
        COUNT(ps.song_id)::int AS song_count
      FROM playlists p
      LEFT JOIN playlist_songs ps ON p.id = ps.playlist_id
      WHERE p.creator_id = $1
      GROUP BY p.id
      ORDER BY p.created_at DESC
      `,
      [userId]
    );

    res.json(result.rows);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

//////////////////////////////////////////////////////
// 🔗 PLAYLIST SONGS
//////////////////////////////////////////////////////

app.post("/playlists/:id/songs", authMiddleware, async (req, res) => {
  const { songId } = req.body;
  const playlistId = req.params.id;

  try {
    await pool.query(
      `INSERT INTO playlist_songs (playlist_id, song_id)
       VALUES ($1, $2)
       ON CONFLICT DO NOTHING`,
      [playlistId, songId]
    );

    res.json({ message: "Song added (safe)" });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.get("/playlists/:id/songs", async (req, res) => {
  const playlistId = req.params.id;

  try {
    const result = await pool.query(
      `
      SELECT s.*
      FROM songs s
      JOIN playlist_songs ps ON s.id = ps.song_id
      WHERE ps.playlist_id = $1
      `,
      [playlistId]
    );

    res.json(result.rows);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.get("/profile", authMiddleware, async (req, res) => {
  try {
    const result = await pool.query(
      "SELECT id, username, profile_image FROM users WHERE id = $1",
      [req.user.userId]
    );

    res.json(result.rows[0]);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.get("/playlists-with-status/:songId", authMiddleware, async (req, res) => {
  const userId = req.user.userId;
  const { songId } = req.params;

  try {
    const result = await pool.query(
      `
      SELECT 
        p.id,
        p.title,
        p.cover,
        COUNT(ps.song_id)::int AS song_count,
        EXISTS (
          SELECT 1 FROM playlist_songs ps2
          WHERE ps2.playlist_id = p.id
          AND ps2.song_id = $2
        ) AS is_added
      FROM playlists p
      LEFT JOIN playlist_songs ps ON p.id = ps.playlist_id
      WHERE p.creator_id = $1
      GROUP BY p.id
      ORDER BY p.created_at DESC
      `,
      [userId, songId]
    );

    res.json(result.rows);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.delete("/playlists/:id/songs/:songId", authMiddleware, async (req, res) => {
  const { id: playlistId, songId } = req.params;

  try {
    await pool.query(
      `DELETE FROM playlist_songs
       WHERE playlist_id = $1 AND song_id = $2`,
      [playlistId, songId]
    );

    res.json({ message: "Song removed" });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.put("/profile", authMiddleware, async (req, res) => {
  const { profile_image } = req.body;

  try {
    const result = await pool.query(
      `UPDATE users
       SET profile_image = $1
       WHERE id = $2
       RETURNING id, username, profile_image`,
      [profile_image, req.user.userId]
    );

    res.json(result.rows[0]);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.post("/logout", authMiddleware, (req, res) => {
  res.json({
    message: "Logout berhasil",
  });
});

app.post("/seed", async (req, res) => {
  try {
    // 🔥 START TRANSACTION
    await pool.query("BEGIN");

    const baseStorageUrl = "https://xyfdsaighjmiiketlhep.supabase.co/storage/v1/object/public";

    //////////////////////////////////////////////////////
    // 🎵 INSERT SONGS
    //////////////////////////////////////////////////////
    const songs = [
      ["Wish You Were Here", "Avril Lavigne"],
      ["Light It Up", "Major Lazer"],
      ["Shape Of My Heart", "Backstreet Boys"],
      ["Billie Jean", "Michael Jackson"],
      ["Umbrella", "Rihanna"],
      ["Love Me Harder", "Ariana Grande"],
      ["Confident", "Justin Bieber"],
      ["All The Stars", "Kendrick Lamar"],
    ];

    const songIds = [];

    for (let i = 0; i < songs.length; i++) {
      const [title, artist] = songs[i];
      const index = i + 1;

      const result = await pool.query(
        `INSERT INTO songs (id, title, artist, url, cover)
         VALUES (gen_random_uuid(), $1, $2, $3, $4)
         RETURNING id`,
        [
          title,
          artist,
          `${baseStorageUrl}/songs/song${index}.mp3`, // Link Lagu
          `${baseStorageUrl}/covers/songCover/cover${index}.jpeg`, // Link Cover Lagu
        ]
      );

      songIds.push(result.rows[0].id);
    }

    //////////////////////////////////////////////////////
    // 📁 INSERT PLAYLISTS
    //////////////////////////////////////////////////////
    const userResult = await pool.query("SELECT id FROM users LIMIT 1");

    if (userResult.rows.length === 0) {
      throw new Error("Tidak ada user, signup dulu bro!");
    }

    const userId = userResult.rows[0].id;

    // Format: [Judul, Deskripsi, Index Lagu 1, Index Lagu 2]
    const playlists = [
      ["Chill Hits", "Relax and unwind", 0, 1],
      ["Throwback", "Old but gold", 2, 3],
      ["Focus Mode", "Stay productive", 4, 5],
      ["Daily Mix", "Random mix", 6, 7],
    ];

    for (let i = 0; i < playlists.length; i++) {
      const [title, desc, s1, s2] = playlists[i];
      const index = i + 1;

      const plResult = await pool.query(
        `INSERT INTO playlists (id, title, creator_id, description, cover)
         VALUES (gen_random_uuid(), $1, $2, $3, $4)
         RETURNING id`,
        [
          title,
          userId,
          desc,
          `${baseStorageUrl}/covers/playlistCover/playlist${index}.jpg`, // Link Cover Playlist
        ]
      );

      const playlistId = plResult.rows[0].id;

      // 🔗 RELATION (Menghubungkan playlist ke lagu yang sudah dibuat)
      await pool.query(
        `INSERT INTO playlist_songs (playlist_id, song_id)
         VALUES ($1, $2), ($1, $3)`,
        [playlistId, songIds[s1], songIds[s2]]
      );
    }

    // ✅ COMMIT
    await pool.query("COMMIT");

    res.json({ message: "🔥 SEED SUCCESS! Data sudah masuk ke PostgreSQL." });
  } catch (err) {
    await pool.query("ROLLBACK");
    res.status(500).json({ error: err.message });
  }
});

//////////////////////////////////////////////////////
// 🚀 START SERVER
//////////////////////////////////////////////////////

app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});