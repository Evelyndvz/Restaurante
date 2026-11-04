# Restaurante
Sabor & Arte — Sistema de Gestão de Banco de Dados RelacionalEste repositório contém o projeto completo de desenvolvimento, modelagem e implementação do Banco de Dados Relacional para o Restaurante Sabor & Arte, desenvolvido em MySQL Server / Workbench.1. Domínio e ContextualizaçãoDomínioGestão de operações de restauração, englobando controle de clientes, mesas do salão, equipe de funcionários, cardápio por categorias, pedidos (salão e delivery), itens de consumo e encerramento financeiro de contas.Problemas Operacionais Encontrados (Cenário Sem SGBD)Inconsistência de Informações: Cadastros duplicados e divergências de preços decorrentes do uso de comandas de papel e planilhas eletrónicas descentralizadas.Erros Transacionais: Perda de comandas, rasuras e divergências no fechamento diário do caixa.Falta de Controle de Salão e Atendimento: Dificuldade em rastrear quais funcionários atenderam cada mesa/pedido e impossibilidade de monitorizar o estado das mesas em tempo real.Ausência de Indicadores de Gestão: Impossibilidade de extração de relatórios consolidados sobre faturamento diário, produtos mais vendidos e ticket médio.2. Proposta de Melhoria com SGBD RelacionalA implementação do banco de dados relacional restaurante_db resolve os gargalos operacionais através das seguintes garantias:Integridade Referencial e Propriedades ACID: Garantia de que nenhum pedido seja registrado sem itens e impedimento de cobranças em duplicidade.Centralização dos Dados: Padronização de preços, produtos e clientes num único repositório central.Rastreabilidade Completa: Associação direta entre cliente, mesa, funcionário responsável, itens consumidos e pagamento efetuado.3. Modelagem Lógica do Banco de DadosTabela de Entidades e AtributosTabelaAtributoTipo de DadoRestrições / Chavesclientesid_clienteINTPK, AUTO_INCREMENTnomeVARCHAR(100)NOT NULLtelefoneVARCHAR(20)NOT NULLemailVARCHAR(100)UNIQUEenderecoVARCHAR(255)Opcionalmesasid_mesaINTPK, AUTO_INCREMENTnumero_mesaINTNOT NULL, UNIQUEcapacidade_pessoasINTNOT NULLstatusVARCHAR(20)DEFAULT 'Livre'funcionariosid_funcionarioINTPK, AUTO_INCREMENTnomeVARCHAR(100)NOT NULLcargoVARCHAR(50)NOT NULLturnoVARCHAR(20)NOT NULLcategoriasid_categoriaINTPK, AUTO_INCREMENTnome_categoriaVARCHAR(50)NOT NULL, UNIQUEprodutosid_produtoINTPK, AUTO_INCREMENTid_categoriaINTFK (categorias.id_categoria), NOT NULLnome_produtoVARCHAR(100)NOT NULLdescricaoTEXTOpcionalprecoDECIMAL(10,2)NOT NULLdisponivelBOOLEANDEFAULT TRUEpedidosid_pedidoINTPK, AUTO_INCREMENTid_mesaINTFK (mesas.id_mesa), NULLid_clienteINTFK (clientes.id_cliente), NULLid_funcionarioINTFK (funcionarios.id_funcionario), NOT NULLtipo_pedidoVARCHAR(20)NOT NULL ('Salão' ou 'Delivery')data_hora_aberturaDATETIMEDEFAULT CURRENT_TIMESTAMPstatus_pedidoVARCHAR(20)DEFAULT 'Em Aberto'itens_pedidoid_pedidoINTPK, FK (pedidos.id_pedido)id_produtoINTPK, FK (produtos.id_produto)quantidadeINTNOT NULL, DEFAULT 1preco_unitario_aplicadoDECIMAL(10,2)NOT NULLobservacaoVARCHAR(150)Opcionalpagamentosid_pagamentoINTPK, AUTO_INCREMENTid_pedidoINTFK (pedidos.id_pedido), NOT NULL, UNIQUEforma_pagamentoVARCHAR(30)NOT NULLvalor_totalDECIMAL(10,2)NOT NULLtaxa_servicoDECIMAL(10,2)DEFAULT 0.00data_hora_pagamentoDATETIMEDEFAULT CURRENT_TIMESTAMPCardinalidades e Relacionamentoscategorias $\to$ produtos ($1 : N$): Uma categoria contém $N$ produtos; um produto possui 1 categoria.clientes $\to$ pedidos ($1 : N$): Um cliente realiza $N$ pedidos; um pedido pertence a no máximo 1 cliente.mesas $\to$ pedidos ($1 : N$): Uma mesa recebe $N$ pedidos ao longo do tempo.funcionarios $\to$ pedidos ($1 : N$): Um funcionário atende $N$ pedidos.pedidos $\leftrightarrow$ produtos ($N : M$): Resolvido através da tabela associativa itens_pedido.pedidos $\leftrightarrow$ pagamentos ($1 : 1$): Cada pedido concluído possui exatamente 1 registro financeiro associado.4. Normalização (1FN até 4FN)1FN (Valores Atômicos): Eliminação de arrays e listas multivaloradas dentro das colunas. Criação da tabela itens_pedido para isolar produtos selecionados.2FN (Dependência Total da Chave Primária): Na tabela associativa itens_pedido (Chave Primária Composta id_pedido + id_produto), os atributos quantidade e preco_unitario_aplicado dependem de ambas as chaves em conjunto.3FN (Eliminação de Dependências Transitivas): Atributos não-chave não dependem de outros atributos não-chave. Por exemplo, a descrição da categoria do produto foi movida para a tabela categorias.4FN (Eliminação de Dependências Multivaloradas Independentes): Isolamento estrito entre os históricos de contatos/endereços dos clientes e os seus registros de pedidos.5. Scripts SQL (DDL e DML)SQL-- ===================================================
-- CRIAÇÃO DO BANCO DE DADOS E ESTRUTURA (DDL)
-- ===================================================
CREATE DATABASE IF NOT EXISTS restaurante_db
DEFAULT CHARACTER SET utf8mb4
DEFAULT COLLATE utf8mb4_unicode_ci;

USE restaurante_db;

CREATE TABLE IF NOT EXISTS clientes (
    id_cliente INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    telefone VARCHAR(20) NOT NULL,
    email VARCHAR(100) UNIQUE,
    endereco VARCHAR(255)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS mesas (
    id_mesa INT AUTO_INCREMENT PRIMARY KEY,
    numero_mesa INT NOT NULL UNIQUE,
    capacidade_pessoas INT NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'Livre'
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS funcionarios (
    id_funcionario INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    cargo VARCHAR(50) NOT NULL,
    turno VARCHAR(20) NOT NULL
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS categorias (
    id_categoria INT AUTO_INCREMENT PRIMARY KEY,
    nome_categoria VARCHAR(50) NOT NULL UNIQUE
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS produtos (
    id_produto INT AUTO_INCREMENT PRIMARY KEY,
    id_categoria INT NOT NULL,
    nome_produto VARCHAR(100) NOT NULL,
    descricao TEXT,
    preco DECIMAL(10, 2) NOT NULL,
    disponivel BOOLEAN NOT NULL DEFAULT TRUE,
    CONSTRAINT fk_produtos_categorias FOREIGN KEY (id_categoria) 
        REFERENCES categorias(id_categoria) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS pedidos (
    id_pedido INT AUTO_INCREMENT PRIMARY KEY,
    id_mesa INT NULL,
    id_cliente INT NULL,
    id_funcionario INT NOT NULL,
    tipo_pedido VARCHAR(20) NOT NULL,
    data_hora_abertura DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    status_pedido VARCHAR(20) NOT NULL DEFAULT 'Em Aberto',
    CONSTRAINT fk_pedidos_mesas FOREIGN KEY (id_mesa) 
        REFERENCES mesas(id_mesa) ON DELETE SET NULL ON UPDATE CASCADE,
    CONSTRAINT fk_pedidos_clientes FOREIGN KEY (id_cliente) 
        REFERENCES clientes(id_cliente) ON DELETE SET NULL ON UPDATE CASCADE,
    CONSTRAINT fk_pedidos_funcionarios FOREIGN KEY (id_funcionario) 
        REFERENCES funcionarios(id_funcionario) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS itens_pedido (
    id_pedido INT NOT NULL,
    id_produto INT NOT NULL,
    quantidade INT NOT NULL DEFAULT 1,
    preco_unitario_aplicado DECIMAL(10, 2) NOT NULL,
    observacao VARCHAR(150),
    PRIMARY KEY (id_pedido, id_produto),
    CONSTRAINT fk_itens_pedido FOREIGN KEY (id_pedido) 
        REFERENCES pedidos(id_pedido) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_itens_produto FOREIGN KEY (id_produto) 
        REFERENCES produtos(id_produto) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS pagamentos (
    id_pagamento INT AUTO_INCREMENT PRIMARY KEY,
    id_pedido INT NOT NULL UNIQUE,
    forma_pagamento VARCHAR(30) NOT NULL,
    valor_total DECIMAL(10, 2) NOT NULL,
    taxa_servico DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
    data_hora_pagamento DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_pagamentos_pedidos FOREIGN KEY (id_pedido) 
        REFERENCES pedidos(id_pedido) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

-- ===================================================
-- POVOAMENTO DOS DADOS (DML) - MÍNIMO 5 REGISTROS
-- ===================================================
INSERT INTO clientes (nome, telefone, email, endereco) VALUES
('Carlos Eduardo', '(11) 98111-2233', 'carlos.eduardo@gmail.com', 'Rua das Flores, 123 - SP'),
('Ana Paula Souza', '(11) 97222-3344', 'ana.souza@hotmail.com', 'Av. Paulista, 1500 - SP'),
('Marcos Vinicius', '(21) 99333-4455', 'marcos.vini@gmail.com', 'Rua Copacabana, 45 - RJ'),
('Juliana Rocha', '(31) 98444-5566', 'juju.rocha@yahoo.com.br', 'Av. Afonso Pena, 800 - MG'),
('Fernando Dias', '(11) 97555-6677', 'fernando.dias@tech.com', 'Rua Augusta, 910 - SP');

INSERT INTO mesas (numero_mesa, capacidade_pessoas, status) VALUES
(1, 2, 'Ocupada'),
(2, 4, 'Livre'),
(3, 6, 'Ocupada'),
(4, 2, 'Livre'),
(5, 8, 'Reservada');

INSERT INTO funcionarios (nome, cargo, turno) VALUES
('Roberto Silva', 'Garçom', 'Noite'),
('Camila Rodrigues', 'Garçom', 'Manhã'),
('Pedro Henrique', 'Garçom', 'Noite'),
('Lucas Almeida', 'Maître', 'Noite'),
('Sofia Martins', 'Atendente Delivery', 'Manhã');

INSERT INTO categorias (nome_categoria) VALUES
('Entradas'),
('Pratos Principais'),
('Bebidas'),
('Sobremesas'),
('Lanches');

INSERT INTO produtos (id_categoria, nome_produto, descricao, preco, disponivel) VALUES
(1, 'Bruschetta Tradicional', 'Pão italiano grelhado com tomates picados e manjericão', 28.00, TRUE),
(2, 'Filet Mignon ao Molho Madeira', 'Acompanha arroz à grega e batatas coradas', 65.00, TRUE),
(3, 'Suco de Laranja Natural 500ml', 'Suco 100% natural sem adição de açúcar', 12.00, TRUE),
(4, 'Petit Gâteau com Sorvete', 'Bolo quente de chocolate com sorvete de baunilha', 24.00, TRUE),
(5, 'Hambúrguer Gourmet Sabor & Arte', 'Blend 180g, queijo cheddar, bacon e maionese da casa', 38.00, TRUE);

INSERT INTO pedidos (id_mesa, id_cliente, id_funcionario, tipo_pedido, data_hora_abertura, status_pedido) VALUES
(1, 1, 1, 'Salão', '2026-11-01 19:30:00', 'Concluído'),
(NULL, 2, 5, 'Delivery', '2026-11-01 20:00:00', 'Concluído'),
(3, 3, 2, 'Salão', '2026-11-02 12:15:00', 'Concluído'),
(NULL, 4, 5, 'Delivery', '2026-11-02 13:00:00', 'Concluído'),
(2, 5, 1, 'Salão', '2026-11-03 20:45:00', 'Concluído');

INSERT INTO itens_pedido (id_pedido, id_produto, quantidade, preco_unitario_aplicado, observacao) VALUES
(1, 1, 1, 28.00, 'Sem alho na bruschetta'),
(1, 3, 2, 12.00, 'Com gelo e adoçante'),
(2, 5, 2, 38.00, 'Ponto da carne: bem passado'),
(2, 3, 2, 12.00, 'Sem gelo'),
(3, 2, 2, 65.00, 'Molho à parte'),
(4, 5, 1, 38.00, NULL),
(4, 4, 1, 24.00, NULL),
(5, 2, 1, 65.00, 'Ao ponto'),
(5, 4, 1, 24.00, NULL);

INSERT INTO pagamentos (id_pedido, forma_pagamento, valor_total, taxa_servico, data_hora_pagamento) VALUES
(1, 'Cartão de Crédito', 57.20, 5.20, '2026-11-01 20:45:00'),
(2, 'PIX', 100.00, 0.00, '2026-11-01 20:40:00'),
(3, 'PIX', 143.00, 13.00, '2026-11-02 13:30:00'),
(4, 'Cartão de Débito', 62.00, 0.00, '2026-11-02 13:45:00'),
(5, 'Dinheiro', 97.90, 8.90, '2026-11-03 22:00:00');
6. Consultas Analíticas e Gerenciais (DQL)SQLUSE restaurante_db;

-- 1. Listagem alfabética de todos os clientes
SELECT id_cliente, nome, telefone, email FROM clientes ORDER BY nome ASC;

-- 2. Produtos ativos por ordem decrescente de preço
SELECT nome_produto, preco FROM produtos WHERE disponivel = TRUE ORDER BY preco DESC;

-- 3. Pedidos abertos na primeira semana de novembro
SELECT id_pedido, tipo_pedido, data_hora_abertura, status_pedido 
FROM pedidos 
WHERE data_hora_abertura BETWEEN '2026-11-01 00:00:00' AND '2026-11-07 23:59:59';

-- 4. Faturamento bruto total e soma das taxas de serviço
SELECT SUM(valor_total) AS faturamento_bruto, SUM(taxa_servico) AS total_taxas FROM pagamentos;

-- 5. Quantidade de produtos por categoria
SELECT c.nome_categoria, COUNT(p.id_produto) AS total_produtos
FROM categorias c LEFT JOIN produtos p ON c.id_categoria = p.id_categoria
GROUP BY c.id_categoria, c.nome_categoria;

-- 6. Detalhamento e subtotal do Pedido ID 1
SELECT pr.nome_produto, ip.quantidade, ip.preco_unitario_aplicado, (ip.quantidade * ip.preco_unitario_aplicado) AS subtotal
FROM itens_pedido ip JOIN produtos pr ON ip.id_produto = pr.id_produto WHERE ip.id_pedido = 1;

-- 7. Contagem de pedidos atendidos por funcionário
SELECT f.nome AS funcionario, f.cargo, COUNT(p.id_pedido) AS total_pedidos
FROM funcionarios f LEFT JOIN pedidos p ON f.id_funcionario = p.id_funcionario
GROUP BY f.id_funcionario, f.nome, f.cargo ORDER BY total_pedidos DESC;

-- 8. Clientes com consumo superior a R$ 60,00
SELECT c.nome AS cliente, p.id_pedido, pg.valor_total
FROM clientes c JOIN pedidos p ON c.id_cliente = p.id_cliente JOIN pagamentos pg ON p.id_pedido = pg.id_pedido
WHERE pg.valor_total > 60.00;

-- 9. Mesas atualmente ocupadas ou reservadas
SELECT numero_mesa, capacidade_pessoas, status FROM mesas WHERE status != 'Livre';

-- 10. Ticket médio das vendas realizadas
SELECT ROUND(AVG(valor_total), 2) AS ticket_medio FROM pagamentos;

-- 11. Produto mais vendido em quantidade de unidades
SELECT pr.nome_produto, SUM(ip.quantidade) AS unidades_vendidas
FROM itens_pedido ip JOIN produtos pr ON ip.id_produto = pr.id_produto
GROUP BY pr.id_produto, pr.nome_produto ORDER BY unidades_vendidas DESC LIMIT 1;

-- 12. Pagamentos realizados via PIX ou Cartão de Crédito
SELECT id_pagamento, id_pedido, forma_pagamento, valor_total FROM pagamentos WHERE forma_pagamento IN ('PIX', 'Cartão de Crédito');

-- 13. Histórico de compras do cliente 'Carlos Eduardo'
SELECT c.nome AS cliente, p.id_pedido, pr.nome_produto, ip.quantidade, pg.valor_total
FROM clientes c JOIN pedidos p ON c.id_cliente = p.id_cliente JOIN itens_pedido ip ON p.id_pedido = ip.id_pedido
JOIN produtos pr ON ip.id_produto = pr.id_produto JOIN pagamentos pg ON p.id_pedido = pg.id_pedido
WHERE c.nome LIKE '%Carlos Eduardo%';

-- 14. Produtos cadastrados que ainda não possuem vendas
SELECT pr.nome_produto, pr.preco FROM produtos pr LEFT JOIN itens_pedido ip ON pr.id_produto = ip.id_produto WHERE ip.id_pedido IS NULL;

-- 15. Relatório gerencial unificado de vendas
SELECT p.id_pedido, p.data_hora_abertura, p.tipo_pedido, COALESCE(c.nome, 'Cliente Não Identificado') AS cliente,
       f.nome AS atendente, pg.forma_pagamento, pg.valor_total
FROM pedidos p LEFT JOIN clientes c ON p.id_cliente = c.id_cliente JOIN funcionarios f ON p.id_funcionario = f.id_funcionario
JOIN pagamentos pg ON p.id_pedido = pg.id_pedido ORDER BY p.data_hora_abertura DESC;
7. Procedimento de Backup (Dump)Via Interface Gráfica (MySQL Workbench)Acesse a aba Administration no painel lateral esquerdo.Selecione Data Export.Em Object Selection, marque o esquema restaurante_db.Selecione Export to Self-Contained File e defina o caminho do arquivo (ex: restaurante_db_dump.sql).Marque Include Create Schema.Defina o modo para Dump Structure and Data.Clique em Start Export.Via Terminal / Linha de Comando (CLI)Bashmysqldump -u root -p --databases restaurante_db > restaurante_db_dump.sql
