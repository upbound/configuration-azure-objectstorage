import models.io.upbound.platform.azure.v1 as platformazurev1
import models.io.upbound.azurem.v1beta1 as azurev1beta1
import models.io.upbound.dev.meta.v1alpha1 as metav1alpha1

_items = [
    metav1alpha1.E2ETest {
        metadata.name = "storage-container"
        spec = {
            # Configure Crossplane for the test environment
            crossplane = {
                version = "2.0.2-up.5"
                autoUpgrade.channel = "Rapid"
            }
            defaultConditions = [
                "Ready"
            ]
            manifests = [
                platformazurev1.StorageContainer {
                    metadata = {
                        name = "uptest-storage"
                        namespace = "default"
                    }
                    spec.parameters = {
                        region = "eastus"
                        managementPolicies = ["*"]
                        providerConfigName = "default"
                    }
                }
            ]
            extraResources = [
                azurev1beta1.ProviderConfig {
                    metadata = {
                        name = "default"
                        namespace = "default"
                    }
                    spec = {
                        credentials = {
                            source = "Upbound"
                        }
                        clientID = "bcf40abd-283c-494b-b186-03d6c864be51"
                        tenantID = "b9925bc4-8383-4c37-b9d2-fa456d1bb1c7"
                        subscriptionID = "038f2b7c-3265-43b8-8624-c9ad5da610a8"
                    }
                }
            ]
            skipDelete = False
            # 5 minutes
            timeoutSeconds = 300
        }
    }
]
items = _items
