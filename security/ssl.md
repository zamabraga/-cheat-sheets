---
title: Certificado SSL
---

X.509 é um formato padrão para certificados de chave pública, documentos digitais que associam com segurança pares de chaves criptográficas a identidades como sites, indivíduos ou organizações.

Introduzido pela primeira vez em 1988 junto com os padrões X.500 para serviços de diretório eletrônico, o X.509 foi adaptado para uso da Internet pela Public-Key Infrastructure da IETF (X.509) (PKIX) grupo de trabalho. RFC 5280 perfila o certificado X.509 v3, a lista de revogação de certificados X.509 v2 (CRL) e descreve um algoritmo para validação do caminho do certificado X.509.

Os aplicativos comuns dos certificados X.509 incluem:

- SSL /TLS e HTTPS para navegação na web autenticada e criptografada
- E-mail assinado e criptografado via S/MIME protocolo
- Assinatura de código
- Assinatura de documento
- Autenticação de cliente
- ID eletrônico emitido pelo governo

## Como funciona? 

O cliente utiliza a chave pública para encriptografar as mensagens ao serem enviadas para o server que utiliza o chave privada para descriptografar as mensagens recebidas pelo cliente

## Criando certificado Self-Signed

### Gerando CA

#### 1. Criar chave privada RSA CA - Private Key

```bash
openssl genrsa -aes256 -out ca-key.pem 4096
```

#### 2. Criar certificado público CA

```bash
openssl req -new -x509 -sha256 -days 365 -key ca-key.pem -out ca.pem
```

### Gerando Certificado

#### 1. Criar chave privada RSA (CSR) - Private Key

```bash
openssl genrsa -out cert-key.pem 4096
```

#### 2. Criar Certificate Signing Request (CSR)

```bash
openssl req -new -sha256 -subj "/CN=Equipe de Infraestrutura Tecnologica Wiz - iTW" -key cert-key.pem -out cert.csr
```

O parâmetro `-subj ` corresponden ao emissor do certificado.


#### 3. Criar arquivo com nomes alternativos

```bash
echo "subjectAltName=DNS.1:your-dns.record,IP.1:257.10.10.1" >> extfile.cnf
```

#### 4. Criar Certificado

```bash
openssl x509 -req -sha256 -days 365 -in cert.csr -CA ca.pem -CAkey ca-key.pem -out cert.pem -extfile extfile.cnf -CAcreateserial

# gera pfx
openssl pkcs12 -export -in cert.pem -inkey cert-key.pem -out cert.pfx  
```

### Validando o certificado

```bash
openssl verify -CAfile ca.pem -verbose cert.pem

```

## Instalando certificado CA como trusted root CA

### Debian & Derivados

- Copie o certificado CA (ca.pem) para o diretorio `/usr/local/share/ca-certificates/ca.crt`
- Atualize o Cert store

```bash
sudo update-ca-certificates
```

### Windows

```powershell
Import-Certificate -FilePath "C:\ca.pem" -CertStoreLocation Cert:\LocalMachine\Root
# Apenas para o usuário atual
Import-Certificate -FilePath "C:\ca.pem" -CertStoreLocation Cert:\CurrentUser\Root
```

## Links

- [How to create a valid self signed SSL Certificate?](https://www.youtube.com/watch?v=VH4gXcvkmOY&feature=youtu.be)
- [Atestado do certificado X.509](https://learn.microsoft.com/pt-br/azure/iot-dps/concepts-x509-attestation)
- [certificados X.509](https://learn.microsoft.com/en-us/azure/iot-hub/reference-x509-certificates)
