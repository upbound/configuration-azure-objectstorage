# Azure Object Storage Configuration

This repository contains an Upbound Configuration for Microsoft Azure Storage Containers that can be used to backup Upbound Spaces.

## Overview

The core components of this Upbound Configuration include:

- **CompositeResourceDefinition (XRD):** Defines the `StorageContainer` API structure
- **Composition:** Configures the Functions Pipeline for storage container provisioning  
- **Embedded Function:** Composition logic in [`functions/compose-container/main.k`](functions/compose-container/main.k)

In this configuration, the API contains:

- **a custom `StorageContainer` resource type**, Defined in [`apis/StorageContainers/definition.yaml`](apis/StorageContainers/definition.yaml)
- **Composition:** Configured in [`apis/StorageContainers/composition.yaml`](apis/StorageContainers/composition.yaml)
- **Embedded Function:** Composition logic in [`functions/compose-container/main.k`](functions/compose-container/main.k)

The configuration creates Azure Storage Containers with configurable parameters including region, resource group, and provider configuration.

## Deployment

- Execute `up project run`
- Alternatively, install from the [Upbound Marketplace](https://marketplace.upbound.io/)
- Check [`examples/`](examples/) for example Composite Resources

## Testing

The configuration can be tested using:

- `up composition render` to render the composition
- `up test run tests/*` to run composition tests  
- `up test run tests/* --e2e` to run end-to-end tests
- `./e2e.sh` to run the end-to-end test suite

## Next steps

This repository serves as a foundational step. To enhance your configuration, consider:

1. Create new API definitions in this repo
2. Edit existing API definition to your needs

To learn more about building APIs for managed control planes in Upbound, read the [Upbound documentation](https://docs.upbound.io/).
