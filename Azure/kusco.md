# Consulta Kusco

## Pesquisa Application Insights pela Instrumental key

```bash
resources
  | where type =~ 'microsoft.insights/components'
  | where properties.InstrumentationKey  == '[INSTRUMENTAL KEY]'
  | project id,name,type,location,subscriptionId,resourceGroup,kind,tags,properties.InstrumentationKey 

```
