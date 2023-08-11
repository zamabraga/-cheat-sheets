# Stderr

A expressão 2> redireciona (>) o fluxo de saída de erro do PowerShell, cujo número é 2 (e que mapeia para stderr) para (&) o fluxo de saída de sucesso do PowerShell, cujo número é 1 (e mapeia para stdout).

```bash
$cmdOutput = svn info 2>&1
```

[Sobre Redirecionamento ](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_redirection?view=powershell-7.3)
