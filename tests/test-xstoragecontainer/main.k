import models.io.upbound.platform.azure.v1 as platformazurev1
import models.io.upbound.azure.v1beta1 as azurev1beta1
import models.io.upbound.azure.storage.v1beta1 as storagev1beta1
import models.io.upbound.azure.storage.v1beta2 as storagev1beta2

import models.io.upbound.dev.meta.v1alpha1 as metav1alpha1

# It's a best practice for composition functions to return only fields whose
# values they care about, since they become the owner of any field they
# return. Allow for fields with defaults to be omitted by the composition
# function by clearing them in our expected resources.
_stripDefaults = lambda obj: any -> any {
    obj | {
        spec.deletionPolicy = Undefined
        spec.managementPolicies = Undefined
    }
}

_specCreateResourceGroup = metav1alpha1.CompositionTest {
    spec = {
        compositionPath: "apis/xstoragecontainers/composition.yaml"
        xrPath: "examples/xstoragecontainer/xstoragecontainer.yaml"
        xrdPath: "apis/xstoragecontainers/definition.yaml"
        timeoutSeconds: 120
        validate: False
    }
}

_specExistingResourceGroup = metav1alpha1.CompositionTest {
    spec = {
        compositionPath: "apis/xstoragecontainers/composition.yaml"
        xrPath: "examples/xstoragecontainer/xstoragecontainer-existing-rg.yaml"
        xrdPath: "apis/xstoragecontainers/definition.yaml"
        timeoutSeconds: 120
        validate: False
    }
}

_test1 = metav1alpha1.CompositionTest {
    metadata.name = "test-xstoragecontainer-create-rg"
    **_specCreateResourceGroup
    spec.assertResources = [
        platformazurev1.XStorageContainer {
            metadata.name: "ref-azure-storagecontainer"
            spec: {
                parameters: {
                    providerConfigName: "default"
                    region: "eastus"
                }
            }
        }
        azurev1beta1.ResourceGroup {
            metadata.annotations = {
                "crossplane.io/composition-resource-name" = "ref-azure-storagecontainer-rg"
            }
            metadata.name = "ref-azure-storagecontainer-rg"
            spec.forProvider: {
                location: "eastus"
            }
            spec.providerConfigRef.name = "default"
        }
        storagev1beta2.Account {
            metadata.annotations = {
                "crossplane.io/composition-resource-name" = "refazurestoragecontaine"
            }
            metadata.name = "refazurestoragecontaine"
            spec.forProvider: {
                accountKind: "BlobStorage"
                accountReplicationType: "LRS"
                accountTier: "Standard"
                location: "eastus"
                resourceGroupName: "ref-azure-storagecontainer-rg"
            }
            spec.providerConfigRef.name = "default"
        }
        storagev1beta1.Container {
            metadata.annotations = {
                "crossplane.io/composition-resource-name" = "ref-azure-storagecontainer-container"
            }
            metadata.name = "ref-azure-storagecontainer-container"
            spec.forProvider: {
                containerAccessType: "private"
                storageAccountNameSelector: {
                    matchControllerRef: True
                }
            }
            spec.providerConfigRef.name = "default"
        }
    ]
}

_test2 = metav1alpha1.CompositionTest {
    metadata.name = "test-xstoragecontainer-existing-rg"
    **_specExistingResourceGroup
    spec.assertResources = [
        platformazurev1.XStorageContainer {
            metadata.name: "ref-azure-storagecontainer-existing-rg"
            spec: {
                parameters: {
                    providerConfigName: "default"
                    region: "eastus"
                    resourceGroup: "existing-rg"
                }
            }
        }
        storagev1beta2.Account {
            metadata.annotations = {
                "crossplane.io/composition-resource-name" = "refazurestoragecontaine"
            }
            metadata.name = "refazurestoragecontaine"
            spec.forProvider: {
                accountKind: "BlobStorage"
                accountReplicationType: "LRS"
                accountTier: "Standard"
                location: "eastus"
                resourceGroupName: "existing-rg"
            }
            spec.providerConfigRef.name = "default"
        }
        storagev1beta1.Container {
            metadata.annotations = {
                "crossplane.io/composition-resource-name" = "ref-azure-storagecontainer-existing-rg-container"
            }
            metadata.name = "ref-azure-storagecontainer-existing-rg-container"
            spec.forProvider: {
                containerAccessType: "private"
                storageAccountNameSelector: {
                    matchControllerRef: True
                }
            }
            spec.providerConfigRef.name = "default"
        }
    ]
}

items = [_test1, _test2]
