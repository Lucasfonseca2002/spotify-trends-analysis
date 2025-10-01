-- ANÁLISES COMPLEXAS COM SCHEMA NORMALIZADO

-- OBJETIVO: Demonstrar utilizando conceitos de análise mais avançadas para descobrir informações interessantes e relevantes para esse projeto

-- 1. ANÁLISE DE COLABORAÇÕES ENTRE ARTISTAS
-- OBJETIVO: Entender quais artistas colaboram mais e se essas colaborações geram maior sucesso comercial
-- Esta análise só é possível com o modelo normalizado, pois na tabela original múltiplos artistas ficavam concatenados

SELECT
    a1.artist_name as artista_principal,
    a2.artist_name as colaborador,
    COUNT(*) as total_colaboracoes,
    ROUND(AVG(t.popularity), 1) as media_popularidade_colaboracoes,
    STRING_AGG(t.track_name, ', ') as exemplos_musicas
FROM trackS_artists ta1
JOIN tracks_artists ta2 ON ta1.track_id = ta2.track_id AND  ta1.artist_id != ta2.artist_id
JOIN artists a1 ON ta1.artist_id = a1.artist_id
JOIN artists a2 ON ta2.artist_id = a2.artist_id
JOIN tracks t ON ta1.track_id = t.track_id
WHERE ta1.is_primary = TRUE  -- garantia de análise de artistas vs colaborador
GROUP BY a1.artist_name, a2.artist_name
HAVING COUNT(*) >= 2  -- buscar pelo menos duas colaborações
ORDER BY total_colaboracoes DESC, media_popularidade_colaboracoes DESC
LIMIT 15;

-- DOCUMENTAÇÃO:
-- O que faz: Identifica pares de artistas que colaboram frequentemente e mede o sucesso dessas parcerias.
-- Como funciona: Usa SELF JOIN na tabela tracks_artists para encontrar múltiplos artistas na mesma música.
--               A condição ta1.is_primary = TRUE garante que analisamos artista principal vs colaborador.
-- Por que é importante: Colaborações são estratégicas na indústria musical para alcançar diferentes audiências.
--                      Esta análise revela quais parcerias são mais produtivas e bem-sucedidas.
-- Insights esperados: Identificar duplas recorrentes, medir impacto comercial de colaborações,
--                     e descobrir se artistas colaborativos têm maior sucesso médio.

-- 2. ARTISTAS MAIS VERSÁTEIS (MÚLTIPLOS GÊNEROS)
-- OBJETIVO: Buscar entender e identificar quais artistas experimentam diferentes gêneros e se essa diversidade tem impacto no sucesso

SELECT
    a.artist_name AS nome_artista,
    COUNT(DISTINCT g.genre_id) AS generos_explorados,
    COUNT(DISTINCT t.track_id) AS total_musicas,
    ROUND(AVG(t.popularity), 1) AS media_popularidade,
    STRING_AGG(DISTINCT g.genre_name, ' , ' ORDER BY g.genre_name) AS listas_generos
FROM artists a
INNER JOIN tracks_artists ta ON a.artist_id = ta.artist_id
INNER JOIN tracks t ON ta.track_id = t.track_id
INNER JOIN genres g ON t.genre_id = g.genre_id
WHERE t.popularity IS NOT NULL
GROUP BY a.artist_name, a.artist_id
HAVING COUNT(DISTINCT g.genre_id) >= 3 AND COUNT(DISTINCT t.track_id) >= 5
ORDER BY generos_explorados DESC, media_popularidade DESC
LIMIT 15;

-- DOCUMENTAÇÃO:
-- O que faz: Analisa artistas que trabalham em múltiplos gêneros e mede sua versatilidade.
-- Como funciona: Conta gêneros distintos por artista e calcula métricas de sucesso.
-- Por que é importante: Versatilidade pode indicar inovação, mas também pode diluir identidade de marca.
-- Insights esperados: Se diversidade de gêneros correlaciona com sucesso comercial.

-- 3. CONSISTÊNCIA DE ÁLBUNS (ANÁLISE DE VARIABILIDADE)
-- OBJETIVO: Encontrar álbuns com qualidades consistentes vs álbuns musicais com hits isolados

SELECT
    al.album_name,
    COUNT(t.track_id) as total_faixas,
    ROUND(AVG(t.popularity), 1) as media_popularidade,
    ROUND(STDDEV(t.popularity), 2) as desvio_padrao,
    MIN(t.popularity) as menor_popularidade,
    MAX(t.popularity) as maior_popularidade,
    CASE
        WHEN STDDEV(t.popularity) <= 10 THEN 'Muito Consistente'
        WHEN STDDEV(t.popularity) <= 20 THEN 'Consistente'
        ELSE 'Váriavel'
    END as perfil_de_consistencia
FROM albuns al
INNER JOIN tracks t ON al.album_id = t.album_id
WHERE t.popularity IS NOT NULL
GROUP BY al.album_name, al.album_id
HAVING COUNT(t.track_id) >= 8
ORDER BY desvio_padrao DESC, media_popularidade DESC
LIMIT 15;

-- 4. TOP ARTISTAS POR GÊNERO
-- OBJETIVO: Identificar os artistas dominantes em cada gênero musical

SELECT
    g.genre_name as nome_genero,
    a.artist_name as nome_artista,
    COUNT(DISTINCT t.track_id) AS total_musicas,
    ROUND(AVG(t.popularity), 1) as media_popularidade,
    MAX(t.popularity) as melhor_hit_musical
FROM genres g
INNER JOIN tracks t ON g.genre_id = t.genre_id
INNER JOIN tracks_artists ta ON t.track_id = ta.track_id
INNER JOIN artists a ON ta.artist_id = a.artist_id
WHERE t.popularity IS NOT NULL
GROUP BY g.genre_name, a.artist_name
HAVING COUNT(DISTINCT t.track_id) >= 3
ORDER BY g.genre_name, total_musicas DESC
LIMIT 15;

-- DOCUMENTAÇÃO:
-- O que faz: Lista os artistas mais produtivos em cada gênero.
-- Como funciona: Agrupa por gênero e artista, ordena por volume de produção.
-- Por que é importante: Cada gênero tem seus próprios líderes e especialistas.
-- Insights esperados: Mapa de domínio territorial na música por gênero.


-- 5. ANÁLISE DE FEATURES DE ÁUDIO POR GÊNERO NORMALIZADO
-- OBJETIVO: Comparar características sonoras médias usando o modelo relacional

SELECT
    g.genre_name,
    COUNT(t.track_id) AS total_tracks,
    ROUND(AVG(t.danceability), 3) AS media_danceability,
    ROUND(AVG(t.energy), 3) AS media_energy,
    ROUND(AVG(t.valence), 3) AS media_valence,
    ROUND(AVG(t.acousticness), 3) AS media_acousticness,
    ROUND(AVG(t.popularity), 1) AS media_popularidade
FROM genres g
         INNER JOIN tracks t ON g.genre_id = t.genre_id
WHERE t.popularity IS NOT NULL
GROUP BY g.genre_id, g.genre_name
HAVING COUNT(t.track_id) >= 30
ORDER BY media_popularidade DESC
LIMIT 20;

-- DOCUMENTAÇÃO:
-- O que faz: Calcula perfil sonoro médio de cada gênero usando tabelas normalizadas.
-- Como funciona: Agrega características de áudio por gênero.
-- Por que é importante: Valida se a normalização mantém integridade dos dados originais.
-- Insights esperados: Perfis sonoros por gênero devem ser consistentes com análises anteriores.

-- 6. MÚSICAS ACIMA DA MÉDIA PARA SEU GÊNERO MUSICAL
-- OBJETIVO: Identificar músicas que se destacam dentro de seu próprio gênero musical
-- Para essa análise será utilizando metodo de subconsulta para comparar cada música com a média do seu gênero

WITH GenreStats AS (
    SELECT
        genre_id,
        AVG(popularity) AS avg_genre_popularity
    FROM tracks
    GROUP BY genre_id
)
SELECT
    t.track_name,
    a.artist_name,
    g.genre_name,
    t.popularity AS popularidade_musica,
    -- A média do gênero agora vem diretamente da nossa CTE, sem subconsulta.
    ROUND(gs.avg_genre_popularity, 1) AS media_genero,
    -- A diferença também é um cálculo simples agora.
    ROUND(t.popularity - gs.avg_genre_popularity, 1) AS diferenca_media
FROM tracks t
         INNER JOIN genres g ON t.genre_id = g.genre_id
         INNER JOIN tracks_artists ta ON t.track_id = ta.track_id
         INNER JOIN artists a ON ta.artist_id = a.artist_id
         INNER JOIN GenreStats gs ON t.genre_id = gs.genre_id
WHERE
    t.popularity > gs.avg_genre_popularity
  AND t.popularity IS NOT NULL
ORDER BY
    diferenca_media DESC
LIMIT 10;


-- 7. ARTISTAS COM MAIOR VARIAÇÃO DE POPULARIDADE
-- MOTIVAÇÃO: Encontrar artistas inconsistentes (hits grandes + flops) vs artistas estáveis
-- Usa subconsulta para calcular diferença entre melhor e pior desempenho

SELECT
    a.artist_name,
    COUNT(t.track_id) as total_musicas,
    MAX(t.popularity) as maior_hit,
    MIN(t.popularity) as menor_hit,
    ROUND(AVG(t.popularity), 1) as media_popularidade,
    (MAX(t.popularity) - MIN(t.popularity)) as amplitude_variacao,
    CASE
        WHEN (MAX(t.popularity) - MIN(t.popularity)) > 50 THEN 'Muito Instável'
        WHEN (MAX(t.popularity) - MIN(t.popularity)) > 30 THEN 'Instável'
        ELSE 'Estável'
        END as perfil_consistencia
FROM artists a
         INNER JOIN tracks_artists ta ON a.artist_id = ta.artist_id
         INNER JOIN tracks t ON ta.track_id = t.track_id
WHERE t.popularity IS NOT NULL
  AND a.artist_id IN (
    SELECT ta2.artist_id
    FROM tracks_artists ta2
    GROUP BY ta2.artist_id
    HAVING COUNT(DISTINCT ta2.track_id) >= 8  -- Apenas artistas com amostra mínima
)
GROUP BY a.artist_id, a.artist_name
HAVING (MAX(t.popularity) - MIN(t.popularity)) >= 30
ORDER BY amplitude_variacao DESC
LIMIT 15;

-- DOCUMENTAÇÃO:
-- O que faz: Identifica artistas com grande variação entre seus maiores sucessos e fracassos.
-- Como funciona: Subconsulta filtra artistas com volume mínimo, query principal calcula amplitude.
-- Por que é importante: Alta variação pode indicar experimentação artística ou falta de identidade clara.
--                      Artistas estáveis mantêm qualidade consistente.
-- Insights esperados: Distinguir "one-hit wonders" de artistas com múltiplos sucessos equilibrados.


-- 8. GÊNEROS COM MAIOR CONCENTRAÇÃO DE ARTISTAS POPULARES
-- MOTIVAÇÃO: Descobrir quais gêneros têm maior concentração de artistas bem-sucedidos
-- Usa subconsulta para definir threshold de "artista popular" e analisa distribuição por gênero

SELECT
    g.genre_name,
    COUNT(DISTINCT a.artist_id) as total_artistas_no_genero,
    COUNT(DISTINCT CASE
                       WHEN avg_pop.media_artista >= (SELECT AVG(popularity) FROM tracks WHERE popularity IS NOT NULL)
                           THEN a.artist_id
        END) as artistas_populares,
    ROUND(100.0 * COUNT(DISTINCT CASE
                                     WHEN avg_pop.media_artista >= (SELECT AVG(popularity) FROM tracks WHERE popularity IS NOT NULL)
                                         THEN a.artist_id
        END) / COUNT(DISTINCT a.artist_id), 1) as percentual_populares
FROM genres g
         INNER JOIN tracks t ON g.genre_id = t.genre_id
         INNER JOIN tracks_artists ta ON t.track_id = ta.track_id
         INNER JOIN artists a ON ta.artist_id = a.artist_id
         INNER JOIN (
    SELECT
        ta2.artist_id,
        t2.genre_id,
        AVG(t2.popularity) as media_artista
    FROM tracks t2
             INNER JOIN tracks_artists ta2 ON t2.track_id = ta2.track_id
    WHERE t2.popularity IS NOT NULL
    GROUP BY ta2.artist_id, t2.genre_id
) avg_pop ON a.artist_id = avg_pop.artist_id AND g.genre_id = avg_pop.genre_id
WHERE t.popularity IS NOT NULL
GROUP BY g.genre_id, g.genre_name
HAVING COUNT(DISTINCT a.artist_id) >= 10  -- Gêneros com amostra mínima
ORDER BY percentual_populares DESC
LIMIT 15;

-- DOCUMENTAÇÃO:
-- O que faz: Calcula que percentual dos artistas em cada gênero são considerados "populares".
-- Como funciona: Subconsulta calcula média por artista, query principal compara com média global.
--               Define "artista popular" como quem está acima da média geral do dataset.
-- Por que é importante: Alguns gêneros podem ter poucos sucessos concentrados, outros distribuem melhor.
--                      Revela barreiras de entrada e competitividade por nicho.
-- Insights esperados: Identificar gêneros democráticos (muitos têm sucesso) vs elitistas (poucos dominam).