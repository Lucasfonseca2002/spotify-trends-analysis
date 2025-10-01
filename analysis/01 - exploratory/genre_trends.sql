-- ====================================================================
-- ANÁLISE APROFUNDADA DE TENDÊNCIAS POR GÊNERO MUSICAL
-- OBJETIVO: Criar um perfil sonoro para cada gênero musical e comparar suas características
-- ====================================================================

-- 1. PERFIL SONORO DOS GÊNEROS MAIS POPULARES
-- OBJETIVO: Criar uma 'impressão digital' de áudio para os 10 gêneros com maior popularidade média.
--           Isso mostra o que define sonoramente cada um desses gêneros.

WITH top_generos_musicais AS (
    -- Criação de uma subconsulta para identificar os 10 gêneros musicais com maior popularidade média
    SELECT
        track_genre
    FROM
        spotify_tracks
    GROUP BY
        track_genre
    HAVING
        COUNT(*) >= 50 -- Garante que o gênero tenha um volume mínimo de músicas para uma média estável
    ORDER BY
        AVG(popularity) DESC
    LIMIT 10
)
SELECT
    st.track_genre,
    COUNT(*) AS total_musicas,
    ROUND(AVG(st.popularity), 1) AS media_popularidade,
    -- O perfil sonoro médio do gênero:
    ROUND(AVG(st.danceability::numeric), 2) AS media_dancabilidade,
    ROUND(AVG(st.energy::numeric), 2) AS media_energia,
    ROUND(AVG(st.acousticness::numeric), 2) AS media_acustica,
    ROUND(AVG(st.instrumentalness::numeric), 2) AS media_instrumental,
    ROUND(AVG(st.valence::numeric), 2) AS media_positividade
FROM spotify_tracks st
         JOIN top_generos_musicais tg ON st.track_genre = tg.track_genre
GROUP BY st.track_genre
ORDER BY media_popularidade DESC;

-- DOCUMENTAÇÃO:
-- O que faz: Identifica os 10 gêneros mais populares e calcula um perfil médio de suas características de áudio (dançabilidade, energia, etc.).
-- Como funciona: Utiliza uma CTE (Common Table Expression) para primeiro selecionar os gêneros de interesse. Em seguida, faz um JOIN da tabela principal com essa lista para filtrar apenas as músicas relevantes e calcular as médias.
-- Por que é importante: Permite uma comparação direta e objetiva das "impressões digitais sonoras" de gêneros de sucesso, ajudando a entender o que os torna comercialmente viáveis.
-- Insights esperados: Descobrir as características que definem os gêneros populares. Por exemplo, "pop" pode ter alta dançabilidade e positividade, enquanto "rock" pode ter alta energia mas menor positividade.


-- 2. VARIABILIDADE DENTRO DOS GÊNEROS (DESVIO PADRÃO)
-- OBJETIVO: Medir se um gênero é sonoramente consistente ou diverso.
--           Um desvio padrão baixo significa que as músicas do gênero são muito parecidas entre si.
--           Um desvio padrão alto significa que o gênero abrange uma grande variedade de sons.

SELECT
    track_genre,
    COUNT(*) as total_musicas,
    ROUND(AVG(energy::numeric), 2) AS media_energia,
    ROUND(STDDEV(energy::numeric), 2) as desvio_padrao_energia, -- Mede a dispersão da energia
    ROUND(AVG(danceability::numeric), 2) AS media_dancabilidade,
    ROUND(STDDEV(danceability::numeric), 2) as desvio_padrao_danceabilidade -- Mede a dispersão da dançabilidade
FROM spotify_tracks
WHERE track_genre IN ('rock', 'pop', 'hip-hop', 'jazz', 'classical', 'electronic', 'k-pop') -- Análise focada em gêneros específicos
GROUP BY track_genre
ORDER BY desvio_padrao_energia DESC;

-- DOCUMENTAÇÃO:
-- O que faz: Calcula a média e o desvio padrão da energia e dançabilidade para uma seleção de gêneros.
-- Como funciona: Utiliza a função de agregação STDDEV (Standard Deviation) para medir a variabilidade das métricas de áudio dentro de cada gênero agrupado.
-- Por que é importante: Vai além das médias para entender a diversidade sonora de um gênero. Um gênero como "rock" pode ter um desvio padrão alto, abrangendo de baladas a heavy metal, enquanto "techno" pode ser mais consistente.
-- Insights esperados: Identificar quais gêneros são sonoramente mais homogêneos (baixo desvio padrão) e quais são mais ecléticos (alto desvio padrão), revelando a amplitude de cada rótulo de gênero.


-- 3. MAPEAMENTO DE GÊNEROS EM UM EIXO ENERGIA vs. VALENCE (POSITIVIDADE)
-- OBJETIVO: Classificar os gêneros em quatro quadrantes de "humor":
--           Q1: Alta Energia, Alta Positividade (Ex: Músicas de festa)
--           Q2: Baixa Energia, Alta Positividade (Ex: Músicas relaxantes e felizes)
--           Q3: Baixa Energia, Baixa Positividade (Ex: Músicas tristes, melancólicas)
--           Q4: Alta Energia, Baixa Positividade (Ex: Músicas intensas, agressivas)

SELECT
    track_genre,
    COUNT(*) AS total_musicas,
    ROUND(AVG(energy::numeric), 2) as media_energia,
    ROUND(AVG(valence::numeric), 2) as media_positividade,
    CASE
        WHEN AVG(energy::numeric) > 0.6 AND AVG(valence::numeric) > 0.6 THEN 'Q1: Energético e Positivo'
        WHEN AVG(energy::numeric) <= 0.6 AND AVG(valence::numeric) > 0.6 THEN 'Q2: Calmo e Positivo'
        WHEN AVG(energy::numeric) <= 0.6 AND AVG(valence::numeric) <= 0.6 THEN 'Q3: Calmo e Melancólico'
        WHEN AVG(energy::numeric) > 0.6 AND AVG(valence::numeric) <= 0.6 THEN 'Q4: Energético e Intenso'
        ELSE 'Neutro'
        END as quadrante_humor
FROM spotify_tracks
GROUP BY track_genre
HAVING COUNT(*) >= 50 -- Filtra gêneros com poucas músicas para não distorcer o resultado
ORDER BY quadrante_humor, media_energia DESC;

-- DOCUMENTAÇÃO:
-- O que faz: Mapeia cada gênero em um "quadrante de humor" baseado na sua combinação de energia e positividade (valence) médias.
-- Como funciona: Utiliza uma expressão CASE WHEN para avaliar as médias de 'energy' e 'valence' de cada gênero e atribuir uma categoria de humor. Os limiares (0.6) definem as fronteiras dos quadrantes.
-- Por que é importante: É uma forma avançada e visual de entender o "sentimento" predominante de cada gênero, criando um mapa emocional que pode ser usado para recomendações, marketing ou análise cultural.
-- Insights esperados: Classificar gêneros em perfis emocionais claros. Por exemplo, "salsa" no Q1 (Energético/Positivo), "ambient" no Q3 (Calmo/Melancólico) e "heavy-metal" no Q4 (Energético/Intenso).