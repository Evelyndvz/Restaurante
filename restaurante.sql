DROP DATABASE IF EXISTS restaurante_db;
CREATE DATABASE restaurante_db
DEFAULT CHARACTER SET utf8mb4
DEFAULT COLLATE utf8mb4_unicode_ci;

USE restaurante_db;

-- 1. Clientes
CREATE TABLE clientes (
    id_cliente INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    telefone VARCHAR(20) NOT NULL,
    email VARCHAR(100) UNIQUE,
    endereco VARCHAR(255)
) ENGINE=InnoDB;

-- 2. Mesas
CREATE TABLE mesas (
    id_mesa INT AUTO_INCREMENT PRIMARY KEY,
    numero_mesa INT NOT NULL UNIQUE,
    capacidade_pessoas INT NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'Livre'
) ENGINE=InnoDB;

-- 3. Funcionarios
CREATE TABLE funcionarios (
    id_funcionario INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    cargo VARCHAR(50) NOT NULL,
    turno VARCHAR(20) NOT NULL
) ENGINE=InnoDB;

-- 4. Categorias
CREATE TABLE categorias (
    id_categoria INT AUTO_INCREMENT PRIMARY KEY,
    nome_categoria VARCHAR(50) NOT NULL UNIQUE
) ENGINE=InnoDB;

-- 5. Produtos
CREATE TABLE produtos (
    id_produto INT AUTO_INCREMENT PRIMARY KEY,
    id_categoria INT NOT NULL,
    nome_produto VARCHAR(100) NOT NULL,
    descricao TEXT,
    preco DECIMAL(10, 2) NOT NULL,
    disponivel BOOLEAN NOT NULL DEFAULT TRUE,
    CONSTRAINT fk_produtos_categorias FOREIGN KEY (id_categoria) 
        REFERENCES categorias(id_categoria) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

-- 6. Pedidos
CREATE TABLE pedidos (
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

-- 7. Itens_Pedido
CREATE TABLE itens_pedido (
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

-- 8. Pagamentos
CREATE TABLE pagamentos (
    id_pagamento INT AUTO_INCREMENT PRIMARY KEY,
    id_pedido INT NOT NULL UNIQUE,
    forma_pagamento VARCHAR(30) NOT NULL,
    valor_total DECIMAL(10, 2) NOT NULL,
    taxa_servico DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
    data_hora_pagamento DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_pagamentos_pedidos FOREIGN KEY (id_pedido) 
        REFERENCES pedidos(id_pedido) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

-- POVOAMENTO DOS DADOS (DML)
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