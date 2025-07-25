import models.io.upbound.platform.azure.v1 as platformazurev1
import models.io.upbound.azure.v1beta1 as azurev1beta1
import models.io.upbound.azure.storage.v1beta1 as storagev1beta1
import models.io.upbound.azure.storage.v1beta2 as storagev1beta2
import regex

#import models.k8s.apimachinery.pkg.apis.meta.v1 as metav1
# observed composite resource
# oxr = option("params").oxr
oxr = platformazurev1.XStorageContainer {**option("params").oxr}
params = oxr.spec.parameters
# observed composed resources
_ocds = option("params").ocds
# desired composite resource
_dxr = option("params").dxr
# desired composed resources
dcds = option("params").dcds

_metadata = lambda name: str -> any {
    {
        annotations = {
            "krm.kcl.dev/composition-resource-name" = name
        }
    }
}
# Helper function to add common spec fields
_add_common_spec_fields = lambda spec: any -> any {
    spec | {
        deletionPolicy = params.deletionPolicy
        providerConfigRef.name = params.providerConfigName
    }
}
# An Azure Storage account can only be lowercase alphanumeric, max 24 chars
_account = regex.replace("${oxr.metadata.name}-account".lower(), "[^\w]", "")[0:23:]

_items = [
    if not params.resourceGroup:
        azurev1beta1.ResourceGroup {
            metadata = _metadata("${oxr.metadata.name}-rg")
            spec = _add_common_spec_fields(azurev1beta1.AzureUpboundIoV1beta1ResourceGroupSpec {
                forProvider = {
                    location = params.region
                }
            })
        }
    storagev1beta2.Account {
        metadata = _metadata(_account)
        spec = _add_common_spec_fields({
            forProvider = {
                accountKind = "BlobStorage"
                accountReplicationType = "LRS"
                accountTier = "Standard"
                location = params.region
                resourceGroupName = params.resourceGroup if params.resourceGroup else "${oxr.metadata.name}-rg"
            }
        })
    }
    storagev1beta1.Container {
        metadata = _metadata("${oxr.metadata.name}-container")
        spec = _add_common_spec_fields({
            forProvider = {
                containerAccessType = "private"
                storageAccountNameSelector = {
                    matchControllerRef = True
                }
            }
        })
    }
]

items = _items
