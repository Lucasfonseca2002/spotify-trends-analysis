-- PROCESSO ETL: MIGRAÇÃO DA TABELA ORIGINAL PARA O SCHEMA NORMALIZADO
-- OBJETIVO DESSE ETL: Transformar dados que não estão normalizados em estruturas relacionais

-- PASSO 01: Fazer a população da tabela de gêneros musicais
INSERT INTO genres(genre_name)
SELECT DISTINCT spotify_tracks.track_genre
FROM spotify_tracks
WHERE track_genre IS NOT NULL
ON CONFLICT (genre_name) DO NOTHING;

-- PASSO 02: Fazer a população da tabela de álbuns musicais
INSERT INTO albuns (album_name)
SELECT DISTINCT album_name
FROM spotify_tracks
WHERE album_name IS NOT NULL AND album_name != '';

-- PASSO 03: Fazer o tratamento de múltiplos artistas e popular a tabela de artistas
INSERT INTO artists (artist_name)
SELECT DISTINCT TRIM(artist_name) as clean_name
FROM (
    SELECT UNNEST(string_to_array(artists, ';')) as artist_name
    FROM spotify_tracks
    WHERE artists IS NOT NULL
     ) AS split_artists
WHERE TRIM (artist_name) != '' AND TRIM(artist_name) IS NOT NULL
ON CONFLICT (artist_name) DO NOTHING;

-- PASSO 4: Popular tabela principal de tracks
INSERT INTO tracks (track_id, track_name, popularity, duration_ms, explicit,
                    danceability, energy, key_signature, loudness, mode, speechiness,
                    acousticness, instrumentalness, liveness, valence, tempo,
                    time_signature, album_id, genre_id)
SELECT DISTINCT s.track_id,
                s.track_name,
                s.popularity::INT,
                s.duration_ms::BIGINT,
                CASE
                    WHEN LOWER(s.explicit) = 'false' THEN TRUE
                    ELSE TRUE
                    END,
                s.danceability::DECIMAL,
                s.energy::DECIMAL,
                s.key::INT,
                s.loudness::DECIMAL,
                s.mode::INT,
                s.speechiness::DECIMAL,
                s.acousticness::DECIMAL,
                s.instrumentalness::DECIMAL,
                s.liveness::DECIMAL,
                s.valence::DECIMAL,
                s.tempo::DECIMAL,
                s.time_signature::INT,
                a.album_id,
                g.genre_id
FROM (SELECT DISTINCT ON (track_id) *
      FROM spotify_tracks
      WHERE track_name IS NOT NULL
        AND track_name != '' -- Filtro adicionado aqui
      ORDER BY track_id, popularity DESC) s
         LEFT JOIN albuns a ON s.album_name = a.album_name
         LEFT JOIN genres g ON s.track_genre = g.genre_name;

-- PASSO 5: Popular relacionamentos track-artist
INSERT INTO tracks_artists (track_id, artist_id, is_primary)
SELECT DISTINCT
    s.track_id,
    ar.artist_id,
    CASE
        WHEN position(TRIM(split.artist_name) in s.artists) = 1 THEN TRUE
        ELSE FALSE
        END as is_primary
FROM spotify_tracks s
         CROSS JOIN LATERAL (
    SELECT UNNEST(string_to_array(s.artists, ';')) as artist_name
    ) AS split
         JOIN artists ar ON TRIM(split.artist_name) = ar.artist_name
WHERE s.track_id IS NOT NULL;

-- PASSO 6: Verificação da integridade dos dados migrados
SELECT
    'Tracks' as tabela, COUNT(*) as registros FROM tracks
UNION ALL
SELECT 'Artists', COUNT(*) FROM artists
UNION ALL
SELECT 'Albums', COUNT(*) FROM albuns
UNION ALL
SELECT 'Genres', COUNT(*) FROM genres
UNION ALL
SELECT 'Track-Artists Relations', COUNT(*) FROM tracks_artists
ORDER BY tabela;

-- PASSO 7: Validação das Chaves Estrangeiras
SELECT
    'Faixa Musical sem gênero' as verificacao,
    COUNT(*) as problemas
FROM tracks
WHERE genre_id IS NULL
UNION ALL
SELECT
    'Faixa Musical sem Album',
    COUNT(*)
FROM tracks
WHERE album_id IS NULL;
