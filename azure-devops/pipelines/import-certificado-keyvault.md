# Import Certificado de um Keyvault

```yml

- task: AzureKeyVault@2
  displayName: Download Certificado
  inputs:
    azureSubscription: "<<Azure Subscription>>"
    KeyVaultName: "<<Key Vault>>"
    SecretsFilter: "<<Chave do Certificado>>"
    RunAsPreJob: true

- pwsh: |
    $kvSecretBytes = [System.Convert]::FromBase64String("$(<<Chave do Certificado>>)")    
    $tempPath = [System.IO.Path]::GetTempPath()
    ## Diretório temporario onde o seram clonados os repositorios
    $pfxPath = [System.IO.Path]::Combine($tempPath, "$([System.IO.Path]::GetRandomFileName()).pfx")
    [System.IO.File]::WriteAllBytes($pfxPath, $kvSecretBytes)
    Import-PfxCertificate -FilePath $pfxPath  Cert:\CurrentUser\My -Password $secure
  displayName: Registra certificado

```
