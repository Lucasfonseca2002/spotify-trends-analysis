-- NORMALIZAÇÃO DO SCHEMA PARA ANÁLISE AVANÇADA
-- OBJETIVO: Realizar a separação dos dados em tabelas relacionais para análises mais complexas

-- TABELA DE GÊNEROS MUSICAIS
CREATE TABLE genres
(
    genre_id   SERIAL PRIMARY KEY,
    genre_name VARCHAR(100) NOT NULL UNIQUE
);

-- TABELA DE ARTISTAS
CREATE TABLE artists
(
    artist_id SERIAL PRIMARY KEY,
    artist_name VARCHAR(255) NOT NULL UNIQUE
);

-- TABELA DE ÁLBUNS MUSICAIS
CREATE TABLE albuns
(
    album_id   SERIAL PRIMARY KEY,
    album_name VARCHAR(255) NOT NULL
);

-- TABELA PRINCIPAL DE TRACKS
CREATE TABLE tracks
(
    track_id         VARCHAR(50) PRIMARY KEY,
    track_name       VARCHAR(500) NOT NULL,
    popularity       INT,
    duration_ms      BIGINT,
    explicit         BOOLEAN,
    danceability     DECIMAL(6, 3),
    energy           DECIMAL(6, 3),
    key_signature    INT,
    loudness         DECIMAL(8, 3),  -- Valores negativos como -17.235
    mode             INT,
    speechiness      DECIMAL(10, 6), -- Para valores como 0.0763
    acousticness     DECIMAL(6, 3),
    instrumentalness DECIMAL(10, 8), -- Para notação científica como 1.01e-06
    liveness         DECIMAL(6, 4),
    valence          DECIMAL(6, 3),
    tempo            DECIMAL(8, 3),
    time_signature   INT,
    album_id         INT,
    genre_id         INT,
    FOREIGN KEY (album_id) REFERENCES albuns (album_id),
    FOREIGN KEY (genre_id) REFERENCES genres (genre_id)
);

-- TABELA DE TRACKS-ARTISTAS (MUITOS PARA MUITOS)
CREATE TABLE tracks_artists
(
    track_id   VARCHAR(50),
    artist_id  INT,
    is_primary BOOLEAN DEFAULT FALSE,
    PRIMARY KEY (track_id, artist_id),
    FOREIGN KEY (track_id) REFERENCES tracks (track_id),
    FOREIGN KEY (artist_id) REFERENCES artists (artist_id)
);

ALTER TABLE tracks ALTER COLUMN track_name TYPE VARCHAR(800);
ALTER TABLE albuns ALTER COLUMN album_name TYPE VARCHAR(800);
ALTER TABLE artists ALTER COLUMN artist_name TYPE VARCHAR(500);

