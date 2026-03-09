---
name: azure-cost-analysis
description: Analyze Azure subscription costs, find unused resources, and identify cost-saving opportunities
disable-model-invocation: true
argument-hint: [subscription-name]
---

Analyze Azure costs for subscription "$ARGUMENTS". Follow all steps below.

## Step 1: Find the subscription

```
az account list --query "[?contains(name, '$ARGUMENTS')].{name:name, id:id, state:state}" -o table
```

If multiple matches, ask the user which one. Store the subscription ID as $SUB_ID for subsequent commands.

## Step 2: Monthly cost trend

Use the Cost Management REST API to get costs by service, grouped monthly for the last 3 months:

```
az rest --method POST \
  --url "https://management.azure.com/subscriptions/$SUB_ID/providers/Microsoft.CostManagement/query?api-version=2023-11-01" \
  --body '{"type":"ActualCost","timeframe":"Custom","timePeriod":{"from":"<3-months-ago-first-of-month>","to":"<last-day-of-previous-month>"},"dataset":{"aggregation":{"totalCost":{"name":"Cost","function":"Sum"}},"grouping":[{"type":"Dimension","name":"ServiceName"}],"granularity":"Monthly"}}'
```

And current month-to-date:

```
az rest --method POST \
  --url "https://management.azure.com/subscriptions/$SUB_ID/providers/Microsoft.CostManagement/query?api-version=2023-11-01" \
  --body '{"type":"ActualCost","timeframe":"MonthToDate","dataset":{"aggregation":{"totalCost":{"name":"Cost","function":"Sum"}},"grouping":[{"type":"Dimension","name":"ServiceName"}]}}'
```

Also get costs by resource group and by individual resource ID to find top spenders.

## Step 3: Infrastructure inventory

Run these in parallel using subagents where possible:

- **VMs**: `az vm list --subscription $SUB_ID -d` — sizes and power states
- **App Service Plans**: `az appservice plan list --subscription $SUB_ID` — SKUs and worker counts
- **AKS clusters**: `az aks list --subscription $SUB_ID` — node pools, VM sizes, counts
- **Redis Cache**: `az redis list --subscription $SUB_ID` — SKUs and capacity
- **SQL servers/databases**: `az sql server list` then `az sql db list` per server — editions and tiers
- **Storage accounts**: `az storage account list --subscription $SUB_ID` — SKUs and access tiers
- **Cosmos DB**: `az cosmosdb list --subscription $SUB_ID`
- **Grafana**: `az grafana list --subscription $SUB_ID`

## Step 4: Find unused resources

Check ALL of the following:

- **Unattached disks**: `az disk list` — look for `diskState != 'Attached'`
- **Unassociated public IPs**: `az network public-ip list` — look for null `ipConfiguration` AND null `natGateway`
- **Orphaned NICs**: `az network nic list` — look for null `virtualMachine` AND null `privateEndpoint`. IMPORTANT: NICs used by private endpoints are NOT orphaned
- **Snapshots**: `az snapshot list` — often forgotten leftovers from deleted VMs
- **Stopped web apps**: `az webapp list --query "[?state=='Stopped']"` — still incur App Service Plan costs
- **Empty SQL servers**: SQL servers with only the system `master` database and no user databases
- **Leftover resource groups**: Look for RG names containing 'migrated', 'old', 'backup', 'test', 'temp' — inspect if they contain resources from decommissioned services
- **Orphaned networking**: Resource groups that only contain networking resources (NIC, NSG, VNet, Public IP) but no VMs — likely leftovers from deleted VMs

## Step 5: Azure Advisor cost recommendations

```
az advisor recommendation list --subscription $SUB_ID --category Cost
```

Focus on: shutdown/delete, right-size, reserved instances, and savings plans recommendations.

## Step 6: Present findings

Structure the report as:

1. **Monthly spend trend** — table with last 3 months + projected current month
2. **Cost breakdown by service** — table sorted by cost descending with percentage
3. **Top 10 most expensive resources**
4. **Unused/orphaned resources** — table with resource name, issue, and estimated savings
5. **Cost-saving opportunities** — grouped by High/Medium/Low priority with estimated monthly savings and effort level
6. **Summary** — total potential savings table by category
