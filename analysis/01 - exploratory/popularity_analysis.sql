-- ====================================================================
-- ANÁLISE APROFUNDADA DE POPULARIDADE
-- OBJETIVO: ENTENDER QUAIS CARACTERÍSTICAS DE ÁUDIO ESTÃO CORRELACIONADAS COM O SUCESSO DE UMA MÚSICA
-- ====================================================================

-- 1. CORRELAÇÃO ENTRE CARACTERÍSTICAS DE ÁUDIO E POPULARIDADE
-- OBJETIVO: Identificar tendências sonoras em músicas de sucesso. Por exemplo: "Músicas populares tendem a ser mais dançantes?"

SELECT
    CASE
        WHEN popularity >= 80 THEN 'Muito Popular (80-100)'
        WHEN popularity >= 60 THEN 'Popular (60-79)'
        WHEN popularity >= 40 THEN 'Moderada (40-59)'
        ELSE 'Pouco Popular (0-39)'
        END as faixa_de_popularidade,
    COUNT(*) as total_de_musicas,
    -- Calculando a média de cada característica para cada faixa de popularidade:
    ROUND(AVG(danceability::decimal), 2) as media_dancabilidade,
    ROUND(AVG(energy::decimal), 2) as media_energia,
    ROUND(AVG(loudness::decimal), 2) as media_intensidade_sonora,
    ROUND(AVG(speechiness::decimal), 2) as media_presenca_fala,
    ROUND(AVG(acousticness::decimal), 2) as media_acustica,
    ROUND(AVG(instrumentalness::decimal), 2) as media_instrumental,
    ROUND(AVG(liveness::decimal), 2) as media_performance_ao_vivo,
    ROUND(AVG(valence::decimal), 2) as media_positividade
FROM
    spotify_tracks
WHERE
    popularity IS NOT NULL
GROUP BY
    faixa_de_popularidade
ORDER BY
    MIN(popularity) DESC;

-- DOCUMENTAÇÃO:
-- O que faz: Agrupa as músicas em quatro faixas de popularidade e calcula a média de todas as principais características de áudio para cada faixa.
-- Como funciona: Usa uma expressão CASE WHEN para criar as faixas. Em seguida, a cláusula GROUP BY agrupa as músicas de uma mesma faixa, e funções de agregação como AVG() calculam a média das características para esses grupos.
-- Por que é importante: É a análise mais direta para correlacionar o som de uma música com seu sucesso comercial. Fornece um guia baseado em dados sobre quais atributos sonoros são mais proeminentes em hits.
-- Insights esperados: Identificar os "ingredientes" de uma música popular. Espera-se que músicas 'Muito Populares' tenham, em média, maior 'danceability', maior 'loudness' (volume) e menor 'acousticness' (acusticidade) do que músicas 'Pouco Populares'.


-- 2. ANÁLISE DE POPULARIDADE POR DURAÇÃO DA MÚSICA
-- OBJETIVO: Verificar se existe uma "duração ideal" para uma música atingir alta popularidade.

SELECT
    CASE
        WHEN duration_ms < 180000 THEN 'Curta (< 3min)'
        WHEN duration_ms BETWEEN 180000 AND 240000 THEN 'Média (3-4min)'
        ELSE 'Longa (> 4min)'
        END AS duracao_faixa,
    COUNT(*) AS total_musicas,
    ROUND(AVG(popularity), 2) AS media_popularidade
FROM spotify_tracks
GROUP BY duracao_faixa
ORDER BY media_popularidade DESC;

-- DOCUMENTAÇÃO:
-- O que faz: Agrupa as músicas por faixas de duração (curta, média, longa) e calcula a popularidade média de cada grupo.
-- Como funciona: A coluna 'duration_ms' (duração em milissegundos) é usada em uma expressão CASE WHEN para segmentar as músicas. A popularidade média é então calculada para cada segmento.
-- Por que é importante: Ajuda a entender padrões de consumo de música. A indústria musical, especialmente para rádio e playlists de streaming, historicamente favorece durações específicas que maximizam o engajamento do ouvinte.
-- Insights esperados: Validar a hipótese de que músicas de duração "Média (3-4min)" tendem a ser mais populares, pois se alinham melhor com os formatos de rádio e a capacidade de atenção do ouvinte médio.


-- 3. IMPACTO DO 'MODO' (MAIOR OU MENOR) NA POPULARIDADE
-- OBJETIVO: Testar a hipótese de que músicas em modo maior (geralmente percebidas como mais 'felizes') são mais populares.

SELECT
    CASE
        WHEN mode::integer = 1 THEN 'Modo Maior (Feliz)'
        ELSE 'Modo Menor (Triste/Melancólico)'
        END as modo_musical,
    COUNT(*) as total_musicas,
    ROUND(AVG(popularity), 2) as media_popularidade
FROM spotify_tracks
GROUP BY modo_musical, mode
HAVING mode IS NOT NULL
ORDER BY media_popularidade DESC;

-- DOCUMENTAÇÃO:
-- O que faz: Separa todas as músicas entre modo maior (major) e modo menor (minor) e compara a popularidade média entre os dois grupos.
-- Como funciona: A coluna 'mode' é um valor binário (1 para maior, 0 para menor). A expressão CASE WHEN traduz esses valores para rótulos legíveis, que são usados para agrupar e calcular a média.
-- Por que é importante: É uma forma de quantificar o impacto da harmonia e do "sentimento" geral de uma música (alegre vs. triste) em sua aceitação pelo grande público.
-- Insights esperados: Confirmar se músicas em 'Modo Maior' têm, em média, uma popularidade maior, o que reforçaria a ideia de que canções com uma sonoridade mais "aberta" e "positiva" possuem um apelo comercial mais amplo.